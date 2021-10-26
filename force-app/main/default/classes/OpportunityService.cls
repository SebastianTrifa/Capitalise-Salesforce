public with sharing class OpportunityService {
    public static void CalculateIntroducerCommission(Set<Id> oppIds) {
        List<Opportunity> opps = [select Id, Introducer_Commission3__c, Confirmed_Funding_Amount__c, Confirmed_Commision__c, Introducer_new__c from Opportunity where Id in :oppIds];
        Set<Id> introIds = new Set<Id>();
        Set<Id> saasIds = new Set<Id>();
        for(opportunity opp : opps) {
            introIds.add(opp.Introducer_new__c);
        }
        Map<Id, Account> introducers = new Map<Id, Account>([select Id, SaaS_Contract__c from Account where Id in :introIds and SaaS_Contract__c != null]);
        for(Account intro : introducers.values()) {
            saasIds.add(intro.SaaS_Contract__c);
        }
        Map<Id, SaaS_Contract__c> contracts = new Map<Id, SaaS_Contract__c>([select Id, Commission2__c from SaaS_Contract__c where Id in :saasIds]);

        for(Opportunity opp : opps) {
            Decimal confirmed_funding_amount = (opp.Confirmed_Funding_Amount__c != null) ? opp.Confirmed_Funding_Amount__c : 0;
            Decimal confirmed_commission = (opp.Confirmed_Commision__c != null) ? opp.Confirmed_Commision__c / 100 : 0;
            Decimal saas_commission = (introducers.containsKey(opp.Introducer_new__c)) ? ((contracts.containsKey(introducers.get(opp.Introducer_new__c).SaaS_Contract__c)) ? contracts.get(introducers.get(opp.Introducer_new__c).SaaS_Contract__c).Commission2__c : 0) : 0;
            saas_commission = (saas_commission != null) ? saas_commission / 100 : 0;
            opp.Introducer_Commission3__c = confirmed_funding_amount * saas_commission * confirmed_commission;
        }

        update opps;
    }

    public static List<Opportunity> CalculateIntroducerCommission(List<Opportunity> scope) {
        Set<Id> introIds = new Set<Id>();
        Set<Id> saasIds = new Set<Id>();
        for(opportunity opp : scope) {
            introIds.add(opp.Introducer_new__c);
        }
        Map<Id, Account> introducers = new Map<Id, Account>([select Id, SaaS_Contract__c from Account where Id in :introIds and SaaS_Contract__c != null]);
        for(Account intro : introducers.values()) {
            saasIds.add(intro.SaaS_Contract__c);
        }
        Map<Id, SaaS_Contract__c> contracts = new Map<Id, SaaS_Contract__c>([select Id, Commission2__c from SaaS_Contract__c where Id in :saasIds]);
        
        for(Opportunity opp : scope) {
            Decimal confirmed_funding_amount = (opp.Confirmed_Funding_Amount__c != null) ? opp.Confirmed_Funding_Amount__c : 0;
            Decimal confirmed_commission = (opp.Confirmed_Commision__c != null) ? opp.Confirmed_Commision__c / 100 : 0;
            Decimal saas_commission = (introducers.containsKey(opp.Introducer_new__c)) ? ((contracts.containsKey(introducers.get(opp.Introducer_new__c).SaaS_Contract__c)) ? contracts.get(introducers.get(opp.Introducer_new__c).SaaS_Contract__c).Commission2__c : 0) : 0;
            saas_commission = (saas_commission != null) ? saas_commission / 100 : 0;
            opp.Introducer_Commission3__c = confirmed_funding_amount * saas_commission * confirmed_commission;
        }

        return scope;
    }

    @AuraEnabled(cacheable=true)
    public static Declined_Opportunity_Checklist__c getChecklist(String oppId){
        try {
            List<Declined_Opportunity_Checklist__c> checklists = [select Id, Call_Logged__c, Email_Logged__c, Notes_Added__c, Notes_Received__c from Declined_Opportunity_Checklist__c where Opportunity__c=:oppId];
            if(checklists.size() > 0) return checklists[0];
            else return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}