-- !!!!!!Take a backup you fool

-----------------------------------------------------------------------------------------------------------------------	

select * from store
-- !!!!!take note of store type code: 10 in this case

-- !!!!!Change the last line to match store typecode:
Declare @daysBack int; 
SET @daysBack = 2; 
UPDATE      [Order] 
SET               OnlineLastModified = DATEADD(DAY, - @daysBack, GETDATE())
WHERE       (OnlineLastModified > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
                            (SELECT       StoreID
                              FROM           Store
                              WHERE       (StoreID = 1005)));

Declare @daysBack int; 
SET @daysBack = 4; 
UPDATE [Order] 
SET OnlineLastModified = DATEADD(DAY, - @daysBack, GETDATE())
WHERE   (OnlineLastModified > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
			(SELECT       StoreID
			  FROM           Store
			  WHERE       (TypeCode = 1)));
			  
			  
			  
-- BigCommerce

Declare @daysBack int; 
SET @daysBack = 21; 
UPDATE [Order] 
SET OnlineLastModified = DATEADD(DAY, - @daysBack, GETDATE())
WHERE   (OnlineLastModified > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
			(SELECT       StoreID
			  FROM           Store
			  WHERE       (TypeCode = 30)));
							  
							  
-----------------------------------------------------------------------------------------------------------------------	
							  
-- !Amazon outage rollback:
-- 1{Rollback:
-- }

Declare @daysBack int; 
SET @daysBack = 5; 
UPDATE   [Order]  
SET        OnlineLastModified = DATEADD(DAY, - @daysBack, GETDATE()) 
WHERE    (OnlineLastModified > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
              (SELECT    StoreID
               FROM      Store
               WHERE    (TypeCode = 10)));


-- 2{Download orders for all Az stores
-- }
-- 3{ Create filter: if local shipped, store !shipped
-- }
-- 4{ manually upload all orders in filter
-- }
-- 			   28
			   
			   

-- Store types: 
-- 	Azn: 10
-- 	BigCommerce: 30
	
-- 	osql -S DESKTOP-OOA8O35\SHIPWORKS -E -d Shipworks -H0000100001
	
-----------------------------------------------------------------------------------------------------------------------	
Declare @daysBack int; 	
SET @daysBack = 3; 
UPDATE      [Order] 
SET               OnlineLastModified = DATEADD(DAY, - @daysBack, GETDATE())
WHERE       (OnlineLastModified > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
                            (SELECT       StoreID
                              FROM           Store
                              WHERE       (StoreID = 1005)));
							  
-----------------------------------------------------------------------------------------------------------------------	
						  
-- ChannelAdvisor Rollback
update [ChannelAdvisorStore] set DownloadDaysBack=<numberofdaysneededToGoBack> where storeID=storeID
The default is 4. if changed to 7 or more, it will make downloads slower depending on the volume of orders needed to download from x number of days back

-----------------------------------------------------------------------------------------------------------------------	
-- !PAYPAL
Declare @daysBack int;
SET @daysBack = 7;
UPDATE       [Order]
SET                Orderdate = DATEADD(DAY, - @daysBack, GETDATE())
WHERE        (Orderdate > DATEADD(DAY, - @daysBack, GETDATE())) AND (StoreID IN
                             (SELECT        StoreID
                               FROM            Store
                               WHERE        (TypeCode = 18)));
