global class BatchUpdatePaidOutFundingSearches implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
    
    global BatchUpdatePaidOutFundingSearches(String a_query) {
        query = a_query;
    }

    global BatchUpdatePaidOutFundingSearches() {
        query = 'select Id, CapitaliseExtId__c, PaidValue__c, PaidProductType__c, Has_Invoice_Finance__c, Confirmed_Funding_Amount__c from Opportunity where StageName = \'Paid Out\' and PaidValue__c = null and CapitaliseExtId__c != null and CapitaliseExtId__c != \'\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        for(Opportunity opp : scope)
        {
            Map<String, Object> opportunityDetails = new Map<String, Object>();
            Boolean success = false;
            if(Test.isRunningTest())
            {
                String jsonResponse = '{"profile":{"id":13655,"status":10,"amount":"150000.00","matches":[{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":16,"invoiceFinance":{"maximumCreditLine":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z"},"products":[16],"status":3,"matchCompletion":100},{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":1,"termLoan":{"maximumAmount":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z"},"products":[1],"status":3,"matchCompletion":100},{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":4,"assetFinance":{"advanceAmount":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z"},"products":[4],"status":3,"matchCompletion":100},{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":8,"merchantCashAdvance":{"fundingAmount":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z"},"products":[8],"status":3,"matchCompletion":100},{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":64,"tradeFinance":{"maximumCreditLine":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z"},"products":[64],"status":3,"matchCompletion":100},{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":128,"propertyFinance":{"amount":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z"},"products":[128],"status":3,"matchCompletion":100},{"id":56335,"offer":{},"products":[128],"status":3,"matchCompletion":100}],"period":36,"statusLabel":"Paid out","author":{"id":14401,"name":"Kipp Noble","email":"kipp.noble@capitalise.com","userType":"introducer","entity":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"champion":true,"team":{"id":3423,"name":"No Team"}},"manager":{"id":14401,"name":"Kipp Noble","email":"kipp.noble@capitalise.com","userType":"introducer","entity":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"champion":true,"team":{"id":3423,"name":"No Team"}},"useOfFunds":"Day to day cashflow","urgency":"ASAP","governmentBacked":false,"contactTime":0,"client":{"id":4088,"entityId":4088,"companyName":"EXCELR8 MOTORSPORT LLP","companyNumber":"OC352448","entityType":0,"createdAt":null,"updatedAt":null,"contentAvailable":null,"businessId":3368,"companyType":2,"companyAddress":{"address":"Unit 1 Roy Humphrey Site A140 Norwich Ipswich Road, Brome, Brome, Eye","postalCode":"IP23 8AW"},"contactName":"Antony Williams","contactEmail":"antony@excelr8motorsport.com","contactPhone":"01379 870880","contactPosition":null,"userLastInvitedAt":null,"revenue":"1602815","profitNet":"63537","netAssets":null,"fixedAssets":"450346","integratedFrom":null,"integratedCompanyName":null},"introducer":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"communicationPreference":2,"isTest":false,"requireDisclosureCommission":false,"disclosureCommissionConfirmedOn":null,"disclosureCommissionConfirmedBy":null,"consultant":{"id":14401,"name":"Kipp Noble","email":"kipp.noble@capitalise.com","userType":"introducer","entity":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"champion":true,"team":{"id":3423,"name":"No Team"}},"profileCompletion":100,"profileDocumentTypes":[{"id":18,"name":"1 year of filed accounts","required":true,"other":false},{"id":19,"name":"Management accounts","required":false,"other":false},{"id":44,"name":"Aged debtor report","required":true,"other":false},{"id":29,"name":"Last 6 months bank statements","required":true,"other":false},{"id":41,"name":"Sample invoice(s)","required":false,"other":false},{"id":25,"name":"2 years of filed accounts","required":false,"other":false},{"id":39,"name":"Supporting information","required":false,"other":false}],"followers":[],"private":false,"createdAt":1584719084,"updatedAt":1593766807,"statusMatchesCount":2,"allMatchesCount":4}}';
                opportunityDetails = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
                success = true;
            } 
            else
            {
                opportunityDetails = CapAPPCallouts.GetSearchProfileByExtId(opp.CapitaliseExtId__c);
                success =  (Boolean)opportunityDetails.get('success');
            } 
            
            
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
                                opp.PaidProductType__c = productType;
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
                            else{
                                List<Object> products = (List<Object>)match.get('products');
                                if(products.size() > 0) opp.PaidProductType__c = (Integer)products[0];
                                opp.PaidValue__c = Decimal.ValueOf((String)profile.get('amount'));
                                opp.Has_Invoice_Finance__c = (opp.PaidProductType__c == 16) ? true : false;
                            }
                            opp.Confirmed_Funding_Amount__c = opp.PaidValue__c;
                        }
                    }
                }
            }
        }
        Database.SaveResult[] dbsr = Database.update(scope, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Opportunity ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}