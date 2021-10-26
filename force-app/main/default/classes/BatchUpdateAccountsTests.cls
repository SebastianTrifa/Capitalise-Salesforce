@isTest
private class BatchUpdateAccountsTests
{
    @TestSetup
	static void Setup()
	{

		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
			acc.Name = 'Business T#' + idx;
			test_businesses.add(acc);
		}

		Account cap = new Account(Name='Capitalise');
		test_businesses.add(cap);
		insert test_businesses;
    }
    

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        String query = 'select Id from Account limit 1';
        BatchUpdateAccounts job = new BatchUpdateAccounts();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        BatchUpdateAccounts job1 = new BatchUpdateAccounts(query);
        // Schedule the test job
        String jobId1 = Database.executeBatch(job1);
        query = 'select Id, First_CAS_Paid_Out__c from Account';
        BatchUpdateAccounts job2 = new BatchUpdateAccounts(query, 'firstpaidoutdate');
        // Schedule the test job
        String jobId2 = Database.executeBatch(job2);
        Test.stopTest();
    }
}