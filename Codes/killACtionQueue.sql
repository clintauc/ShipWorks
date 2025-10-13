-- lists all actions in action queue
select * from actionqueue
	
-- // kills a given action by ID
--	//Deletes ALL actions of this same type
delete from actionqueue where actionID = xxxxxx	

-- //Delete one single specific action	
delete from actionqueue where actionqueueID = xxxxxxxxxxx
	
-- //Shows individual sub-tasks of an action	
select * from ActionQueueStep 
	
-- //clear out step tasks based on status	
delete from ActionQueueStep where StepStatus = X
	
-- //restart an action if it has stalled and you have reason to think it will run now	
Update actionqueue set status='0' where status = '3'
	
-- //Clear out old actions but leave newer ones
delete from actionqueue where triggerdate < '2025-05-30 05:02:13.623'
	
	
-------------------------------------------------
-- !!!!!Available Statuses
-- 0 = Dispatched; Initial state, the action was just dispatched
-- 1 = 1 Incomplete; The action is currently being processed. The workflow may be done (every step
-- processed), but some steps may be postponed.
-- 2 = Success; The action was ran, and is complete with success
-- 3 = Error; The action was ran, and there was a failure
-- 4 = Postponed; The queue is suspeneded while waiting for a Postponed step
-- 5 = ResumeFromPostponed; The queue has had its postponed step consumed, and is ready to
-- keep going the next time its processed
-------------------------------------------------

!!!!!Restart AQSched:
after changing statuses or clearing out stuck action, to get the rest to run you can either close/open sw or run the following
Note: if the action is restricted to run on a certain computer this may need to be done on that computer
Run in command prompt not DB5

cd c:\Program Files\ShipWorks
shipworks.exe /s=schedulergo
-------------------------------------------------

-- !!!!!Stuck uploads due to manual(usually WalMart) orders
-- Identify source of stuck action
-- Update the date value to a little bit before the top action's trigger dateTime'

Select C.ActionqueueID, A.ShipmentID, B.OrderNumberCOmplete
from shipment A
inner join [order] B on A.OrderID=B.OrderID
inner join Actionqueue C  on C.ObjectID = A.ShipmentID
where A.Processed = 1 and B.OrderNumberComplete LIKE '%-M%' and ProcessedDate > '2021-09-17 01:12:58.713'