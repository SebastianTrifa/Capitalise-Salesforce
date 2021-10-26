@isTest
private class BatchUpdateOpportunitiesTests {
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
    

    @isTest static void test_batchupdate() 
    {
        Test.startTest();
        String query = 'select Id from Opportunity limit 1';
        BatchUpdateOpportunities job = new BatchUpdateOpportunities();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        BatchUpdateOpportunities job1 = new BatchUpdateOpportunities(query);
        // Schedule the test job
        String jobId1 = Database.executeBatch(job1);
        query = 'select Id, Introducer_Commission3__c, Confirmed_Funding_Amount__c, Confirmed_Commision__c, Introducer_new__r.SaaS_Contract__r.Commission2__c from Opportunity where Introducer_Commission3__c = null';
        BatchUpdateOpportunities job2 = new BatchUpdateOpportunities(query, 'Introducer Commission');
        // Schedule the test job
        String jobId2 = Database.executeBatch(job2);
        Test.stopTest();
    }
}