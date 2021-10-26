/** 
(c) 2020 Capitalise
Developed by Revolent Group, London (United Kingdom)
@date 07/2020 
@author Kevin Tchaka 
*/

trigger CustomTalkdeskActivityTrigger on talkdesk__Talkdesk_Activity__c (after insert) {
    CustomTalkdeskActivityTriggerHelper.entry(
        Trigger.operationType,
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
        );
}