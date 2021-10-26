public with sharing class AccountTriggerHandler {
    public static Boolean hasRan = false;
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < Account > newList,
        Map < Id, Account > newMap,
        List < Account > oldList,
        Map < Id, Account > oldMap
    ) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                AccountValidationRules(newList);
            }
            when BEFORE_UPDATE {
                AccountValidationRules(newList);
            }
        }
    }

    private static void AccountValidationRules(List<Account> accounts)
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();

        for(Account acc : accounts)
        {
            if (acc.RecordTypeId == introducerRecordTypeId && (acc.Membership_Level__c == null || acc.Membership_Level__c == ''))
            {
                acc.addError('Membership Level cannot be null or blank for Introducer accounts');
            }
        }
    }
}