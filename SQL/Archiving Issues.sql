!!!!!!Stuck Archiving??
The Drive must have at least 20GB free at all times to run ShipWorks efficiently and the archive should be successful at over 20GB

-------------------------------------------------------------------------------------------------------------
-- Check SQL version 
--Queries to run for info:
- Select @@version (checks sql version)
- update SQL Cumulative Updates - https://www.microsoft.com/en-us/download/details.aspx?id=56128
- Exec sp_spaceused (checks MDF & LDF size)


-------------------------------------------------------------------------------------------------------------
-- Turn off the Archive action and remove from the ActionQueue	

--Find the ActionID for the Archive Action.
select * from ActionQueue

-- Delete that ActionID in the following
delete from ActionQueue where ActionID= 

----------------

--Find and disable the Archive action.
select * from [Action]
--Find the Auto Archive action and notate its ActionID
Update [Action] set Enabled=0 where actionID=

----------------
--First, set the DB to single user mode:
-- Connect to Master DB

ALTER DATABASE ZArchiving_ShipWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE

--Next, change the DB name back to what it was before:
ALTER DATABASE ZArchiving_ShipWorks MODIFY NAME = ShipWorks;

--Next put DB back into Multi User:
ALTER DATABASE ShipWorks SET MULTI_USER

----------------
--Possibly useful query
ALTER DATABASE ShipWorks SET TRUSTWORTHY ON