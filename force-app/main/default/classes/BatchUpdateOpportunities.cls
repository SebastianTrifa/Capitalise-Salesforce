global class BatchUpdateOpportunities implements Database.Batchable<sObject> {
    
    String query;
    String action;
    
    global BatchUpdateOpportunities(String a_query) {
        query = a_query;
        action = 'default';
    }

    global BatchUpdateOpportunities(String a_query, String a_case) {
        query = a_query;
        action = a_case;
    }

    global BatchUpdateOpportunities() {
        query = 'select Id from Opportunity';
        action = 'default';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        switch on action {
            when 'Introducer Commission' {
                scope = OpportunityService.CalculateIntroducerCommission(scope);
            }
        }
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