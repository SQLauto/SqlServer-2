use xmltest
go

create xml schema collection invoice_xsd
as
'<?xml version="1.0" encoding="utf-8"?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="Invoice">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="CustomerName" type="xs:string" />
				<xs:element name="LineItems">
					<xs:complexType>
						<xs:sequence>
							<xs:element maxOccurs="unbounded" name="LineItem">
								<xs:complexType>
									<xs:sequence>
										<xs:element name="Sku" type="xs:unsignedShort" />
										<xs:element name="Description" type="xs:string" />
										<xs:element name="Price" type="xs:decimal" />
									</xs:sequence>
								</xs:complexType>
							</xs:element>
						</xs:sequence>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
			<xs:attribute name="InvoiceID" type="xs:unsignedShort" use="required" />
			<xs:attribute name="dept" type="xs:string" use="required" />
			<xs:attribute name="backorder" type="xs:boolean" use="optional" />
		</xs:complexType>
	</xs:element>
</xs:schema>'
GO

create table xmlinvoice2(
 invoiceid integer identity primary key,
 invoice xml(DOCUMENT invoice_xsd)
)
GO

insert into xmlinvoice2 values('
<Invoice InvoiceID="1000" dept="hardware">
   <CustomerName>Jane Smith</CustomerName>
   <LineItems>
      <LineItem>
         <Sku>134</Sku>
         <Description>Gear</Description>
         <Price>9.95</Price>
      </LineItem>
   </LineItems>
</Invoice>')

insert into xmlinvoice2 values('
<Invoice InvoiceID="1001" dept="hardware">
   <CustomerName>Fred Jones</CustomerName>
   <LineItems>
      <LineItem>
         <Sku>118</Sku>
         <Description>Widget</Description>
         <Price>2.95</Price>
      </LineItem>
   </LineItems>
</Invoice>')

insert into xmlinvoice2 values('
<Invoice InvoiceID="1002" dept="garden" backorder="true">
   <CustomerName>Joe Johnson</CustomerName>
   <LineItems>
      <LineItem>
         <Sku>534</Sku>
         <Description>Shovel</Description>
         <Price>19.95</Price>
      </LineItem>
      <LineItem>
         <Sku>537</Sku>
         <Description>Fork</Description>
         <Price>39.95</Price>
      </LineItem>
   </LineItems>
</Invoice>')

insert into xmlinvoice2 values('
<Invoice InvoiceID="1003" dept="garden">
   <CustomerName>Abe Wells</CustomerName>
   <LineItems>
      <LineItem>
         <Sku>331</Sku>
         <Description>Trellis</Description>
         <Price>9.95</Price>
      </LineItem>
   </LineItems>
</Invoice>')

insert into xmlinvoice2 values('
<Invoice InvoiceID="1004" dept="sundries">
   <CustomerName>Mary Weaver</CustomerName>
   <LineItems>
      <LineItem>
         <Sku>795</Sku>
         <Description>Umbrella</Description>
         <Price>4.95</Price>
      </LineItem>
   </LineItems>
</Invoice>')

insert into xmlinvoice2 values('
<Invoice InvoiceID="1005" dept="hardware">
   <CustomerName>Patricia Walker</CustomerName>
   <LineItems>
      <LineItem>
         <Sku>134</Sku>
         <Description>Gear</Description>
         <Price>9.95</Price>
      </LineItem>
      <LineItem>
         <Sku>118</Sku>
         <Description>Widget</Description>
         <Price>2.95</Price>
      </LineItem>
   </LineItems>
</Invoice>')
GO

select * from xmlinvoice2
GO