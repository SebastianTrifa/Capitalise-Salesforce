@isTest
private class BatchUpdateContactsTests
{
    @TestSetup
	static void Setup()
	{
		List<Contact> intro_contacts = new List<Contact>();
		Introducer__c intro = new Introducer__c();
		intro.name = 'Introducer Test';
		insert intro;

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
		con.Introducer__c = intro.id;
		intro_contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
		con1.Introducer__c = intro.id;
		intro_contacts.add(con1);

		insert intro_contacts;
    }
    

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        BatchUpdateContacts job = new BatchUpdateContacts();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
		BatchUpdateContacts job1 = new BatchUpdateContacts(1);
        // Schedule the test job
        String jobId1 = Database.executeBatch(job1);
		String query = 'select Id from Contact Limit 20';
		BatchUpdateContacts job2 = new BatchUpdateContacts(query);
        // Schedule the test job
        String jobId2 = Database.executeBatch(job2);
        Test.stopTest();
    }
}