trigger AccountTrigger on Account (before insert, before update) {
    AccountTriggerHandler.entry(
        Trigger.operationType,
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
        ); 
}