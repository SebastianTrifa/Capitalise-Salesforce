@isTest
private class FundingSearchCancelReasonUpdaterTest {
    @TestSetup
    static void setup()
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
		con.AccountId = cap.Id;
		intro_contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
		con1.AccountId = cap.Id;
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

		for(Integer idx = 0; idx < 3; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_introducers[idx].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
            opp.name = 'test search prev#' + idx;
            opp.CapitaliseExtId__c = 'TestID#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Canceled';
			opp.Owner_Locked__c = false;
			opp.SearchedAmount__c = 250000;
			opp.Funding_Specialist__c = funding_specialists[math.mod(idx,2)].Id;
			previous_searches.add(opp);
		}

        insert previous_searches;
        List<ContentDocumentLink> notesLink = new List<ContentDocumentLink>();
        List<ContentVersion> notes = new List<ContentVersion>();
        Map<String, Id> note_opp = new Map<String, Id>();

        for(Opportunity opp : previous_searches)
        {
            Integer idx = 0;
            for(Integer i = 0; i < 3; i++)
            {
                ContentVersion note = new ContentVersion();
                note.Title = 'Funding Match Updated';
                String noteValue = '';
                switch on idx 
                {
                    when 0 
                    {
                        noteValue = 'Lloyds Bank Commercial Finance updated match status to Cancelled. The reason given was: "Mango Passion".';
                    }
                    when 1 
                    {
                        noteValue = (math.mod(i, 2) == 0) ?
                            'Lloyds Bank Commercial Finance updated match status to Cancelled. The reason given was: "Chocolate Oblivion".' : 
                            'Lloyds Bank Commercial Finance updated match status to Cancelled. The reason given was: "Vanilla Perdition".';
                    }
                    when 2 
                    {
                        noteValue = (math.mod(i, 3) == 0) ?
                            'Lloyds Bank Commercial Finance updated match status to Cancelled. The reason given was: "Strawberry Fusion".' :
                            (math.mod(i, 3) == 1) ?
                                'Lloyds Bank Commercial Finance updated match status to Cancelled. The reason given was: "Raspberry Fusion".' :
                                'Lloyds Bank Commercial Finance updated match status to Cancelled. The reason given was: "Mulberry Fusion".';
                    }
                }
                note.VersionData = Blob.ValueOf(noteValue);
                note.PathOnClient = 'test#' + idx + '_' + i;
                notes.add(note);

                note_opp.put(note.PathOnClient, previous_searches[idx].Id);
            }
            idx++;
        }

        insert notes;

        List<ContentVersion> insertedNotes = [select Id, ContentDocumentId, PathOnClient from ContentVersion where Id In :notes];

        Integer oppctr = -1;
        for(Integer i = 0; i < insertedNotes.size(); i++)
        {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = insertedNotes[i].ContentDocumentId;
            if(math.mod(i,3)==0) oppctr++;
            link.LinkedEntityId = note_opp.get(insertedNotes[i].PathOnClient);
            notesLink.add(link);
        }

        insert notesLink;
    }

    @isTest
    static void TestCancelReasonFinder()
    {
        List<Opportunity> oppRecords = [select Id from Opportunity where StageName='Canceled'];
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : oppRecords)
            oppIds.add(opp.Id);

        Test.startTest();
        FundingSearchCancelReasonUpdater.FutureCancelReasonFinder(oppIds);
        Test.stopTest();

    }
}