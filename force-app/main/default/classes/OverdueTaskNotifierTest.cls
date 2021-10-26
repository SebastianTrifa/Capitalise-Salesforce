@isTest
private class OverdueTaskNotifierTest {
    
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 08 7 ? 2025';

    @TestSetup
    static void setup(){
        Task ownertask = new Task();
        ownertask.OwnerId = UserInfo.getUserId();
        ownertask.ActivityDate = System.today() - 7;
        ownertask.Priority = 'Normal';
        ownertask.Status = 'Open';
        ownertask.Subject = 'Test Overdue Task';
        insert ownertask;
    }
    
    @isTest
	static void DummyTest()
	{
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTestOverdueTaskNotifier',
            CRON_EXP, 
            new OverdueTaskNotifier());       
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
	}
}