-----------------------------------------------------
-- © Copyright 2001-2005 Microsoft Corporation. 
-- All rights reserved.
-- This document is for informational purposes only. 
-- MICROSOFT MAKES NO WARRANTIES, EXPRESS OR IMPLIED,
-- IN THIS SUMMARY.
-----------------------------------------------------

--- This T-SQL script illustrates the use of XML 
--- indexes on untyped XML data type column

--- To get started, create a new database called
--- XMLTestDB. We'll create a table in it and 
--- populate the table.

----------------------------------------------------
--- Cleanup
----------------------------------------------------
USE		master
GO

if	EXISTS (SELECT * FROM sys.databases
			WHERE name = 'XMLTestDB')
	DROP	DATABASE XMLTestDB
GO

---------------------------
--- Initialization
---------------------------
CREATE	DATABASE XMLTestDB
GO

USE XMLTestDB
GO

SET STATISTICS TIME ON
GO

---------------------------------------------------
------ Create a table with an untyped XML column
---------------------------------------------------
CREATE TABLE docs ( 
	pk		INT PRIMARY KEY, 
	xCol	XML)
GO

---------------------------------------------------
----- Add several rows to the table
---------------------------------------------------
INSERT docs VALUES(1, '<?xml version="1.0"?>
  <book subject="autobiography" publicationdate="1981" 
		ISBN="1-861003-11-0">
    <title>The Autobiography of Benjamin Franklin</title>
    <author>
      <first-name>Benjamin</first-name>
      <last-name>Franklin</last-name>
    </author>
    <price>8.99</price>
  </book>')

INSERT docs VALUES(2, '<?xml version="1.0"?>
  <book subject="novel" publicationdate="1967" 
		ISBN="0-201-63361-2">
    <title>The Confidence Man</title>
    <author>
      <first-name>Herman</first-name>
      <last-name>Melville</last-name>
    </author>
    <price>11.99</price>
  </book>')

INSERT docs VALUES(3, '<?xml version="1.0"?>
  <book subject="philosophy" publicationdate="1991" 
		ISBN="1-861001-57-6">
    <title>The Gorgias</title>
    <author>
      <first-name>Sidas</first-name>
      <last-name>Plato</last-name>
    </author>
    <price>9.99</price>
  </book>')

INSERT INTO docs VALUES (4,
'<book subject="security" publicationdate="2002" ISBN="0-7356-1588-2">
	<title>Writing Secure Code</title>
	<author>
		<first-name>Michael</first-name>
		<last-name>Howard</last-name>
		<company>Microsoft</company>
	</author>
	<author>
		<first-name>David</first-name>
		<last-name>LeBlanc</last-name>
		<company>Microsoft</company>
	</author>
    <author>
      <first-name>Herman</first-name>
      <last-name>Melville</last-name>
	  <company>Unknown</company>
    </author>
    <author>
      <first-name>Benjamin</first-name>
      <last-name>Franklin</last-name>
	  <affiliation>Government</affiliation>
    </author>
    <author>
      <first-name>Anaken</first-name>
      <last-name>Skywalker</last-name>
	  <movie>Star Wars</movie>
    </author>
    <author>
      <first-name>Spider</first-name>
      <last-name>Man</last-name>
	  <purpose>Social welfare</purpose>
    </author>
    <author>
      <first-name>Super</first-name>
      <last-name>Man</last-name>
	  <purpose>Social welfare</purpose>
    </author>
    <author>
      <first-name>Cat</first-name>
      <last-name>Woman</last-name>
	  <purpose>Social welfare</purpose>
    </author>
    <author>
      <first-name>Bat</first-name>
      <last-name>Man</last-name>
	  <purpose>Social welfare</purpose>
    </author>
	<price>39.99</price>
</book>')
GO

--- Add 1010 more rows that differ only in the ISBN attribute
--- This illustrates how selectivity helps in the choice of
--- secondary XML indexes
DECLARE	@stmt nvarchar(1024)
DECLARE	@iCount int
SET	@iCount = 10
WHILE @iCount < 1020
BEGIN
	SET	@stmt = 
		N'INSERT docs VALUES(' 
		+ CAST (@iCount AS varchar (4)) + 
		N', ''<?xml version="1.0"?>
		<book subject="novel" 
				publicationdate="1967" 
				ISBN="' 
				+ CAST (@iCount AS varchar (4))+ N'">
			<title>The Confidence Man</title>
			<author>
				<first-name>Herman</first-name>
				<last-name>Melville</last-name>
			</author>
			<author>
				<first-name>David</first-name>
				<last-name>LeBlanc</last-name>
			</author>
			<price>11.99</price>
		</book>'')';
	EXEC sp_executeSql @stmt; 
	SET @iCount = @iCount+1
END
GO

--- Total number of rows in table "docs"
SELECT	count(pk) totalRows
FROM	docs
GO

-------------------------------------------------------
------ QUERY 1: 
------ TO SHOW EFFECTIVENESS OF PRIMARY XML INDEX AND
------ PATH SECONDARY XML INDEX
------ The query below finds the books matching the 
------ specified ISBN in the XML column
-------------------------------------------------------
SELECT pk
FROM   docs
WHERE  xCol.exist ('/book/@ISBN [. = "1-861003-11-0"]') = 1
GO

--------------------------------------------------
------ Primary XML index
--------------------------------------------------
--- The cost of runtime parsing of the XML data can be avoided by
--- creating the primary XML index on the XML column
---
--- Drop XML indexes on the XML column
if	EXISTS (SELECT * FROM sys.xml_indexes
			WHERE name = 'idx_xCol' AND using_xml_index_id IS NULL)
	DROP	INDEX idx_xCol ON docs
GO

--- Create the primary XML index on the XML column
CREATE PRIMARY XML INDEX idx_xCol on docs (xCol)
GO



------ RERUN QUERY 1 WITH PRIMARY XML INDEX:
SELECT pk
FROM   docs
WHERE  xCol.exist ('/book/@ISBN [. = "1-861003-11-0"]') = 1
GO




--------------------------------------------------
------ Secondary XML index of type PATH
--------------------------------------------------
--- Primary XML index is clustered on (pk of table docs,
--- internal identifier if each XML node). It is not
--- clustered on the path values. Query 1 will clearly benefit
--- from a index whose key fields are path (field name HID)
--- and VALUE, where HID and VALUE are columns in PXI. This is
--- the PATH secondary XML index

if	EXISTS (SELECT * FROM sys.xml_indexes
			WHERE name = 'idx_xCol_Path' AND secondary_type = 'P')
	DROP	INDEX idx_xCol_Path ON docs
GO

 
CREATE XML INDEX idx_xCol_Path on docs (xCol)
	USING XML INDEX idx_xCol FOR PATH
GO



------ RERUN QUERY 1 WITH PATH XML INDEX:
------   1. The Clustered Index Seek on PXI is replaced with an Index
------      Seek on the PATH secondard XML index idx_xCol_Path. 
------   2. In the Properties page, notice that the Seek Predicates
------      are the HID value and the search value "security"
------ Speedup relatively independent of path length

SELECT pk
FROM   docs
WHERE  xCol.exist ('/book/@ISBN [. = "1-861003-11-0"]') = 1
GO




-----------------------------------------------------------
------ QUERY 2: 
------ TO SHOW EFFECTIVENESS OF VALUE SECONDARY XML INDEX
------ The query below finds the books matching an
------ unspecified attribute
-----------------------------------------------------------
SELECT	pk
FROM	docs
WHERE	xCol.exist ('/book//@ISBN[. = "0-7356-1588-2"]') = 1
GO



--------------------------------------------------
------ Secondary XML index of type VALUE
--------------------------------------------------
if	EXISTS (SELECT * FROM sys.xml_indexes
			WHERE name = 'idx_xCol_Value' AND secondary_type = 'V')
	DROP	INDEX idx_xCol_Value ON docs
GO


CREATE XML INDEX idx_xCol_Value on docs (xCol)
	USING XML INDEX idx_xCol FOR VALUE
GO



------ RERUN QUERY 2 WITH VALUE XML INDEX:
SELECT	pk
FROM	docs
WHERE	xCol.exist ('/book/@*[. = "0-7356-1588-2"]') = 1
GO



-----------------------------------------------------------
------ QUERY 3: 
------ MORE SPECTACULAR DIFFERENCE BETWEEN PATH AND VALUE 
------ SECONDARY XML INDEXES
-----------------------------------------------------------
SELECT	pk
FROM	docs
WHERE	xCol.exist ('/book/@*[. = "0-7356-1588-2"]') = 1
GO


if	EXISTS (SELECT * FROM sys.xml_indexes
			WHERE name = 'idx_xCol_Value' AND secondary_type = 'V')
	DROP	INDEX idx_xCol_Value ON docs
GO


--- Query execution with PATH and no VALUE secondary XML index
SELECT	pk
FROM	docs
WHERE	xCol.exist ('/book/@*[. = "0-7356-1588-2"]') = 1
GO

------------------------------------------------------
--------------------------------------------------
------ Evaluating Predicates Using Context Node 
--------------------------------------------------
------ QUERY 4: 
------------------------------------------------------
SELECT pk
FROM   docs
WHERE  xCol.exist ('/book[author/first-name = "Spider"]') = 1
GO


--- Rewrite below evaluates check for first-name “Spider” 
--- more efficiently
SELECT pk
FROM   docs
WHERE  xCol.exist ('/book/author/first-name[. = "Spider"]') = 1
GO





-----------------------------------------------------------------
------ PERFORMANCE DIFFERENCE BETWEEN XQUERY AND XPATH
------ QUERY 5: Find first-name of authors
-----------------------------------------------------------------
SELECT count(pk)
FROM   docs
WHERE  xCol.exist ('/book/author//first-name') = 1
GO


--- The following XQuery is intuitive ...
SELECT count(pk)
FROM   docs
WHERE  xCol.exist ('
		for $s in /book/author
		return $s//first-name') = 1
GO

--- Use longer paths ... 
SELECT count(pk)
FROM   docs
WHERE  xCol.exist ('
		for $s in /book/author//first-name
		return $s') = 1
GO



---------------------------------------------------------------------
---------------------------------------------------------------------
------ Promoting properties using computed columns
------ Promote frequently-queried properties
------   Single valued --> computed columns
------   Multi-valued  --> property table
------
------ Steps for computed columns:
------   1. Define a user-defined function (UDF) to 
------      extract a scalar value using XML data type 
------      methods
------   2. Computed column defined by UDF is appended to table
------   3. Relational indexes created on those columns as needed
------   4. Index the XML column for querying other data
---------------------------------------------------------------------
------ User-defined function for price of <book>
CREATE FUNCTION udf_get_book_price (@xData xml)
RETURNS real
WITH SCHEMABINDING
BEGIN
   DECLARE @price real
   SELECT @price = @xData.value('(/book/price)[1]', 'real')
   RETURN @price
END
GO
   
------ Append a computed column to the table for price
ALTER TABLE docs
ADD	PRICE AS dbo.udf_get_book_price(xCol) PERSISTED
GO

------ Index the price column to speed up queries
CREATE INDEX idx_price ON docs (PRICE)
GO


------ The PRICE column is read-only - it is maintained by the engine
SELECT	*
FROM	docs
GO

---------------------------------------------------------------------
------ Using the promoted property
---------------------------------------------------------------------
------ QUERY 6:
SELECT count(pk)
FROM   docs
WHERE  PRICE = 8.99
GO


--- Anakogous query on the XML column
SELECT pk
FROM   docs
WHERE  xCol.exist ('/book/price [. = 8.99]') = 1
GO


------ User-defined function for ISBN of <book>
CREATE FUNCTION udf_get_book_isbn (@xData xml)
RETURNS nvarchar(32)
WITH SCHEMABINDING
BEGIN
   DECLARE @isbn nvarchar(32)
   SELECT @isbn = @xData.value('(/book/@ISBN)[1]', 'nvarchar(32)')
   RETURN @isbn
END
GO
   
------ Append a computed column to the table for price
ALTER TABLE docs
ADD	ISBN AS dbo.udf_get_book_isbn(xCol) 
GO

------ Index the price column to speed up queries
CREATE INDEX idx_isbn ON docs (ISBN)
GO


------ The ISBN column is read-only - it is maintained by the engine
SELECT	*
FROM	docs
GO

---------------------------------------------------------------------
------ Using the promoted property ISBN
---------------------------------------------------------------------
------ QUERY 7:
SELECT ISBN
FROM   docs
WHERE  pk = 1
GO

--- Using XML indexes ... index seek occurs
SELECT	xCol.value ('(/book/@ISBN)[1]', 'nvarchar(32)')
FROM	docs
WHERE   pk = 1
GO
