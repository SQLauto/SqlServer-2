drop database test
go

create database test
go

use test
go

create table T (pk INT PRIMARY KEY, xCol XML) 
go

insert T values(1,
'<book genre="security" publicationdate="2002" ISBN="0-7356-1588-2">
   <title>Writing Secure Code</title>
   <author>
      <first-name>Michael</first-name>
      <last-name>Howard</last-name>
   </author>
   <author>
      <first-name>David</first-name>
      <last-name>LeBlanc</last-name>
   </author>
   <price>39.99</price>
</book>')
go

CREATE PRIMARY XML INDEX idx_xCol on T (xCol)
go

-- this could use a PATH index
SELECT pk, xCol
FROM   T
WHERE  xCol.exist ('/book[@genre = "novel"]') = 1
go

-- here is how to create PATH index
CREATE XML INDEX idx_xCol_Path on T (xCol)
   USING XML INDEX idx_xCol FOR PATH
go

-- this could use a PROPERTY index
SELECT xCol.value ('(/book/@genre)[1]', 'varchar(50)'),
    xCol.value ('(/book/title)[1]', 'varchar(50)'),
    xCol.value ('(/book/@ISBN)[1]', 'varchar(50)')
FROM    T
go

-- here is how to create PROPERTY index
CREATE XML INDEX idx_xCol_Path on T (xCol)
   USING XML INDEX idx_xCol FOR PATH
go

-- this could use a VALUE index
SELECT xCol
FROM     T
WHERE    xCol.exist ('//book[@ISBN = "1-8610-0157-6"]') = 1
go

-- here is how to create VALUE index
CREATE XML INDEX idx_xCol_Path on T (xCol)
   USING XML INDEX idx_xCol FOR VALUE
go

-- this could use the full-text index
-- full-text CONTAINS is not same as XQuery contains
SELECT * 
FROM   T 
WHERE  CONTAINS(xCol,'custom') 
AND    xCol.exist('/book/title/text()[contains(.,"custom")]') =1
go

-- this is property promotion
-- uses a computed column based on XML data type methods
-- this only works if the property you are promting is a singleton

-- Create the user-defined function for ISBN of books:
CREATE FUNCTION udf_get_book_ISBN (@xData xml)
RETURNS varchar(20)
BEGIN
   DECLARE @ISBN   varchar(20)
   SELECT @ISBN = @xData.value('/book[1]/@ISBN', 'varchar(20)')
   RETURN @ISBN 
END
go

-- Add a computed column to the table for ISBN:
ALTER TABLE      T
ADD   ISBN AS dbo.udf_get_book_ISBN(xCol)
go

-- not using the computed column
SELECT xCol
FROM   T
WHERE  xCol.exist ('/book[@ISBN = "0-7356-1588-2"]') = 1

-- on the XML column can be rewritten to use the computed column as follows:
SELECT xCol
FROM   T
WHERE  ISBN = '0-7356-1588-2'

-- if you want to promote a proprty that is not a singleton
-- you have to create a property table

create table tblPropAuthor (propPK int, propAuthor varchar(max))
go

-- populate the table with a UDF and triggers
-- note: this could also be a CLR trigger that uses client SqlXml
create function udf_XML2Table (@pk int, @xCol xml)
returns @ret_Table table (propPK int, propAuthor varchar(max))
with schemabinding
as
begin
      insert into @ret_Table 
      select @pk, nref.value('.', 'varchar(max)')
      from   @xCol.nodes('/book/author/first-name') R(nref)
      return
end
go

-- maintain the properties table with triggers
-- insert trigger:
create trigger trg_docs_INS on T for insert
as
      declare @wantedXML xml
      declare @FK int
select @wantedXML = xCol from inserted
      select @FK = PK from inserted

   insert into tblPropAuthor
   select * from dbo.udf_XML2Table(@FK, @wantedXML)
go

--Delete trigger: deletes rows from the property table based on the primary key value of deleted rows
create trigger trg_docs_DEL on T for delete
as
   declare @FK int
   select @FK = PK from deleted
   delete tblPropAuthor where propPK = @FK

-- Update trigger: deletes existing rows in the property table corresponding to the updated XML instance, and inserts new rows into the property table
create trigger trg_docs_UPD
on T
for update
as
if update(xCol) or update(pk)
begin
      declare @FK int
      declare @wantedXML xml
      select @FK = PK from deleted
      delete tblPropAuthor where propPK = @FK

   select @wantedXML = xCol from inserted
select @FK = pk from inserted

insert into tblPropAuthor 
      select * from dbo.udf_XML2Table(@FK, @wantedXML)

-- use the properties table; this requires a join
-- Example: find XML instances whose authors have the first name "David"
SELECT xCol 
FROM     T JOIN tblPropAuthor ON T.pk = tblPropAuthor.propPK
WHERE    tblPropAuthor.propAuthor = 'David'
go

---
--- XQUERY
---

-- nodes can make a singleton
SELECT nref.value('@genre', 'varchar(max)') LastName
FROM   T CROSS APPLY xCol.nodes('//book') AS R(nref)
go

-- error - not a singleton
SELECT xCol.value('//author/last-name', 'nvarchar(50)') LastName
FROM   T
go

-- still not a singleton
SELECT xCol.value('//author/last-name[1]', 'nvarchar(50)') LastName
FROM   T
go

-- this is a singleton
SELECT xCol.value('(//author/last-name)[1]', 'nvarchar(50)') LastName
FROM   T
go

-- this is anyType even if there is a schema. because of parent axis
-- xCol.query('/book/@genre/../price')); 

-- example of nodes
SELECT nref.value('first-name[1]', 'nvarchar(50)') FirstName,
       nref.value('last-name[1]', 'nvarchar(50)') LastName
FROM   T CROSS APPLY xCol.nodes('//author') AS R(nref)
WHERE  nref.exist('.[first-name != "David"]') = 1

drop table testtab
drop xml schema collection sc1

-- no namespace schema
CREATE XML SCHEMA COLLECTION sc1
AS
'<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="age" type="xs:int"/>
<xs:element name="r">
<xs:simpleType>
   <xs:union memberTypes="xs:int xs:float xs:double"/>
</xs:simpleType>
</xs:element>
</xs:schema>'
go

create table testtab (xmlcol xml(sc1))
go

insert testtab values('<age>12</age><r>4</r>')
insert testtab values('<age>12</age><r>5</r>')
insert testtab values('<age>12</age><r>6.78</r>')

-- XQuery [testtab.xmlcol.query()]: 'text()' is not supported on simple typed 
-- or 'http://www.w3.org/2001/XMLSchema#anyType' elements, found 'element(age) *'.
select xmlcol.query('/age/text()') from testtab

select xmlcol.query('data(/age)') from testtab

-- string(/age) doesn't work
select xmlcol.query('string(/age[1])') from testtab

-- XQuery [testtab.xmlcol.query()]: The input to 'avg' must be of a single numeric type. 
-- Single, because this version of the server does not support dynamic numeric promotion.
select xmlcol.query('avg(//r)') from testtab

select xmlcol.query('avg(for $r in //r return $r cast as xs:double ?)') from testtab

-- fails
select xmlcol.query('(//r)[1] + 1') from testtab

-- works
select xmlcol.query('((//r)[1] cast as xs:int?) + 1') from testtab