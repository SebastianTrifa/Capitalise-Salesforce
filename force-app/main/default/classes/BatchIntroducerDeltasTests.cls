@isTest
private class BatchIntroducerDeltasTests {
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
            acc.Managed_Clients__c = 7 - idx;
            acc.Managed_Clients_Snap__c = 1 + idx;
            acc.Managed_Clients_Connected_Snap_Daily__c = 3 + idx;
            acc.Managed_Clients_Connected_Snap_Monthly__c = 5 + idx;
            acc.Managed_Clients_Connected__c = 6 - idx;
            acc.Managed_Clients_Connected_Snap__c = 2 + idx;
			test_businesses.add(acc);
		}

		insert test_businesses;
    }
    

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        BatchIntroducersConnectedClientsDeltas job = new BatchIntroducersConnectedClientsDeltas();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        BatchIntroducersConnectedClientsDeltas job1 = new BatchIntroducersConnectedClientsDeltas('Weekly');
        // Schedule the test job
        jobId = Database.executeBatch(job1);
        BatchIntroducersConnectedClientsDeltas job2 = new BatchIntroducersConnectedClientsDeltas('Monthly');
        // Schedule the test job
        jobId = Database.executeBatch(job2);
        BatchIntroducersConnectedClientsDeltas job3 = new BatchIntroducersConnectedClientsDeltas('Banana');
        // Schedule the test job
        jobId = Database.executeBatch(job3);
        Test.stopTest();
    }
}