@isTest(seeAllData=false)
private class test_sevendaysdate {
    @isTest public static void testmethod1(){
        
        CloseDateRule__c  cd = new CloseDateRule__c();
        cd.Days__c = 7;
        cd.Name='dias';
        insert cd;
        opportunity opp = new opportunity();
        opp.name='teste';
        opp.StageName='Qualification';
        insert opp;
        
         User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
        u.LastName = 'Yohan';
        u.Email = 'puser000@amamama.com';
        u.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;
    }
    @isTest public static void testmethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        CloseDateRule__c  cd = new CloseDateRule__c();
        cd.Days__c = 7;
        cd.Name='dias';
        insert cd;
        
        WebHook_URL__c  wh = new WebHook_URL__c();
        wh.Capitalise_Security_Token__c = 'asfasgfagsgasgas';
        wh.password__c='platfi';
        wh.username__c='platfi';
        wh.URL__c='asfasgasgasg';
        insert wh;
        
        user__c uu = new user__c();
        uu.FirstName__c= 'Colin';
        insert uu;
        
        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        u.LastName = uu.FirstName__c;
        u.Email = 'puser000@amamama.com';
        u.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;
        
        User u1 = new User();
        u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        u1.LastName = 'miguel';
        u1.Email = 'puser000@amamama.com';
        u1.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        u1.CompanyName = 'TEST';
        u1.Title = 'title';
        u1.Alias = 'alias';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        insert u1;
        
        Account introd = new Account();
        introd.Name = 'teste';
        
        insert introd;
        
        list<opportunity> lopp = new list<opportunity> ();
        list<opportunity> lopp1 = new list<opportunity> ();
        opportunity opp1 = new opportunity ();
        opp1.AccountId = introd.id;
        opp1.Name='teste';
        opp1.StageName='Submitted';
        opp1.capitaliseExtID__c='9999999';
        insert opp1;
        
        opportunity opp2 = new opportunity ();
        opp2.AccountId = introd.id;
        opp2.Name='teste';
        opp2.StageName='Submitted';
        opp2.capitaliseExtID__c='9999998';
        insert opp2;
        
        opportunity opp3 = new opportunity ();
        opp3.AccountId = introd.id;
        opp3.Name='teste';
        opp3.StageName='Submitted';
        insert opp3;
        lopp.add(opp1);
        lopp.add(opp2);

        opp1.Type= 'New Business';
        update opp1;
        
         Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
        Map<id,Opportunity> newmap = new Map<id,Opportunity>();
        Opportunity acct = new Opportunity(Name='Test Account',StageName='Submitted');
        insert acct;
      
        oldmap.put(acct.id, acct);

        test.stopTest();
    } 
    
}


/* if(xx.CloseDate == Null)
{
List<CloseDateRule__c> mcs = CloseDateRule__c.getall().values();
system.debug('aaa '+ mcs[0].Days__c);
xx.CloseDate =  date.today() + (integer)(mcs[0].Days__c);
}*/