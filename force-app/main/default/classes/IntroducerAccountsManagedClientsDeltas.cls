global class IntroducerAccountsManagedClientsDeltas implements Schedulable {
    global void execute(SchedulableContext context) {
        BatchIntroducersConnectedClientsDeltas job = new BatchIntroducersConnectedClientsDeltas('Weekly');
        // Schedule the test job
        String jobId = Database.executeBatch(job);
    }
}