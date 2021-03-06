use xmltest
go

-- update when changed
update statistics xmlinvoice
dbcc freeproccache

-- PK - clustered index
-- TVF /Invoice
-- TVF /Invoice/InvoiceID
select * from xmlinvoice 
where invoice.exist('/Invoice[@InvoiceID = "1003"]') = 1

-- query plan change? yes 
-- PK - clustered index
-- TVF /Invoice/@InvoiceID
select * from xmlinvoice 
where invoice.exist('/Invoice/@InvoiceID[. = "1003"]') = 1

-- xml primary
create primary xml index invoiceidx ON xmlinvoice(invoice)

-- see columns in the node table
SELECT c.object_id, substring(c.name,1,10), c.column_id, c.system_type_id, c.user_type_id, max_length, precision FROM sys.columns c
 JOIN sys.indexes i ON i.object_id = c.object_id
 WHERE i.name = 'invoiceidx'
 AND i.type = 1

-- to decode the types in node table
select * from sys.types

dbcc freeproccache

-- top down execution
-- execution starts with primary xml index

-- first scan on node table (clustered index scan)
-- then seek on base table (clustered index seek by primary key of node table)
select *
from xmlinvoice
where invoice.exist('/Invoice/@InvoiceID[. = "1003"]') = 1


create xml index invpathidx on xmlinvoice(invoice)
 using xml index invoiceidx for path
dbcc freeproccache

-- top down execution
-- first scan on table for xml not null
-- now uses index seek on path index
select *
from xmlinvoice
where invoice.exist('/Invoice/@InvoiceID[. = "1003"]') = 1


create xml index invvalidx on xmlinvoice(invoice)
 using xml index invoiceidx for value

create xml index invpropidx on xmlinvoice(invoice)
 using xml index invoiceidx for property

dbcc freeproccache

-- with all indexes defined
-- first scan on table for xml not null
-- uses index seek on value index
select *
from xmlinvoice
where invoice.exist('/Invoice/@InvoiceID[. = "1003"]') = 1

drop index invvalidx on xmlinvoice
dbcc freeproccache

-- with only path and property
-- first scan on table for xml not null
-- still uses index seek on path 
select *
from xmlinvoice
where invoice.exist('/Invoice/@InvoiceID[. = "1003"]') = 1

-- make sure we have all three indexes
create xml index invvalidx on xmlinvoice(invoice)
 using xml index invoiceidx for value
dbcc freeproccache


-- uses value index
-- then primary key
select *
from xmlinvoice
where invoice.exist('/Invoice/CustomerName/text()[. = "Mary Weaver"]') = 1

-- uses value index and primary index
-- then primary key
-- this is 50-50 with previous one
select *
from xmlinvoice
where invoice.exist('/Invoice/CustomerName[text() = "Mary Weaver"]') = 1

-- data(.) and string(.)
-- clustered index scan
-- then prop index
-- then primary key
select *
from xmlinvoice
where invoice.exist('/Invoice/CustomerName[data(.) = "Mary Weaver"]') = 1

-- index seek on property CustomerName
-- index seek on primary key
-- this is 50-50 with the next one
select *
from xmlinvoice
where invoice.exist('/Invoice//CustomerName[text() = "Mary Weaver"]') = 1

-- index seek on property CustomerName
-- clustered index seek on desc
-- then invoke data function, filter result
select *
from xmlinvoice
where invoice.exist('/Invoice//CustomerName[. = "Mary Weaver"]') = 1
dbcc freeproccache
-- uses value index 
-- path is not selective
-- search value is selective
-- this wins over next query 40%-60%
select *
from xmlinvoice
where invoice.exist('//Invoice/@InvoiceID[. = "1003"]') = 1

-- uses primary for //Invoice
-- uses property for //Invoice/@InvoiceID
select *
from xmlinvoice
where invoice.exist('//Invoice[@InvoiceID = "1003"]') = 1


-- uses primary for /Invoice
-- uses value for /Invoice/@InvoiceID
select *
from xmlinvoice
where invoice.exist('/Invoice[@InvoiceID = "1003"]') = 1

-- property for invoiceID
select *
from xmlinvoice
where invoice.exist('/Invoice/@InvoiceID') = 1

-- primary
select *
from xmlinvoice
where invoice.value('/Invoice[1]/@InvoiceID', 'int') = 1003

-- clustered index seek /Invoice
-- index seek path
-- clustered index seek /Invoice/desc
-- UDX XML SERIALIZER
select invoice.query('/Invoice[@InvoiceID = "1003"]')
from xmlinvoice

-- clustered index /LineItem
-- clustered index /desc
-- index seek property /Invoice
-- index seek path @InvoiceID
select invoice.query('/Invoice[@InvoiceID = "1003"]//LineItem')
from xmlinvoice

-- clustered index LineItem
-- property index Invoice
-- index value @InvoiceID
select invoice.query('//Invoice[@InvoiceID = "1003"]//LineItem')
from xmlinvoice

-- uses node table
-- with recursive navigation
select invoice.value('/Invoice[1]/LineItems[1]/LineItem[1]/Sku[1]', 'int'),
 invoice.value('/Invoice[1]/LineItems[1]/LineItem[1]/Description[1]', 'nvarchar(40)')
from xmlinvoice


-- uses node table with top query
-- uses UDX with XML DATA function
-- with first one, this one wins 69% - 31%
select invoice.value('(//Sku)[1]', 'int'),
 invoice.value('(//Description)[1]', 'nvarchar(40)')
from xmlinvoice

-- uses primary index
-- uses Desc row
-- uses UDX with serializer
select invoice.query('/Invoice/CustomerName')
from xmlinvoice


-- index scan on table
-- index seek on property index (for LineItems)
-- clustered index seek - primary index (top, first name)
-- clustered index seek - primary index (top, last name)
select ref.value('Sku[1]', 'int'),
       ref.value('Description[1]', 'nvarchar(40)')
from xmlinvoice
cross apply invoice.nodes('/Invoice/LineItems/LineItem') R(ref)


select * from xmlinvoice
where invoice.exist('/Invoice/CustomerName[text() = "Mary Weaver"]') = 1

select * from xmlinvoice
where invoice.exist('/Invoice/CustomerName') = 1

select * from xmlinvoice
where invoice.exist('//Invoice/@InvoiceID[. = "1003"]') = 1

select * from xmlinvoice 
where invoice.exist('/Invoice/@InvoiceID[. = "1003"]') = 1

select * from xmlinvoice
where invoice.exist('//Invoice/@InvoiceID[. > "1003"]') = 1

select * from xmlinvoice
where invoice.exist('/Invoice/LineItems/LineItem/Sku') = 1





