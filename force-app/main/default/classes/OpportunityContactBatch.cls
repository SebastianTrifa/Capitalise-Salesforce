global class OpportunityContactBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global OpportunityContactBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select introducer_contact__c, (Select ContactId from OpportunityContactRoles) from Opportunity where introducer_contact__c != null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<OpportunityContactRole> oppCRole = new List<OpportunityContactRole>();
        
        for(Opportunity opp :scope) {          
			Boolean checkIC = true;
            for(OpportunityContactRole ocr : opp.OpportunityContactRoles) {
                if (opp.Introducer_Contact__c == ocr.ContactId ) {
                    checkIc = false;
                }
            }
            if(checkIc) {
                OpportunityContactRole oppCR = new OpportunityContactRole();
                oppCr.OpportunityId = opp.Id;
                oppCr.ContactId = opp.Introducer_Contact__c;
                oppCRole.add(oppCr);
            }
            
        }
        Database.SaveResult[] dbsr = Database.insert(oppCRole, false);
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}