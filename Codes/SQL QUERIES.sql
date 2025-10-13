-------------------------------------------------------------------------------------------------------------------------
-- Select user

SELECT * FROM [user]

-- [Blank password:]
update [user] set password='1B2M2Y8AsgTpgAmY7PhCfg==' where UserID='***'

-------------------------------------------------------------------------------------------------------------------------
SELECT * FROM [store]

--[Migrate store prompt]
UPDATE [store] set ShouldMigrate=0 WHERE StoreID='****'
--[Disconnect from HUB:]
UPDATE [store] set WarehouseStoreID=NULL WHERE StoreID='****'

UPDATE [store] set WarehouseStoreID=NULL, ManagedInHub=0, ShouldMigrate=0 WHERE storeid=storeid;

-------------------------------------------------------------------------------------------------------------------------

--[Check for database corruption:]
Dbcc checkdb(Shipworks)

-------------------------------------------------------------------------------------------------------------------------

--[Check for fragmentation:]
SELECT
   t.NAME 'Table name',
   i.NAME 'Index name',
   ips.index_type_desc,
   ips.alloc_unit_type_desc,
   ips.index_depth,
   ips.index_level,
   ips.avg_fragmentation_in_percent,
   ips.fragment_count,
   ips.avg_fragment_size_in_pages,
   ips.page_count,
   ips.avg_page_space_used_in_percent,
   ips.record_count,
   ips.ghost_record_count,
   ips.Version_ghost_record_count,
   ips.min_record_size_in_bytes,
   ips.max_record_size_in_bytes,
   ips.avg_record_size_in_bytes,
   ips.forwarded_record_count
FROM
   sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ips
INNER JOIN
   sys.tables t ON ips.OBJECT_ID = t.Object_ID
INNER JOIN
   sys.indexes i ON ips.index_id = i.index_id AND ips.OBJECT_ID = i.object_id
WHERE
   AVG_FRAGMENTATION_IN_PERCENT > 0.0
ORDER BY
   AVG_FRAGMENTATION_IN_PERCENT, fragment_count
   
-------------------------------------------------------------------------------------------------------------------------

-- [Defrag process:]
(Run first query in step one if the computer can handle it.)
STEP 1
-- Checks for temp table
-- Drops temp table and creates new table for fragmented data
IF OBJECT_ID('tempdb..#tablevar') IS NOT NULL DROP TABLE #tablevar
CREATE table #tablevar (lngid INT IDENTITY(1,1), objectid INT, index_id INT)
INSERT INTO #tablevar-- (objectid, index_id)
SELECT [object_id] as 'objectid',index_id
FROM sys.dm_db_index_physical_stats (DB_ID('ShipWorks'),NULL,NULL,NULL,'DETAILED')
WHERE ((avg_fragmentation_in_percent > 15)
OR (avg_page_space_used_in_percent < 60))
AND page_count > 8
AND index_id NOT IN (0)

-- Returns ALTER queries

SELECT distinct 'ALTER INDEX ' + ind.[name] + ' ON ' + sc.[name] + '.[' + OBJECT_NAME(objectid) + '] REBUILD'
     FROM #tablevar tv
             INNER JOIN sys.indexes ind
                   ON tv.objectid = ind.[object_id]
                   AND tv.index_id = ind.index_id
             INNER JOIN sys.objects ob
                   ON tv.objectid = ob.[object_id]
             INNER JOIN sys.schemas sc
                   ON sc.schema_id = ob.schema_id
STEP 2
COPY RESULTS & PASTE INTO DB5
<results from above query>

-------------------------------------------------------------------------------------------------------------------------

-- [Enable MULTI_USER] // Fix for Stuck Database Update
SELECT name, user_access_desc
FROM sys.databases
WHERE name = 'ShipWorks';

ALTER DATABASE ShipWorks SET MULTI_USER

-------------------------------------------------------------------------------------------------------------------------

-- [Check Actionqueue | Clear ActionQueue | Reset ActionQueue]
SELECT * from actionqueue

delete from actionqueue where triggerdate<'****'

Update actionqueue set status='0' where status = '3'

-------------------------------------------------------------------------------------------------------------------------

