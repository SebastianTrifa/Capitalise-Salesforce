global class BatchAccountSetPrimaryContactOne implements Database.Batchable<sObject> {
    String query;
    global BatchAccountSetPrimaryContactOne() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Primary_Contact__c from Account where Primary_Contact__c = null';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        List<AggregateResult> contactCount = [select COUNT(Id) numcontacts, AccountId acc from Contact where AccountId IN :scope Group By AccountId];

        Set<Id> accsWithOneContact = new Set<Id>();

        for(AggregateResult res : contactCount)
        {
            Integer numContacts = (Integer) res.get('numcontacts');
            if(numContacts == 1) accsWithOneContact.add((Id)res.get('acc'));
        }

        Map<Id, Id> contactToAcc = new Map<Id, Id>();

        for(Contact con : [select Id, AccountId from Contact where AccountId in :accsWithOneContact])
        {
            contactToAcc.put(con.AccountId, con.Id);
        }

        for(Account acc : scope)
        {
            acc.Primary_Contact__c = (contactToAcc.containsKey(acc.Id)) ? contactToAcc.get(acc.Id) : null;
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