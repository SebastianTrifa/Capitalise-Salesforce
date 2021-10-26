@isTest
private class CustomTalkdeskActivityTriggerHelperTest {
    @TestSetup
    static void setup(){
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
		con1.AccountId = test_businesses[0].id;
		intro_contacts.add(con1);

		insert intro_contacts;
    }

    @isTest static void test_method_one()
    {
        Contact con = [select Id, AccountId from Contact limit 1];

        talkdesk__Talkdesk_Activity__c newActivity = new talkdesk__Talkdesk_Activity__c();
        newActivity.talkdesk__User__c = UserInfo.getUserId();
        newActivity.talkdesk__Contact__c = con.Id;
        newActivity.talkdesk__Start_Time__c = system.now().addMinutes(-7);
        newActivity.talkdesk__End_Time__c = system.now();
		newActivity.Name = 'Test 1,2,3';
		newActivity.talkdesk__Channel__c = 'SMS';
        newActivity.talkdesk__Talkdesk_Id__c = 'BogusID000XX1234567';

        insert newActivity;
    }
}