-- !!!!!!lookup SQL server port Number
-- 	//Run the following code block as one command:
	
DECLARE      @portNumber  NVARCHAR(10)
EXEC  xp_instance_regread
@rootkey    = 'HKEY_LOCAL_MACHINE',
@key        =
'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
@value_name = 'TcpDynamicPorts',
@value      = @portNumber OUTPUT
SELECT [Port Number] = @portNumber

-- !!!!!Connection string is then formatted as such: 
	192.168.0.127\shipworks,49270
  
-------------------------------------------------------------------------------------------------------------

-- !!!!!not sql
-- Use this to truncate ref fields on labels:
-- 	{substring(//Order/Item/Name,1,30)}
 
-- Working popup:
	mshta "javascript:var sh=new ActiveXObject( 'WScript.Shell' ); sh.Popup( 'ALERT! Package weight is over 5 pounds!',0, 'ShipWorks Notification', 64 );close()"

-- End SW from CMD
taskkill /F /IM shipworks.exe

-------------------------------------------------------------------------------------------------------------

-- !!!!!UPS OB error - get key:
select shipengineapikey from shippingsettings


-------------------------------------------------------------------------------------------------------------

-- !!!!!Shipping settings crashing SW
select * from shippingdefaultsrule
select * from shippingproviderrule
delete from shippingproviderrule WHERE
.....
....
...

-------------------------------------------------------------------------------------------------------------

-- !!!!!Unlink store from hub
-- !!!!!DONT DO THIS ANYMORE
Take backup
select storeid, storename, warehousestoreID from store 
--  - Notate the StoreID for each store to be disconnected
--  - Notate the WarehouseStoreID for each store to be disconnected

Update store Set WarehouseStoreID= NULL Where StoreID=xxxx
--  - Run query for each StoreID previously notated.

-- !!!!To completely detatch a DB from the hub. Only do if NO stores need to be rub connected
Select * from Configuration
--  - Notate WarehouseID in case we need to reconnect at a later point.
--  - Notate Warehouse Name in case we need to reconnect at a later point.
update Configuration set WarehouseID=''
update Configuration set WarehouseName=''

----------------------------------------------------------------------------------------------------------------------------------

-- !!!!!CLR STRICT
ALTER DATABASE ShipWorks set trustworthy on
EXEC sp_changedbowner 'sa'
sp_configure 'show advanced options', 1; 
GO 
RECONFIGURE; 
GO 
sp_configure 'clr enabled', 1; 
GO 
RECONFIGURE; 
GO

or...

EXEC sp_configure 'show advanced options', 1
RECONFIGURE;
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;

----------------------------------------------------------------------------------------------------------------------------------

-- !!!!!Manually reset Az auth token
Declare @AuthToken nvarchar(100)
SET @AuthToken = 'amzn.mws.16ada015-08fb-edda-4334-b4561b4456a9';
update AmazonStore set AuthToken= @AuthToken
where storeid='2005'

----------------------------------------------------------------------------------------------------------------------------------

-- !!!!!remove stuuck downloads from download queue:
-- Close SW on the PC trying to download

delete from download where Ended IS NULL

-- !!!!!remove records older than a certain date:
delete from download where Ended > '2021-1-01 19:02:11.047'

-- !!!!!See just open downloads 
Select * from [download] where Ended IS NULL
----------------------------------------------------------------------------------------------------------------------------------

-- !!!!!SQL logs
-- They can be found for a local database in %appdata% in the local folder
-- AppData - > Local -> Microsoft -> Microsoft SQL Server Local DB -> Instances

-- For a non-local database %programfiles%
-- Program Files -> Microsoft SQL Server -> MSSQL14.SHIPWORKS (can be different) -> MSSQL -> DATA

----------------------------------------------------------------------------------------------------------------------------------

-- !!!!!Check for custom triggers
SELECT * FROM Action WHERE cast (TriggerSettings as nvarchar(max)) LIKE '%Restriction value="1"%' 
----------------------------------------------------------------------------------------------------------------------------------


-- !!!!!Deleting shipments from db example:
SELECT * FROM Action WHERE cast (TriggerSettings as nvarchar(max)) LIKE '%Restriction value="1"%'

Select * from [order] WHERE orderNumber=25557
Select * from shipment WHERE OrderID=80616006
Delete from shipment WHERE OrderID=80616006


Delete from shipment WHERE ShipmentID=316240031
select * from UPSShipment where ShipmentID=316240031
select * from ShipmentReturnItem where ShipmentID=316240031

select top(50) * from Shipment where orderID=80616006 order by processedDate desc
Delete TOP(100) from Shipment where OrderID=80616006
Delete TOP(1900) from Shipment where OrderID=80616006
Delete TOP(98) from Shipment where OrderID=80616006
----------------------------------------------------------------------------------------------------------------------------------

-- !!!!!Reset template preview
update templateusersettings set previewcount = 1 where previewcount = -1

Select * from Template Where Name='Shopify Recon' 
Select TemplateID from Template Where Name='Shopify Recon' 
198025 
Select * from TemplateUserSettings Where TemplateID=198025 
update templateusersettings set previewcount = 1 where TemplateID=198025
---reload SW
----------------------------------------------------------------------------------------------------------------------------------



ALTER DATABASE ShipWorks SET MULTI_USER
DBCC checkdb([ShipWorks])


-- obdcad32.exe
-- SQLServerManager14.msc

-- tags:shipworks
----------------------------------------------------------------------------------------------------------------------------------

-- To change an order status on DataBase.

Select * from [order] where ordernumbercomplete='xxxxx'
Then
Select * from shipment where orderid=xxxxxx
Then
update Shipment set processed = 0 where orderid=xxxx
Then
Update Shipment set processed=1 where orderid=xxxx