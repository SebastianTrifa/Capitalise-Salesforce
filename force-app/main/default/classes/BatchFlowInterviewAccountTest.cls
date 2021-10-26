@isTest
private class BatchFlowInterviewAccountTest {
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
    

    @isTest static void test_batchflowInterview() 
    {
        Test.startTest();
        String query = 'select Id from Account limit 1';
        String flowInterview = 'Introducer Commission';
        BatchFlowInterviewAccount job = new BatchFlowInterviewAccount();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        System.debug(jobId);
        BatchFlowInterviewAccount job1 = new BatchFlowInterviewAccount(query);
        // Schedule the test job
        String jobId1 = Database.executeBatch(job1);
        System.debug(jobId1);
        flowInterview = 'Last Paid Out Close Date';
        BatchFlowInterviewAccount job2 = new BatchFlowInterviewAccount(query, flowInterview);
        // Schedule the test job
        String jobId2 = Database.executeBatch(job2);
        System.debug(jobId2);
        flowInterview = 'Account NPS Score';
        BatchFlowInterviewAccount job3 = new BatchFlowInterviewAccount(query, flowInterview);
        // Schedule the test job
        String jobId3 = Database.executeBatch(job3);
        System.debug(jobId3);
        Test.stopTest();
    }
}