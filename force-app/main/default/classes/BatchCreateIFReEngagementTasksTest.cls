@isTest
private class BatchCreateIFReEngagementTasksTest {
    @TestSetup
    static void setup(){
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
		Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;
		
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
		intro_contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
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
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_introducers[idx].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
            opp.name = 'test search prev#' + idx;
            opp.CapitaliseExtId__c = 'TestID#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
            opp.stagename = 'Paid Out';
            opp.Has_Invoice_Finance__c = true;
            opp.PaidDate__c = system.now() - idx;
			opp.Owner_Locked__c = false;
			opp.SearchedAmount__c = 250000;
			opp.Funding_Specialist__c = funding_specialists[math.mod(idx,2)].Id;
			previous_searches.add(opp);
		}

		insert previous_searches;
    }

    @isTest static void test_batchcreatetasks() 
    {
        Date cutoff = system.today() - 2;

        Test.startTest();
        BatchCreateIFReEngagementTasks job = new BatchCreateIFReEngagementTasks();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        System.debug('Youpi');
        BatchCreateIFReEngagementTasks job1 = new BatchCreateIFReEngagementTasks(cutoff);
        // Schedule the test job
        String job1Id = Database.executeBatch(job1);
        Test.stopTest();
    }
}