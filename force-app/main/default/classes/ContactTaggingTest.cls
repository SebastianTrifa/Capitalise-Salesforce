@isTest
private class ContactTaggingTest {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	@isTest static void test_method_one() {
		 Test.startTest();
		 //Criar dados de Teste de contactso e tags
		 //
		 //
		tags__c tags = new tags__c();
        tags.CapitaliseExtID__c = '999';
        tags.Field1__c = 'Network';
        tags.Field1_Value__c = 'PKF';
        insert tags;
        
        tags__c tags1 = new tags__c();
        tags1.CapitaliseExtID__c = '998';
        tags1.Field1__c = 'User Acquired by Landing Page';
        tags1.Field1_Value__c = 'homepage';
        insert tags1;
        
        tags__c tags2 = new tags__c();
        tags2.CapitaliseExtID__c = '997';
        tags2.Field1__c = 'User Acquired by';
        tags2.Field1_Value__c = 'Lender Invitee';
        insert tags2;
        
        tags__c tags3 = new tags__c();
        tags3.CapitaliseExtID__c = '996';
        tags3.Field1__c = 'Data Cleansing';
        tags3.Field1_Value__c = 'Bounced';
        insert tags3;

        tags__c tags4 = new tags__c();
        tags4.CapitaliseExtID__c = '995';
        tags4.Field1__c = 'Person Type';
        tags4.Field1_Value__c = 'Lender';
        insert tags4;
        
        tags__c tags5 = new tags__c();
        tags5.CapitaliseExtID__c = '994';
        tags5.Field1__c = 'Lead Capture Content';
        tags5.Field1_Value__c = 'Escalate Guide';
        insert tags5;
        
        tags__c tags6 = new tags__c();
        tags6.CapitaliseExtID__c = '993';
        tags6.Field1__c = 'Communication History';
        tags6.Field1_Value__c = 'Spoken to them';
        insert tags6;
        
        tags__c tags7 = new tags__c();
        tags7.CapitaliseExtID__c = '992';
        tags7.Field1__c = 'Communication Category';
        tags7.Field1_Value__c = 'Non-sales Nurture';
        insert tags7;
        
        tags__c tags8 = new tags__c();
        tags8.CapitaliseExtID__c = '991';
        tags8.Field1__c = 'Lead Source';
        tags8.Field1_Value__c = 'Personal Contact';
        insert tags8;
        
        tags__c tags9 = new tags__c();
        tags9.CapitaliseExtID__c = '990';
        tags9.Field1__c = 'Signup As';
        tags9.Field1_Value__c = 'Signed Up Business';
        insert tags9;

        tags__c tags10 = new tags__c();
        tags10.CapitaliseExtID__c = '989';
        tags10.Field1__c = 'Funding Search Status';
        tags10.Field1_Value__c = 'First Funding Search Business';
        insert tags10;
        
        tags__c tags11 = new tags__c();
        tags11.CapitaliseExtID__c = '988';
        tags11.Field1__c = 'Referred to';
        tags11.Field1_Value__c = 'Start Up Loan Company';
        insert tags11;

        List<Lead_Source__c> lsList = new List<Lead_Source__c>();
        Lead_Source__c ls1 = new Lead_Source__c();
        ls1.CapitaliseExtID__c = '999';
        ls1.Field_1__c = 'Network';
        ls1.Field_1_Value__c = 'PKF';
        lslist.add(ls1);

        Lead_Source__c ls2 = new Lead_Source__c();
        ls2.CapitaliseExtID__c = '998';
        ls2.Field_1__c = 'Lead Source';
        ls2.Field_1_Value__c = 'PKF';
        lslist.add(ls2);

        Lead_Source__c ls3 = new Lead_Source__c();
        ls3.CapitaliseExtID__c = '997';
        ls3.Field_1__c = 'Person Type';
        ls3.Field_1_Value__c = 'PKF';
        lslist.add(ls3);

        Lead_Source__c ls4 = new Lead_Source__c();
        ls4.CapitaliseExtID__c = '996';
        ls4.Field_2__c = 'Lead Source Detail';
        ls4.Field_2_Value__c = 'PKF';
        lslist.add(ls4);

