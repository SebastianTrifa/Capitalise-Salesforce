@RestResource(urlMapping='/Partners/v1/*')
global with sharing class PartnerManager {
    @HttpPost
    global static ID createRelationship(String partnerExtID, String accountExtID) {
        RestResponse response = RestContext.response;
        if(String.isBlank(partnerExtId) || String.isBlank(accountExtID)) {
            response.statusCode = 404;
            response.responseBody = Blob.valueOf('partnerExtId or accountExtID invalid. No accounts found!');
            return null;
        }

        Set<String> accIds = new Set<String> {partnerExtID, accountExtID};
        List<Account> accounts = [select Id, Name, CapitaliseExtId__c from Account where CapitaliseExtId__c in :accIds];
        Map<String, Account> accMap = new Map<String, Account>();
        for(Account acc : accounts) {
            accMap.put(acc.CapitaliseExtId__c, acc);
        }

        if(accMap.containsKey(partnerExtID) && accMap.containsKey(accountExtID)) {
            Partner_Relationship__c relationship = new Partner_Relationship__c();
            relationship.Partner_Account__c = accMap.get(partnerExtID).Id;
            relationship.Linked_Account__c = accMap.get(accountExtID).Id;

            insert relationship;
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(relationship.Id);
            return relationship.Id;
        }
        response.statusCode = 404;
        response.responseBody = Blob.valueOf('partnerExtId or accountExtID invalid. No accounts found!');
        return null;
    }
}