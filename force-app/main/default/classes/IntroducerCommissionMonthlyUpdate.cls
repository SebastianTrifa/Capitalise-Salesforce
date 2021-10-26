global class IntroducerCommissionMonthlyUpdate implements Schedulable {
    global void execute(SchedulableContext context) {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        String flowInterview = 'Introducer Commission';
        String query = 'select Id from Account where RecordTypeId = \'' + introducerRecordTypeId + '\'';
        BatchFlowInterviewAccount job = new BatchFlowInterviewAccount(query, flowInterview);
        // Schedule the test job
        String jobId = Database.executeBatch(job, 150);
    }
}