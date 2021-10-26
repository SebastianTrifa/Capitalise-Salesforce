@isTest
private class OpportunityContactBatch_test {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   
        //Second Method
    //
    @isTest static void test_method_two() {
		 Test.startTest();
        
        contact con = new contact();
        con.LastName = 'TesteName';
        insert con;
        
        Opportunity oppp = new Opportunity();
        oppp.Introducer_Contact__c = con.id;
        oppp.Name= 'teste';
        oppp.StageName='Submitted';
        oppp.CloseDate= system.today();
        insert oppp;
        
        OpportunityContactRole ocr1 = new OpportunityContactRole ();
        ocr1.OpportunityId = oppp.Id;
        ocr1.ContactId = oppp.Introducer_Contact__c;
        //ocr1.ContactId = con.id;
        insert ocr1;
        
         // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new OpportunityContactSchedule());
         
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