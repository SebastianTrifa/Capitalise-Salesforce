@isTest
private class AccountHealthScoreHistoryUtilityTests {
    @TestSetup
	static void Setup()
	{
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Business T#' + idx;
            acc.RecordTypeId = introducerRecordTypeId;
            acc.HealthScore2__c = 7.34 * (idx + 1);
			test_businesses.add(acc);
		}

		insert test_businesses;
    }
    

    @isTest static void test_recordCreation() 
    {
        List<Account> accs = [select Id, HealthScore2__c from Account where Name like 'Business T%'];
        Set<Id> accIds = new Set<Id>();

        for(Account acc : accs) {
            accIds.add(acc.Id);
        }

        Test.startTest();
        AccountHealthScoreHistoryUtility job = new AccountHealthScoreHistoryUtility();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        Test.stopTest();
        List<Introducer_HealthScore_History__c> history = [select Id, Name, HealthScore__c from Introducer_HealthScore_History__c where Introducer__c in :accIds];
        system.debug(history);
        system.AssertEquals(accs.size(), history.size());
    }
}