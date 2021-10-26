@isTest
private class SendEmailTests {
    @TestSetup
	static void Setup()
	{
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
			opp.Introducer__c = intro.id;
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_introducers[idx].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.Owner_Locked__c = false;
			opp.SearchedAmount__c = 250000;
			opp.Funding_Specialist__c = funding_specialists[math.mod(idx,2)].Id;
			previous_searches.add(opp);
		}

		insert previous_searches;
	}

    @isTest
    static void testSendEmailSuccess() {
        Opportunity opp = [select Id, Funding_Specialist__c, AccountId, Introducer_Contact__c from Opportunity where Name like 'test search prev#%' limit 1];
        SendEmail.InvokeSendEmail request = new sendEmail.InvokeSendEmail();
        request.RelatedToID = opp.Id;
        request.ContactOrLeadID = opp.Introducer_Contact__c;
        request.ToAddresses = 'test@test.com';
        request.ccAddresses = 'test1@test.com';
        request.bccAddresses = 'test2@test.com';
        request.SaveAsActivity = true;
        request.Subject = 'Test';
        request.TextBody = 'That\'s a Test Yo!';
        request.HtmlBody = '<div><p>That\'s a Test Yo!</p></div>';
        request.TreatBodiesAsTemplate = false;
        request.TreatTargetObjectAsRecipient = false;
        request.UseSignature = true;

        Test.startTest();
        sendEmail.SendEmail(new List<SendEmail.InvokeSendEmail>{request});
        Test.stopTest();
    }

    @isTest
    static void testSendEmailFailure() {
        Opportunity opp = [select Id, Funding_Specialist__c, AccountId, Introducer_Contact__c from Opportunity where Name like 'test search prev#%' limit 1];
        SendEmail.InvokeSendEmail request = new sendEmail.InvokeSendEmail();
        request.RelatedToID = opp.Id;
        request.ToAddresses = 'test@test.com';
        request.ccAddresses = 'test1@test.com';
        request.bccAddresses = 'test2@test.com';
        request.SaveAsActivity = true;
        request.Subject = 'Test';
        request.TextBody = 'That\'s a Test Yo!';
        request.HtmlBody = '<div><p>That\'s a Test Yo!</p></div>';
        request.TreatBodiesAsTemplate = false;
        request.UseSignature = true;

        Test.startTest();
        sendEmail.SendEmail(new List<SendEmail.InvokeSendEmail>{request});
        Test.stopTest();
    }

    @isTest
    static void testSendEmailFailure2() {
        Opportunity opp = [select Id, Funding_Specialist__c, AccountId, Introducer_Contact__c from Opportunity where Name like 'test search prev#%' limit 1];
        SendEmail.InvokeSendEmail request = new sendEmail.InvokeSendEmail();
        request.RelatedToID = opp.Id;
        request.SaveAsActivity = true;
        request.Subject = 'Test';

        request.TreatBodiesAsTemplate = false;
        request.UseSignature = true;

        Test.startTest();
        sendEmail.SendEmail(new List<SendEmail.InvokeSendEmail>{request});
        Test.stopTest();
    }

    @isTest
    static void testSendEmailFailure3() {
        Opportunity opp = [select Id, Funding_Specialist__c, AccountId, Introducer_Contact__c from Opportunity where Name like 'test search prev#%' limit 1];
        SendEmail.InvokeSendEmail request = new sendEmail.InvokeSendEmail();
        request.RelatedToID = opp.Id;
        request.ContactOrLeadID = opp.Introducer_Contact__c;
        request.ToAddresses = 'test@test.com';
        request.SaveAsActivity = true;
        request.Subject = 'Test';
        request.TextBody = 'That\'s a Test Yo!';
        request.HtmlBody = '<div><p>That\'s a Test Yo!</p></div>';
        request.TreatBodiesAsTemplate = false;
        request.TreatTargetObjectAsRecipient = false;
        request.UseSignature = true;

        Test.startTest();
        sendEmail.SendEmailForceError(new List<SendEmail.InvokeSendEmail>{request});
        Test.stopTest();
    }

    @isTest
    static void testSendEmailSuccessTemplate() {
        Opportunity opp = [select Id, Funding_Specialist__c, AccountId, Introducer_Contact__c from Opportunity where Name like 'test search prev#%' limit 1];
        EmailTemplate template = [select Id, Name From EmailTemplate limit 1];
        SendEmail.InvokeSendEmail request = new sendEmail.InvokeSendEmail();
        request.RelatedToID = opp.Id;
        request.ContactOrLeadID = opp.Introducer_Contact__c;
        request.EmailTemplateID = template.Id;
        request.ToAddresses = 'test@test.com';
        request.ccAddresses = 'test1@test.com';
        request.bccAddresses = 'test2@test.com';
        request.SaveAsActivity = true;
        request.Subject = 'Test';
        request.TreatBodiesAsTemplate = false;
        request.TreatTargetObjectAsRecipient = false;
        request.UseSignature = true;

        Test.startTest();
        sendEmail.SendEmail(new List<SendEmail.InvokeSendEmail>{request});
        Test.stopTest();
    }
}