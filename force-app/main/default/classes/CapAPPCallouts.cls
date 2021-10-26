public with sharing class CapAPPCallouts {

    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }

    public static Map<String, String> AuthorizationDetails;
    public static Map<String, String> authDetails {
        get {
            if (AuthorizationDetails == null) {
                AuthorizationDetails = new Map<String, String>();
            }
            return AuthorizationDetails;
        }
        set;
    }

    public static HttpResponse GetAuthenticationToken()
    {
        authDetails.put('password', 'a9rd3bu2WZrjm5xw');
        authDetails.put('email', 'salesforce.api.user@no-reply.capitalise.com');
        String authenticate_url_uat = 'https://prod-15.uksouth.logic.azure.com:443/workflows/6e9b3826ac7849e58f5d94367288192d/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=nv2IgRIQ0Lidt4K16odfcHkeRy8w_pfLUqXNqK0did4';
        String authenticate_url = 'https://prod-08.uksouth.logic.azure.com:443/workflows/f8997c11b2ee46a897d6bda5459e6db4/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=HWJrMTtBY32UhUcXGVSiR8XPBiwD05rp-FAQcac1tXI';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authenticate_url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(20000);
        String jsonAuthDetails = JSON.serialize(authDetails);
        request.setBody('{"email": "salesforce.api.user@no-reply.capitalise.com", "password": "9j@QcsDcc7@4JkK"}');
        HttpResponse response = http.send(request);
        
        return response;
    }

    public static Map<String, Object> GetSearchProfileById(String oppId)
    {
        Map<String, Object> result = new Map<String, Object>();

        List<Opportunity> opps = [select Id, CapitaliseExtId__c from Opportunity where Id=:oppId limit 1];

        if(opps.size() != 0)
        {
            Opportunity opp = opps[0];

            result = GetSearchProfileByExtId(opp.CapitaliseExtId__c);
        }
        else
        {
            result.put('success', false);
            result.put('failureStage', 'querying record');
            result.put('response', 'No existing record with ID: ' + oppId);
        }

        return result;
    }

    public static Map<String, Object> GetSearchProfileByExtId(String ExternalId)
    {
        String uat_endpoint_prefix = 'https://uat.capitalise.com/api/platform/v1/funding/searches/';
        String prod_enpoint_prefix = 'https://capitalise.com/api/platform/v1/funding/searches/';
        String endpoint_suffix = '?includeMatches=true';
        String endpoint_url = prod_enpoint_prefix + ExternalId + endpoint_suffix;

        Boolean gotToken = authDetails.keySet().contains('bearer_token');
        HttpResponse tokenResponse;
        Integer responseStatusCode = -1;
        String tokenResponseBody;
        if(!gotToken)
        {
            tokenResponse = GetAuthenticationToken();
            responseStatusCode = tokenResponse.getStatusCode();
            tokenResponseBody = tokenResponse.getBody();
        }
        
        Map<String, Object> result = new Map<String, Object>();
        

        if(responseStatusCode == 200 || gotToken)
        {
            String tokenstr;
            if(!gotToken)
            {
                String jsonResponse = tokenResponse.getBody();
                Map<String, String> token = new Map<String, String>();
                Map<String, Object> jsonstr = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse); 
                for(String key : jsonstr.keySet())
                    token.put(key, String.valueOf(jsonstr.get(key)));
    
                tokenstr = (String)token.get('access_token');
                authDetails.put('bearer_token', tokenstr);
            }
            else tokenstr = authDetails.get('bearer_token');

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint_url);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + tokenstr);
            request.setTimeout(20000);
            HttpResponse response = http.send(request);

            responseStatusCode = response.getStatusCode();
            String responseBody = response.getBody();

            if(responseStatusCode == 200)
            {
                result.put('profile', (Map<String, Object>)JSON.deserializeUntyped(responseBody));
                result.put('response', responseBody);
                result.put('success', true);
            }
            else {
                result.put('failureStage', 'Read Profile ' + ExternalId);
                result.put('Status Code', responseStatusCode);
                result.put('response', responseBody);
                result.put('success', false);
            }
        }
        else {
            result.put('success', false);
            result.put('failureStage', 'Authentication');
            result.put('Status Code', responseStatusCode);
            result.put('response', tokenResponseBody);
        }
        
        return result;
    }

    @future(callout=true)
    public static void UpdatePaidOutFundingSearches(Set<String> oppsExtIds)
    {
        List<Opportunity> opps = [select Id, CapitaliseExtId__c, PaidValue__c, PaidProductType__c, Has_Invoice_Finance__c, Confirmed_Funding_Amount__c from Opportunity where CapitaliseExtId__c In :oppsExtIds];

        for(Opportunity opp : opps)
        {
            try 
            {
                Map<String, Object> opportunityDetails = GetSearchProfileByExtId(opp.CapitaliseExtId__c);
                Boolean success = (Boolean)opportunityDetails.get('success');
                
                if(success == true)
                {
                    Map<String, Object> profile = (Map<String, Object>)opportunityDetails.get('profile');

                    List<Object> matches = (List<Object>)profile.get('matches');

                    for(Object a_match : matches)
                    {
                        Map<String, Object> match = (Map<String, Object>)a_match;
                        Set<String> matchKeys = match.keySet();

                        if(matchKeys.contains('status'))
                        {
                            Integer status = (Integer)match.get('status');
                            if(status == 3)
                            {
                                Map<String, Object> offer = (Map<String, Object>)match.get('offer');
                                Set<String> offerKeys = offer.keySet();
                                if(offerKeys.size() > 0)
                                {
                                    Integer productType = (Integer)offer.get('productType');
                                    opp.PaidProductType__c = (opp.PaidProductType__c == null) ? productType : opp.PaidProductType__c;
                                    Map<String, Object> terms;
                                    switch on productType {
                                        when 1 {
                                            terms = (Map<String,Object>)offer.get('termLoan');
                                            if(terms != null)    
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? (Decimal)terms.get('maximumAmount') : opp.PaidValue__c;
                                            else
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                        }
                                        when 4 {
                                            terms = (Map<String,Object>)offer.get('assetFinance');
                                            if(terms != null)    
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? (Decimal)terms.get('advanceAmount') : opp.PaidValue__c;
                                            else
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                        }
                                        when 8 {
                                            terms = (Map<String,Object>)offer.get('merchantCashAdvance');
                                            if(terms != null)    
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? (Decimal)terms.get('fundingAmount') : opp.PaidValue__c;
                                            else
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                        }
                                        when 16 {
                                            terms = (Map<String,Object>)offer.get('invoiceFinance');
                                            if(terms != null)    
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? (Decimal)terms.get('maximumCreditLine') : opp.PaidValue__c;
                                            else
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                            opp.Has_Invoice_Finance__c = true;
    
                                        }
                                        when 64 {
                                            terms = (Map<String,Object>)offer.get('tradeFinance');
                                            if(terms != null)    
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? (Decimal)terms.get('maximumCreditLine') : opp.PaidValue__c;
                                            else
                                                opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                        }
                                        when 128 {
                                            terms = (Map<String,Object>)offer.get('propertyFinance');
                                            opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                        }
                                    }   
                                }
                                else
                                {
                                    List<Object> products = (List<Object>)match.get('products');
                                    if(products.size() > 0) opp.PaidProductType__c = (Integer)products[0];
                                    opp.PaidValue__c = (opp.PaidValue__c == null) ? Decimal.ValueOf((String)profile.get('amount')) : opp.PaidValue__c;
                                    opp.Has_Invoice_Finance__c = (opp.PaidProductType__c == 16) ? true : false;
                                }
                                opp.Confirmed_Funding_Amount__c = opp.PaidValue__c;
                            }
                        }
                    }
                }
            }
            catch (Exception e) 
            {        
                System.debug('Error: ' + e.getMessage() + ' LN: ' + e.getLineNumber() + ' at: ' + e.getStackTraceString());
            }
        }
        update opps;
    }
}