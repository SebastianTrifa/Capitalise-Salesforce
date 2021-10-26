/** 
(c) 2018 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date Date of creation 08.2018 
@author Miguel Sampaio 

@description Test class to Task list controller component

@modifications 
*/
@isTest
private class TaskListController_test {
    
    @isTest static void test_method_one() {
        Account intro = new Account ();
        intro.name = 'Test';
        insert intro;
        
        Contact con = new Contact();
        con.lastname = 'Lastest';
        con.AccountId = intro.id;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'In Progress';
        opp.CloseDate = system.today();
        opp.AccountId = intro.id;
        opp.Name = 'Test Opportunity';
        insert opp;
        
        Task t = new Task();
        t.subject = 'Call';
        t.WhoId = con.id;
        t.Start_Date__c = system.today();
        insert t;
        
        Task t1 = new Task();
        t1.subject = 'Call';
        t1.WhatId = opp.id;
        t1.Start_Date__c = system.today();
        insert t1;
        
        event e = new event();
        e.subject = 'Call';
        e.WhoId = con.id;
        e.StartDateTime = system.today();
        e.DurationInMinutes = 10;
        insert e;
        
        event e1 = new event();
        e1.subject = 'Call';
        e1.WhatId = opp.id;
        e1.StartDateTime = system.today();
        e1.DurationInMinutes = 10;
        insert e1;
        
        ContentNote cn = new ContentNote();
        cn.Title = 'test1';
        String body = 'Please work';
        cn.Content = Blob.valueOf(body.escapeHTML4());
        insert cn;
        
        ContentDocumentLink link1 = new ContentDocumentLink();
        link1.ContentDocumentId = cn.id;
        link1.LinkedEntityId = con.id;
        link1.ShareType = 'V';
        link1.Visibility = 'AllUsers';
        
        insert link1;
        
        ContentDocumentLink link2 = new ContentDocumentLink();
        link2.ContentDocumentId = cn.id;
        link2.LinkedEntityId = opp.id;
        link2.ShareType = 'V';
        link2.Visibility = 'AllUsers';
        
        insert link2;
        
        test.StartTest();
        TaskListController.getResultList(intro.id);
        test.StopTest();
        
        
    }
    
    
}