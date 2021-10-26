global class HealthScoreScheduler implements Schedulable {
    global void execute(SchedulableContext context)
    {
        BatchAccountHealthscoreKeys job = new BatchAccountHealthscoreKeys();
        // Schedule the test job
        String jobId = Database.executeBatch(job);
        AccountsPartnerHealthscore.ComputeAccountsPartnerHealthscoreEngagement(context.getTriggerId());
        AccountsPartnerHealthscore.ComputeAccountsPartnerHealthscoreSpread(context.getTriggerId());
    }
}