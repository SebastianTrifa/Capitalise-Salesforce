public with sharing class MakeIntroducerButton {
    
    public account record {get;set;}
    
    public MakeIntroducerButton (ApexPages.StandardController ctrl){
        record = (Account)ctrl.getRecord();
    }
    
    public PageReference IntroducerButton() {
        system.debug('accountid' + record.id);
        account acc = [select id, name, ownerId, CapitaliseExtId__c from account where id=:record.id];
        system.debug('cptls '+acc.CapitaliseExtId__c);
        if(String.isBlank(acc.CapitaliseExtId__c)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The Introducer Object is now redundant, instead change the account record type to Introducer! And send a message to an admin so we can retire this button.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This specific Business cannot be converted to Introducer!');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
}