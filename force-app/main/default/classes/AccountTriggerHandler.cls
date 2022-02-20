public with sharing class AccountTriggerHandler {
    public static Boolean hasRan = false;
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < Account > newList,
        Map < Id, Account > newMap,
        List < Account > oldList,
        Map < Id, Account > oldMap
    ) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                AccountValidationRules(newList);
            }
            when BEFORE_UPDATE {
                AccountValidationRules(newList);
                CloseLostAccountRisk(newList);
            }
        }
    }

    private static void CloseLostAccountRisk(List<Account> accounts) {
        Id SubscriptionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
        Id FundingId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id RetentionId = Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Retention').getRecordTypeId();
        Id OnboardingId = Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        Id FoundationId = Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Foundation').getRecordTypeId();
        List<Id> primaryContacts = new List<Id>();
        for(Account account : accounts){
            primaryContacts.add(account.Primary_Contact__c);
        }

        Map<Id, Account> casesLast90Days = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, CaseNumber FROM Cases WHERE DAY_ONLY(CreatedDate) = LAST_N_DAYS:90) FROM Account  WHERE Id IN :accounts]);
        Map<Id, Account> casesClosed = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, CaseNumber FROM Cases WHERE IsClosed = TRUE) FROM Account WHERE Id IN :accounts]);
        Map<Id, Account> currentRisks = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, Name, Stage__c, Age__c, Warning_Signs__c, Clients_Connected_in_Monitor__c, RecordTypeId FROM Risks__r WHERE Stage__c NOT IN ('Won', 'Lost') AND RecordTypeId != :retentionId ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :accounts]);
        Map<Id, Account> subscriptionOpportunities = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, Name, Payback__c FROM Opportunities WHERE RecordTypeId = :SubscriptionId AND StageName NOT IN ('Closed Won', 'Closed Lost') ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :accounts]);
        Map<Id, Account> fundingOpportunities = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, Name, Payback__c FROM Opportunities WHERE RecordTypeId = :FundingId AND StageName NOT IN ('Declined', 'Cancelled', 'Canceled')) FROM Account WHERE Id IN :accounts]);
        Map<Id, Contact> activities = new Map<Id, Contact>([SELECT Id, Name, (SELECT Id, Name FROM talkdesk__Talkdesk_Activities__r WHERE DAY_ONLY(CreatedDate) = LAST_N_DAYS:60) FROM Contact WHERE Id IN :primaryContacts]);
        Map<Id, Contact> emailClicks = new Map<Id, Contact>([SELECT Id, Name, (SELECT Id, Name FROM ddm__Email_Clicks__r WHERE DAY_ONLY(CreatedDate) = LAST_N_DAYS:60) FROM Contact WHERE Id IN :primaryContacts]);


        //List<string> riskTypes = new List<string>{'Onboarding','Foundation'};
        //List<RecodType> riskTypeIds = [select Id, Name from RecordType where sObjectType='Risk__c' AND DeveloperName IN :('Onboarding','Foundation')];
        List<Risk__c> updateRisks = new List<Risk__c>();
        //Map<Id, Integer> casesClosedMap = new Map<Id, Integer>(currentRisk.RecordType.DeveloperName);
        //for(Account account : casesClosed){
            //casesClosedMap.put((Id)account.Id, (Integer)account.Cases.size());
        //}
        for(Account account : accounts){
            if(currentRisks.get(account.Id).Risks__r.size() != 0){
                    for(Integer i=0; i< currentRisks.get(account.Id).Risks__r.size(); i++){
                        if(casesClosed.get(account.Id).Cases.size() >= 5 || 
                			currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c >= 3 || 
                			//(activities.containsKey(account.Primary_Contact__c) && activities.get(account.Primary_Contact__c).talkdesk__Talkdesk_Activities__r.size() == 0) ||
                			//(emailClicks.containsKey(account.Primary_Contact__c) && emailClicks.get(account.Primary_Contact__c).ddm__Email_Clicks__r.size() == 0) ||
                            ((currentRisks.get(account.Id).Risks__r[i].RecordTypeId == FoundationId || currentRisks.get(account.Id).Risks__r[i].RecordTypeId == OnboardingId) &&
                        		(casesLast90Days.get(account.Id).Cases.size() == 0 && account.CreatedDate.date().daysBetween(System.today()) > 90)))
                        {
                    			currentRisks.get(account.Id).Risks__r[i].Stage__c = 'Lost';
                    			updateRisks.add(currentRisks.get(account.Id).Risks__r[i]);
                    			Risk__c retentionRisk = new Risk__c(Customer__c = account.Id, Name = ' Retention Risk — ' + Account.Name, Open_Reason__c = 'Retention risk', Priority__c = 'Medium', RecordTypeId = RetentionId, Stage__c = 'Identified', Start_Date__c = System.today(), End_date__c = System.today());
                    			updateRisks.add(retentionRisk);
                        }
                    else{
                    		currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c = 0;
                    		string DeveloperName = Schema.SObjectType.Risk__c.getRecordTypeInfosById().get(currentRisks.get(account.Id).Risks__r[i].RecordTypeId).getDeveloperName();
                    		if(account.HealthScore__c < 0.45)
                        		currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
                    		if(account.Conversion_Rate__c < 0.1)
                        		currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
                    		if(subscriptionOpportunities.get(account.Id).Opportunities.size() > 0 && subscriptionOpportunities.get(account.Id).Opportunities[0].Payback__c > 0)
                        		currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
                    		if(account.NPS_Score__c < 7)
                                currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
                            if(currentRisks.get(account.Id).Risks__r[i].Clients_Connected_in_Monitor__c > 0)
                                currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
                            if(currentRisks.get(account.Id).Risks__r[i].Age__c > Expected_Time_in_Stage__mdt.getInstance(DeveloperName).Time_in_Stage__c)
                                currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
                            if(fundingOpportunities.get(account.Id).Opportunities.size() > 0)
                                currentRisks.get(account.Id).Risks__r[i].Warning_Signs__c += 1;
            		}
                } 
        	}
        }
        upsert(updateRisks);
    }

    private static void AccountValidationRules(List<Account> accounts)
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();

        for(Account acc : accounts)
        {
            if (acc.RecordTypeId == introducerRecordTypeId && (acc.Membership_Level__c == null || acc.Membership_Level__c == ''))
            {
                acc.addError('Membership Level cannot be null or blank for Introducer accounts');
            }
        }
    }
}