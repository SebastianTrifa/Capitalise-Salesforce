trigger SaaSContractTrigger on Saas_Contract__c (before insert) {
    SaaSContractTriggerHandler.entry(
        Trigger.operationType,
        Trigger.new,
        Trigger.newMap,
        Trigger.old,
        Trigger.oldMap
        ); 
}