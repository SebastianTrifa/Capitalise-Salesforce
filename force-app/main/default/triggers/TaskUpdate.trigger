trigger TaskUpdate on Task (before insert, after insert, after update) {
    TaskTriggerHelper.entry(
        Trigger.operationType,
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
    );
}