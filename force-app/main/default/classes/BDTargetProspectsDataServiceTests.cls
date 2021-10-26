@isTest
private class BDTargetProspectsDataServiceTests {
    private static Integer numIntroducers = 7;
    @TestSetup
    static void makeData(){
        List<Account> introducers = new List<Account>();
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();

        for(Integer idx = 0; idx < numIntroducers; idx++) {
            Account acc = new Account(Name='TargetProspectDataServiceTestAccount#' + idx, RecordTypeId=introducerRecordTypeId, Type_of_Firm_2__c='Accountant');
            acc.Membership_Level__c = 'Light';
            acc.Primary_Contact__c = null;
            introducers.add(acc);
        }

        insert introducers;
    }

    @isTest
    static void testGetAccounts() {
        List<Account> accounts = BDTargetProspectsDataService.getAccounts(null, null);
        system.debug(accounts);
    }

    @isTest
    static void testGetUsers() {
        List<User> users = BDTargetProspectsDataService.getOwners();
        system.debug(users);
    }

    @isTest
    static void testCreateOpps() {
        List<Account> accounts = BDTargetProspectsDataService.getAccounts('Zone__c', 'ASC');
        accounts = BDTargetProspectsDataService.getAccounts(null, null);
        List<User> users = BDTargetProspectsDataService.getOwners();
        List<Id> accIds = new List<Id>();
        for(Account acc : accounts) {
            accIds.add(acc.Id);
        }
        List<Opportunity> opps = BDTargetProspectsDataService.createOpportunities(accIds, users[0].Id, system.today());
        system.debug(opps);
    }
}