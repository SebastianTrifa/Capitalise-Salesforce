@isTest
private class WebHookClassTest {
     @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        // 
        
        list<sObject>triggerNew = new list<sObject>();
         sObject sObj = Schema.getGlobalDescribe().get('Opportunity').newSObject() ;
         triggerNew.add(sObj);
         list<sObject>triggerOld = new list<sObject>();
         triggerOld.add(sObj);
         Webhook.jsonContent(triggerNew, triggerOld);
        WebHook_URL__c wh = new 	WebHook_URL__c();
         wh.URL__c = 'asfasgas';
         insert wh;
         String content = 'asgasgsga';
         Webhook.callout(wh.URL__c, content);
         test.stopTest();
     }
}