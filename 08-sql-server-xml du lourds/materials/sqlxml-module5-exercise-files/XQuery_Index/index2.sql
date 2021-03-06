use xmltest
go

-- update when changed
update statistics xmlinvoice2
dbcc freeproccache

-- PK - clustered index
-- TVF /Invoice
-- TVF /Invoice/InvoiceID
select * from xmlinvoice2 
where invoice.exist('/Invoice[@InvoiceID = 1003]') = 1

-- query plan change? yes 
-- PK - clustered index
-- TVF /Invoice/@ISDN
select * from xmlinvoice2 
where invoice.exist('(/Invoice/@InvoiceID)[1][. = 1003]') = 1

-- vs without schema
select * from xmlinvoice 
where invoice.exist('(/Invoice/@InvoiceID)[1][. = "1003"]') = 1

-- xml primary
create primary xml index invoiceidx2 ON xmlinvoice2(invoice)

dbcc freeproccache

-- bottom up execution
-- execution starts with primary xml index
-- first scan on node table
-- then seek on base table
select *
from xmlinvoice2
where invoice.exist('/Invoice/@InvoiceID[. = 1003]') = 1

-- compare to no schema collection
select *
from xmlinvoice
where invoice.exist('/Invoice/@InvoiceID[. = 1003]') = 1


create xml index invpathidx2 on xmlinvoice2(invoice)
 using xml index invoiceidx2 for path
dbcc freeproccache

-- top down execution
-- first scan on table for xml not null
-- now uses index seek on path
-- **with schema this plan changes, bottom up
select *
from xmlinvoice2
where invoice.exist('/Invoice/@InvoiceID[. = 1003]') = 1

create xml index invvalidx2 on xmlinvoice2(invoice)
 using xml index invoiceidx2 for value

create xml index invpropidx2 on xmlinvoice2(invoice)
 using xml index invoiceidx2 for property

dbcc freeproccache

-- with all indexes defined
-- first scan on table for xml not null
-- still uses index seek on value
select *
from xmlinvoice2
where invoice.exist('/Invoice/@InvoiceID[. = 1003]') = 1

drop index invvalidx2 on xmlinvoice2
dbcc freeproccache

-- with only path and property
-- first scan on table for xml not null
-- still uses index seek on path 
select *
from xmlinvoice2
where invoice.exist('/Invoice/@InvoiceID[. = 1003]') = 1

-- make sure we have all three indexes
create xml index invvalidx2 on xmlinvoice2(invoice)
 using xml index invoiceidx2 for value
dbcc freeproccache


-- uses property index CustomerName
-- uses clustered index seek Desc
select *
from xmlinvoice2
where invoice.exist('/Invoice/CustomerName[. = "Mary Weaver"]') = 1

-- uses property index - CustomerName
-- uses path index - text()
-- this is 50-50 with previous one
select *
from xmlinvoice2
where invoice.exist('/Invoice/CustomerName[text() = "Mary Weaver"]') = 1

-- data(.) and string(.)
-- same plan as .
select *
from xmlinvoice2
where invoice.exist('/Invoice/CustomerName[data(.) = "Mary Weaver"]') = 1

select *
from xmlinvoice2
where invoice.exist('/Invoice/CustomerName[string(.) = "Mary Weaver"]') = 1

-- index seek on property CustomerName
-- index seek on value text()
-- this is 50-50 with the next one
select *
from xmlinvoice2
where invoice.exist('/Invoice//CustomerName[text() = "Mary Weaver"]') = 1

-- index seek on property CustomerName
-- clustered index seek on desc
-- then invoke data function, filter result
select *
from xmlinvoice2
where invoice.exist('/Invoice//CustomerName[. = "Mary Weaver"]') = 1
dbcc freeproccache
-- uses value index 
-- path is not selective
-- search value is selective
-- this wins over next query 40%-60%
select *
from xmlinvoice2
where invoice.exist('//Invoice/@InvoiceID[. = 1003]') = 1

-- uses property for //Invoice
-- uses value for //Invoice/@InvoiceID
select *
from xmlinvoice2
where invoice.exist('//Invoice[@InvoiceID = 1003]') = 1


-- uses property for /Invoice
-- uses path for /Invoice/@InvoiceID
select *
from xmlinvoice2
where invoice.exist('/Invoice[@InvoiceID = 1003]') = 1

-- clustered index seek /Invoice
-- index seek path
-- clustered index seek /Invoice/desc
-- UDX XML SERIALIZER
select invoice.query('/Invoice[@InvoiceID = 1003]')
from xmlinvoice2

-- clustered index /LineItem
-- clustered index /desc
-- index seek property /Invoice
-- index seek path @InvoiceID
select invoice.query('/Invoice[@InvoiceID = 1003]//LineItem')
from xmlinvoice2

-- clustered index LineItem
-- property index Invoice
-- index value @InvoiceID
select invoice.query('//Invoice[@InvoiceID = 1003]//LineItem')
from xmlinvoice2

-- uses node table
-- with recursive navigation
select invoice.value('/Invoice[1]/LineItems[1]/LineItem[1]/Sku[1]', 'int'),
 invoice.value('/Invoice[1]/LineItems[1]/LineItem[1]/Description[1]', 'nvarchar(40)')
from xmlinvoice2


-- uses node table with top query
-- uses UDX with XML DATA function
-- with first one, this one wins 69% - 31%
select invoice.value('(//Sku)[1]', 'int'),
 invoice.value('(//Description)[1]', 'nvarchar(40)')
from xmlinvoice2

-- uses primary index
-- uses Desc row
-- uses UDX with serializer
select invoice.query('/Invoice/CustomerName')
from xmlinvoice2


-- index scan on table
-- index seek on property index (for LineItems)
-- clustered index seek - primary index (top, first name)
-- clustered index seek - primary index (top, last name)
select ref.value('Sku[1]', 'int'),
       ref.value('Description[1]', 'nvarchar(40)')
from xmlinvoice2
cross apply invoice.nodes('/Invoice/LineItems/LineItem') R(ref)
