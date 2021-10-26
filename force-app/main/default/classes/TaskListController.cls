public with sharing class TaskListController {
    @AuraEnabled
    public static List<ResultWrapper> getResultList(string recordid){
        
        list<task> listtask = [SELECT id,Isclosed,status, subject, description, whoid, who.name, who.type, What.name, What.type, Start_Date__c FROM Task  WHERE  whoid in (select id from contact where AccountId = :recordid)];
		list<task> listtaskopp = [SELECT id,Isclosed,status, subject, description, whoid, who.name, What.name, What.type, Start_Date__c FROM Task  WHERE  whatid in (select id from opportunity where AccountId = :recordid)];
        list<Event> listEvent = [SELECT id,subject, whoid, who.name, who.type, What.name, What.type, StartDateTime FROM Event  WHERE  whoid in (select id from contact where AccountId = :recordid)];
        list<Event> listEventopp = [SELECT id,subject, whoid, who.name, who.type, What.name, What.type, StartDateTime FROM Event  WHERE  whatid in (select id from opportunity where AccountId = :recordid)];
        list<ContentDocument> listNote = [select id, title,ContentModifiedDate,  (select id, LinkedEntityId, LinkedEntity.name, LinkedEntity.type from contentdocumentlinks where LinkedEntityId in (select id from contact where AccountId = :recordid)) from contentdocument where FileType='snote'];
        list<ContentDocument> listNoteopp = [select id, title,ContentModifiedDate,  (select id, LinkedEntityId, LinkedEntity.name, LinkedEntity.type from contentdocumentlinks where LinkedEntityId in (select id from opportunity where AccountId = :recordid)) from contentdocument where FileType='snote'];
        system.debug('listNote '+listNote);
        list<ResultWrapper> ListWrapper = new list<ResultWrapper>();
        
        for(task t : listtask){
            ListWrapper.add(new ResultWrapper(t.id, t.subject, 'Contact - '+ t.who.name ,t.WhoId, t.Who.type, 'Contact Task', t.Start_Date__c));
        }
        for(task t1 : listtaskopp){
            ListWrapper.add(new ResultWrapper(t1.id, t1.subject, 'Opportunity - ' + t1.what.name ,t1.WhatId, t1.What.type, 'Opportunity Task', t1.Start_Date__c));
        }
        for(event e : listEvent){
            ListWrapper.add(new ResultWrapper(e.id, e.subject,'Contact - '+ e.who.name ,e.WhoId, e.Who.type, 'Contact Event', e.StartDateTime));
        }
        for(event e1 : listEventopp){
            ListWrapper.add(new ResultWrapper(e1.id, e1.subject,'Opportunity - '+ e1.what.name ,e1.WhatId, e1.What.type, 'Opportunity Event', e1.StartDateTime));
        }
        for(ContentDocument n : listNote){
            for(ContentDocumentlink nl : n.contentDocumentLinks){
                ListWrapper.add(new ResultWrapper(n.id, n.title,'Contact - '+ nl.LinkedEntity.name,nl.LinkedEntityId, nl.LinkedEntity.type, 'Contact Note', null));
            }
        }
        for(ContentDocument n : listNoteopp){
            for(ContentDocumentlink nl : n.contentDocumentLinks){
                ListWrapper.add(new ResultWrapper(n.id, n.title,'Opportunity - '+ nl.LinkedEntity.name,nl.LinkedEntityId, nl.LinkedEntity.type, 'Opportunity Note', null));
            }
        }
        
        return ListWrapper;
    }
    
}