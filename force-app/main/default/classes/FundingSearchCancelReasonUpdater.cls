/** 
(c) 2020 Capitalise
Developed by Revolent Group, London (United Kingdom)
@date 07/2020 
@author Kevin Tchaka 
*/

public with sharing class FundingSearchCancelReasonUpdater 
{
    @future(callout=false)
    public static void FutureCancelReasonFinder(Set<Id> recordIds)
    {
        DateTime rerunTime = system.now().addMinutes(15);
        String cronRerunTime = '0 ' + rerunTime.minute() + ' ' + rerunTime.hour() + ' ' + rerunTime.day() + ' ' + rerunTime.month() + ' ?';
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);

        try {            
            List<Opportunity> workload = [select Id, Cancel_Reason__c from Opportunity where Id in :recordIds];
            List<Opportunity> updatedOpportunities = CancelReasonFinder(workload);
            
            Set<Id> retryIds = new Set<Id>();
            for(Opportunity opp : updatedOpportunities)
            {
                if(opp.Cancel_Reason__c == null)
                    retryIds.add(opp.Id);
            }
            if(retryIds.size() > 0)
            {
                System.schedule('FundingSearchCancelReasonUpdater' + h, cronRerunTime, new CanceledFundingSearchSchedulable(retryIds));
                b = Crypto.GenerateAESKey(128);
                h = EncodingUtil.ConvertTohex(b);
            } 
            
            update updatedOpportunities;

        } catch (DmlException e) {
            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) System.schedule('FundingSearchCancelReasonUpdater' + h, cronRerunTime, new CanceledFundingSearchSchedulable(recordIds));
        }
        
    }

    public static List<Opportunity> CancelReasonFinder(List<Opportunity> workload) 
    {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : workload)
        {
            oppIds.add(opp.Id);
        }

        Map<Id, List<ContentDocumentLink>> opportunities_notes = new Map<Id, List<ContentDocumentLink>>();

        List<ContentDocumentLink> cdL = [select Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionData from ContentDocumentLink where LinkedEntityId In :oppIds];
        for(ContentDocumentLink cd : cdL)
        {
            if(cd.ContentDocument.LatestPublishedVersion.Title == 'Funding Match Updated')
            {
                if(opportunities_notes.keySet().contains(cd.LinkedEntityId))
                {
                    List<ContentDocumentLink> temp = opportunities_notes.get(cd.LinkedEntityId);
                    temp.add(cd);
                    opportunities_notes.put(cd.LinkedEntityId, temp);
                }
                else 
                {
                    List<ContentDocumentLink> temp = new List<ContentDocumentLink>();
                    temp.add(cd);
                    opportunities_notes.put(cd.LinkedEntityId, temp);
                }
            }
        }

        for(Opportunity opp : workload)
        {
            List<ContentDocumentLink> notes = new List<ContentDocumentLink>();
            if(opportunities_notes.keySet().contains(opp.Id))
                notes = opportunities_notes.get(opp.Id);

            if(notes.size() > 0)
            {
                Map<String, Integer> reason_score = new Map<String, Integer>();

                for(ContentDocumentLink note : notes)
                {
                    String noteContent = note.ContentDocument.LatestPublishedVersion.VersionData.toString().unescapeHtml4();
                    Pattern p = Pattern.compile('reason given was: \"(\\S+(\\s\\S+)*)\".');
                    Matcher m = p.matcher(noteContent);
                    Boolean reasonFound = m.find();
                    if(reasonFound)
                    {
                        String reason = m.group(1);
                        if(reason_score.keySet().contains(reason))
                            reason_score.put(reason, reason_score.get(reason) + 1);
                        else
                            reason_score.put(reason, 1);
                    }
                }

                Integer topScore = 0;

                for(String reason : reason_score.keySet())
                {
                    Integer score = reason_score.get(reason);
                    if(score >= topScore)
                    {
                        opp.Cancel_Reason__c = (topScore == score) ? opp.Cancel_Reason__c + ' | ' + reason : reason;
                        topScore = score;
                    }
                }

                If(reason_score.keySet().size() == 0) opp.Cancel_Reason__c = 'None Assigned!';
            }
        }

        return workload;
    }
}