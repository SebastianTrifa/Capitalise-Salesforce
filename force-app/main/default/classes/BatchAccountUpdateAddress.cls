global class BatchAccountUpdateAddress implements Database.Batchable<sObject> {
    String query;
    
    global BatchAccountUpdateAddress() {
        query = 'select Id, BillingAddress, ShippingAddress, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet from Account';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for(Account acc : scope) {
            if(acc.BillingAddress == null && acc.ShippingAddress != null) {
                acc.BillingCity = acc.ShippingCity;
                acc.BillingCountry = acc.ShippingCountry;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingState = acc.ShippingState;
                acc.BillingStreet = acc.ShippingStreet;
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