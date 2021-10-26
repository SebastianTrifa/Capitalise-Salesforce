global class InactiveFundingSearchUpdater implements Schedulable {
    global void execute(SchedulableContext context)
    {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id IntroducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();

        Date cutoffdate = Date.today();
        cutoffdate -= 60;
        List<Opportunity> opps = new List<Opportunity>();
        List<String> owner_names = new List<String>();
        List<Id> introducers_tmp = new List<Id>();
        Group acc_managers_group = [select Id, Name from Group where Name='Account Managers' limit 1];

        List<GroupMember> account_managers = [select UserOrGroupId from GroupMember where GroupId=:acc_managers_group.Id];

        List<Id> acc_managers_id = new List<Id>();
        for(GroupMember gm : account_managers)
        {
            acc_managers_id.add(gm.UserOrGroupId);
        }
         
        owner_names.add('CapitaliseAPP');
        owner_names.add('Marketing');
        
        for(Opportunity opp : [select Id, OwnerId, Owner.Name, Introducer_new__c, Funding_Specialist__c from Opportunity where Owner.Name in :owner_names and RecordTypeId=:fundingSearchRecordTypeId])
        {
            if(opp.Introducer_new__c != null)
                introducers_tmp.add(opp.Introducer_new__c);
        }
        Set<Id> introducers = new Set<Id>(introducers_tmp);

        Map<Id, Boolean> introducers_activities = new Map<Id, Boolean>();
        Map<Id, Integer> introducer_activityCount = new Map<Id, Integer>();
        for(Account acc : [select Id, Name, (select OwnerId, ActivityDate, Status from ActivityHistories where OwnerId in :acc_managers_id and ActivityDate > :cutoffdate) from Account where Id in :introducers])
        {
            Integer acc_manager_activities = acc.ActivityHistories.size();
            introducer_activityCount.put(acc.Id, acc_manager_activities);
        }

        for(Account acc : [select Id, Name, (select OwnerId, ActivityDate, Status from OpenActivities where OwnerId in :acc_managers_id and ActivityDate > :cutoffdate) from Account where Id in :introducers])
        {
            Integer acc_manager_activities = acc.OpenActivities.size() + introducer_activityCount.get(acc.Id);
            introducer_activityCount.put(acc.Id, acc_manager_activities);
        }

        for(Id introId : introducer_activityCount.keySet())
        {
            Integer acc_manager_activities = introducer_activityCount.get(introId);
            introducers_activities.put(introId, acc_manager_activities == 0);
        }

        for(Opportunity opp : [select Id, OwnerId, Owner.Name, Introducer_new__c, Funding_Specialist__c, Owner_Locked__c from Opportunity where Owner.Name in :owner_names and RecordTypeId=:fundingSearchRecordTypeId])
        {
            if(opp.Introducer_new__c != null && introducers_activities.get(opp.Introducer_new__c))
            {
                if(opp.Funding_Specialist__c != null && opp.OwnerId != opp.Funding_Specialist__c)
                {
                    opp.OwnerId = opp.Funding_Specialist__c;
                    opp.Owner_Locked__c = true;
                    opps.add(opp);
                }
            }
        }

        update opps;
    }
}