global class IntroducersManagedClientsDailyDeltas implements Schedulable {
    global void execute(SchedulableContext context) {
        BatchIntroducersConnectedClientsDeltas job = new BatchIntroducersConnectedClientsDeltas('Daily');
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}