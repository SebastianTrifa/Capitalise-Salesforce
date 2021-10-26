global class BatchIntroducersConnectedClientsDeltas implements Database.Batchable<sObject> {
    string query;
    string recurrence;

    global BatchIntroducersConnectedClientsDeltas() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Managed_Clients_Connected__c, Managed_Clients_Connected_Delta__c, Managed_Clients_Connected_Snap__c, Managed_Clients__c, Managed_Clients_Delta__c, Managed_Clients_Snap__c, Managed_Clients_Connected_Snap_Monthly__c, Managed_Clients_Connected_Snap_Daily__c, Managed_Clients_Connected_Delta_Month__c, Managed_Clients_Connected_Delta_Daily__c from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
        recurrence = 'Daily';
    }

    global BatchIntroducersConnectedClientsDeltas(string a_recurrence) {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Managed_Clients_Connected__c, Managed_Clients_Connected_Delta__c, Managed_Clients_Connected_Snap__c, Managed_Clients__c, Managed_Clients_Delta__c, Managed_Clients_Snap__c, Managed_Clients_Connected_Snap_Monthly__c, Managed_Clients_Connected_Snap_Daily__c, Managed_Clients_Connected_Delta_Month__c, Managed_Clients_Connected_Delta_Daily__c from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
        recurrence = a_recurrence;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        switch on recurrence {
            when 'Weekly' {
                scope = AccountService.CalculateWeeklyDeltas(scope);
            }
            when 'Monthly' {
                scope = AccountService.refreshMonthlyDeltas(scope);
            }
            when else {
                scope = AccountService.CalculateDailyDeltas(scope);
            }
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