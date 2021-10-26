@isTest
private class AccountHealthScoreSorterTests {
    
    @TestSetup
	static void Setup()
	{
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
		Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;

		List<Contact> intro_contacts = new List<Contact>();

		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 3; idx++)
		{
			Account acc = new Account();
            acc.Name = 'Business T#' + idx;
            acc.Penetration_Key__c = (3 - idx) * 3;
            acc.Spread_Key__c = (3 - idx) * 3;
            acc.Recent_Searches__c = (3 - idx) * 4;
            acc.Managed_Clients_Connected__c = (3 - idx) * 10;
            acc.Recent_Paid_Out_Searches__c = (3 - idx) * 4 / (idx + 2);
            acc.Engagement_Key__c = (3 - idx) * 3;
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

		for(Integer idx = 0; idx < 3; idx++)
		{
			Account acc = new Account();
			acc.Name = 'Introducer T#' + idx;
			test_introducers.add(acc);
		}
		insert test_introducers;

		List<Opportunity> previous_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[math.mod(idx, 3)].Id;
			opp.Introducer_new__c = test_introducers[math.mod(idx, 3)].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
            opp.Owner_Locked__c = false;
            opp.Secured__c = false;
			opp.SearchedAmount__c = idx * 10000;
			previous_searches.add(opp);
        }
        
        for(Integer idx = 0; idx < 3; idx++)
		{
			opportunity opp = new opportunity();
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_introducers[idx].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = securedFundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.Owner_Locked__c = false;
            opp.SearchedAmount__c = (2 - idx) * 10000;
            opp.Secured__c = true;
			previous_searches.add(opp);
		}

