/** 
(c) 2021 Capitalise
Developed for Capitalise, London (United Kingdom)
@date 07/2021 
@author Kevin Tchaka 
*/

public with sharing class CDLTriggerHelper {
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < ContentDocumentLink > newList,
        Map < Id, ContentDocumentLink > newMap,
        List < ContentDocumentLink > oldList,
        Map < Id, ContentDocumentLink > oldMap
    ) {
        switch on triggerEvent {
            when AFTER_INSERT {
                EmailNotificationsForNotes(newList);
            }
        }
    }

    public static void EmailNotificationsForNotes(List<ContentDocumentLink> newList) {
        Set<Id> docsIds = new Set<Id>();
        Set<Id> flaggedDocs = new Set<Id>();
        Set<Id> linkedEntitiesId = new Set<Id>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<FeedItem> feeds = new List<FeedItem>();
        List<String> validOppStages = new List<String> {'Reviewing', 'At Offer', 'Awaiting Client', 'With Credit Commitee', 'Approved'};
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        for(ContentDocumentLink cdl : newList) {
            docsIds.add(cdl.ContentDocumentId);
        }

        for(ContentNote cv : [select Id, Title, Content from ContentNote where Title='Funding Match Updated' and Id in :docsIds]) {
            String textContent = cv.Content.toString();
            if(textContent.contains('Private comment'))
                flaggedDocs.add(cv.Id);
        }

        for(ContentDocumentLink cdl : newList) {
            if(flaggedDocs.contains(cdL.ContentDocumentId)) {
                linkedEntitiesId.add(cdL.LinkedEntityId);
            }
        }
        

        for(Opportunity opp : [select Id, Funding_Specialist__c, Funding_Specialist__r.Email, OwnerId, Account.Name from Opportunity where Id in :linkedEntitiesId and StageName in :validOppStages]) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('ACTION REQUIRED - Opportunity');
            mail.setplainTextBody('A lender has updated the opportunity below related to ' + opp.Account.Name + ' - please review\n' + baseUrl + '/' + opp.Id);
            mail.setTargetObjectId(opp.Funding_Specialist__c);
            mail.setToAddresses(new String[] {opp.Funding_Specialist__r.Email});
            mail.setTreatTargetObjectasRecipient(true);
            mail.setWhatId(opp.Id);
            mails.add(mail);

            FeedItem feed = new FeedItem();
            feed.ParentId = (opp.Funding_Specialist__c != null) ? opp.Funding_Specialist__c : opp.OwnerId;
            feed.Body = 'A lender has updated the opportunity below related to ' + opp.Account.Name + ' - please review';
            feed.Body += '\n' + baseUrl + '/' + opp.Id;
            feeds.add(feed);
        }

        if(!feeds.isEmpty()) insert feeds;

        try {
            if (!mails.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);

                Integer mailIndex = 0;
                for(Messaging.SendEmailResult result : results) {
                    if(!result.isSuccess()) {
                        System.debug(result.getErrors());
                    }
                    mailIndex++;
                }
            }
        } catch (Exception ex) {
            System.debug(ex);
        }
    }
}