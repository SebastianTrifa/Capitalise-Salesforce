trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    CDLTriggerHelper.entry(
        Trigger.operationType,
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
        ); 
}