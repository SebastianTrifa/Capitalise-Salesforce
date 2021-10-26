@isTest
private class BatchIntroducerManagedClientsDeltasTests {
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
            acc.Managed_Clients_Connected__c = 6 - idx;
            acc.Managed_Clients_Connected_Snap__c = 2 + idx;
			test_businesses.add(acc);
		}

		insert test_businesses;
    }
    

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        BatchIntroducersManagedClientsDeltas job = new BatchIntroducersManagedClientsDeltas();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        Test.stopTest();
    }
}