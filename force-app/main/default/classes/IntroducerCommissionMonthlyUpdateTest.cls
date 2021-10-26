@isTest
private class IntroducerCommissionMonthlyUpdateTest {
     // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 08 7 ? 2025';

    @TestSetup
    static void setup(){
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
    }
    
    @isTest
	static void DummyTest()
	{
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTestMonthlyommissionUpdate',
            CRON_EXP, 
            new IntroducerCommissionMonthlyUpdate());       
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
	}
}