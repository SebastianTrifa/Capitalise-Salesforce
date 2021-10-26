global class BatchAccountFirstOpportunityDate implements Database.Batchable<sObject> {

    String query;
    global BatchAccountFirstOpportunityDate() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Name, First_Opportunity_Date2__c from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
    }

    global BatchAccountFirstOpportunityDate(String a_query) {
        query = a_query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<Id> fundingSearchesTypesIds = new Set<Id>();
        
        fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId());
        fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId());
        Id recoveryTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Recovery').getRecordTypeId();
        List<AggregateResult> eldestSearches = [select Min(CreatedDate) firstDate, Introducer_new__c introId from Opportunity where Introducer_new__c in :scope and RecordTypeId in :fundingSearchesTypesIds Group By Introducer_new__c];
        List<AggregateResult> eldestRecoveries = [select Min(CreatedDate) firstDate, AccountId accId from Opportunity Where AccountId in :scope and RecordTypeId = :recoveryTypeId Group By AccountId];

        Map<Id, DateTime> eldestSearchesMap = new Map<Id, DateTime>();
        Map<Id, DateTime> eldestRecoveryMap = new Map<Id, DateTime>();

        for(AggregateResult result : eldestSearches)
        {
            eldestSearchesMap.put((Id)result.get('introId'), (DateTime)result.get('firstDate'));
        }

        for(AggregateResult res : eldestRecoveries)
        {
            eldestRecoveryMap.put((Id)res.get('accId'), (DateTime)res.get('firstDate'));
        }

        for(Account acc : scope)
        {
            DateTime recovery = (eldestRecoveryMap.containsKey(acc.Id)) ? eldestRecoveryMap.get(acc.Id) : null;
            DateTime fs = (eldestSearchesMap.containsKey(acc.Id)) ? eldestSearchesMap.get(acc.Id) : null;

            DateTime earliest = (recovery < fs) ? recovery : fs;

            acc.First_Opportunity_Date2__c = (earliest != null) ? earliest.date() : null; 
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