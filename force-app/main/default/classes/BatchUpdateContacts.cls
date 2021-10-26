global class BatchUpdateContacts implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
    String msg; 
    Integer option;
    Integer nberrors;
    Boolean errors;
    
    global BatchUpdateContacts(String a_query) {
        query = a_query;
        option = 0;
        msg = '';
        errors = false;
        nberrors = 0;
    }

    global BatchUpdateContacts(Integer a_case) {
        option = a_case;
        msg = '';
        errors = false;
        nberrors = 0;
        switch on option {
            when 1 {
                query = 'select Id, Email, Email_2__c from Contact';
            }
        }
    }

    global BatchUpdateContacts() {
        query = 'select Id from Contact';
        option = 0;
        msg = '';
        errors = false;
        nberrors = 0;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        switch on option {
            when 1 {
                for(Contact c : scope) {
                    c.Email_2__c = c.Email;
                }
            }
        }

        Database.SaveResult[] dbsr = Database.update(scope, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Contact ID: ' + sr.getId());
            }
            else {
                errors = true;
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    msg += '\nThe following error has occurred.';                    
                    msg += ' ' + err.getStatusCode() + ': ' + err.getMessage();
                    msg += 'Contact fields that affected this error: ' + err.getFields() + '\n';
                    nberrors++;
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { UserInfo.getUserEmail() };
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex Error Handler');
        mail.setSubject('Batch Contact Update Error');
        if(errors) {
            mail.setPlainTextBody('There were ' + nberrors + ' errors during the process!\n' + msg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}