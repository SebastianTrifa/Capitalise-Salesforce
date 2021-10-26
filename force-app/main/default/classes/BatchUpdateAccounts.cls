global class BatchUpdateAccounts implements Database.Batchable<sObject> {
    
    String query;
    String exhibit;
    
    global BatchUpdateAccounts(String a_query) {
        query = a_query;
        exhibit = 'default';
    }

    global BatchUpdateAccounts(String a_query, String a_case) {
        query = a_query;
        exhibit = a_case;
    }

    global BatchUpdateAccounts() {
        query = 'select Id from Account';
        exhibit = 'default';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        switch on exhibit {
            when 'firstpaidoutdate' {
                scope = AccountService.FindFirstCasePaidOutDate(scope);
            }
        }
        Database.SaveResult[] dbsr = Database.update(scope, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}