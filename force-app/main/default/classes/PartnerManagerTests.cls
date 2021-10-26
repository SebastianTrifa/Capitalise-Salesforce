@isTest
private class PartnerManagerTests {
    @TestSetup
    static void setup(){
        List<Account> accs = new List<Account>();

        accs.add(new Account(Name='TestAccount #1', CapitaliseExtId__c='Test1'));
        accs.add(new Account(Name='TestAccount #2', CapitaliseExtId__c='Test2'));

        insert accs;
    }

    @isTest static void testCreateRelationshipGood() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Partners/v1';
        req.httpMethod = 'POST';
        req.addParameter('partnerExtID', 'Test1');
        req.addParameter('accountExtID', 'Test2');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Id relationshipId = PartnerManager.createRelationship('Test1', 'Test2');
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        SYstem.assertEquals(relationshipId, RestContext.response.responseBody.toString());
    }

    @isTest static void testCreateRelationshipWrongParameters() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Partners/v1';
        req.httpMethod = 'POST';
        req.addParameter('partnerExtID', 'Test1');
        req.addParameter('accountExtID', 'Test2');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Id relationshipId = PartnerManager.createRelationship('Tes', 'Test2');
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
    }

    @isTest static void testCreateRelationshipMissingParameters() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Partners/v1';
        req.httpMethod = 'POST';
        req.addParameter('partnerExtID', 'Test1');
        req.addParameter('accountExtID', 'Test2');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Id relationshipId = PartnerManager.createRelationship('Test1', '');
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
    }
}