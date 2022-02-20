public with sharing class BatchLenderHealthscore {
    String query;
    Boolean quaterly;
    global BatchLenderHealthScore() {
        //quaterly = true;
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        query = 'select Id, Name, Lender_Conversion_Key__c, Lender_Monetary_Key__c, Active_Contacts_Key__c, Platform_Use_API_Key__c, Last_Quarterly_Meeting__c, Lender_Conversion__c, Lender_Monetary__c, Active_Contacts__c, Platform_Use_API__c, Feedback__c from Account where RecordTypeId = \'' + lenderRecordTypeId + '\'';
    }

    global BatchLenderHealthScore(Boolean a_quaterly) {
        quaterly = a_quaterly;
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        query = 'select Id, Name, Lender_Conversion_Key__c, Lender_Monetary_Key__c, Active_Contacts_Key__c, Platform_Use_API_Key__c, Last_Quarterly_Meeting__c, Lender_Conversion__c, Lender_Monetary__c, Active_Contacts__c, Platform_Use_API__c, Feedback__c from Account where RecordTypeId = \'' + lenderRecordTypeId + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        Integer quintile = scope.size() / 5;
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();

        List<AccountHealthScoreSorter> sortedLenderConversionAccounts = new List<AccountHealthScoreSorter>();
        List<AccountHealthScoreSorter> sortedLenderMonetaryAccounts = new List<AccountHealthScoreSorter>();
        List<AccountHealthScoreSorter> sortedActiveContactsAccounts = new List<AccountHealthScoreSorter>();
        List<AccountHealthScoreSorter> sortedPlatformUseAccounts = new List<AccountHealthScoreSorter>();
        List<AccountHealthScoreSorter> sortedFeedbackAccounts = new List<AccountHealthScoreSorter>();
        Map<Id, Account> accMap = new Map<Id, Account>();

        for(Account acc : scope){
            sortedLenderConversionAccounts.add(new AccountHealthScoreSorter(acc, 'Lender Conversion'));
            sortedLenderMonetaryAccounts.add(new AccountHealthScoreSorter(acc, 'Lender Monetary'));
            sortedActiveContactsAccounts.add(new AccountHealthScoreSorter(acc, 'Active Contacts'));
            sortedFeedbackAccounts.add(new AccountHealthScoreSorter(acc, 'Feedback'));
            accMap.put(acc.Id, acc);
        }

        sortedLenderConversionAccounts.sort();
        sortedLenderMonetaryAccounts.sort();
        sortedActiveContactsAccounts.sort();
        sortedFeedbackAccounts.sort();

        for(Integer idx = 0; idx < sortedLenderConversionAccounts.size(); idx++)
        {
            if(accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion_Key__c != 0)
            {
                if(quintile == 0)
                {
                    accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion__c = idx + 1;
                }
                else if(idx < quintile)
                {
                    accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion__c = 1;
                }
                else if(idx < 2 * quintile)
                {   
                    accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion__c = 2;
                }
                else if(idx < 3 * quintile)
                {
                    accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion__c = 3;
                }
                else if(idx < 4 * quintile)
                {
                    accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion__c = 4;
                }
                else
                {
                    accMap.get(sortedLenderConversionAccounts[idx].acc.Id).Lender_Conversion__c = 5;
                }
            }
        }

        for(Integer idx = 0; idx < sortedLenderMonetaryAccounts.size(); idx++)
        {
            if(accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary_Key__c != 0)
            {
                if(quintile == 0)
                {
                    accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary__c = idx + 1;
                }
                else if(idx < quintile)
                {
                    accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary__c = 1;
                }
                else if(idx < 2 * quintile)
                {   
                    accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary__c = 2;
                }
                else if(idx < 3 * quintile)
                {
                    accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary__c = 3;
                }
                else if(idx < 4 * quintile)
                {
                    accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary__c = 4;
                }
                else
                {
                    accMap.get(sortedLenderMonetaryAccounts[idx].acc.Id).Lender_Monetary__c = 5;
                }
            }
        }
        
        for(Integer idx = 0; idx < sortedActiveContactsAccounts.size(); idx++)
        {
            if(accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts_Key__c != 0)
            {
                if(quintile == 0)
                {
                    accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts__c = idx + 1;
                }
                else if(idx < quintile)
                {
                    accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts__c = 1;
                }
                else if(idx < 2 * quintile)
                {   
                    accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts__c = 2;
                }
                else if(idx < 3 * quintile)
                {
                    accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts__c = 3;
                }
                else if(idx < 4 * quintile)
                {
                    accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts__c = 4;
                }
                else
                {
                    accMap.get(sortedActiveContactsAccounts[idx].acc.Id).Active_Contacts__c = 5;
                }
            }
        }

        for(Integer idx = 0; idx < sortedFeedbackAccounts.size(); idx++)
        {
            if(accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback_Key__c != 0)
            {
                if(quintile == 0)
                {
                    accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback__c = idx + 1;
                }
                else if(idx < quintile)
                {
                    accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback__c = 1;
                }
                else if(idx < 2 * quintile)
                {   
                    accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback__c = 2;
                }
                else if(idx < 3 * quintile)
                {
                    accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback__c = 3;
                }
                else if(idx < 4 * quintile)
                {
                    accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback__c = 4;
                }
                else
                {
                    accMap.get(sortedFeedbackAccounts[idx].acc.Id).Feedback__c = 5;
                }
            }
        }

        if(acc.CAPAPP_PLATFORM_USAGE__c = 'API, picks up from platform and updates all status including decline and offer with commentary where needed'){
            acc.Platform_Use_API__c = 5;
        }
        else if(acc.CAPAPP_PLATFORM_USAGE__c = 'API, but does not update status for non API applications'){
            acc.Platform_Use_API__c = 4;
        }
        else if(acc.CAPAPP_PLATFORM_USAGE__c = 'picks up from platform and updates all status including decline and offer with commentary where needed'){
            acc.Platform_Use_API__c = 3;
        }
        else if(acc.CAPAPP_PLATFORM_USAGE__c = 'picks up from the platform but does not change status'){
            acc.Platform_Use_API__c = 2;
        }
        else if(acc.CAPAPP_PLATFORM_USAGE__c = 'does not use platform'){
            acc.Platform_Use_API__c = 1;
        }
        else{
            acc.Platform_Use_API__c = 1;
        }

        Database.SaveResult[] dbsr = Database.update(scope, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}
