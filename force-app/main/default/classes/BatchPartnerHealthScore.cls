global class BatchPartnerHealthScore implements Database.Batchable<sObject> {
    String query;
    Boolean quaterly;
    global BatchPartnerHealthScore() {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        quaterly = false;
        query = 'select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=\'' + introducerRecordTypeId + '\'';
    }

    global BatchPartnerHealthScore(Boolean a_quaterly) {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        quaterly = a_quaterly;
        query = 'select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=\'' + introducerRecordTypeId + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<Id> fundingSearchesTypesIds = new Set<Id>();
        fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId());
        fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId());
        List<AggregateResult> recentSearchesZone1 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 1];
        List<AggregateResult> recentSearchesZone2 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 2];
        List<AggregateResult> recentSearchesZone3 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 3];
        List<AggregateResult> recentSearchesZone4 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 4];

        List<AggregateResult> recentPaidSearchesZone1 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where StageName = 'Paid Out' and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 1];
        List<AggregateResult> recentPaidSearchesZone2 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where StageName = 'Paid Out' and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 2];
        List<AggregateResult> recentPaidSearchesZone3 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where StageName = 'Paid Out' and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 3];
        List<AggregateResult> recentPaidSearchesZone4 = [select Count(Id) recent, Count_Distinct(Introducer_new__c) intros from Opportunity where StageName = 'Paid Out' and DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and Introducer_Zone__c = 4];

        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();

        List<AggregateResult> monetaryAggregate1 = [select AVG(Monetary_Key_Unsecured__c) monetaryUD, AVG(Monetary_Key_Secured__c) monetarySD from Account where Zone__c=1 and RecordTypeId = :introducerRecordTypeId];
        List<AggregateResult> monetaryAggregate2 = [select AVG(Monetary_Key_Unsecured__c) monetaryUD, AVG(Monetary_Key_Secured__c) monetarySD from Account where Zone__c=2 and RecordTypeId = :introducerRecordTypeId];
        List<AggregateResult> monetaryAggregate3 = [select AVG(Monetary_Key_Unsecured__c) monetaryUD, AVG(Monetary_Key_Secured__c) monetarySD from Account where Zone__c=3 and RecordTypeId = :introducerRecordTypeId];
        List<AggregateResult> monetaryAggregate4 = [select AVG(Monetary_Key_Unsecured__c) monetaryUD, AVG(Monetary_Key_Secured__c) monetarySD from Account where Zone__c=4 and RecordTypeId = :introducerRecordTypeId];

        for(Account acc : scope)
        {
            Double recencyKey = 0.0, zoneFactor = 0.01, recencyZone = 0.0;
            Decimal monetarySD, monetaryUD;
            Integer intros = 0, recentSearches = 0, recentPaidSearches = 0;
            Integer zone = Integer.valueOf(acc.Zone__c);
            switch on zone {
                when 1 {
                    intros = (Integer)recentSearchesZone1[0].get('intros');
                    recentSearches = (Integer) recentSearchesZone1[0].get('recent');
                    recentPaidSearches = (Integer) recentPaidSearchesZone1[0].get('recent');
                    zoneFactor = 0.01;
                    monetarySD = (Decimal)monetaryAggregate1[0].get('monetarySD');
                    monetaryUD = (Decimal)monetaryAggregate1[0].get('monetaryUD');
                }
                when 2 {
                    intros = (Integer)recentSearchesZone2[0].get('intros');
                    recentSearches = (Integer) recentSearchesZone2[0].get('recent');
                    recentPaidSearches = (Integer) recentPaidSearchesZone2[0].get('recent');
                    zoneFactor = 0.01;
                    monetarySD = (Decimal)monetaryAggregate2[0].get('monetarySD');
                    monetaryUD = (Decimal)monetaryAggregate2[0].get('monetaryUD');
                }
                when 3 {
                    intros = (Integer)recentSearchesZone3[0].get('intros');
                    recentSearches = (Integer) recentSearchesZone3[0].get('recent');
                    recentPaidSearches = (Integer) recentPaidSearchesZone3[0].get('recent');
                    zoneFactor = 0.05;
                    monetarySD = (Decimal)monetaryAggregate3[0].get('monetarySD');
                    monetaryUD = (Decimal)monetaryAggregate3[0].get('monetaryUD');
                }
                when 4 {
                    intros = (Integer)recentSearchesZone4[0].get('intros');
                    recentSearches = (Integer) recentSearchesZone4[0].get('recent');
                    recentPaidSearches = (Integer) recentPaidSearchesZone4[0].get('recent');
                    zoneFactor = 0.1;
                    monetarySD = (Decimal)monetaryAggregate4[0].get('monetarySD');
                    monetaryUD = (Decimal)monetaryAggregate4[0].get('monetaryUD');
                }
            }

            if(quaterly) {
                recencyZone = (intros != 0) ? recentSearches / intros : recentSearches;
                recencyKey = (acc.Recent_Searches__c != null) ? ((recencyZone != 0) ? 1.0 * acc.Recent_Searches__c / recencyZone : 0) : 0;
                Double companyConversionRate = (recentSearches != 0) ? 1.0 * recentPaidSearches / recentSearches : 0;

                Double rateKey = (acc.Conversion_Rate_Key__c != null) ? ((companyConversionRate != 0) ? acc.Conversion_Rate_Key__c / companyConversionRate : 0) : 0;

                if(rateKey > 0.8) acc.Conversion_Rate__c = 5;
                else if(rateKey > 0.6) acc.Conversion_Rate__c = 4;
                else if(rateKey > 0.4) acc.Conversion_Rate__c = 3;
                else if(rateKey > 0.2) acc.Conversion_Rate__c = 2;
                else acc.Conversion_Rate__c = 1;
                
                if(recencyKey > 0.8) acc.Recency__c = 5;
                else if(recencyKey > 0.6) acc.Recency__c = 4;
                else if(recencyKey > 0.4) acc.Recency__c = 3;
                else if(recencyKey > 0.2) acc.Recency__c = 2;
                else acc.Recency__c = 1;
            }

            if(acc.Penetration_Key__c == null) acc.Penetration__c = 1;
            else if(acc.Penetration_Key__c > 0.8) acc.Penetration__c = 5;
            else if(acc.Penetration_Key__c > 0.6) acc.Penetration__c = 4;
            else if(acc.Penetration_Key__c > 0.4) acc.Penetration__c = 3;
            else if(acc.Penetration_Key__c > 0.2) acc.Penetration__c = 2;
            else acc.Penetration__c = 1;

            Double cutOff = (acc.Number_of_Clients__c != null) ? acc.Number_of_Clients__c * zoneFactor : 0;
            Double attachment = (cutOff != 0) ? ((acc.Managed_Clients_Connected__c != null) ? acc.Managed_Clients_Connected__c / cutOff : 0) : 0;
            
            if(attachment > 0.8) acc.Attachment__c = 5;
            else if(attachment > 0.6) acc.Attachment__c = 4;
            else if(attachment > 0.4) acc.Attachment__c = 3;
            else if(attachment > 0.2) acc.Attachment__c = 2;
            else acc.Attachment__c = 1;

            Double monetaryIndicatorS = (acc.Monetary_Key_Secured__c != null) ? ((monetarySD != null && monetarySD != 0) ? acc.Monetary_Key_Secured__c / monetarySD : 0) : 0;
            Double monetaryIndicatorU = (acc.Monetary_Key_Unsecured__c != null) ? ((monetaryUD != null && monetaryUD != 0) ? acc.Monetary_Key_Unsecured__c / monetaryUD : 0) : 0;

            if(monetaryIndicatorS > 0.8) acc.Monetary_Secured__c = 5;
            else if(monetaryIndicatorS > 0.6) acc.Monetary_Secured__c = 4;
            else if(monetaryIndicatorS > 0.4) acc.Monetary_Secured__c = 3;
            else if(monetaryIndicatorS > 0.2) acc.Monetary_Secured__c = 2;
            else acc.Monetary_Secured__c = 1;

            if(monetaryIndicatorU > 0.8) acc.Monetary_Unsecured__c = 5;
            else if(monetaryIndicatorU > 0.6) acc.Monetary_Unsecured__c = 4;
            else if(monetaryIndicatorU > 0.4) acc.Monetary_Unsecured__c = 3;
            else if(monetaryIndicatorU > 0.2) acc.Monetary_Unsecured__c = 2;
            else acc.Monetary_Unsecured__c = 1;
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