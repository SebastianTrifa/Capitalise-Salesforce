/** 
(c) 2020 Capitalise
Developed by Revolent Group, London (United Kingdom)
@date 07/2020 
@author Kevin Tchaka 
*/

global class BatchFundingSearchCancelReasonUpdater implements Database.Batchable<sObject> {
    String query;
    
    global BatchFundingSearchCancelReasonUpdater() {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        query = 'select Id, Cancel_Reason__c from Opportunity where Cancel_Reason__c = null and StageName=\'Canceled\' and RecordTypeId=\'' + fundingSearchRecordTypeId + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        List<Opportunity> updatedOpportunities = FundingSearchCancelReasonUpdater.CancelReasonFinder(scope);

        Database.SaveResult[] dbsr = Database.update(scope, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Opportunity ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}