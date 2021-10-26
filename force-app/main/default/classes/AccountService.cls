public with sharing class AccountService {
    public static void SinkingHealthScoreAlert(List<Account> accounts) {
        List<FeedItem> feeds = new List<FeedItem>();
        List<Task> tasks = new List<Task>();

        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        for(Account acc : accounts) {
            FeedItem feed = new FeedItem();
            feed.ParentId = acc.OwnerId;
            feed.Body = 'The healthscore of this account (' + acc.Name + ') is trending down over the last 3 months, please review this account as it probably needs your attention.';
            feed.Body += '\n' + baseUrl + '/' + acc.Id;
            feeds.add(feed);

            Task task = new Task();
            task.Subject = 'Healthscore Declining';
            task.ActivityDate = system.today() + 7;
            task.WhatId = acc.Id;
            task.OwnerId = acc.OwnerId;
            task.Priority = 'Normal';
            task.Status = 'Not Started';
            tasks.add(task);
        }

        insert tasks;
        insert feeds;
    }

    public static List<Account> FindFirstCasePaidOutDate(List<Account> accounts) {
        Id subscriptionId = Schema.SObjectType.OPportunity.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();

        List<AggregateResult> eldestSearches = [select Min(CloseDate) firstDate, Introducer_new__c introId from Opportunity where Introducer_new__c in :accounts and RecordTypeId != :subscriptionId and StageName in ('Closed Won', 'Case Won', 'Paid Out') Group By Introducer_new__c];
        List<AggregateResult> eldestCases = [select Min(CloseDate) firstDate, AccountId accId from Opportunity Where AccountId in :accounts and RecordTypeId != :subscriptionId and StageName in ('Closed Won', 'Case Won', 'Paid Out') Group By AccountId];

        Map<Id, DateTime> eldestSearchesMap = new Map<Id, DateTime>();
        Map<Id, DateTime> eldestCasesMap = new Map<Id, DateTime>();

        for(AggregateResult result : eldestSearches)
        {
            eldestSearchesMap.put((Id)result.get('introId'), (DateTime)result.get('firstDate'));
        }

        for(AggregateResult res : eldestCases)
        {
            eldestCasesMap.put((Id)res.get('accId'), (DateTime)res.get('firstDate'));
        }

        for(Account acc : accounts)
        {
            DateTime direct = (eldestCasesMap.containsKey(acc.Id)) ? eldestCasesMap.get(acc.Id) : null;
            DateTime asIntroducer = (eldestSearchesMap.containsKey(acc.Id)) ? eldestSearchesMap.get(acc.Id) : null;

            DateTime earliest = (direct < asIntroducer) ? direct : asIntroducer;

            acc.First_CAS_Paid_Out__c = (earliest != null) ? earliest.date() : null; 
        }

        return accounts;
    }

    public static List<Account> CalculateDailyDeltas(List<Account> accounts) {
        for(Account acc : accounts) {
            
            acc.Managed_Clients_Connected__c = (acc.Managed_Clients_Connected__c != null) ? acc.Managed_Clients_Connected__c : 0;
            acc.Managed_Clients_Connected_Snap_Daily__c = (acc.Managed_Clients_Connected_Snap_Daily__c != null) ? acc.Managed_Clients_Connected_Snap_Daily__c : 0;
            
            acc.Managed_Clients_Connected_Delta_Daily__c = acc.Managed_Clients_Connected__c - acc.Managed_Clients_Connected_Snap_Daily__c;
            acc.Managed_Clients_Connected_Snap_Daily__c = acc.Managed_Clients_Connected__c;
        }

        return accounts;
    }

    public static List<Account> refreshMonthlyDeltas(List<Account> accounts) {
        for(Account acc : accounts) {
            acc.Managed_Clients_Connected_Delta_Month__c = 0;
            acc.Managed_Clients_Connected__c = (acc.Managed_Clients_Connected__c != null) ? acc.Managed_Clients_Connected__c : 0;

            acc.Managed_Clients_Connected_Snap_Monthly__c = acc.Managed_Clients_Connected__c;
        }

        return accounts;
    }

    public static List<Account> CalculateMonthlyDeltas(List<Account> accounts) {
        for(Account acc : accounts) {
            acc.Managed_Clients_Connected__c = (acc.Managed_Clients_Connected__c != null) ? acc.Managed_Clients_Connected__c : 0;
            acc.Managed_Clients_Connected_Snap_Monthly__c = (acc.Managed_Clients_Connected_Snap_Monthly__c != null) ? acc.Managed_Clients_Connected_Snap_Monthly__c : 0;

            acc.Managed_Clients_Connected_Delta_Month__c = acc.Managed_Clients_Connected__c - acc.Managed_Clients_Connected_Snap_Monthly__c;
            acc.Managed_Clients_Connected_Snap_Monthly__c = acc.Managed_Clients_Connected__c;
        }

        return accounts;
    }

    public static List<Account> CalculateWeeklyDeltas(List<Account> accounts) {
        for(Account acc : accounts)
        {
            acc.Managed_Clients__c = (acc.Managed_Clients__c != null) ? acc.Managed_Clients__c : 0;
            acc.Managed_Clients_Connected__c = (acc.Managed_Clients_Connected__c != null) ? acc.Managed_Clients_Connected__c : 0;
            acc.Managed_Clients_Snap__c = (acc.Managed_Clients_Snap__c != null) ? acc.Managed_Clients_Snap__c : 0;
            acc.Managed_Clients_Connected_Snap__c = (acc.Managed_Clients_Connected_Snap__c != null) ? acc.Managed_Clients_Connected_Snap__c : 0;
            
            acc.Managed_Clients_Delta__c = acc.Managed_Clients__c - acc.Managed_Clients_Snap__c;
            acc.Managed_Clients_Connected_Delta__c = acc.Managed_Clients_Connected__c - acc.Managed_Clients_Connected_Snap__c;
            acc.Managed_Clients_Snap__c = acc.Managed_Clients__c;
            acc.Managed_Clients_Connected_Snap__c = acc.Managed_Clients_Connected__c;    
        }

        return accounts;
    }
}