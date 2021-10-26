public with sharing class AccountsPartnerHealthscore {

    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }

    private static String serviceKeyProd = 'bb3639473d12b7f0b68851fc02518aed';
    private static String serviceKeyUAT = '9fe51f7a39f48cc4e5667878389020e0';
    private static String serviceUrlProd = 'https://prod-01.uksouth.logic.azure.com:443/workflows/7305205f29504da189d88c608dc6ab72/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=S9EwR7WdND3VlzWV2wr0tcYqWCH78eY_4jxQR38DHBM';
    private static String serviceUrlUAT = 'https://prod-21.uksouth.logic.azure.com:443/workflows/fb7f61413a1544929560856cd3280661/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=DAxlrfd2zootiEtgZVi8PlI5n17oEaDI61XNqGKvs0U';

    public static void ComputeAccountsPartnerHealthscoreMonetary(String jobId) {
        String serviceUrl, serviceKey;

        if(runningInASandbox)
        {
            serviceUrl = serviceUrlUAT;
            serviceKey = serviceKeyUAT;
        }
        else
        {
            serviceUrl = serviceUrlProd;
            serviceKey = serviceKeyProd;
        }

        system.debug('Partner HealthScore Monetary (): ' + jobId);
        
        List<Account> introducers = ZoneMonetaryComputations();

        JSONGenerator writer = JSON.createGenerator(false);
        writer.writeStartObject();
        writer.writeStringField('key', serviceKey);
        writer.writeFieldName('results');
        writer.writeStartArray();

        for(Account intro : introducers)
        {
            writer.writeStartObject();
            writer.writeStringField('type', 'Account');
            writer.writeIdField('id', intro.Id);
            writer.writeStringField('jobid', jobId);
            writer.writeFieldName('data');
            writer.writeStartObject();
            writer.writeNumberField('Monetary_Secured__c', intro.Monetary_Secured__c);
            writer.writeNumberField('Monetary_Unsecured__c', intro.Monetary_Unsecured__c);
            writer.writeEndObject();
            writer.writeEndObject();
        }

        writer.writeEndArray();
        writer.writeEndObject();

        String payload = writer.getAsString();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(serviceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        request.setBody(payload);
        if(jobId != 'TestRun' && !Test.isRunningTest()) HttpResponse response = http.send(request);
    }

    public static void ComputeAccountsPartnerHealthscoreRecency(String jobId) {
        String serviceUrl, serviceKey;

        if(runningInASandbox)
        {
            serviceUrl = serviceUrlUAT;
            serviceKey = serviceKeyUAT;
        }
        else
        {
            serviceUrl = serviceUrlProd;
            serviceKey = serviceKeyProd;
        }

        List<Account> introducers = ZoneRecencyComputations();

        JSONGenerator writer = JSON.createGenerator(false);
        writer.writeStartObject();
        writer.writeStringField('key', serviceKey);
        writer.writeFieldName('results');
        writer.writeStartArray();

        for(Account intro : introducers)
        {
            writer.writeStartObject();
            writer.writeStringField('type', 'Account');
            writer.writeIdField('id', intro.Id);
            writer.writeStringField('jobid', jobId);
            writer.writeFieldName('data');
            writer.writeStartObject();
            writer.writeNumberField('Recency__c', intro.Recency__c);
            writer.writeEndObject();
            writer.writeEndObject();
        }

        writer.writeEndArray();
        writer.writeEndObject();

        String payload = writer.getAsString();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(serviceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        request.setBody(payload);
        if(jobId != 'TestRun' && !Test.isRunningTest()) HttpResponse response = http.send(request);
    }

    public static void ComputeAccountsPartnerHealthscoreConversion(String jobId) {
        String serviceUrl, serviceKey;

        if(runningInASandbox)
        {
            serviceUrl = serviceUrlUAT;
            serviceKey = serviceKeyUAT;
        }
        else
        {
            serviceUrl = serviceUrlProd;
            serviceKey = serviceKeyProd;
        }

        List<Account> introducers = ZoneConversionComputations();

        JSONGenerator writer = JSON.createGenerator(false);
        writer.writeStartObject();
        writer.writeStringField('key', serviceKey);
        writer.writeFieldName('results');
        writer.writeStartArray();

        for(Account intro : introducers)
        {
            writer.writeStartObject();
            writer.writeStringField('type', 'Account');
            writer.writeIdField('id', intro.Id);
            writer.writeStringField('jobid', jobId);
            writer.writeFieldName('data');
            writer.writeStartObject();
            writer.writeNumberField('Conversion_Rate__c', intro.Conversion_Rate__c);
            writer.writeEndObject();
            writer.writeEndObject();
        }

        writer.writeEndArray();
        writer.writeEndObject();

        String payload = writer.getAsString();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(serviceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        request.setBody(payload);
        if(jobId != 'TestRun' && !Test.isRunningTest()) HttpResponse response = http.send(request);
    }

    public static void ComputeAccountsPartnerHealthscorePenetrationAttachment(String jobId) {
        String serviceUrl, serviceKey;

        if(runningInASandbox)
        {
            serviceUrl = serviceUrlUAT;
            serviceKey = serviceKeyUAT;
        }
        else
        {
            serviceUrl = serviceUrlProd;
            serviceKey = serviceKeyProd;
        }

        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        List<Account> introducers = [select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=:introducerRecordTypeId];

        introducers = ComputeAttachment(introducers);
        introducers = ComputePenetration(introducers);

        JSONGenerator writer = JSON.createGenerator(false);
        writer.writeStartObject();
        writer.writeStringField('key', serviceKey);
        writer.writeFieldName('results');
        writer.writeStartArray();

        for(Account intro : introducers)
        {
            writer.writeStartObject();
            writer.writeStringField('type', 'Account');
            writer.writeIdField('id', intro.Id);
            writer.writeStringField('jobid', jobId);
            writer.writeFieldName('data');
            writer.writeStartObject();
            writer.writeNumberField('Penetration__c', intro.Penetration__c);
            writer.writeNumberField('Attachment__c', intro.Attachment__c);
            writer.writeEndObject();
            writer.writeEndObject();
        }

        writer.writeEndArray();
        writer.writeEndObject();

        String payload = writer.getAsString();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(serviceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        request.setBody(payload);
        if(jobId != 'TestRun' && !Test.isRunningTest()) HttpResponse response = http.send(request);
    }

    public static void ComputeAccountsPartnerHealthscoreSpread(String jobId) {
        String serviceUrl, serviceKey;

        if(runningInASandbox)
        {
            serviceUrl = serviceUrlUAT;
            serviceKey = serviceKeyUAT;
        }
        else
        {
            serviceUrl = serviceUrlProd;
            serviceKey = serviceKeyProd;
        }

        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        List<Account> introducers = [select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=:introducerRecordTypeId];

        introducers = ComputeSpread(introducers);

        JSONGenerator writer = JSON.createGenerator(false);
        writer.writeStartObject();
        writer.writeStringField('key', serviceKey);
        writer.writeFieldName('results');
        writer.writeStartArray();

        for(Account intro : introducers)
        {
            writer.writeStartObject();
            writer.writeStringField('type', 'Account');
            writer.writeIdField('id', intro.Id);
            writer.writeStringField('jobid', jobId);
            writer.writeFieldName('data');
            writer.writeStartObject();
            writer.writeNumberField('Spread__c', intro.Spread__c);
            writer.writeEndObject();
            writer.writeEndObject();
        }

        writer.writeEndArray();
        writer.writeEndObject();

        String payload = writer.getAsString();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(serviceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        request.setBody(payload);
        if(jobId != 'TestRun' && !Test.isRunningTest()) HttpResponse response = http.send(request);
    }

    public static void ComputeAccountsPartnerHealthscoreEngagement(String jobId) {
        String serviceUrl, serviceKey;

        if(runningInASandbox)
        {
            serviceUrl = serviceUrlUAT;
            serviceKey = serviceKeyUAT;
        }
        else
        {
            serviceUrl = serviceUrlProd;
            serviceKey = serviceKeyProd;
        }

        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        List<Account> introducers = [select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=:introducerRecordTypeId];

        introducers = ComputeEngagement(introducers);

        JSONGenerator writer = JSON.createGenerator(false);
        writer.writeStartObject();
        writer.writeStringField('key', serviceKey);
        writer.writeFieldName('results');
        writer.writeStartArray();

        for(Account intro : introducers)
        {
            writer.writeStartObject();
            writer.writeStringField('type', 'Account');
            writer.writeIdField('id', intro.Id);
            writer.writeStringField('jobid', jobId);
            writer.writeFieldName('data');
            writer.writeStartObject();
            writer.writeNumberField('Engagement__c', intro.Engagement__c);
            writer.writeEndObject();
            writer.writeEndObject();
        }

        writer.writeEndArray();
        writer.writeEndObject();

        String payload = writer.getAsString();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(serviceUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        request.setBody(payload);
        if(jobId != 'TestRun' && !Test.isRunningTest()) HttpResponse response = http.send(request);
    }

    private static List<Account> ZoneConversionComputations()
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        List<Account> introducersZone1 = new List<Account>();
        List<Account> introducersZone2 = new List<Account>();
        List<Account> introducersZone3 = new List<Account>();
        List<Account> introducersZone4 = new List<Account>();
        List<Account> introducers = new List<Account>();

        for(Account acc : [select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=:introducerRecordTypeId])
        {
            if(acc.Zone__c == 1) {
                introducersZone1.add(acc);
            }
            else if(acc.Zone__c == 2) {
                introducersZone2.add(acc);
            }
            else if(acc.Zone__c == 3) {
                introducersZone3.add(acc);
            }
            else if(Acc.Zone__c == 4) {
                introducersZone4.add(acc);
            }
        }

        introducersZone1 = ComputeConversionRate(introducersZone1);
        introducersZone2 = ComputeConversionRate(introducersZone2);
        introducersZone3 = ComputeConversionRate(introducersZone3);
        introducersZone4 = ComputeConversionRate(introducersZone4);

        introducers.addAll(introducersZone1);
        introducers.addAll(introducersZone2);
        introducers.addAll(introducersZone3);
        introducers.addAll(introducersZone4);

        return introducers;
    }

    private static List<Account> ZoneRecencyComputations()
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        List<Account> introducersZone1 = new List<Account>();
        List<Account> introducersZone2 = new List<Account>();
        List<Account> introducersZone3 = new List<Account>();
        List<Account> introducersZone4 = new List<Account>();
        List<Account> introducers = new List<Account>();

        for(Account acc : [select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=:introducerRecordTypeId])
        {
            if(acc.Zone__c == 1) {
                introducersZone1.add(acc);
            }
            else if(acc.Zone__c == 2) {
                introducersZone2.add(acc);
            }
            else if(acc.Zone__c == 3) {
                introducersZone3.add(acc);
            }
            else if(Acc.Zone__c == 4) {
                introducersZone4.add(acc);
            }
        }

        introducersZone1 = ComputeRecency(introducersZone1);
        introducersZone2 = ComputeRecency(introducersZone2);
        introducersZone3 = ComputeRecency(introducersZone3);
        introducersZone4 = ComputeRecency(introducersZone4);

        introducers.addAll(introducersZone1);
        introducers.addAll(introducersZone2);
        introducers.addAll(introducersZone3);
        introducers.addAll(introducersZone4);

        return introducers;
    }

    private static List<Account> ZoneMonetaryComputations()
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        List<Account> introducersZone1 = new List<Account>();
        List<Account> introducersZone2 = new List<Account>();
        List<Account> introducersZone3 = new List<Account>();
        List<Account> introducersZone4 = new List<Account>();
        List<Account> introducers = new List<Account>();
        system.debug('Zone Monetary Computations');

        for(Account acc : [select Id, Zone__c, Monetary_Secured__c, Monetary_Unsecured__c, Monetary_Key_Secured__c, Monetary_Key_Unsecured__c, Recency__c, Recent_Searches__c, Penetration_Key__c, Penetration__c, Managed_Clients_Connected__c, Attachment__c, Conversion_Rate_Key__c, Conversion_Rate__c, Engagement_Key__c, Engagement__c, Spread_Key__c, Spread__c, Number_of_Clients__c from Account where RecordTypeId=:introducerRecordTypeId])
        {
            if(acc.Zone__c == 1) {
                introducersZone1.add(acc);
            }
            else if(acc.Zone__c == 2) {
                introducersZone2.add(acc);
            }
            else if(acc.Zone__c == 3) {
                introducersZone3.add(acc);
            }
            else if(Acc.Zone__c == 4) {
                introducersZone4.add(acc);
            }
        }

        system.debug('Zone 1: ');

        introducersZone1 = (introducersZone1.size() != 0) ? ComputeMonetary(introducersZone1) : introducersZone1;
        system.debug('Zone 2: ');
        introducersZone2 = (introducersZone2.size() != 0) ? ComputeMonetary(introducersZone2) : introducersZone2;
        system.debug('Zone 3: ');
        introducersZone3 = (introducersZone3.size() != 0) ? ComputeMonetary(introducersZone3) : introducersZone3;
        system.debug('Zone 4: ');
        introducersZone4 = (introducersZone4.size() != 0) ? ComputeMonetary(introducersZone4) : introducersZone4;

        introducers.addAll(introducersZone1);
        introducers.addAll(introducersZone2);
        introducers.addAll(introducersZone3);
        introducers.addAll(introducersZone4);

        return introducers;
    }

    private static List<Account> ComputeRecency(List<Account> accounts) {
        
        //Set<Id> fundingSearchesTypesIds = new Set<Id>();
        //fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId());
        //fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId());
        List<AggregateResult> recentSearchesAgg = [select Count(Id) recent from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90];// and RecordTypeId in :fundingSearchesTypesIds
        Integer recentSearches = (Integer) recentSearchesAgg[0].get('recent');

        for(Account acc : accounts)
        {
            Double recencyKey = (acc.Recent_Searches__c != null) ? ((recentSearches != 0) ? 1.0 * acc.Recent_Searches__c / recentSearches : 0) : 0;
            
            if(recencyKey > 0.8) acc.Recency__c = 5;
            else if(recencyKey > 0.6) acc.Recency__c = 4;
            else if(recencyKey > 0.4) acc.Recency__c = 3;
            else if(recencyKey > 0.2) acc.Recency__c = 2;
            else acc.Recency__c = 1;
        }

        return accounts;
    }

    private static List<Account> ComputeMonetary(List<Account> accounts)
    {

        Id fundingSearchesTypesIds = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchesTypesIds = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();

        Decimal monetarySD = 0, monetaryUD = 0;

        for(Account acc : accounts)
        {
            monetarySD += (acc.Monetary_Key_Secured__c != null) ? acc.Monetary_Key_Secured__c : 0;
            monetaryUD += (acc.Monetary_Key_Unsecured__c != null) ? acc.Monetary_Key_Unsecured__c : 0;
        }

        monetarySD /= accounts.size();
        monetaryUD /= accounts.size();
        system.debug('Accounts: ' + accounts.size());
        system.debug('Secured monetary average: ' + monetarySD);
        system.debug('Unsecured monetary average: ' + monetaryUD);

        for(Account acc : accounts)
        {
            Double monetaryIndicatorS = (acc.Monetary_Key_Secured__c != null) ? acc.Monetary_Key_Secured__c / monetarySD : 0;
            Double monetaryIndicatorU = (acc.Monetary_Key_Unsecured__c != null) ? acc.Monetary_Key_Unsecured__c / monetaryUD : 0;

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

        return accounts;
    }

    private static List<Account> ComputePenetration(List<Account> accounts) {
        for(Account acc : accounts)
        {
            if(acc.Penetration_Key__c == null) acc.Penetration__c = 1;
            if(acc.Penetration_Key__c > 0.8) acc.Penetration__c = 5;
            else if(acc.Penetration_Key__c > 0.6) acc.Penetration__c = 4;
            else if(acc.Penetration_Key__c > 0.4) acc.Penetration__c = 3;
            else if(acc.Penetration_Key__c > 0.2) acc.Penetration__c = 2;
            else acc.Penetration__c = 1;
        }

        return accounts;
    }

    private static List<Account> ComputeConversionRate(List<Account> accounts) {
        List<AccountHealthScoreSorter> sortedAccounts = new List<AccountHealthScoreSorter>();
        Map<Id, Account> accMap = new Map<Id, Account>();

        Set<Id> fundingSearchesTypesIds = new Set<Id>();
        fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId());
        fundingSearchesTypesIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId());
        List<AggregateResult> recentSearchesAgg = [select Count(Id) recent from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds];
        List<AggregateResult> recentPaidOutSearchesAgg = [select Count(Id) recent from Opportunity where DAY_ONLY(CreatedDate) = LAST_N_DAYS:90 and RecordTypeId in :fundingSearchesTypesIds and StageName = 'Paid Out'];
        
        Integer recentSearches = (Integer) recentSearchesAgg[0].get('recent');
        Integer recentPaidOutSearches = (Integer) recentPaidOutSearchesAgg[0].get('recent');
        Double companyConversionRate = 1.0 * recentPaidOutSearches / recentSearches;

        for(Account acc : accounts)
        {
            Double rateKey = (acc.Conversion_Rate_Key__c != null) ? acc.Conversion_Rate_Key__c / companyConversionRate : 0;

            if(rateKey > 0.8) acc.Conversion_Rate__c = 5;
            else if(rateKey > 0.6) acc.Conversion_Rate__c = 4;
            else if(rateKey > 0.4) acc.Conversion_Rate__c = 3;
            else if(rateKey > 0.2) acc.Conversion_Rate__c = 2;
            else acc.Conversion_Rate__c = 1;
        }

        return accounts;
    }

    private static List<Account> ComputeAttachment(List<Account> accounts) {

        Double zoneFactor = 0.1;
        for(Account acc : accounts)
        {
            if(acc.Zone__c == 4) zoneFactor = 0.1;
            else if(acc.Zone__c == 3) zoneFactor = 0.05;
            else if(acc.Zone__c == 2 || acc.Zone__c == 1) zoneFactor = 0.01;

            Double cutOff = (acc.Number_of_Clients__c != null) ? acc.Number_of_Clients__c * zoneFactor : 0;
            Double attachment = (cutOff != 0) ? ((acc.Managed_Clients_Connected__c != null) ? acc.Managed_Clients_Connected__c / cutOff : 0) : 1;
            
            if(attachment > 0.8) acc.Attachment__c = 5;
            else if(attachment > 0.6) acc.Attachment__c = 4;
            else if(attachment > 0.4) acc.Attachment__c = 3;
            else if(attachment > 0.2) acc.Attachment__c = 2;
            else acc.Attachment__c = 1;
        }

        return accounts;
    }

    private static List<Account> ComputeEngagement(List<Account> accounts) {
        List<AccountHealthScoreSorter> sortedAccounts = new List<AccountHealthScoreSorter>();
        Map<Id, Account> accMap = new Map<Id, Account>();

        Integer quintile = accounts.size() / 5;

        for(Account acc : accounts)
        {
            if(acc.Engagement_Key__c != 0) {
                sortedAccounts.add(new AccountHealthScoreSorter(acc, 'Engagement'));
                accMap.put(acc.Id, acc);
            }
        }

        sortedAccounts.sort();

        for(Integer idx = 0; idx < sortedAccounts.size(); idx++)
        {
            if(quintile == 0)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Engagement__c = idx + 1;
            }
            else if(idx < quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Engagement__c = 1;
            }
            else if(idx < 2 * quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Engagement__c = 2;
            }
            else if(idx < 3 * quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Engagement__c = 3;
            }
            else if(idx < 4 * quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Engagement__c = 4;
            }
            else
            {
                accMap.get(sortedAccounts[idx].acc.Id).Engagement__c = 5;
            }
        }

        for(Account acc : accounts)
        {
            acc.Engagement__c = (accMap.containsKey(acc.Id)) ? accMap.get(acc.Id).Engagement__c : 1;
        }

        return accounts;
    }

    private static List<Account> ComputeSpread(List<Account> accounts) {
        List<AccountHealthScoreSorter> sortedAccounts = new List<AccountHealthScoreSorter>();
        Map<Id, Account> accMap = new Map<Id, Account>();

        Integer quintile = accounts.size() / 5;

        for(Account acc : accounts)
        {
            if(acc.Spread_Key__c != 0) {
                sortedAccounts.add(new AccountHealthScoreSorter(acc, 'Spread'));
                accMap.put(acc.Id, acc);
            }
        }

        sortedAccounts.sort();

        for(Integer idx = 0; idx < sortedAccounts.size(); idx++)
        {
            if(quintile == 0)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Spread__c = idx + 1;
            }
            else if(idx < quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Spread__c = 1;
            }
            else if(idx < 2 * quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Spread__c = 2;
            }
            else if(idx < 3 * quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Spread__c = 3;
            }
            else if(idx < 4 * quintile)
            {
                accMap.get(sortedAccounts[idx].acc.Id).Spread__c = 4;
            }
            else
            {
                accMap.get(sortedAccounts[idx].acc.Id).Spread__c = 5;
            }
        }

        for(Account acc : accounts)
        {
            acc.Spread__c = (accMap.containsKey(acc.Id)) ? accMap.get(acc.Id).Spread__c : 1;
        }

        return accounts;
    }
}