global class CanceledFundingSearchSchedulable implements Schedulable {

    Set<Id> recordsIds;

    global void execute(SchedulableContext context)
    {
        DateTime rerunTime = system.now();
        rerunTime = rerunTime.addMinutes(15);
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String cronRerunTime = '0 ' + rerunTime.minute() + ' ' + rerunTime.hour() + ' ' + rerunTime.day() + ' ' + rerunTime.month() + ' ?';

        try {
            List<Opportunity> workload = [select Id, Cancel_Reason__c from Opportunity where Id in :recordsIds];
            List<Opportunity> updatedOpportunities = FundingSearchCancelReasonUpdater.CancelReasonFinder(workload);
            update updatedOpportunities;
        } catch (DmlException e) {    
            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) System.schedule('FundingSearchCancelReasonUpdater' + h, cronRerunTime, new CanceledFundingSearchSchedulable(recordsIds));
        }
        system.abortJob(context.getTriggerId());
    }

    global CanceledFundingSearchSchedulable(Set<Id> a_recordsIds)
    {
        recordsIds = a_recordsIds;
    }
}