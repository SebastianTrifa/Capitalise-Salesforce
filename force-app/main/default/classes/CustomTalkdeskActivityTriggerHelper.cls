/** 
(c) 2020 Capitalise
Developed by Revolent Group, London (United Kingdom)
@date 07/2020 
@author Kevin Tchaka 
*/
public with sharing class CustomTalkdeskActivityTriggerHelper {
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < talkdesk__Talkdesk_Activity__c > newList,
        Map < Id, talkdesk__Talkdesk_Activity__c > newMap,
        List < talkdesk__Talkdesk_Activity__c > oldList,
        Map < Id, talkdesk__Talkdesk_Activity__c > oldMap
    ) {
        switch on triggerEvent {
            when AFTER_INSERT {
                createAccountActivity(newList);
            }
        }
    }

    public static void createAccountActivity(List<talkdesk__Talkdesk_Activity__c> newList)
    {
        List<Task> activitiesToAdd = new List<Task>();
        for(talkdesk__Talkdesk_Activity__c activity : [select Id, Name, talkdesk__Contact__c, talkdesk__Contact__r.AccountId, talkdesk__Account__c, talkdesk__Start_Time__c, talkdesk__User__c, talkdesk__User__r.Name, talkdesk__Notes__c from talkdesk__Talkdesk_Activity__c where Id In :newList and talkdesk__Channel__c = 'SMS'])
        {
            if(activity.talkdesk__Account__c != null || activity.talkdesk__Contact__c != null)
            {
                Task newTask = new Task();
                newTask.WhatId = (activity.talkdesk__Account__c != null) ? activity.talkdesk__Account__c : activity.talkdesk__Contact__r.AccountId;
                newTask.Description = (activity.talkdesk__User__c != null) ? activity.Name + ' by ' + activity.talkdesk__User__r.Name : activity.Name;
                newTask.Description += '\n' + URL.getSalesforcebaseUrl().toExternalForm() + '/' + activity.Id;
                newTask.Description += '\n' + activity.talkdesk__Notes__c;
                newTask.WhoId = activity.talkdesk__Contact__c;
                newTask.ActivityDate = activity.talkdesk__Start_Time__c.date();
                newTask.Status = 'Completed';
                newTask.Subject = activity.Name;
                newTask.OwnerId = (activity.talkdesk__User__c != null) ? activity.talkdesk__User__c : UserInfo.getUserId();

                activitiesToAdd.add(newTask);
            }
        }

        insert activitiesToAdd;
    }
}