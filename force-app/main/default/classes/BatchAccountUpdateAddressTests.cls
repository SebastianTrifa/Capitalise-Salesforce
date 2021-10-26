@isTest
private class BatchAccountUpdateAddressTests {
    @TestSetup
	static void Setup()
	{
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Business T#' + idx;
            acc.ShippingCity = 'Pandemonia';
            acc.ShippingCountry = 'Hell';
            acc.ShippingPostalCode = 'AFL UDW';
            acc.ShippingState = 'Seventh Circle';
            acc.ShippingStreet = '666 Pit of Remorse';
			test_businesses.add(acc);
		}

		insert test_businesses;
    }
    

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        BatchAccountUpdateAddress job = new BatchAccountUpdateAddress();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        Test.stopTest();
    }
}