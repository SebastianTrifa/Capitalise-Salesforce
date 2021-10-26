@isTest
private class TaskUpdateTest {
    
    @TestSetup static void setup(){
        Id MQLTPCARecordTypeId = Schema.SObjectType.SaaS_Task_Process__c.getRecordTypeInfosByName().get('MQL/TP to Call Attempts').getRecordTypeId();

        contact c = new contact ();
        c.lastname = 'test';
        c.Email = 'test@test.com';
        insert c;

        opportunity opp = new opportunity();
        opp.closedate = system.today() + 7;
        opp.name = 'test opp';
        opp.stagename = 'Paid Out';
        opp.Owner_Locked__c = false;
        opp.Opportunity_Contact__c = c.Id;
        insert opp;

        Saas_Task_Process__c process = new Saas_Task_Process__c(Name='Test Process', Current_Step__c=0, RecordTypeId=MQLTPCARecordTypeId, Opportunity__c=opp.Id, Recipient_Contact__c=c.Id);
        insert process;

        Task t = new Task();
        t.Subject = 'Test Task SaaS Task Process';
        t.Type = 'Task';
        t.WhatId = process.Id;
        t.Status = 'Open';
        insert t;

        Task t1 = new Task();
        t1.Subject = 'Test Task SaaS Task Process';
        t1.Type = 'Task';
        t1.WhatId = process.Id;
        t1.Status = 'Completed';
        insert t1;

        Task t2 = new Task();
        t2.Subject = 'IF RE-ENGAGEMENT';
        t2.ActivityDate = System.today();
        t2.Type = 'Task';
        t2.Status = 'Not Started';
        insert t2;
    }

    @isTest static void test_renewal_reengagement() {
        List<Task> tasks = [select Id, Subject, Status from Task where Subject='IF RE-ENGAGEMENT'];
        for(Task t : tasks) {
            t.Status = 'Completed';
        }
        update tasks;

        Task t2 = new Task();
        t2.Subject = 'TL RE-ENGAGEMENT';
        t2.ActivityDate = System.today();
        t2.Type = 'Task';
        t2.Status = 'Not Started';
        insert t2;

        t2.Status = 'Completed';
        update t2;

    }

    @isTest static void test_method_one() {
        contact c = new contact ();
        c.lastname = 'test';
        insert c;

        Lead l = new Lead(LastName='test2', Company='Test Inc');
        insert l;
        
        task t = new task ();
        t.taskSubtype = 'Email';
        t.Subject = 'n';
        t.whoid = c.id;
        insert t;

        task t2 = new task ();
        t2.taskSubtype = 'Email';
        t2.Subject = 'n';
        t2.whoid = l.id;
        insert t2;
    }

    @isTest static void test_saasTaskProcess_related_task_update() {

        List<Task> tasks = [select Id, WhatId, Status from Task where Subject='Test Task SaaS Task Process'];
        for(Task t : tasks) {
            t.Status = 'Completed';
        }
        update tasks;
        system.debug('updated task: ' + tasks);

        Saas_Task_Process__c p = [select Id, Current_Step__c from Saas_Task_Process__c where Name = 'Test Process' limit 1];
        system.debug('queried process: ' + p);

        system.assertEquals(1, p.Current_Step__c);
    }
}