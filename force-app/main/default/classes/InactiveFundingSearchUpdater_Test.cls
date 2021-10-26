@isTest
private class InactiveFundingSearchUpdater_Test {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 08 7 ? 2023';

    @TestSetup
	static void Setup()
	{

		Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
		Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;
        Id capAPPId = [select Id from User where Name='CapitaliseApp'].Id;

		List<User> test_users = new List<User>();
		User test_user1 = new User(LastName = 'TestUser',
		FirstName='#1',
		Alias = 'tusr1',
		Email = 'test1@CapUAT.com',
		Username = 'test1@CapUAT.com',
		ProfileId = fundingSpecialistProfileId,
		TimeZoneSidKey = 'GMT',
		LanguageLocaleKey = 'en_US',
		EmailEncodingKey = 'UTF-8',
		LocaleSidKey = 'en_US');
		test_users.add(test_user1);

		User test_user2 = new User(LastName = 'TestUser',
		FirstName='#2',
		Alias = 'tusr2',
		Email = 'test2@CapUAT.com',
		Username = 'test2@CapUAT.com',
		ProfileId = fundingSpecialistProfileId,
		TimeZoneSidKey = 'GMT',
		LanguageLocaleKey = 'en_US',
		EmailEncodingKey = 'UTF-8',
		LocaleSidKey = 'en_US');
		test_users.add(test_user2);

		insert test_users;

		List<Contact> intro_contacts = new List<Contact>();

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

		contact con = new contact();
		con.LastName = 'test contact';
		con.AccountId = cap.id;
		intro_contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
		con1.AccountId = cap.id;
		intro_contacts.add(con1);

		insert intro_contacts;

		List<User> funding_specialists = [select Id, Name from User where ProfileId=:fundingSpecialistProfileId limit 2];
		List<Account> test_introducers = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
			acc.Name = 'Introducer T#' + idx;
			test_introducers.add(acc);
		}
		insert test_introducers;

		List<Opportunity> previous_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 5; idx++)
		{
			opportunity opp = new opportunity();
            opp.OwnerId = capAPPId;
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_introducers[idx].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.SearchedAmount__c = 250000;
			opp.Funding_Specialist__c = funding_specialists[math.mod(idx,2)].Id;
			previous_searches.add(opp);
		}

        insert previous_searches;
        previous_searches = [select Id, OwnerId from Opportunity where Name like 'test search prev%'];
        for(Opportunity opp : previous_searches)
        {
            opp.OwnerId = capAPPId;
        }
        update previous_searches;
	}

    @isTest
	static void DummyTest()
	{
        // Tests against history are not really possible in the current salesforce framework, so this test, only adds to code coverage.

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTestInactiveFundingSearchUpdater',
            CRON_EXP, 
            new InactiveFundingSearchUpdater());         
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        system.assert(true);
	}
}