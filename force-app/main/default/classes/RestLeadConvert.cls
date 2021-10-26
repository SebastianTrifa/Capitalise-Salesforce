@RestResource(urlMapping='/ConvertLead/*')
global with sharing class RestLeadConvert {            
    
    @HttpGet
    global static String doGet() {
        String ret = 'fail';
        //RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string AccountID = RestContext.request.params.get('AccountID'); 
        system.debug('ola '+ AccountID);
        String leadId = RestContext.request.params.get('leadId'); 
        system.debug('ola1 '+ leadId);
        String OppId = RestContext.request.params.get('OppId'); 
        system.debug('ola2 '+ OppId);
        String ContactId = RestContext.request.params.get('ContactId'); 
        system.debug('ola2 '+ ContactId);
        Database.LeadConvert lc = new Database.LeadConvert();
        list<Account>caplead = new list<Account>();
        list<Account> acc = new list<Account>();
        if(AccountId != null) {
            acc =  [SELECT Id, Name  FROM Account WHERE CapitaliseExtId__c = :AccountId];            
        }    
        list<Contact> con = new list<Contact>();
        if(ContactId != null) {
            con =  [SELECT Id, Name, AccountId FROM Contact WHERE CapitaliseExtId__c = :ContactId];            
        }  
        list<lead> l = [SELECT Id  FROM lead WHERE CapitaliseExtId__c = :leadId];
        if(l.size()>0){
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);  
        if(!acc.isEmpty()){
            lc.setAccountId(acc[0].id);
            system.debug('lc.setAccountId(acc[0].id) '+ acc[0].id);
        }
       /* else{
            caplead = [select id from account where name='CapitaliseLead' limit 1];
            system.debug('aaaa '+ caplead);
            con[0].AccountId = caplead[0].Id;
            system.debug('vvvv '+ con[0].AccountId);
            update con;
        }*/
        if(!con.isEmpty()){
            lc.setContactId(con[0].id);
            system.debug('lc.setContactId(acc[0].id) '+ con[0].id);
        }
        
        lc.setLeadId(l[0].Id);
            system.debug('lc.setLeadId(l[0].Id) '+ l[0].Id);
        Database.LeadConvertResult lcr ;
        try{
            lcr = Database.convertLead(lc);
            system.debug('lcr '+lcr);
            system.debug('*****lcr.isSuccess()'+lcr.isSuccess());            
            ret = lcr.getAccountId(); 
            list<lead> le = [SELECT Id, ConvertedOpportunityID, ConvertedContactID, ConvertedAccountID  FROM lead WHERE id = :lc.GetleadId()];
            list<opportunity> opp = [select id, accountid from opportunity where id =: le[0].ConvertedOpportunityID];
            opp[0].CapitaliseExtId__c = OppID;
             if(acc.isEmpty()) {
            opp[0].accountid = null;
             }
            update opp;
            //ConvertedOpportunityID
            if(con.isEmpty()){delete[select id from contact where id =:le[0].ConvertedContactID];}
            if(acc.isEmpty()){delete[select id from account where id =:le[0].ConvertedAccountID];}
            
          	return ret;
          
        }
        catch(exception ex){
            system.debug('***NOT CONVERTED**' + ex);   
            RestContext.response.statusCode = 400;
            return  String.valueof(ex);
        }
        }
        else{
            return('No Leads referred');
        }
        
        
    }
    
}