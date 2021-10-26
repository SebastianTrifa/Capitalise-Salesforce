/** 
(c) 2018 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date 2018 
@author Miguel Sampaio 

@description

*/
trigger OpportunityLineItemScheduleTrigger on OpportunityLineItemSchedule (after insert, after update, after delete, before insert, before update, before delete) {
    OpportunityLineItemScheduleTriggerHelper.entry(
                        Trigger.operationType,
                        Trigger.new,
                        Trigger.newMap,
                        Trigger.old,
                        Trigger.oldMap
                        ); 
}