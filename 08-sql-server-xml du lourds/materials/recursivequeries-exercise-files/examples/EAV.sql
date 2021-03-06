
use [TSQL]

--drop database [TSQL]
go


-- make sure to run PivotBldSql to fill tables
print 'make sure to run PivotBldSql to fill tables'
go
truncate table properties
delete products

drop table products
go

-- table to hold product data
create table products
(
id int primary key,
name varchar(max)
)

go
--drop table properties
go

-- table to hold properties
create table properties
(
	id int,
	name varchar(50),
	value varchar(max),
-- restrict as one to many relationship
	CONSTRAINT PK_properties PRIMARY KEY (id, name),
-- one table is products
	FOREIGN KEY (id) REFERENCES	products (id)
)
go

---delete properties
--delete products
go
select top(10) * from products

select top(10) * from properties


-- >>>>>>>>>>>>>>>>>>>>>>>>> example 1 Basic Pivot <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-- virtual table has all of the columns of properties table
select * from properties
PIVOT (
-- each value will come from the corresponding "value"
-- column of the properties table
MAX(value)
-- rows that have a name equal to
-- "color", "type" or "amount" will
-- be added to the columns of the output table
for name in ([color], [type], [amount])
)
AS P
-- this limits the virtual table to Swish rows
where id in (select id from products where name='Swish')
go


select * from properties
PIVOT (
-- each value will come from the corresponding "value"
-- column of the properties table
MAX(value)
-- rows that have a name equal to
-- "color", "type" or "amount" will
-- be added to the columns of the output table
for name in ([color], [len], [width], [fiber])
)
AS P
-- this limits the virtual table to Swish rows
where id in (select id from products where name='rug')
go


with swish
as
(
select * from properties
PIVOT (
-- each value will come from the corresponding "value"
-- column of the properties table
MAX(value)
-- rows that have a name equal to
-- "color", "type" or "amount" will
-- be added to the columns of the output table
for name in ([color], [type], [amount])
)
AS P
-- this limits the virtual table to Swish rows
--where id in (select id from products where name='Swish')
)
 select distinct name from swish
 join products on 
 swish.id = products.id
where color is not null 




-- >>>>>>>>>>>>>>>>>>>>>>>>> example 2 Basic Pivot of entire input table <<<<<<<<<<<


-- virtual table has all of the columns of properties table
select * from properties
PIVOT (
-- each value will come from the corresponding "value"
-- column of the properties table
MAX(value)
-- rows that have a name equal to
-- "color", "type" or "amount" will
-- be added to the columns of the output table
for name in ([color], [type], [amount])
)
AS P
-- note that there is no WHERE clause here
-- so all rows in the input table will
-- be included in the virtual table
go

-- check the results produced. Some rows
-- will have NULL's in them. The nulls correspond
-- to products that were missing some of the color,
-- type or amount properties




-- >>>>>>>>>>>>>>>>>>>>>>>>> example 3 Basic Pivot example 1 done using a CTE <<<<<<<<<<<

-- CTE defines virtual table
with VTable as
(
select * from properties
-- note that where clause in example 1
-- moved into CTE 
where id in (select id from products where name = 'Swish')
)
select * from VTable
PIVOT (
-- each value will come from the corresponding "value"
-- column of the properties table
MAX(value)
-- rows that have a name equal to
-- "color", "type" or "amount" will
-- be added to the columns of the output table
for name in ([color], [type], [amount])
)
AS P


-- >>>>>>>>>>>>>>>>>>>>>>>>> example 4 Pivot from join of two table <<<<<<<<<<<

-- this example joins propertes and products
-- and added the product name to the output


-- CTE defines virtual table
with VTable as
(
select prod.name as Product, prop.* from properties as prop,
	products as prod
where prop.id = prod.id
-- note that where clause in example 1
-- moved into CTE 
)
-- don't include in the output
select Product, color, type, amount from VTable
PIVOT (
-- each value will come from the corresponding "value"
-- column of the properties table
MAX(value)
-- rows that have a name equal to
-- "color", "type" or "amount" will
-- be added to the columns of the output table
for name in ([color], [type], [amount])
)
AS P

-- check the output, note that product name
-- is in Product column