        Lead_Source__c ls5 = new Lead_Source__c();
        ls5.CapitaliseExtID__c = '995';
        ls5.Field_2__c = 'Introducer Type';
        ls5.Field_2_Value__c = 'PKF';
        lslist.add(ls5);

        Lead_Source__c ls6 = new Lead_Source__c();
        ls6.CapitaliseExtID__c = '994';
        ls6.Field_3__c = 'Contact Owner';
        ls6.Field_3_Value__c = 'PKF';
        lslist.add(ls6);

        Lead_Source__c ls7 = new Lead_Source__c();
        ls7.CapitaliseExtID__c = '993';
        ls7.Field_3__c = 'Person Type';
        ls7.Field_3_Value__c = 'PKF';
        lslist.add(ls7);

        Lead_Source__c ls8 = new Lead_Source__c();
        ls8.CapitaliseExtID__c = '992';
        ls8.Field_4__c = 'Introducer Type';
        ls8.Field_4_Value__c = 'PKF';
        lslist.add(ls8);

        Lead_Source__c ls9 = new Lead_Source__c();
        ls9.CapitaliseExtID__c = '991';
        ls9.Field_4__c = 'Lead Source';
        ls9.Field_4_Value__c = 'PKF';
        lslist.add(ls9);

        insert lslist;
                                            
        contact con = new contact ();
        con.LastName = 'test';
        con.InfusionSoftExtId__c = '111';
        con.TagsID__c = '999';
        con.LeadSourceExtID__c = '999';
        insert con;
        
        contact con1 = new contact ();
        con1.LastName = 'test';
        con1.InfusionSoftExtId__c = '112';
        con1.TagsID__c = '998';
        con1.LeadSourceExtID__c = '998';
        insert con1;
        
        contact con2 = new contact ();
        con2.LastName = 'test';
        con2.InfusionSoftExtId__c = '113';
        con2.TagsID__c = '997';
        con2.LeadSourceExtID__c = '997';
        insert con2;
        
        contact con3 = new contact ();
        con3.LastName = 'test';
        con3.InfusionSoftExtId__c = '114';
        con3.TagsID__c = '996';
        con3.LeadSourceExtID__c = '996';
        insert con3;
		
        contact con4 = new contact ();
        con4.LastName = 'test';
        con4.InfusionSoftExtId__c = '115';
        con4.TagsID__c = '995';
        con4.LeadSourceExtID__c = '995';
        insert con4;
        
        contact con5 = new contact ();
        con5.LastName = 'test';
        con5.InfusionSoftExtId__c = '116';
        con5.TagsID__c = '994';
        con5.LeadSourceExtID__c = '994';
        insert con5;
        
        contact con6 = new contact ();
        con6.LastName = 'test';
        con6.InfusionSoftExtId__c = '117';
        con6.TagsID__c = '993';
        con6.LeadSourceExtID__c = '993';
        insert con6;
        
        contact con7 = new contact ();
        con7.LastName = 'test';
        con7.InfusionSoftExtId__c = '118';
        con7.TagsID__c = '992';
        con7.LeadSourceExtID__c = '992';
        insert con7;
        
        contact con8 = new contact ();
        con8.LastName = 'test';
        con8.InfusionSoftExtId__c = '119';
        con8.TagsID__c = '991';
        con8.LeadSourceExtID__c = '991';
        insert con8;
        
        contact con9 = new contact ();
        con9.LastName = 'test';
        con9.InfusionSoftExtId__c = '120';
        con3.TagsID__c = '990';
        insert con9;
        
        contact con10 = new contact ();
        con10.LastName = 'test';
        con10.InfusionSoftExtId__c = '121';
        con10.TagsID__c = '989';
        insert con10;
        
        contact con11 = new contact ();
        con11.LastName = 'test';
        con11.InfusionSoftExtId__c = '122';
        con11.TagsID__c = '988';
        insert con11;
        
        
      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ContactTaggingSchedule());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      Test.stopTest();
	}		
}