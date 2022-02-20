global class HealthScoreQuaterlyScheduler implements Schedulable {
    global void execute(SchedulableContext context)
    {
        BatchAccountHealthscoreKeys job = new BatchAccountHealthscoreKeys(true);
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}