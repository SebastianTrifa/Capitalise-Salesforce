global class PartnerHealthscoreHistoryScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        BatchPartnerHealthscoreHistory job = new BatchPartnerHealthscoreHistory();
        String jobId = Database.executeBatch(job);
    }
}