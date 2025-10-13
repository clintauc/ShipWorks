-- !Identify the correct storeID
select * from store

-- !Most recent OnlineLastModified time at the top of this list
select top(10) orderid,onlinelastmodified from [order] where storeid= '10004005' and ismanual=0 order by onlinelastmodified desc

-- !or use the following query to include the normal order number as well
select top(10) orderid,onlinelastmodified,ordernumbercomplete from [order] where storeid='20038005' and ismanual=0 order by onlinelastmodified desc

-- !Repeate the next step, incrementing the time slowly, until new orders come in
update [order] set onlinelastmodified = '2020-10-01 14:45:00' where storeid= '10004005' and orderid= '147066006'

-----------

select * from store
select top(10) orderid,onlinelastmodified,orderdate,ordernumbercomplete from [order] where storeid='20038005' and ismanual=0 order by onlinelastmodified desc
update [order] set onlinelastmodified = '2020-10-01 14:45:00' where storeid= '10004005' and orderid= 147066006

update [order] set onlinelastmodified = '2020-10-01 14:45:00' where storeid= '10004005' and orderid= 147066006


-- !!!!!WalMart:
-- !!!!Find WM storeID:
select * from store

-- !!!!!Update the soteID in the following:
select top(10) orderid,orderDate,ordernumbercomplete from [order] where storeid='3005' and ismanual=0 order by OrderDate desc
-- !!!!!Copy original values from the top row returned in case we need to revert changes for some reason:
563716006	2021-09-15 11:59:28	5862591778278
-- !!!!Update the orderDate, orderID, and storeID:
update [order] set orderDate = '2021-09-15 12:05:00' where storeid= '005' and orderid='563716006'

