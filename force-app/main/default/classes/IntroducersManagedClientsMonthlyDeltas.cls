global class IntroducersManagedClientsMonthlyDeltas implements Schedulable {
    global void execute(SchedulableContext context) {
        BatchIntroducersConnectedClientsDeltas job = new BatchIntroducersConnectedClientsDeltas('Monthly');
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}