-- [Database purge queries:] [Data's Inside Date range will not be affected]
purgeaudit @olderthan = '******', @rununtil = '2024-12-31', @softDelete = 0
purgeemailoutbound @olderthan = '******', @rununtil = '2024-12-31', @softDelete = 0
purgelabels @olderthan = 'todays-date', @rununtil = '2024-12-31', @softDelete = 0
purgeprintresult @olderthan = 'todays-date', @rununtil = '2024-12-31', @softDelete = 0
purgeabandonedresources @olderthan = 'tomorrows-date', @rununtil = '2024-12-31', @softDelete = 0
truncate table AuditChangeDetail
truncate table DownloadDetail


-------------------------------------------------------------------------------------------------------------------------

-- [Clear authentication token:]
UPDATE [store] set continuationtoken = NULL where StoreID = '----'

-------------------------------------------------------------------------------------------------------------------------

--[Shrink database]
DBCC shrinkdatabase (0,0)

-------------------------------------------------------------------------------------------------------------------------

--[Skip Order]
select * from [Store]
SELECT TOP(10) orderid,onlinelastmodified FROM [order] WHERE storeid='****' AND ismanual=0 ORDER BY onlinelastmodified DESC
UPDATE [order] SET onlinelastmodified='****' WHERE orderid='orderid'

-------------------------------------------------------------------------------------------------------------------------

-- Check DB Location
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'YourDatabaseName'); 

-------------------------------------------------------------------------------------------------------------------------
--[Check Storage Tables ('Other')]
SELECT
    t.NAME AS TableName,
    i.name as indexName,
    sum(p.rows) as RowCounts,
    sum(a.total_pages) as TotalPages,
    sum(a.used_pages) as UsedPages,
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB,
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB,
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND
    i.index_id <= 1GROUP BY
    t.NAME, i.object_id, i.index_id, i.name
ORDER BY
   TotalSpaceMB desc
   
-------------------------------------------------------------------------------------------------------------------------

--[Check DB Storage]
exec sp_spaceused

-------------------------------------------------------------------------------------------------------------------------
-- MAXIMUM 90DAYS, and depends on marketplace
--[Rollback query]
Declare @daysBack int; 
SET @daysBack = 2; 
UPDATE      [Order] 
SET               OnlineLastModified = DATEADD(DAY, - @daysBack, GETDATE())
WHERE       (OnlineLastModified > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
                            (SELECT       StoreID
                              FROM           Store
                              WHERE       (StoreID = 1005)));
-------------------------------------------------------------------------------------------------------------------------

