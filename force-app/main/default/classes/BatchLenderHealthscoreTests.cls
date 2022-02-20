@isTest
private class BatchLenderHealthscoreTests {
    @TestSetup
	static void Setup()
	{
        Id lenderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lender').getRecordTypeId();

		List<Contact> intro_contacts = new List<Contact>();

		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Business T#' + idx;
            acc.Recent_Searches__c = (3 - idx) * 4;
            acc.Managed_Clients_Connected__c = (3 - idx) * 10;
            acc.Recent_Paid_Out_Searches__c = (3 - idx) * 4 / (idx + 2);
            acc.Number_of_Members_Champions__c = 5 + (idx + 1);
            acc.Number_of_Clients__c = idx * 400 + 249;
			acc.CAPAPP_PLATFORM_USAGE__c = 'API, but does not update status for non API applications';
			acc.Last_Quarterly_Meeting__c = System.today() - 60;
			test_businesses.add(acc);
		}

		Account cap = new Account(Name='Capitalise');
		test_businesses.add(cap);
		insert test_businesses;

		contact con = new contact();
		con.LastName = 'test contact';
		intro_contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
		intro_contacts.add(con1);

		insert intro_contacts;

		List<User> funding_specialists = [select Id, Name from User where ProfileId=:fundingSpecialistProfileId limit 2];
		List<Account> test_lenders = new List<Account>();

		for(Integer idx = 0; idx < 3; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Lender T#' + idx;
			test_lender.add(acc);
		}
		insert test_lenders;

		List<Opportunity> previous_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 18; idx++)
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
			opp.AccountId = test_businesses[idx].Id;
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
        BatchLenderHealthscore job = new BatchLenderHealthscore();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
		BatchLenderHealthscore job1 = new BatchLenderHealthscore(true);
        // Schedule the test job
        jobId = Database.executeBatch(job1);
        Test.stopTest();
    }
}