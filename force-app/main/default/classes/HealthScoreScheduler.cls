global class HealthScoreScheduler implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext context)
    {
        BatchAccountHealthscoreKeys job = new BatchAccountHealthscoreKeys();
        BatchLenderHealthscoreKeys job = new BatchLenderHealthscoreKeys();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}