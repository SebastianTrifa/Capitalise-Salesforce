@isTest
private class RestLeadConvertTest {
    static testMethod void testRest() {
        
        Lead newlead = new Lead();
        newlead.LastName = 'LeadTest';
        newlead.CapitaliseExtId__c = '1234';
        newlead.Company = 'TestCompany';
        insert newlead;
        
        WebHook_URL__c weburl = new WebHook_URL__c();
        weburl.URL__c ='www.capitalise.com';
        weburl.Capitalise_Security_Token__c='asgas1245';
        weburl.password__c='password123';
        insert weburl;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/ConvertLead';
        req.addParameter('AccountID', '1233');
        req.addParameter('ContactId', '1233');
        req.addParameter('leadId', '1234');
        req.addParameter('OppId', '5678');
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestLeadConvert.doGet();
        Test.stopTest();
        
    }

}