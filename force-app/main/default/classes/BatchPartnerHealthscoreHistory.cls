global class BatchPartnerHealthscoreHistory implements Database.Batchable<sObject> {
    String query;
    global BatchPartnerHealthscoreHistory() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Name, HealthScore__c from Account where RecordTypeId=\'' + introducerRecordTypeId + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Introducer_HealthScore_History__c> changes = new List<Introducer_HealthScore_History__c>();
        
        for(Account acc : scope)
        {
            Introducer_HealthScore_History__c a_change = new Introducer_HealthScore_History__c();
            a_change.Introducer__c = acc.Id;
            a_change.Record_Date__c = system.today();
            a_change.HealthScore__c = acc.HealthScore__c;
            a_change.Name = acc.Name + '_' + a_change.Record_Date__c;
            changes.add(a_change);
        }

        Database.SaveResult[] dbsr = Database.insert(changes, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Account Healthscore History ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('HealthScore History fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}