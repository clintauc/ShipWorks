
--[Blank Password]
update [user] set password='1B2M2Y8AsgTpgAmY7PhCfg==' where username='***'

--------------------------------------------------------------------------------

--[Check Fragmentation:] Check Storage in MB

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

----------------------------------------------------------------
--[Check Fragmentation:] Check Storage in GB
SELECT 
 t.NAME AS TableName,
    i.name as indexName,
    sum(p.rows) as RowCounts,
    sum(a.total_pages) as TotalPages,
    sum(a.used_pages) as UsedPages,
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024. as TotalSpaceMB,
    (sum(a.used_pages) * 8) / 1024. as UsedSpaceMB,
    (sum(a.data_pages) * 8) / 1024. as DataSpaceMB,
    (sum(a.total_pages) * 8) / 1048576. as TotalSpaceGB,
    (sum(a.used_pages) * 8) / 1048576. as UsedSpaceGB,
    (sum(a.data_pages) * 8) / 1048576. as DataSpaceGB
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


---------------------------------------------------------------------

-- [Clear ActionQueue | Reset ActionQueue]

delete from actionqueue where triggerdate<'****'
Update actionqueue set status='0' where status = '3'

-------------------------------------------------------------------------

--[Database purge queries:]

purgeaudit @olderthan = '******', @rununtil = '2024-12-31', @softDelete = 0

purgeemailoutbound @olderthan = '******', @rununtil = '2024-12-31', @softDelete = 0

purgelabels @olderthan = 'todays-date', @rununtil = '2024-12-31', @softDelete = 0

purgeprintresult @olderthan = 'todays-date', @rununtil = '2024-12-31', @softDelete = 0

purgeabandonedresources @olderthan = 'todays-date', @rununtil = '2021-12-31', @softDelete = 0

truncate table AuditChangeDetail

truncate table DownloadDetail


-- -orderThan=date up to which records are to be purged
-- -runUntil is a date in the future
-- -use yyyy-MM-dd, include a 0 if needed for single digit days/months
-- -use single tick quotes around dates
-- - softDelete=0 completely removes a record, softDelete=1 only deletes the contents of said record

-------------------------------------------------------------------------


-- DELETE ORDERS FROM DATABASE (For testing)

-- 1. Delete from OrderCharge
DELETE FROM `OrderCharge`
WHERE OrderID IN (SELECT OrderID FROM `Order` WHERE OrderDate < DATE_SUB(NOW(), INTERVAL 30 DAY));

-- 2. Delete from OrderItem
DELETE FROM `OrderItem`
WHERE OrderID IN (SELECT OrderID FROM `Order` WHERE OrderDate < DATE_SUB(NOW(), INTERVAL 30 DAY));

-- 3. Delete from Shipment
DELETE FROM `Shipment`
WHERE OrderID IN (SELECT OrderID FROM `Order` WHERE OrderDate < DATE_SUB(NOW(), INTERVAL 30 DAY));

-- 4. Finally, delete the master Order record
DELETE FROM `Order`
WHERE OrderDate < DATE_SUB(NOW(), INTERVAL 30 DAY);
