@isTest
private class BatchLenderHealthscoreKeysTests {
    @TestSetup
	static void Setup()
	{
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
		Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;

		List<Contact> contacts = new List<Contact>();

		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 3; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Business T#' + idx;
            acc.Recent_Searches__c = (3 - idx) * 4;
            acc.Managed_Clients_Connected__c = (3 - idx) * 1000;
            acc.Recent_Paid_Out_Searches__c = (3 - idx) * 4 / (idx + 2);
            acc.Number_of_Members_Champions__c = 5 + (idx + 1);
            acc.Number_of_Clients__c = idx * 14 + 3;
			acc.CAPAPP_PLATFORM_USAGE__c = 'API, but does not update status for non API applications';
			acc.Last_Quarterly_Meeting__c = System.today() - 60;
			test_businesses.add(acc);
		}

		Account cap = new Account(Name='Capitalise');
		test_businesses.add(cap);
		insert test_businesses;

		contact con = new contact();
		con.LastName = 'test contact';
		contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
		contacts.add(con1);

		insert contacts;

		List<User> funding_specialists = [select Id, Name from User where ProfileId=:fundingSpecialistProfileId limit 2];
		List<Account> test_lenders = new List<Account>();

		for(Integer idx = 0; idx < 3; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Introducer T#' + idx;
			test_lenders.add(acc);
		}
		insert test_lenders;

		List<Opportunity> previous_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 9; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[math.mod(idx, 3)].Id;
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
			opp.Confirmed_CommisionMoney__c = idx * 10000;
			previous_searches.add(opp);
        }
        
        for(Integer idx = 0; idx < 3; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[idx].Id
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = securedFundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.Owner_Locked__c = false;
            opp.Confirmed_CommisionMoney__c = (2 - idx) * 10000;
            opp.Secured__c = true;
			previous_searches.add(opp);
		}

		insert previous_searches;
    }

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        BatchLenderHealthscoreKeys job = new BatchLenderHealthscoreKeys();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        String query = 'select Id, Name, Lender_Conversion_Key__c, Lender_Monetary_Key__c, Active_Contacts_Key__c, Platform_Use_API_Key__c, Last_Quarterly_Meeting__c, Lender_Conversion__c, Lender_Monetary__c, Active_Contacts__c, Platform_Use_API__c, Feedback__c from Account where RecordTypeId = \'' + lenderRecordTypeId + '\''
        BatchLenderHealthscoreKeys job1 = new BatchLenderHealthscoreKeys(query);
        // Schedule the test job
        jobId = Database.executeBatch(job1);
		BatchLenderHealthscoreKeys job2 = new BatchLenderHealthscoreKeys(query, true);
        // Schedule the test job
        jobId = Database.executeBatch(job2);
        Test.stopTest();
    }
}