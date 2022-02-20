global class BatchLenderHealthscoreKeys implements Database.Batchable<sObject> {
    
    String query;
    Boolean quaterly;
    global BatchLenderHealthscoreKeys() {
        //quaterly = true;
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        query = 'select Id, Name, Lender_Conversion_Key__c, Lender_Monetary_Key__c, Active_Contacts_Key__c, Platform_Use_API_Key__c, Last_Quarterly_Meeting__c, Lender_Conversion__c, Lender_Monetary__c, Active_Contacts__c, Platform_Use_API__c, Feedback__c from Account where RecordTypeId = \'' + lenderRecordTypeId + '\'';
    }

    global BatchAccountHealthscoreKeys(String a_query) {
        query = a_query;
        //quaterly = true;
    }

    global BatchAccountHealthscoreKeys(Boolean fullOperation) {
        quaterly = fullOperation;
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        query = 'select Id, Name, Lender_Conversion_Key__c, Lender_Monetary_Key__c, Active_Contacts_Key__c, Platform_Use_API_Key__c, Last_Quarterly_Meeting__c, Lender_Conversion__c, Lender_Monetary__c, Active_Contacts__c, Platform_Use_API__c, Feedback__c from Account where RecordTypeId = \'' + lenderRecordTypeId + '\'';
    }

    global BatchAccountHealthscoreKeys(String a_query, Boolean fullOperation) {
        quaterly = fullOperation;
        query = a_query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<AggregateResult> metricsLenderMonetaryAggregate = [select Count(Id) numOpps, AVG(Confirmed_CommisionMoney__c) lenderMonetaryKey, AccountId accountId
                                            From Opportunity
                                            Where AccountId in :scope and StageName = 'Paid Out'
                                            Group By AccountId];
        List<AggregateResult> metrics90daysAggregate = [select Count(Id) recentSearches, AccountId accountId 
                                            From Opportunity 
                                            Where AccountId in :scope and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 
                                            Group By AccountId];
        List<AggregateResult> paidOutMetrics90daysAggregate = [select Count(Id) recentSearches, AccountId accountId 
                                            From Opportunity 
                                            Where AccountId in :scope and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and StageName = 'Paid Out' 
                                            Group By AccountId];
        List<AggregateResult> activeContactsAggregate = [select Count(Id) activeContacts, AccountId accId
                                            From Contact
                                            Where AccountId in :scope
                                            Group By AccountId];
        
        Map<Id, AggregateResult> metricsLenderMonetary = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> metrics90Days = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> paidOutMetrics90Days = new Map<Id, AggregateResult>();
        Map<Id, Integer> activeContacts = new Map<Id, Integer>();

        for(AggregateResult res : metricsLenderMonetaryAggregate)
        {
            metricsLenderMonetary.put((Id)res.get('accountId'), res);
        }

        for(AggregateResult res : metrics90daysAggregate)
        {
            metrics90Days.put((Id)res.get('accountId'), res);
        }

        for(AggregateResult res : paidOutMetrics90daysAggregate)
        {
            paidOutMetrics90Days.put((Id)res.get('accountId'), res);
        }

        for(AggregateResult res : activeContactsAggregate)
        {
            activeContacts.put((Id)res.get('accId'), (Integer)res.get('activeContacts'));
        }

        for(Account acc : scope)
        {
            system.debug(acc);

            Double recentSearches = (metrics90Days.containsKey(acc.Id)) ? (Integer) metrics90Days.get(acc.Id).get('recentSearches') : 0;
            Double recentPaidOutSearches = (paidOutMetrics90Days.containsKey(acc.Id)) ? (Integer) paidOutMetrics90Days.get(acc.Id).get('recentSearches') : 0;
            Double numberContacts = (activeContacts.containsKey(acc.Id)) ? (Integer) activeContacts.get(acc.Id) : 0;

            acc.Recent_Searches__c = recentSearches;
            acc.Recent_Paid_Out_Searches__c = recentPaidOutSearches;
            acc.Lender_Conversion_Key__c = (recentSearches != 0) ? recentPaidOutSearches / recentSearches : 0;
            acc.Lender_Monetary_Key__c = (metricsLenderMonetary.containsKey(acc.Id)) ? (Decimal) metricsLenderMonetary.get(acc.Id).get('lenderMonetaryKey') : 0;
            acc.Active_Contacts_Key__c = (numberContacts != 0) ? numberContacts : 0;
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
        BatchLenderHealthScore job = new BatchLenderHealthScore();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}
