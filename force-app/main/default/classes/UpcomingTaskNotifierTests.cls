@isTest
private class UpcomingTaskNotifierTests {
    
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 08 7 ? 2025';
    
    @isTest(SeeAllData=true)
	static void DummyTest()
	{
        Account cap = new Account(Name='Capitalise');
        insert cap;


        List<Task> tasks = new List<Task>();
        Task ownertask = new Task();
        ownertask.OwnerId = UserInfo.getUserId();
        ownertask.ActivityDate = System.today() + 15;
        ownertask.Priority = 'Normal';
        ownertask.Status = 'Open';
        ownertask.Subject = 'Test Upcoming RE-ENGAGEMENT';
        ownertask.WhatId = cap.Id;
        tasks.add(ownertask);

        Task dueTask = new Task();
        dueTask.OwnerId = UserInfo.getUserId();
        dueTask.ActivityDate = System.today();
        dueTask.Priority = 'Normal';
        dueTask.Status = 'Open';
        dueTask.Subject = 'Test Due RE-ENGAGEMENT';
        dueTask.WhatId = cap.Id;
        tasks.add(dueTask);
        
        insert tasks;

        Set<String> subjects = new Set<String>();
        subjects.add('Test Upcoming RE-ENGAGEMENT');
        subjects.add('Test Due RE-ENGAGEMENT');

        Set<Id> tasksIds = new Set<Id>();
        
        for(Task t : tasks) {
            tasksIds.add(t.WhatId);
        }
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTestUpcomingTaskNotifier',
            CRON_EXP, 
            new UpcomingTaskNotifier());
        // Stopping the test will run the job synchronously
        Test.stopTest();
        List<FeedItem> posts = [select Id, ParentId, Body from FeedItem where ParentId in :tasksIds];
        system.debug(posts); 
	}
}