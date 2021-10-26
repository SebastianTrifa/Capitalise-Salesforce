/** 
(c) 2020 Capitalise
Developed by Revolent Group, London (United Kingdom)
@date 08/2020 
@author Kevin Tchaka 
*/
public with sharing class TaskTriggerHelper {

    // Trigger entry point
    public static Boolean hasRan = false;
    public static void entry(System.TriggerOperation triggerEvent, List < Task > newList, Map < Id, Task > newMap, List < Task > oldList, Map < Id, Task > oldMap) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                linkOpportunityForSaasTaskProcess(newList);
            }
            when AFTER_INSERT {
                emailSubTaskUpdateLastContactedDateOnContact(newList);
            }
            when AFTER_UPDATE {
                if(!hasRan) {
                    updateRelatedSaasTaskProcessIfRelevant(newList, oldMap);
                    renewReEngagementTasks(newList);
                    hasRan = true;
                }
            }
        }
    }

    public static void renewReEngagementTasks(List<Task> taskList) {
        List<Task> renewals = new List<Task>();

        for(Task t : taskList) {

            if(t.Status == 'Completed') {
                if(t.Subject == 'TL RE-ENGAGEMENT') {
                    Task newTask = t.clone();
                    newTask.ActivityDate = System.today().addMonths(6);
                    newTask.Status = 'Not Started';
                    renewals.add(newTask);
                }
                else if(t.Subject == 'IF RE-ENGAGEMENT') {
                    Task newTask = t.clone();
                    newTask.Status = 'Not Started';
                    newTask.ActivityDate = System.today().addMonths(9);
                    renewals.add(newTask);
                }
            }
        }

        if(!renewals.isEmpty()) insert renewals;
    }

    public static void linkOpportunityForSaasTaskProcess(List<Task> tasksList) {
        Set<Id> saaSTasksProcessIds = new Set<Id>();
        for(Task t : tasksList) {
            if (t.WhatId != null && t.WhatId.getSObjectType() == SaaS_Task_Process__c.SObjectType) {
                saaSTasksProcessIds.add(t.WhatId);
            }
        }

        Map<Id, SaaS_Task_Process__c> processes = new Map<Id, SaaS_Task_Process__c>([select Id, Opportunity__c from SaaS_Task_Process__c where Id in :saaSTasksProcessIds]);

        for(Task t : tasksList) {
            if(processes.containsKey(t.WhatId))
            {
                t.SaaS_Task_Process__c = t.WhatId;
                t.WhatId = processes.get(t.WhatId).Opportunity__c;
            }
        }
    }

    public static void updateRelatedSaasTaskProcessIfRelevant(List<Task> tasksList, Map<Id, Task> oldMap) {
        Set<Id> saaSTasksProcessIds = new Set<Id>();

        for(Task t : tasksList) {
            Task oldTask = oldMap.get(t.Id);
            if (t.SaaS_Task_Process__c != null && t.Status == 'Completed' && oldTask.Status != 'Completed') {
                saaSTasksProcessIds.add(t.SaaS_Task_Process__c);
            }
        }

        List<SaaS_Task_Process__c> processesToUpdate = [select Id, Current_Step__c from SaaS_Task_Process__c where Id in :saaSTasksProcessIds];
        for(SaaS_Task_Process__c process : processesToUpdate) {
            process.Current_Step__c += 1;
        }

        update processesToUpdate;
    }

    private static void emailSubTaskUpdateLastContactedDateOnContact(List<Task> tasksList) {
        set<id> setid = new set<id>();
        for (Task t : tasksList) {
            setid.add(t.id);
        }
        
        list<task> listtask = [select id, email_type__c, TaskSubType, whoid from task where id in: setid];
        system.debug(listtask);
        list<task> listnew = new list<task>();
        List<Contact> listcon = new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        for(task t : listtask){
            system.debug(t.TaskSubtype);
            if(t.TaskSubtype == 'Email'){
                task tas = new task();
                tas.Id = t.id;
                tas.Email_Type__c = 'Email';
                listnew.add(tas);
                
                
                if(t.whoid != null && !conIds.contains(t.whoId)) {
                    String prefix = String.valueOf(t.whoId).substring(0,3);
                    String contactPrefix = Contact.SObjectType.getDescribe().getKeyPrefix();
                    if(prefix == contactPrefix){
                        Contact c = new Contact();
                        c.Id = t.WhoId;
                        c.Last_Contacted_Date__c = system.today();
                        listcon.add(c);
                        conIds.add(t.whoId);
                    }
                }
            }
        }

        update listnew;
        update listcon;
    }
}