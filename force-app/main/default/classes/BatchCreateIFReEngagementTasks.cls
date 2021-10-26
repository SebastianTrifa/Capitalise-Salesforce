global class BatchCreateIFReEngagementTasks implements Database.Batchable<sObject> {
    
    String query;
    
    global BatchCreateIFReEngagementTasks() {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
        query = 'select Id, OwnerId, Introducer_new__r.OwnerId, PaidDate__c, Funding_Specialist__c from Opportunity where Has_Invoice_Finance__c=true and StageName=\'Paid Out\' and RecordTypeId in (\'' + fundingSearchRecordTypeId + '\',\'' + securedFundingSearchRecordTypeId + '\')';
    }

    global BatchCreateIFReEngagementTasks(Date cutoffdate) {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
        query = 'select Id, OwnerId, Introducer_new__r.OwnerId, PaidDate__c, Funding_Specialist__c from Opportunity where Has_Invoice_Finance__c=true and StageName=\'Paid Out\' and PaidDate__c > ' + ((DateTime)cutoffdate).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' and RecordTypeId in (\'' + fundingSearchRecordTypeId + '\',\'' + securedFundingSearchRecordTypeId + '\')';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Task> taskList = new List<Task>();

        List<FeedItem> posts = new List<FeedItem>();
        Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;
        List<Id> fsIds = new List<Id>();
        List<User> funding_specialists = [select Id, isActive from User where ProfileId=:fundingSpecialistProfileId and isActive=true];

        List<Task> existingTasks = [select Id, WhatId from Task where Subject='IF RE-ENGAGEMENT' and Status!='Completed'];
        Set<Id> alreadyProcessedOpps = new Set<Id>();
        for(Task t : existingTasks)
            alreadyProcessedOpps.add(t.WhatId);

        for(User fs : funding_specialists)
            fsIds.add(fs.Id);

        for(Opportunity opp : scope)
        {
            if(!alreadyProcessedOpps.contains(opp.Id)) {
                Id randomFS = fsIds[Math.abs(Math.mod(Crypto.getRandomInteger(), fsIds.size()))];
                Date paidDate = Date.newInstance(opp.PaidDate__c.year(), opp.PaidDate__c.month(), opp.PaidDate__c.day());

                Task fstask = new Task();
                fstask.OwnerId = opp.Funding_Specialist__c;
                fstask.ActivityDate = paidDate + 270;
                fstask.Priority = 'Normal';
                fstask.Status = 'Not Started';
                fstask.Subject = 'IF RE-ENGAGEMENT';
                fstask.WhatId = opp.Id;
                taskList.add(fstask);

                FeedItem post = new FeedItem();
                post.ParentId = opp.Id;
                post.Body = 'Term Loan Re-Engagement Task added! @[' + opp.Funding_Specialist__c + ']';
                posts.add(post);
            }
            
        }
        Database.SaveResult[] dbsr = Database.insert(taskList, false);
        for(Database.SaveResult sr : dbsr)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully created Task ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Task fields that affected this error: ' + err.getFields());
                }
            }
        }

        Database.SaveResult[] dbsr1 = Database.insert(posts, false);
        for(Database.SaveResult sr : dbsr1)
        {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully created Feed ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Chatter feed fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}