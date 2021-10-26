trigger RiskTrigger on Risk__c (before insert, before update, after update) 
{
	if(trigger.isBefore)
    {
        if(Trigger.isUpdate)
        {
            RiskTriggerHandler.handleBeforeInsertAndUpdateValidationRules((List<Risk__c>)Trigger.new);
            RiskTriggerHandler.handleBeforeUpdate((Map<Id,Risk__c>)Trigger.newMap, (Map<Id,Risk__c>)Trigger.oldMap);
            
        }

        //added by Miguel 22/01
        if(Trigger.isInsert){
            RiskTriggerHandler.handleBeforeInsertAndUpdateValidationRules((List<Risk__c>)Trigger.new);            
        }
    }
    else if(trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            RiskTriggerHandler.handleAfterUpdate((Map<Id, Risk__c>)Trigger.newMap, (Map<Id, Risk__c>)Trigger.oldMap);
        }
    }
}