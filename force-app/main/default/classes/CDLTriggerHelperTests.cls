@isTest
private class CDLTriggerHelperTests {
    @TestSetup
	static void Setup()
	{
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        
		Account cap = new Account(Name='Capitalise');
        insert cap;
        
        List<Opportunity> test_businesses = new List<Opportunity>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Opportunity opp = new Opportunity();
            opp.Name = 'Business T#' + idx;
            opp.AccountId = cap.Id;
            opp.Introducer_new__c = cap.Id;
			opp.closedate = system.today() + 7;
            opp.CapitaliseExtId__c = 'TestID#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.Owner_Locked__c = false;
			opp.SearchedAmount__c = 250000;
			test_businesses.add(opp);
		}

		insert test_businesses;
    }

    @isTest static void test_notes_notifications() {
        String body = 'Private comment test this is a test.';
        ContentNote note = new ContentNote(Title='Funding Match Updated');
        note.Content = Blob.valueOf(body.escapeHTML4());
        Opportunity opp = [select Id, Name from Opportunity where Name like 'Business T#%' limit 1];
        opp.StageName = 'At Offer';

        update opp;
        insert note;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = note.Id;
        cdl.LinkedEntityId = opp.Id;
        cdl.ShareType = 'I';

        insert cdl;
    }
}