--[Find PORT#]
DECLARE     @portNumber NVARCHAR(10)
EXEC xp_instance_regread
@rootkey   = 'HKEY_LOCAL_MACHINE',
@key       =
'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
@value_name = 'TcpDynamicPorts',
@value     = @portNumber OUTPUT
SELECT [Port Number] = @portNumber
-------------------------------------------------------------------------------------------------------------------------

--[Update Amazon API Region]
UPDATE AmazonStore SET AmazonApiRegion='CA' where StoreID = 'insert_Canada_storeID'
-------------------------------------------------------------------------------------------------------------------------

--[Disable AutoDownload]
update [store] set autodownload=0 where StoreID = '****'

-------------------------------------------------------------------------------------------------------------------------

--[Add 'OriginalChannelOrderID' table to DB]
Alter TABLE OrderSearch Add OriginalChannelOrderID varchar(50);

-------------------------------------------------------------------------------------------------------------------------

--[Customer Key]
select customerkey from configuration

-------------------------------------------------------------------------------------------------------------------------

--[Blank Customer Key]
update configuration set customerkey=''

-------------------------------------------------------------------------------------------------------------------------

--[Checks for ShipEngineKey (FedEx Migration Error)]
select ShipEngineAPIKey from ShippingSettings

-------------------------------------------------------------------------------------------------------------------------

--[Sets new ShipEngineKey] (FedEx Migration Error)
update ShippingSettings set ShipEngineAPIKey=''

-------------------------------------------------------------------------------------------------------------------------

--[List FedEx Accounts in DB5] (FedEx Migration Error)
select * from FedExAccount

-------------------------------------------------------------------------------------------------------------------------

--[Check for DOWNLOAD Actions]
SELECT * FROM Action WHERE cast (TriggerSettings as nvarchar(max)) LIKE '%Restriction value="1"%'

-------------------------------------------------------------------------------------------------------------------------

--[Clear Warehouse (for whole DB)]
update Configuration set WarehouseID=''
update Configuration set WarehouseName=''

-------------------------------------------------------------------------------------------------------------------------

--[Remove stuck download process]
delete from download where ended is null

-------------------------------------------------------------------------------------------------------------------------

--[Search for DB Triggers]
SELECT
    so.name TriggerName,
    USER_NAME(so.uid) TriggerOwner,
    USER_NAME(so2.uid) TableSchema,
    OBJECT_NAME(so.parent_obj) TableName,
    OBJECTPROPERTY( so.id, 'ExecIsUpdateTrigger') IsUpdate,
    OBJECTPROPERTY( so.id, 'ExecIsDeleteTrigger') IsDelete,
    OBJECTPROPERTY( so.id, 'ExecIsInsertTrigger') IsInsert,
    OBJECTPROPERTY( so.id, 'ExecIsAfterTrigger') IsAfter,
    OBJECTPROPERTY( so.id, 'ExecIsInsteadOfTrigger') IsInsteadOf,
    OBJECTPROPERTY(so.id, 'ExecIsTriggerDisabled') IsDisabled
FROM
       sysobjects so INNER JOIN sysobjects so2
        ON so.parent_obj = so2.Id
WHERE
       so.type = 'TR'
Order By TableName asc

-------------------------------------------------------------------------------------------------------------------------

--[FedEx Account Editing Queries:]
Update FedExAccount set [Street1]='****' Where FedExAccountID='****' 
Update FedExAccount set [City]='****' Where FedExAccountID='****' 
Update FedExAccount set [StateProvCode]='****' Where FedExAccountID='****' 
Update FedExAccount set [PostalCode]='****' Where FedExAccountID='****'

-------------------------------------------------------------------------------------------------------------------------

--[Check SQL Version:]
select SERVERPROPERTY('Edition') as [edition]

-------------------------------------------------------------------------------------------------------------------------

--[Change ODBC Import Strategy to 'All Orders':]
update odbcstore set ImportStrategy = '0' where storeid = ****

-------------------------------------------------------------------------------------------------------------------------

--[ODBC 'All Orders' Import Strategy not allowed:]
UPDATE [store] SET ManagedInHub='0' where storeid = ****

-------------------------------------------------------------------------------------------------------------------------

--[Set DATABASE to Trustworthy:]

ALTER DATABASE ShipWorks set trustworthy on

-------------------------------------------------------------------------------------------------------------------------

--[Set DATABASE owner to 'sa':]
EXEC sp_changedbowner 'sa'

-------------------------------------------------------------------------------------------------------------------------

--[Take new backup with DB5:]
BACKUP DATABASE ShipWorks TO DISK = 'C:\Program Files\ShipWorks\Backup.bak';

-------------------------------------------------------------------------------------------------------------------------

--[Customer Matching query:]
INSERT INTO [dbo].[Customer]
           ([BillFirstName]
           ,[BillMiddleName]
           ,[BillLastName]
           ,[BillCompany]
           ,[BillStreet1]
           ,[BillStreet2]
           ,[BillStreet3]
           ,[BillCity]
           ,[BillStateProvCode]
           ,[BillPostalCode]
           ,[BillCountryCode]
           ,[BillPhone]
           ,[BillFax]
           ,[BillEmail]
           ,[BillWebsite]
           ,[ShipFirstName]
           ,[ShipMiddleName]
           ,[ShipLastName]
           ,[ShipCompany]
           ,[ShipStreet1]
           ,[ShipStreet2]
           ,[ShipStreet3]
           ,[ShipCity]
           ,[ShipStateProvCode]
           ,[ShipPostalCode]
           ,[ShipCountryCode]
           ,[ShipPhone]
           ,[ShipFax]
           ,[ShipEmail]
           ,[ShipWebsite]
           ,[RollupOrderCount]
           ,[RollupOrderTotal]
           ,[RollupNoteCount])
     SELECT [Order].[BillFirstName]
           ,[Order].[BillMiddleName]
           ,[Order].[BillLastName]
           ,[Order].[BillCompany]
           ,[Order].[BillStreet1]
           ,[Order].[BillStreet2]
           ,[Order].[BillStreet3]
           ,[Order].[BillCity]
           ,[Order].[BillStateProvCode]
           ,[Order].[BillPostalCode]
           ,[Order].[BillCountryCode]
           ,[Order].[BillPhone]
           ,[Order].[BillFax]
           ,[Order].[BillEmail]
           ,[Order].[BillWebsite]
           ,[Order].[ShipFirstName]
           ,[Order].[ShipMiddleName]
           ,[Order].[ShipLastName]
           ,[Order].[ShipCompany]
           ,[Order].[ShipStreet1]
           ,[Order].[ShipStreet2]
           ,[Order].[ShipStreet3]
           ,[Order].[ShipCity]
           ,[Order].[ShipStateProvCode]
           ,[Order].[ShipPostalCode]
           ,[Order].[ShipCountryCode]
           ,[Order].[ShipPhone]
           ,[Order].[ShipFax]
           ,[Order].[ShipEmail]
           ,[Order].[ShipWebsite]
           ,0
           ,0
           ,0
        FROM [Order]
            WHERE OrderID IN (
                SELECT MAX(OrderID) AS MatchingOrderID
                    FROM [Order]
                        LEFT JOIN [Customer]
                            ON [Order].CustomerID = [Customer].CustomerID
                                AND [Order].BillFirstName = [Customer].BillFirstName
                                AND [Order].BillLastName = [Customer].BillLastName
                                AND [Order].BillStreet1 = [Customer].BillStreet1
                                AND [Order].BillCity = [Customer].BillCity
                    WHERE [Customer].CustomerID IS NULL
                    GROUP BY [Order].BillFirstName, [Order].BillLastName, [Order].BillStreet1, [Order].BillCity)
GO
UPDATE [Order]
    SET CustomerID = (SELECT TOP 1 CustomerID
                        FROM Customer
                        WHERE Customer.BillFirstName = WhereOrder.BillFirstName
                            AND Customer.BillLastName = WhereOrder.BillLastName
                            AND Customer.BillStreet1 = WhereOrder.BillStreet1
                            AND Customer.BillCity = WhereOrder.BillCity
                        ORDER BY CustomerID ASC)
    FROM [Order] AS WhereOrder
        LEFT JOIN [Customer]
            ON WhereOrder.CustomerID = [Customer].CustomerID
                AND WhereOrder.BillFirstName = [Customer].BillFirstName
                AND WhereOrder.BillLastName = [Customer].BillLastName
                AND WhereOrder.BillStreet1 = [Customer].BillStreet1
                AND WhereOrder.BillCity = [Customer].BillCity
    WHERE [Customer].CustomerID IS NULL

-------------------------------------------------------------------------------------------------------------------------

--[Disable Trigger:

DISABLE TRIGGER triggernamehere ON tablenamehere

-------------------------------------------------------------------------------------------------------------------------

--[Delete Trigger:]
DROP trigger namehere ON dbo.tablenamehere

-------------------------------------------------------------------------------------------------------------------------

--[Database Repair Queries:] (Run one at a time...)
ALTER DATABASE ShipWorks SET EMERGENCY
GO
DBCC CHECKDB(ShipWorks)use ShipWorks
GO
ALTER DATABASE ShipWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DBCC CHECKDB(ShipWorks,repair_allow_data_loss)
GO
ALTER DATABASE ShipWorks SET MULTI_USER
GO
-------------------------------------------------------------------------------------------------------------------------

-- Reset SQL Password (in CMD
osql -S SERVER\SHIPWORKS_2022 -U sa -P ShipW@rks1 -H 0000100001 -d ShipWorks
sqlcmd –S sqlserverinstance –E 
use databasename
sp_password NULL,’new password’,'sa'press Enter

sqlcmd -S YourServerName -U YourUsername -P YourCurrentPassword

    ALTER LOGIN YourUsername WITH PASSWORD = 'YourNewPassword';
-------------------------------------------------------------------------------------------------------------------------

-- Amazon Not downloading orders if already downloaded in backend
Update [Store] SET [ContinuationToken] = 'PasteContinuationToken' Where StoreId = '11005';

-------------------------------------------------------------------------------------------------------------------------

-- USPS Account SE Carrier ID
select ShipEngineCarrierId from UspsAccount

-------------------------------------------------------------------------------------------------------------------------

-- Check custom triggers installed.
SELECT 
	OBJECT_NAME(parent_obj) 'Table Name',
	OBJECT_NAME(id) 'Trigger Name',
    CASE 
		WHEN OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') = 1 THEN 'Disabled'
		ELSE 'Enabled'
		END AS 'Trigger Status',
	CASE 
		WHEN OBJECTPROPERTY( id, 'ExecIsAfterTrigger') = 1 THEN 'After'
		WHEN OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger') = 1 THEN 'Instead of'
		ELSE ''
		END AS  'Is After/Instead of',
	CASE 
		WHEN OBJECTPROPERTY( id, 'ExecIsInsertTrigger') = 1 THEN 'Insert'
		WHEN OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') = 1 THEN 'Update'
		WHEN OBJECTPROPERTY( id, 'ExecIsDeleteTrigger') = 1 THEN 'Delete'
		ELSE ''
		END AS  'Is Insert/Update/Delete'
FROM sysobjects 
WHERE type = 'TR' AND	
	OBJECT_NAME(id) != 'FilterNodeSetSwFilterNodeID'
Order By 'Table Name' asc;

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
