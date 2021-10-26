@isTest
private class HealthScoreSchedulerTest {

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 08 7 ? 2025';
    
    @TestSetup
	static void Setup()
	{
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 20; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Business T#' + idx;
            acc.RecordTypeId = introducerRecordTypeId;
            acc.Managed_Clients_Connected__c = 10 * idx;
            acc.Monetary_Key_Secured__c = 10000.00 * (idx + 1);
            acc.Monetary_Key_Unsecured__c = 10000.00 * (idx + 1);
            acc.Recent_Searches__c = 5 * (idx + 1);
            acc.Penetration_Key__c = 7 * (idx + 1);
            acc.Recent_Paid_Out_Searches__c = 3 * (idx + 1);
            acc.Engagement_Key__c = (2 + idx) * 5;
            acc.Spread_Key__c = (3 + idx) * 3;
            acc.Number_of_Clients__c = (idx * 100) + (idx * 200) + 100;
			test_businesses.add(acc);
		}

        insert test_businesses;
        
        List<Opportunity> previous_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 9; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[math.mod(idx, 3)].Id;
			opp.Introducer_new__c = test_businesses[math.mod(idx, 3)].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
            opp.stagename = (math.mod(idx, 3) == 0) ? 'Paid Out' : 'Incomplete';
            if(opp.stagename == 'Paid Out')
            {
                opp.PaidProductType__c = (math.mod(idx, 2) == 0) ? 1 : 16;
            }
            opp.Owner_Locked__c = false;
            opp.Secured__c = false;
			opp.SearchedAmount__c = idx * 10000;
			previous_searches.add(opp);
        }
        
        for(Integer idx = 0; idx < 3; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_businesses[idx].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = securedFundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.Owner_Locked__c = false;
            opp.SearchedAmount__c = (2 - idx) * 10000;
            opp.Secured__c = true;
			previous_searches.add(opp);
		}

		insert previous_searches;
    }


    @isTest
	static void DummyTest()
	{
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTestOverdueTaskNotifier',
            CRON_EXP, 
            new HealthScoreScheduler());       
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
	}
}