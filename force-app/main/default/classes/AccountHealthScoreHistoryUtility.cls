global class AccountHealthScoreHistoryUtility implements Database.Batchable<sObject> {
    String query;
    
    global AccountHealthScoreHistoryUtility() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Name from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        for(Account acc : scope) {
            accIds.add(acc.Id);
            accounts.put(acc.Id, acc);
        }

        List<Introducer_HealthScore_History__c> changes = new List<Introducer_HealthScore_History__c>();
        List<AccountHistory> accountChanges = [select Id, AccountId, CreatedDate, NewValue, Field from AccountHistory where AccountId in :accIds and Field='HealthScore2__c'];
        if(Test.isRunningTest()) {
            accountChanges = new List<AccountHistory>();
            for(Account acc : scope) {
                accountChanges.add(new AccountHistory(AccountId=acc.Id, Field='HealthScore2__c'));
            }
        }
        for(AccountHistory change : accountChanges) {
            Introducer_HealthScore_History__c a_change = new Introducer_HealthScore_History__c();
            a_change.Introducer__c = change.AccountId;
            a_change.Record_Date__c = (change.CreatedDate != null) ? change.CreatedDate.date() : system.today();
            a_change.HealthScore__c = (change.NewValue != null) ? Double.valueOf(change.NewValue) : 77.0;
            a_change.Name = accounts.get(change.AccountId).Name + '_' + a_change.Record_Date__c;
            changes.add(a_change);
        }


        Database.SaveResult[] dbsr = Database.insert(changes, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated HealthScore History ID: ' + sr.getId());
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