		insert previous_searches;
    }
    
    @isTest static void testRecency()
    {
        List<AccountHealthScoreSorter> sortedAccounts = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id from Account where Name Like 'Business T#%'];
        Map<Id, List<Opportunity>> oppIdsPerAccMap = new Map<Id, List<Opportunity>>();
        List<Opportunity> opps = [select Id, AccountId, Younger_than_90_Days__c from Opportunity where Younger_than_90_Days__c=true and AccountId in :accs];
        system.Debug(opps);
        for(Opportunity opp : opps)
        {
            if(oppIdsPerAccMap.containsKey(opp.AccountId))
            {
                List<Opportunity> accOpps = oppIdsPerAccMap.get(opp.AccountId);
                accOpps.add(opp);
                oppIdsPerAccMap.put(opp.AccountId, accOpps);
            }
            else{
                List<Opportunity> accOpps = new List<Opportunity>();
                accOpps.add(opp);
                oppIdsPerAccMap.put(opp.AccountId, accOpps);
            }
        }

        for(Integer idx = 0; idx < accs.size(); idx++)
        {
            Account acc = accs[idx];
            List<Opportunity> oppIds = oppIdsPerAccMap.get(acc.Id);
            for(Integer idx2 = 0; idx2 < oppIds.size(); idx2++)
            {
                if(idx2 < idx + 1)
                    oppIds[idx2].Younger_than_90_Days__c = false;
            }
            oppIdsPerAccMap.put(acc.Id, oppIds);
        }

        List<Opportunity> updatedOpps = new List<Opportunity>();
        for(Id accId : oppIdsPerAccMap.keySet())
        {
            List<Opportunity> oppList = oppIdsPerAccMap.get(accId);
            updatedOpps.addAll(oppList);
        }
        update updatedOpps;

        List<Account> accsToSOrt = [select Id, Name, Recent_Searches__c from Account where name Like 'Business T#%'];

        for(Account acc : accsToSOrt)
        {
            sortedAccounts.add(new AccountHealthScoreSorter(acc, 'Recency'));
        }

        System.debug(accsToSOrt);
        sortedAccounts.sort();

        System.debug(sortedAccounts);

        System.assertEquals('Business T#0', sortedAccounts[2].acc.Name);
        System.assertEquals('Business T#1', sortedAccounts[1].acc.Name);
        System.assertEquals('Business T#2', sortedAccounts[0].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Recent_Searches__c=null), 'Recency');
        Integer ras = accNull.compareTo(sortedAccounts[0]);
        ras = sortedAccounts[0].compareTo(accNull);
        ras = sortedAccounts[0].compareTo(sortedAccounts[1]);
        ras = sortedAccounts[1].compareTo(sortedAccounts[0]);
        
    }

    @isTest static void testMonetarySecured()
    {
        List<AccountHealthScoreSorter> accSecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Monetary_Key_Secured__c from Account where Name Like 'Business T#%'];

        Integer counter = accs.size();
        for(Account acc : accs)
        {
            acc.Monetary_Key_Secured__c = counter * 10000.00;
            counter--;
            accSecuredList.add(new AccountHealthScoreSorter(acc, 'Monetary Secured'));
        }

        accSecuredList.sort();

        System.assertEquals('Business T#2', accSecuredList[0].acc.Name);
        System.assertEquals('Business T#1', accSecuredList[1].acc.Name);
        System.assertEquals('Business T#0', accSecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Monetary_Key_Secured__c=null), 'Monetary Secured');
        Integer ras = accNull.compareTo(accSecuredList[0]);
        ras = accSecuredList[0].compareTo(accNull);
        ras = accSecuredList[0].compareTo(accSecuredList[1]);
        ras = accSecuredList[1].compareTo(accSecuredList[0]);
    }

    @isTest static void testMonetaryUnsecured()
    {
        List<AccountHealthScoreSorter> accUnsecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Monetary_Key_Unsecured__c from Account where Name Like 'Business T#%'];

        Integer counter = 1;
        for(Account acc : accs)
        {
            acc.Monetary_Key_Unsecured__c = counter * 10000.00;
            counter++;
            accUnsecuredList.add(new AccountHealthScoreSorter(acc, 'Monetary Unsecured'));
        }

        accUnsecuredList.sort();

        System.assertEquals('Business T#0', accUnsecuredList[0].acc.Name);
        System.assertEquals('Business T#1', accunsecuredList[1].acc.Name);
        System.assertEquals('Business T#2', accunsecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Monetary_Key_Unsecured__c=null), 'Monetary Unsecured');
        Integer ras = accNull.compareTo(accUnsecuredList[0]);
        ras = accUnsecuredList[0].compareTo(accNull);
        ras = accUnsecuredList[0].compareTo(accUnsecuredList[1]);
        ras = accUnsecuredList[1].compareTo(accUnsecuredList[0]);
    }

    @isTest static void testPenetration()
    {
        List<AccountHealthScoreSorter> accSecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Penetration_Key__c from Account where Name Like 'Business T#%'];

        for(Account acc : accs)
        {
            accSecuredList.add(new AccountHealthScoreSorter(acc, 'Penetration'));
        }

        accSecuredList.sort();

        System.assertEquals('Business T#2', accSecuredList[0].acc.Name);
        System.assertEquals('Business T#1', accSecuredList[1].acc.Name);
        System.assertEquals('Business T#0', accSecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Penetration_Key__c=null), 'Penetration');
        Integer ras = accNull.compareTo(accSecuredList[0]);
        ras = accSecuredList[0].compareTo(accNull);
        ras = accSecuredList[0].compareTo(accSecuredList[1]);
        ras = accSecuredList[1].compareTo(accSecuredList[0]);
    }

    @isTest static void testAttachment()
    {
        List<AccountHealthScoreSorter> accSecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Managed_Clients_Connected__c from Account where Name Like 'Business T#%'];

        for(Account acc : accs)
        {
            accSecuredList.add(new AccountHealthScoreSorter(acc, 'Attachment'));
        }

        accSecuredList.sort();

        System.assertEquals('Business T#2', accSecuredList[0].acc.Name);
        System.assertEquals('Business T#1', accSecuredList[1].acc.Name);
        System.assertEquals('Business T#0', accSecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Managed_Clients_Connected__c=null), 'Attachment');
        Integer ras = accNull.compareTo(accSecuredList[0]);
        ras = accSecuredList[0].compareTo(accNull);
        ras = accSecuredList[0].compareTo(accSecuredList[1]);
        ras = accSecuredList[1].compareTo(accSecuredList[0]);
    }

    @isTest static void testConversion()
    {
        List<AccountHealthScoreSorter> accSecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Conversion_Rate_Key__c from Account where Name Like 'Business T#%'];

        for(Account acc : accs)
        {
            accSecuredList.add(new AccountHealthScoreSorter(acc, 'Conversion'));
        }

        accSecuredList.sort();

        System.assertEquals('Business T#1', accSecuredList[0].acc.Name);
        System.assertEquals('Business T#2', accSecuredList[1].acc.Name);
        System.assertEquals('Business T#0', accSecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null'), 'Conversion');
        Integer ras = accNull.compareTo(accSecuredList[0]);
        ras = accSecuredList[0].compareTo(accNull);
        ras = accSecuredList[0].compareTo(accSecuredList[1]);
        ras = accSecuredList[1].compareTo(accSecuredList[0]);
    }

    @isTest static void testEngagement()
    {
        List<AccountHealthScoreSorter> accSecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Engagement_Key__c from Account where Name Like 'Business T#%'];

        for(Account acc : accs)
        {
            accSecuredList.add(new AccountHealthScoreSorter(acc, 'Engagement'));
        }

        accSecuredList.sort();

        System.assertEquals('Business T#2', accSecuredList[0].acc.Name);
        System.assertEquals('Business T#1', accSecuredList[1].acc.Name);
        System.assertEquals('Business T#0', accSecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Engagement_Key__c=null), 'Engagement');
        Integer ras = accNull.compareTo(accSecuredList[0]);
        ras = accSecuredList[0].compareTo(accNull);
        ras = accSecuredList[0].compareTo(accSecuredList[1]);
        ras = accSecuredList[1].compareTo(accSecuredList[0]);
    }

    @isTest static void testSpread()
    {
        List<AccountHealthScoreSorter> accSecuredList = new List<AccountHealthScoreSorter>();
        List<Account> accs = [select Id, Name, Spread_Key__c from Account where Name Like 'Business T#%'];

        for(Account acc : accs)
        {
            accSecuredList.add(new AccountHealthScoreSorter(acc, 'Spread'));
        }

        accSecuredList.sort();

        System.assertEquals('Business T#2', accSecuredList[0].acc.Name);
        System.assertEquals('Business T#1', accSecuredList[1].acc.Name);
        System.assertEquals('Business T#0', accSecuredList[2].acc.Name);

        AccountHealthScoreSorter accNull = new AccountHealthScoreSorter(new Account(Name='Test Null', Spread_Key__c=null), 'Spread');
        Integer ras = accNull.compareTo(accSecuredList[0]);
        ras = accSecuredList[0].compareTo(accNull);
        ras = accSecuredList[0].compareTo(accSecuredList[1]);
        ras = accSecuredList[1].compareTo(accSecuredList[0]);
    }

    @isTest static void testMixedSecuredMonetary()
    {
        List<AccountHealthScoreSorter> accUnsecuredList = new List<AccountHealthScoreSorter>();
        List<AccountHealthScoreSorter> accScrambledList = new List<AccountHealthScoreSorter>();
        List<Account> businessAccs = [select Id, Name, Monetary_Key_Secured__c from Account where Name Like 'Business T#%'];
        List<Account> introducerAccs = [select Id, Name, Monetary_Key_Secured__c from Account where Name Like 'Introducer T#%'];

        for(Account acc : businessAccs)
        {
            acc.Monetary_Key_Secured__c = 10000.00;
            accUnsecuredList.add(new AccountHealthScoreSorter(acc, 'Monetary Secured'));
        }

        for(Account acc : introducerAccs)
        {
            acc.Monetary_Key_Secured__c = null;
            accUnsecuredList.add(new AccountHealthScoreSorter(acc, 'Monetary Secured'));
        }

        for(Integer idx = 0; idx < 3; idx++)
        {
            accScrambledList.add(accUnsecuredList[idx]);
            accScrambledList.add(accUnsecuredList[idx + 3]);
        }

        accUnsecuredList.sort();
        accScrambledList.sort();
    }
}