global class BatchIntroducersManagedClientsDeltas implements Database.Batchable<sObject> {
    string query;

    global BatchIntroducersManagedClientsDeltas() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Managed_Clients_Connected__c, Managed_Clients_Connected_Delta__c, Managed_Clients_Connected_Snap__c, Managed_Clients__c, Managed_Clients_Delta__c, Managed_Clients_Snap__c from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        for(Account acc : scope)
        {
            if(acc.Managed_Clients__c == null)
            {
                acc.Managed_Clients__c = 0;
            }
            if(acc.Managed_Clients_Connected__c == null)
            {
                acc.Managed_Clients_Connected__c = 0;
            }
            if(acc.Managed_Clients_Snap__c == null)
            {
                acc.Managed_Clients_Snap__c = 0;
            }
            if(acc.Managed_Clients_Connected_Snap__c == null)
            {
                acc.Managed_Clients_Connected_Snap__c = 0;
            }
            acc.Managed_Clients_Delta__c = acc.Managed_Clients__c - acc.Managed_Clients_Snap__c;
            acc.Managed_Clients_Connected_Delta__c = acc.Managed_Clients_Connected__c - acc.Managed_Clients_Connected_Snap__c;
            acc.Managed_Clients_Snap__c = acc.Managed_Clients__c;
            acc.Managed_Clients_Connected_Snap__c = acc.Managed_Clients_Connected__c;    
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