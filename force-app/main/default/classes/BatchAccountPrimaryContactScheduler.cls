global class BatchAccountPrimaryContactScheduler implements Schedulable {
    global void execute(SchedulableContext context)
    {
        BatchAccountSetPrimaryContactOne job = new BatchAccountSetPrimaryContactOne();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}