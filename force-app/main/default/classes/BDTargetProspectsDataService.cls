public without sharing class BDTargetProspectsDataService {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String sortBy, String sortDirection){
        try {
            Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
            List<String> unwantedLevels = new List<String>{'Pro-1', 'Pro-2', 'Pro-3', 'Pro-4', 'Pro-5' , 'Partner-1', 'Partner-2', 'Partner-3', 'Enterprise-1', 'Enterprise-2', 'Enterprise-3', 'Enterprise-4', 'Enterprise-5', 'Starter'};
            string query = 'select Id, Name, Zone__c, Primary_Contact_Email__c, Primary_Contact_Phone__c, Number_of_partners__c, Number_of_Staff__c, Country__c ' +
                'from Account ' +
                'where Type_of_Firm__c=\'Accountant\' and Number_of_Open_Subscriptions__c = 0 and Membership_Level__c not in :unwantedLevels and RecordTypeId=\'' + introducerRecordTypeId + '\' and Number_of_Opportunities__c=null and (not Name like \'%Capitalise%\') and (not Name like \'%Platfi%\') ';
            if (sortBy != null && sortDirection != null) {
                query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
            }
            List<Account> results = filterClosedLostPast6Months(Database.query(query));

            return results;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Account> filterClosedLostPast6Months(List<Account> queryResults) {
        List<Id> accIds = new List<Id>();
        for(Account acc : queryResults) {
            accIds.add(acc.Id);
        }

        Map<Id, Integer> numOppsLostPast6Months = new Map<Id, Integer>();

        List<AggregateResult> lostOppsByAccount = [select Count(Id) lostSubs, AccountId account
                                                    from Opportunity 
                                                    where AccountId in :accIds and StageName = 'Closed Lost' and CloseDate = LAST_N_MONTHS:6
                                                    Group By AccountId];

        for(AggregateResult res : lostOppsByAccount) {
            numOppsLostPast6Months.put((Id)res.get('account'), (Integer)res.get('lostSubs'));
        }

        List<Account> finalResult = new lIst<Account>();

        for(Account acc : queryResults) {
            if(!numOppsLostPast6Months.containsKey(acc.Id)) {
                finalResult.add(acc);
            }
            else if(numOppsLostPast6Months.get(acc.Id) == 0) {
                finalResult.add(acc);
            }
        }

        return finalResult;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getOwners(){
        try {
            List<User> users = [select Id, Name from User where Id in (select userOrGroupId from GroupMember where Group.Name = 'BD Team')];
            return users;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Opportunity> createOpportunities(List<Id> accountIds, Id ownerId, Date closeDate){
        try {
            List<Account> introducers = [select Id, Name from Account where ID in :accountIds];
            List<User> users = [select Id, Name from User where Id in (select userOrGroupId from GroupMember where Group.Name = 'BD Team')];
            List<Opportunity> oppsToCreate = new List<Opportunity>();
            List<String> story = new List<String>();
            story.add('Yo!');
            story.add('I\'m litterally doing this to pad');
            story.add('Don\'t bother trying to read it\'s kind of pointless');
            story.add('I\'m leaving it to the council to make it better.');
            story.add('This is my special 7 sided trick.');
            story.add('But really there\'s no point to it.');
            story.add('Just adding extra lines here, this should do though.');
            Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
            List<String> unwantedLevels = new List<String>{'Pro-1', 'Pro-2', 'Pro-3', 'Pro-4', 'Pro-5' , 'Partner-1', 'Partner-2', 'Partner-3', 'Enterprise-1', 'Enterprise-2', 'Enterprise-3', 'Enterprise-4', 'Enterprise-5', 'Starter'};
            Id subscriptionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();

            for(Account acc : introducers) {
                Opportunity opp = new Opportunity(Name=acc.Name, AccountId=acc.Id, StageName='Target Prospects', CloseDate=closeDate, OwnerId=ownerId, LeadSource='Sales Generated', Lead_Source_detail__c='Sales Team Outbound', RecordTypeId=subscriptionRecordTypeId);
                oppsToCreate.add(opp);
            }
            system.debug(oppsToCreate);
            insert oppsToCreate;
            return oppsToCreate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}