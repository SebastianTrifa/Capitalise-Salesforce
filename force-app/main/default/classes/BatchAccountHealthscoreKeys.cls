global class BatchAccountHealthscoreKeys implements Database.Batchable<sObject> {
    
    String query;
    Boolean quaterly;
    global BatchAccountHealthscoreKeys() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        quaterly = false;
        query = 'select Id, Name, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recent_Searches__c, Recent_Paid_Out_Searches__c, Number_of_Clients__c, Penetration_Key__c, Engagement_Key__c, Number_of_Members_Champions__c, Spread_Key__c from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
    }

    global BatchAccountHealthscoreKeys(String a_query) {
        query = a_query;
        quaterly = false;
    }

    global BatchAccountHealthscoreKeys(Boolean fullOperation) {
        quaterly = fullOperation;
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        query = 'select Id, Name, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recent_Searches__c, Recent_Paid_Out_Searches__c, Number_of_Clients__c, Penetration_Key__c, Engagement_Key__c, Number_of_Members_Champions__c, Spread_Key__c from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
    }

    global BatchAccountHealthscoreKeys(String a_query, Boolean fullOperation) {
        quaterly = fullOperation;
        query = a_query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<AggregateResult> metricsAggregate = [select Count(Id) numOpps, AVG(SearchedAmount__c) monetaryKey, Introducer_new__c introId
                                    From Opportunity
                                    Where Introducer_new__c in :scope and Secured__c = false
                                    Group By Introducer_new__c];
        List<AggregateResult> metricsSecuredAggregate = [select Count(Id) numOpps, AVG(SearchedAmount__c) monetaryKey, Introducer_new__c introId
                                    From Opportunity
                                    Where Introducer_new__c in :scope and Secured__c = true
                                    Group By Introducer_new__c];
        List<AggregateResult> metrics90daysAggregate = [select Count(Id) recentSearches, Count_Distinct(Introducer_Contact__c) recentActiveMembers, Introducer_new__c introId 
                                            From Opportunity 
                                            Where Introducer_new__c in :scope and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 
                                            Group By Introducer_new__c];
        List<AggregateResult> paidOutMetrics90daysAggregate = [select Count(Id) recentSearches, Introducer_new__c introId 
                                            From Opportunity 
                                            Where Introducer_new__c in :scope and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and StageName = 'Paid Out' 
                                            Group By Introducer_new__c];
        List<AggregateResult> penetrationMetricsAggregate = [select Count(Id) yearSearches, Introducer_new__c introId
                                            From Opportunity
                                            Where Introducer_new__c in :scope and DAY_ONLY(CreatedDate) = LAST_N_DAYS:365
                                            Group By Introducer_new__c];
        List<AggregateResult> engagementMetricsAggregate = [select Count(Id) productsSearches, Introducer_new__c introId
                                            From Opportunity
                                            Where Introducer_new__c in :scope and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and StageName = 'Paid Out' and PaidProductType__c != 1
                                            Group By Introducer_new__c];
        List<AggregateResult> memberContactsAggregate = [select Count(Id) members, AccountId accId
                                            From Contact
                                            Where Role__c='Member'
                                            Group By AccountId];
        
        Map<Id, AggregateResult> metrics = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> metricsSecured = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> metrics90Days = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> paidOutMetrics90Days = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> penetrationMetric = new Map<Id, AggregateResult>();
        Map<Id, AggregateResult> engagementMetric = new Map<Id, AggregateResult>();
        Map<Id, Integer> membersPerAccount = new Map<Id, Integer>();

        for(AggregateResult res : metricsAggregate)
        {
            metrics.put((Id)res.get('introId'), res);
        }

        for(AggregateResult res : metricsSecuredAggregate)
        {
            metricsSecured.put((Id)res.get('introId'), res);
        }

        for(AggregateResult res : metrics90daysAggregate)
        {
            metrics90Days.put((Id)res.get('introId'), res);
        }

        for(AggregateResult res : paidOutMetrics90daysAggregate)
        {
            paidOutMetrics90Days.put((Id)res.get('introId'), res);
        }

        for(AggregateResult res : penetrationMetricsAggregate)
        {
            penetrationMetric.put((Id)res.get('introId'), res);
        }

        for(AggregateResult res : engagementMetricsAggregate)
        {
            engagementMetric.put((Id)res.get('introId'), res);
        }

        for(AggregateResult res : memberContactsAggregate)
        {
            membersPerAccount.put((Id)res.get('accId'), (Integer)res.get('members'));
        }

        for(Account acc : scope)
        {
            system.debug(acc);

            Integer recentSearches = (metrics90Days.containsKey(acc.Id)) ? (Integer) metrics90Days.get(acc.Id).get('recentSearches') : 0;
            Integer recentActiveMembers = (metrics90Days.containsKey(acc.Id)) ? (Integer) metrics90Days.get(acc.Id).get('recentActiveMembers') : 0;
            Integer recentPaidOutSearches = (paidOutMetrics90Days.containsKey(acc.Id)) ? (Integer) paidOutMetrics90Days.get(acc.Id).get('recentSearches') : 0;
            Integer yearSearches = (penetrationMetric.containsKey(acc.Id)) ? (Integer) penetrationMetric.get(acc.Id).get('yearSearches') : 0;
            Integer productsSearches = (engagementMetric.containsKey(acc.Id)) ? (Integer) engagementMetric.get(acc.Id).get('productsSearches') : 0;
            Integer members = (membersPerAccount.containsKey(acc.Id)) ? (Integer) membersPerAccount.get(acc.Id) : 0;

            acc.Monetary_Key_Secured__c = (metricsSecured.containsKey(acc.Id)) ? (Decimal) metricsSecured.get(acc.Id).get('monetaryKey') : 0;
            acc.Monetary_Key_Unsecured__c = (metrics.containsKey(acc.Id)) ? (Decimal) metrics.get(acc.Id).get('monetaryKey') : 0;
            acc.Monetary_Key_Secured__c = (acc.Monetary_Key_Secured__c != null) ? acc.Monetary_Key_Secured__c : 0;
            acc.Monetary_Key_Unsecured__c = (acc.Monetary_Key_Unsecured__c != null) ? acc.Monetary_Key_Unsecured__c : 0;
            if(acc.Number_of_Clients__c == null) acc.Number_of_Clients__c = 0;
            acc.Penetration_Key__c = (acc.Number_of_Clients__c != 0) ? yearSearches / (acc.Number_of_Clients__c * 0.07) : 0;
            if(quaterly) {
                acc.Recent_Searches__c = recentSearches;
                acc.Recent_Paid_Out_Searches__c = recentPaidOutSearches;
                acc.Engagement_Key__c = (recentSearches != 0) ? productsSearches / recentSearches : 0;
                acc.Spread_Key__c = (members != 0) ? recentActiveMembers / members : 0;
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
        BatchPartnerHealthScore job = new BatchPartnerHealthScore(quaterly);
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}