/** 
(c) 2018 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date 09/2018 
@author Miguel Sampaio - Kevin Tchaka 

@modifications 14/01 [MS] - Change the Introducer Object and fields reference to Account Object. 
                        - There were to methods, 1 to sum Commission and other to count Opps. These 2 methods were merged.
@modifications 29/05/2020 [KT] - Added 3 methods 1 to return a boolean indication of whether a funding search is secured, another to
                                retrieve and estimate the occupancy of unsecured funding specialists and finally one to assign the least busy specialist to a funding search.
                                - Added the setSecured method to set the Secured field for funding searches.
*/
public with sharing class rsOpportunityChangeContactStageHelper {
    // Trigger entry point
    public static Boolean hasRan = false;
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < Opportunity > newList,
        Map < Id, Opportunity > newMap,
        List < Opportunity > oldList,
        Map < Id, Opportunity > oldMap
    ) {
        // Dispatch trigger event to corresponding methods 
        switch on triggerEvent {
            when AFTER_INSERT {
                // Processing for after insert an Opportunity
                changeOwnerOpportunity(newList);
                countOppsAndSumCommission(newList);
                countAccountOpportunitiesAndSumCommission(newList);
                contactRelationshipStage(newList);
                lastFundingSearchInserted(newList);
                //SubscriptionOpportunityUpdateLineItemSchedules(newList);
            }
            when AFTER_UPDATE {
                // Processing for after update an Opportunity
                if (!hasRan) {
                    countOppsAndSumCommission(newList);
                    countAccountOpportunitiesAndSumCommission(newList);
                    contactRelationshipStage(newList);
                    lastFundingSearchInserted(newList);
                    webhook(newList, oldMap);
                    createTaskOnPaidOutOpportunity(newList);
                    reparentTasksOnFSUpdate(newList, oldMap);
                    //SubscriptionOpportunityUpdateLineItemSchedules(newList);
                    hasRan = true;
                }
            }
            when BEFORE_INSERT {
                // Processing for before insert an Opportunity
                //opportunitySubscriptionFieldsValidationRule(newList);
                setCloseDateAndOwner(newList);
                List<Opportunity> funding_searches = new List<Opportunity>();
                Id invoiceFinanceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Invoice Finance').getRecordTypeId();
                Map < Id, Schema.RecordTypeInfo > opportunityRecordTypeByIdMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
                for(Opportunity opportunityRecord : newList)
                {
                    if(opportunityRecord.Name.contains('IF')) {
                        opportunityRecord.RecordTypeId = invoiceFinanceRecordTypeId;
                    }
                    if(opportunityRecordTypeByIdMap.get(opportunityRecord.RecordTypeId).getName() == 'Funding Search') 
                        funding_searches.add(opportunityRecord);
                }
                setSecured(funding_searches);
                assignSpecialistToUnsecuredSearches(funding_searches);
            }
            when BEFORE_UPDATE {
                // Processing for before update an Opportunity
                //opportunitySubscriptionFieldsValidationRule(newList);
                setCloseDateAndOwner(newList);
                paidOutOpportunityChange(newList, oldMap);
                CanceledOpportunityReasonFinder(newList, oldMap);
            }
            when AFTER_DELETE {
                // Process when is deleted an Opportunity
                countOppsAndSumCommission(oldList);
                countAccountOpportunitiesAndSumCommission(oldList);
                contactRelationshipStage(oldList);
            }
        }
    }

    /**
     * @description Helper method to validate is required fields are filled when an Opportunity is Closed Won
     
    public static void opportunitySubscriptionFieldsValidationRule(List < Opportunity > newList) {

        Map < Id, Schema.RecordTypeInfo > opportunityRecordTypeByIdMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();

        for (Opportunity opportunityRecord: newList) {
            string errorMessage = 'You must fill the field(s):';
            if (opportunityRecordTypeByIdMap.get(opportunityRecord.RecordTypeId).getName() == 'Subscription' && opportunityRecord.StageName == 'Closed Won') {
                if (opportunityRecord.First_SaaS_Meeting__c == null) errorMessage += ' First SaaS Meeting;';
            }
            if (errorMessage != 'You must fill the field(s):') {
                opportunityRecord.addError(errorMessage);
            }
        }

    }*/

    /**
     * @description Helper method to set Opportunity Owner as Introducer Owner when an Opportunity is Inserted
     */
    public static void changeOwnerOpportunity(List < Opportunity > newList) {

        List < Opportunity > listOpportunities = new List < Opportunity > ();
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();

        for (Opportunity opportunityRecord: [SELECT Id, name, Introducer_new__r.OwnerId, Introducer_new__r.RecordTypeId, Ownerid, Owner.profileid, Owner_Locked__c FROM Opportunity WHERE Id IN: newList]) {
            Opportunity o = new Opportunity();
            o.Id = opportunityRecord.Id;
            if (opportunityRecord.Introducer_new__r.RecordTypeId == introducerRecordTypeId && !opportunityRecord.Owner_Locked__c) {
                o.OwnerId = opportunityRecord.Introducer_new__r.OwnerId;
            }
            listOpportunities.add(o);
        }

        update listOpportunities;
    }

    /**
     * @description Helper method - if an Opportunity change to paid out the closedate and paid out date is today
     */
    public static void paidOutOpportunityChange(List < Opportunity > newList, Map < Id, Opportunity > oldMap) {

        Set<String> oppIds = new Set<String>();
        for (Opportunity opportunityRecord: newList) {
            Boolean oldCheck = oldMap != null ? oldMap.get(opportunityRecord.id).IsClosed : false;
            Boolean oldPaidOut = oldMap != null ? oldMap.get(opportunityRecord.id).StageName != 'Paid Out' : true;

            if (opportunityRecord.IsClosed && !oldCheck) {
                opportunityRecord.CloseDate = System.today();
            }

            if (opportunityRecord.StageName == 'Paid Out' && oldPaidOut) {
                opportunityRecord.Paid_Out_Date__c = System.today();
                opportunityRecord.PaidDate__c = System.today();
                oppIds.add(opportunityRecord.CapitaliseExtId__c);
            }
            else if(opportunityRecord.StageName == 'Paid Out')
            {
                opportunityRecord.PaidDate__c = (opportunityRecord.PaidDate__c == null) ? opportunityRecord.Paid_Out_Date__c : opportunityRecord.PaidDate__c;
                //oppIds.add(opportunityRecord.CapitaliseExtId__c);
            }
        }

        if(!System.isFuture() && !Test.isRunningTest() && !CapAPPCallouts.runningInASandbox && !System.isBatch()) 
        {
            if(oppIds.size() > 0 && oppIds.size() < 25) CapAPPCallouts.UpdatePaidOutFundingSearches(oppIds);
            else if(oppIds.size() >= 25)
            {
                List<String> escapedOppIds = new List<String>();
                for(String extId : oppIds)
                    escapedOppIds.add(String.escapeSingleQuotes(extId));
                String query = 'select Id, CapitaliseExtId__c, PaidValue__c, PaidProductType__c, Has_Invoice_Finance__c from Opportunity where StageName = \'Paid Out\' and PaidValue__c = null and CapitaliseExtId__c in (' + String.join(escapedOppIds, ', ') + ')';
                BatchUpdatePaidOutFundingSearches job = new BatchUpdatePaidOutFundingSearches(query);
                // Schedule the test job
                String jobId = Database.executeBatch(job);
            }
        }
    }

    /**
        * @description Helper method to counts the total number of Opportunities and Paid out Opportunities related to the Contacts (Introducer and Business)
        * @description Sum Opportunities Commission related to Contacts (Introducer and Business).
        */
    public static void countOppsAndSumCommission(List < Opportunity > newList) {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
        set < id > setIntroducerContactIds = new set < Id > ();
        set < id > setBusinessContactIds = new set < Id > ();
        for (Opportunity opportunityRecord: newList) {
            if(opportunityRecord.RecordTypeId == fundingSearchRecordTypeId || opportunityRecord.RecordTypeId == securedFundingSearchRecordTypeId){
                setIntroducerContactIds.add(opportunityRecord.Introducer_Contact__c);
                setBusinessContactIds.add(opportunityRecord.Business_Contact__c);
            }
        }

        //Introducer Contacts
        if (setIntroducerContactIds.size() > 0) {
            List < Contact > introducerContactList = [SELECT Confirmed_Commission_Ex_VAT__c, Introducer_Contact_Opportunities__c, Number_of_Paid_out_Opportunities__c, (SELECT Id, StageName, Confirmed_Commission_Ex_VAT__c FROM IntroducerContact_Opportunities__r) FROM Contact WHERE Id in: setIntroducerContactIds];
            if (introducerContactList.size() > 0) {
                for (Contact contactRecord: introducerContactList) {
                    contactRecord.Introducer_Contact_Opportunities__c = contactRecord.IntroducerContact_Opportunities__r.size();
                    Integer count = 0;
                    Decimal countCommissionVAT = 0;
                    if (contactRecord.IntroducerContact_Opportunities__r.size() > 0) {
                        for (opportunity opportunityRecord: contactRecord.IntroducerContact_Opportunities__r) {
                            if (opportunityRecord.Confirmed_Commission_Ex_VAT__c != null) {
                                countCommissionVAT = countCommissionVAT + opportunityRecord.Confirmed_Commission_Ex_VAT__c;
                            } else {
                                countCommissionVAT = 0;
                            }
                            if (opportunityRecord.StageName == 'Paid Out') {
                                count = count + 1;
                            }
                            contactRecord.Number_of_Paid_out_Opportunities__c = count;
                            contactRecord.Confirmed_Commission_Ex_VAT__c = countCommissionVAT;
                        }
                    } else {
                        contactRecord.Number_of_Paid_out_Opportunities__c = 0;
                        contactRecord.Confirmed_Commission_Ex_VAT__c = 0;
                    }
                }
                update introducerContactList;
            }
        }

        //Business Contacts
        if (setBusinessContactIds.size() > 0) {
            List < Contact > businessContactList = [SELECT Confirmed_Commission_Ex_VAT__c, Introducer_Contact_Opportunities__c, Number_of_Paid_out_Opportunities__c, (SELECT Id, StageName, Confirmed_Commission_Ex_VAT__c FROM BusinessContact_Opportunities__r) FROM Contact WHERE Id in: setBusinessContactIds];
            if (businessContactList.size() > 0) {
                for (Contact contactRecord: businessContactList) {
                    contactRecord.Introducer_Contact_Opportunities__c = contactRecord.BusinessContact_Opportunities__r.size();
                    Integer count = 0;
                    Decimal countCommissionVAT = 0;
                    if (contactRecord.BusinessContact_Opportunities__r.size() > 0) {
                        for (opportunity opportunityRecord: contactRecord.BusinessContact_Opportunities__r) {
                            if (opportunityRecord.Confirmed_Commission_Ex_VAT__c != null) {
                                countCommissionVAT = countCommissionVAT + opportunityRecord.Confirmed_Commission_Ex_VAT__c;
                            } else {
                                countCommissionVAT = 0;
                            }
                            if (opportunityRecord.StageName == 'Paid Out') {
                                count = count + 1;
                            }
                            contactRecord.Number_of_Paid_out_Opportunities__c = count;
                            contactRecord.Confirmed_Commission_Ex_VAT__c = countCommissionVAT;
                        }
                    } else {
                        contactRecord.Number_of_Paid_out_Opportunities__c = 0;
                        contactRecord.Confirmed_Commission_Ex_VAT__c = 0;
                    }
                }
                update businessContactList;
            }
        }
    }


    /**
     * @description Helper method to Count All Opportunities and Paid Out Opportunities Related to an Account (Introducer and Business)
     * @description Sum Opportunities Commission related to Accounts.(Introducer and Business)
     */
    public static void countAccountOpportunitiesAndSumCommission(List < Opportunity > newList) {

        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
        Set < Id > setBusinessId = new Set < Id > ();
        Set < Id > setIntroducerId = new Set < Id > ();
        for (Opportunity opportunityRecord: newList) {
            system.debug(opportunityRecord.Name);
            system.debug(opportunityRecord.RecordTypeId);
            system.debug(fundingSearchRecordTypeId);
            if(opportunityRecord.RecordTypeId == fundingSearchRecordTypeId || opportunityRecord.RecordTypeId == securedFundingSearchRecordTypeId){
            setBusinessId.add(opportunityRecord.AccountId);
            setIntroducerId.add(opportunityRecord.Introducer_new__c);
            }
        }

        system.debug(setBusinessId);
         system.debug(setIntroducerId);

        //Business
        if (setBusinessId.size() > 0) {
            List < Account > businessList = [SELECT Confirmed_Commission_Ex_VAT__c, Number_of_Opportunities__c, Number_of_Paid_out_Opportunities__c, (SELECT Id, StageName, Confirmed_Commission_Ex_VAT__c FROM Opportunities) FROM Account WHERE Id in: setBusinessId];
            if (businessList.size() > 0) {
                for (Account accountRecord: businessList) {
                    System.debug('aquibusiness');
                    system.debug(accountRecord.Opportunities.size());
                    accountRecord.Number_of_Opportunities__c = accountRecord.Opportunities.size();
                    Integer count = 0;
                    Decimal countCommissionVAT = 0;
                    if (accountRecord.Opportunities.size() > 0) {
                        for (opportunity opportunityRecord: accountRecord.Opportunities) {
                            if (opportunityRecord.Confirmed_Commission_Ex_VAT__c != null) {
                                countCommissionVAT = countCommissionVAT + opportunityRecord.Confirmed_Commission_Ex_VAT__c;
                            } else {
                                countCommissionVAT = 0;
                            }
                            if (opportunityRecord.StageName == 'Paid Out') {
                                count = count + 1;
                            }
                            accountRecord.Number_of_Paid_out_Opportunities__c = count;
                            accountRecord.Confirmed_Commission_Ex_VAT__c = countCommissionVAT;
                        }
                    } else {
                        accountRecord.Number_of_Paid_out_Opportunities__c = 0;
                        accountRecord.Confirmed_Commission_Ex_VAT__c = 0;
                    }
                }
                update businessList;
            }
        }
        //Introducers
        if (setIntroducerId.size() > 0) {
            List < Account > introducerList = [SELECT Confirmed_Commission_Ex_VAT__c, Number_of_Opportunities__c, Number_of_Paid_out_Opportunities__c, (SELECT Id, StageName, Confirmed_Commission_Ex_VAT__c FROM Introducer_Opportunities__r) FROM Account WHERE Id in: setIntroducerId];
            if (introducerList.size() > 0) {
                System.debug('aquiinyto');
                for (Account accountRecord: introducerList) {
                    accountRecord.Number_of_Opportunities__c = accountRecord.Introducer_Opportunities__r.size();
                    Integer count = 0;
                    Decimal countCommissionVAT = 0;
                    if (accountRecord.Introducer_Opportunities__r.size() > 0) {
                        for (opportunity opportunityRecord: accountRecord.Introducer_Opportunities__r) {
                            if (opportunityRecord.Confirmed_Commission_Ex_VAT__c != null) {
                                countCommissionVAT = countCommissionVAT + opportunityRecord.Confirmed_Commission_Ex_VAT__c;
                            } else {
                                countCommissionVAT = 0;
                            }
                            if (opportunityRecord.StageName == 'Paid Out') {
                                count = count + 1;
                            }
                            accountRecord.Number_of_Paid_out_Opportunities__c = count;
                            accountRecord.Confirmed_Commission_Ex_VAT__c = countCommissionVAT;
                        }
                    } else {
                        accountRecord.Number_of_Paid_out_Opportunities__c = 0;
                        accountRecord.Confirmed_Commission_Ex_VAT__c = 0;
                    }
                }
                update introducerList;
            }
        }
    }

    /**
     * @description Helper method to set the right stage to Introducer contact relationShip Stage according to the number of Paid out and submitted opportunities
     */
    public static void contactRelationshipStage(list < Opportunity > newList) {
        
        Id debtRecoveryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Recovery').getRecordTypeId();
        Set < Id > setContactIds = new Set < Id > ();
        for (Opportunity opportunityRecord: newList) {
            if(opportunityRecord.RecordTypeId != debtRecoveryRecordTypeId)
                setContactIds.add(opportunityRecord.Introducer_Contact__c);
        }

        List < Contact > contactsList = new List < Contact > ();
        for (Contact contactRecord: [SELECT Id, Introducer_Contact_Opportunities__c, Number_of_Paid_out_Opportunities__c FROM Contact WHERE Id IN: setContactIds]) {
            contact updatedContact = new contact();
            updatedContact.Id = contactRecord.Id;
            if (contactRecord.Introducer_Contact_Opportunities__c == 1) {
                updatedContact.Relationship_Stage__c = 'Activation';
                system.debug('Activation');
            }
            if (contactRecord.Number_of_Paid_out_Opportunities__c == 1 && contactRecord.Introducer_Contact_Opportunities__c == 1) {
                updatedContact.Relationship_Stage__c = 'First Client';
                system.debug('First Client');
            }
            if (contactRecord.Number_of_Paid_out_Opportunities__c == 1 && contactRecord.Introducer_Contact_Opportunities__c >= 2) {
                updatedContact.Relationship_Stage__c = 'Servicing';
                system.debug('Servicing');
            }
            if (contactRecord.Number_of_Paid_out_Opportunities__c >= 2 && contactRecord.Introducer_Contact_Opportunities__c >= 3) {
                updatedContact.Relationship_Stage__c = 'Advocacy';
                system.debug('Advocacy');
            }
            contactsList.add(updatedContact);
        }

        update contactsList;

    }

    /**
     * @description Helper method to set the last funding search date on Introducer
     */
    public static void lastFundingSearchInserted(list < Opportunity > newList) {
        List < Contact > contactList = new List < Contact > ();
        for (Opportunity opportunityRecord: [SELECT Id, CreatedDate, Introducer_Contact__r.Last_Funding_Search_Date__c, Introducer_Contact__c FROM Opportunity WHERE Id IN: newList]) {
            if (opportunityRecord.Introducer_Contact__c != null && (opportunityRecord.Introducer_Contact__r.Last_Funding_Search_Date__c < opportunityRecord.CreatedDate.date() || opportunityRecord.Introducer_Contact__r.Last_Funding_Search_Date__c == null)) {
                contact contactRecord = new contact();
                contactRecord.id = opportunityRecord.Introducer_Contact__c;
                contactRecord.Last_Funding_Search_Date__c = opportunityRecord.CreatedDate.date();
                if(!contactList.contains(contactRecord))
                    contactList.add(contactRecord);
            }
        }
        update contactList;
    }

    /**
     * @description Helper method to Create a task when has a paid out date and has an Invoice Finance.
     */
    public static void createTaskOnPaidOutOpportunity(list < Opportunity > newList) {
        Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;
        List<User> funding_specialists = [select Id, isActive from User where ProfileId=:fundingSpecialistProfileId and isActive=true];
        List<Id> fsIds = new List<Id>();
        List<Id> assignedFSIds = new List<Id>();
        for(Opportunity opportunityRecord : newList)
        {
            assignedFSIds.add(opportunityRecord.Funding_Specialist__c);
        }
        
        List<Task> existingTasks = [select Id, WhatId from Task where Subject Like '% RE-ENGAGEMENT' and Status!='Completed' and WhatId in :newList];
        Set<Id> alreadyProcessedOpps = new Set<Id>();
        for(Task t : existingTasks)
            alreadyProcessedOpps.add(t.WhatId);

        List<User> assigned_funding_specialists = [select Id, isActive from User where Id in :assignedFSIds];
        Map<Id, Boolean> user_active = new Map<Id, Boolean>();
        for(User a_user : assigned_funding_specialists)
            user_active.put(a_user.Id, a_user.isActive);
        for(User fs : funding_specialists)
            fsIds.add(fs.Id);

        List < Task > listTask = new List < Task > ();

        for (Opportunity opportunityRecord: newList) {
            if (opportunityRecord.StageName == 'Paid Out' && opportunityRecord.PaidValue__c != null && opportunityRecord.PaidProductType__c != null && !alreadyProcessedOpps.contains(opportunityRecord.Id)) {
                Date paidDate = Date.newInstance(opportunityRecord.PaidDate__c.year(), opportunityRecord.PaidDate__c.month(), opportunityRecord.PaidDate__c.day());
                
                Id randomFS = fsIds[Math.abs(Math.mod(Crypto.getRandomInteger(), fsIds.size()))];
                Id fsOrRandom;

                if(user_active.containsKey(opportunityRecord.Funding_Specialist__c))
                    fsOrRandom = (user_active.get(opportunityRecord.Funding_Specialist__c)) ? opportunityRecord.Funding_Specialist__c : randomFS;
                else if(opportunityRecord.Funding_Specialist__c != null)
                    fsOrRandom = opportunityRecord.Funding_Specialist__c;
                else
                    fsOrRandom = randomFS;
                Integer productType = (Integer)opportunityRecord.PaidProductType__c;
                switch on productType {
                    when 1 {
                        Task fstask = new Task();

                        fstask.OwnerId = (opportunityRecord.Funding_Specialist__c != null) ? opportunityRecord.Funding_Specialist__c : randomFS;
                        fstask.ActivityDate = paidDate.addMonths(6);
                        fstask.Priority = 'Normal';
                        fstask.Status = 'Not Started';
                        fstask.Subject = 'TL RE-ENGAGEMENT';
                        fstask.WhatId = opportunityRecord.Id;

                        if(fstask.OwnerId != null) listTask.add(fstask);
                    }
                    when 16 {
                        Task fstask = new Task();

                        fstask.OwnerId = (opportunityRecord.Funding_Specialist__c != null) ? opportunityRecord.Funding_Specialist__c : randomFS;
                        fstask.ActivityDate = paidDate + 270;
                        fstask.Priority = 'Normal';
                        fstask.Status = 'Not Started';
                        fstask.Subject = 'IF RE-ENGAGEMENT';
                        fstask.WhatId = opportunityRecord.Id;

                        if(fstask.OwnerId != null) listTask.add(fstask);
                    }
                }
            }
        }
        if(listTask.size() > 0) insert listTask;
    }

    /**
     * @description Helper method to set the Close Date if null and Owner when inserted from the platform. 
     */
    public static void setCloseDateAndOwner(List < Opportunity > newList) {
        List < CloseDateRule__c > closeDateRule = CloseDateRule__c.getall().values();
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id debtRecoveryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Recovery').getRecordTypeId();
        Id creditImprovementRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Credit Improvement').getRecordTypeId();
        Id grantsRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Grants').getRecordTypeId();
        Id rdTaxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('R&D Tax').getRecordTypeId();

        Set<Id> casOppTypes = new Set<Id> {debtRecoveryRecordTypeId, creditImprovementRecordTypeId, grantsRecordTypeId, rdTaxRecordTypeId};
        Set < Id > accIds = new Set<Id>();
        for(Opportunity opportunityRecord: newList)
        {
            if(opportunityRecord.Introducer_new__c != null)
            {
                accIds.add(opportunityRecord.Introducer_new__c);
            }
            else if(casOppTypes.contains(opportunityRecord.RecordTypeId)) 
            {
                accIds.add(opportunityRecord.AccountId);
            }
        }

        Map < id, string > accountMap = new Map < id, string > ();

         for (Account accountRecord: [SELECT Id, OwnerId FROM Account WHERE Id IN: accIds]) {
            accountMap.put(accountRecord.Id, accountRecord.OwnerId);
        }

        for (Opportunity opportunityRecord: newList) {
            if (opportunityRecord.CloseDate == Null) {
                opportunityRecord.CloseDate = (closeDateRule.size() > 0) ? date.today() + (integer)(closeDateRule[0].Days__c) : date.today() + 7;
            }
        }

        Profile profileName = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileid()];

        for (Opportunity opportunityRecord: newList) {
            if (profileName.Name == 'API Only') {
                // if Account exists set the same Owner
                if (opportunityRecord.Introducer_new__c != null && !opportunityRecord.Owner_Locked__c) {
                    opportunityRecord.OwnerId = accountMap.get(opportunityRecord.Introducer_new__c);
                }else if (casOppTypes.contains(opportunityRecord.RecordTypeId)) {
                    opportunityRecord.OwnerId = accountMap.get(opportunityRecord.AccountId);
                }
            }
        }
    }

    /**
     * @description Helper method to send info to webhook.
     */
    public static void webhook(List < Opportunity > newList, Map < Id, Opportunity > oldMap) {

        Profile profileName = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileid()];

        if (profileName.Name != 'API Only') {
            for (Opportunity opportunityRecord: newList) {
                if (opportunityRecord.CapitaliseExtId__c != null) {
                    List < Opportunity > oppList = new List < Opportunity > ();
                    List < Opportunity > oldList = new List < Opportunity > ();
                    oppList.add(opportunityRecord);
                    oldList.add(oldMap.get(opportunityRecord.Id));
                    String content = WebhookHelper.jsonContent(oppList, oldList);
                    if(!System.isFuture() && !Test.isRunningTest() && !System.isBatch()) WebhookHelper.callout(content);
                }
            }
        }
    }

    public static void SubscriptionOpportunityUpdateLineItemSchedules(List<Opportunity> newList)
    {
        Id subscriptionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
        List<Opportunity> subscriptionOpportunities = new List<Opportunity>();
        for (Opportunity opportunityRecord: newList) {
            if (opportunityRecord.RecordTypeId == subscriptionRecordTypeId)
            {
                subscriptionOpportunities.add(opportunityRecord);
            }
        }

        List<OpportunityLineItem> itemsList = [select Id, OpportunityId from OpportunityLineItem where OpportunityId in :subscriptionOpportunities];
        List<OpportunityLineItemSchedule> itemSchedulesList = [select Id from OpportunityLineItemSchedule where OpportunityLineItemId in :itemsList];
        if(itemSchedulesList.size() > 0) update itemSchedulesList;
    }

    public static void CanceledOpportunityReasonFinder(List<Opportunity> newList, Map<Id, Opportunity> oldMap)
    {
        DateTime runTime = system.now().addMinutes(15);
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String cronRunTime = '0 ' + runTime.minute() + ' ' + runTime.hour() + ' ' + runTime.day() + ' ' + runTime.month() + ' ?';
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opportunityRecord: newList) 
        {
            if(oldMap.get(opportunityRecord.id).StageName != 'Canceled' && opportunityRecord.StageName == 'Canceled')
                oppIds.add(opportunityRecord.Id);
        }

        if(!System.isFuture() && !Test.isRunningTest() && !System.isBatch()) 
        {
            if(oppIds.size() > 0) System.schedule('FundingSearchCancelReasonUpdater ' + h, cronRunTime, new CanceledFundingSearchSchedulable(oppIds));
        }
    }

    /**
     * @description Helper method to reparent open tasks when Funding_Specialist changes. 
     */
    private static void reparentTasksOnFSUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap)
    {
        List<Task> openTasks = new List<Task>();
        for(Opportunity opp : newList) {
            Opportunity prevOpp = oldMap.get(opp.Id);
            if(opp.Funding_Specialist__c != prevOpp.Funding_Specialist__c) {
                for(Task t : [select Id, OwnerId from Task where WhatId=:opp.Id and OwnerId=:prevOpp.Funding_Specialist__c and Status != 'Completed']) {
                    t.OwnerId = opp.Funding_Specialist__c;
                    openTasks.add(t);
                }
            }
        }

        if(openTasks.size() > 0) update openTasks;
    }

    /**
     * @description Helper method returning a boolean indicating whether a funding search is secured or not. 
     */
    private static Boolean isFundingSearchSecured(Opportunity opportunityRecord)
    {
        Boolean secured = false;

        
        if(opportunityRecord.SearchedAmount__c >= 500000 || opportunityRecord.Name.contains(' PF')) secured = true;
        else if(opportunityRecord.Asset_Types__c == null || opportunityRecord.Asset_Types__c == '') secured = false;
        else if(opportunityRecord.Asset_Types__c != null) 
        {
            if(opportunityRecord.Asset_Types__c.contains('Property')) secured = true;
            else if(opportunityRecord.SearchedAmount__c >= 300000)
            {
                if(opportunityRecord.Asset_Types__c.contains('Transportation') || opportunityRecord.Asset_Types__c.contains('Office') || opportunityRecord.Asset_Types__c.contains('Stock') || opportunityRecord.Asset_Types__c.contains('Manufacturing')) secured = true;
            }
        }

        return secured;
    }

    public static void setSecured(List<Opportunity> newList)
    {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id securedFundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Secured Funding Search').getRecordTypeId();
        for (Opportunity opportunityRecord: newList) {
            if (opportunityRecord.RecordTypeId == fundingSearchRecordTypeId)
            {
                opportunityRecord.Secured__c = isFundingSearchSecured(opportunityRecord);
                if(opportunityRecord.Secured__c)
                {
                    opportunityRecord.RecordTypeId = securedFundingSearchRecordTypeId;
                }
            }
        }
    }

    /**
     * @description Helper method to assign the Funding Specialist to an unsecured funding search.
     */
    public static void assignSpecialistToUnsecuredSearches(List<Opportunity> newList)
    {
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
        Id invoiceFinanceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Invoice Finance').getRecordTypeId(); 
        Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;
        List<User> funding_specialists = [select Id, isActive from User where ProfileId=:fundingSpecialistProfileId and isActive=true];
        List<Id> funding_specialist_ids = new List<Id>();
        List<Id> introducers_ids = new List<Id>();
        List<Id> business_ids = new List<Id>();

        for(Opportunity opportunityRecord : newList)
        {
            if(opportunityRecord.AccountId != null) business_ids.add(opportunityRecord.AccountId);
            if(opportunityRecord.Introducer_new__c != null) introducers_ids.add(opportunityRecord.Introducer_new__c);
        }
        List<Account> introducers = [select Id, Name from Account where Id in :introducers_ids];
        List<Account> businesses = [select Id, Name from Account where Id in :business_ids];
        Map<Id, String> introducers_name = new Map<Id, String>();
        Map<Id, String> businesses_name = new Map<Id, String>();

        for(Account acc : introducers)
        {
            introducers_name.put(acc.Id, acc.Name);
        }

        for(Account acc : businesses)
        {
            businesses_name.put(acc.Id, acc.Name);
        }

        for(user a_user : funding_specialists)
            funding_specialist_ids.add(a_user.Id);

        Map<Id, Map<String, Integer>> specialists_stages_count_map = new Map<Id, Map<String, Integer>>();
        for(AggregateResult item : [select Count(Id), StageName, Funding_Specialist__c From Opportunity Where Funding_Specialist__c != null and Funding_Specialist__r.ProfileId=:fundingSpecialistProfileId and RecordTypeId=:fundingSearchRecordTypeId and StageName In ('Incomplete', 'Awaiting Client Contact', 'Awaiting Documents') and Introducer_new__c != null and Introducer_new__r.Name != 'Capitalise' Group By Funding_Specialist__c, StageName, RecordTypeId])
        {
            Id specialist = (Id)item.get('Funding_Specialist__c');
            String stage = (String)item.get('StageName');
            Integer count = (Integer)item.get('expr0');
            Map<String, Integer> stageDetails = new Map<String, Integer>();
            stageDetails.put(stage, count);
            if(!specialists_stages_count_map.containsKey(specialist))
            {
                specialists_stages_count_map.put(specialist, stageDetails);
            }
            else
            {
                Map<String, Integer> stages_count = specialists_stages_count_map.get(specialist);
                stages_count.putAll(stageDetails);
                specialists_stages_count_map.put(specialist, stages_count);
            }
                
        }

        Map<Id, Id> business_specialist_recent = new Map<Id, Id>();
        List<AggregateResult> items = [select Id, DAY_ONLY(CreatedDate), AccountId, Funding_Specialist__c from Opportunity where Funding_Specialist__r.ProfileId=:fundingSpecialistProfileId and AccountId != null and RecordTypeId=:fundingSearchRecordTypeId Group By AccountId, Funding_Specialist__c, Id, DAY_ONLY(CreatedDate) order by DAY_ONLY(CreatedDate) desc];
        for(AggregateResult item : items)
        {
            Id business_id = (Id)item.get('AccountId');
            Id specialist = (Id)item.get('Funding_Specialist__c');
            if(funding_specialist_ids.contains(specialist) && !business_specialist_recent.containsKey(business_id))
                business_specialist_recent.put(business_id, specialist);
        }

        Map<Id, Map<Id, Id>> introducers_specialist_recent = new Map<Id, Map<Id, Id>>();
        items = [select Id, DAY_ONLY(CreatedDate), Introducer_new__c, Introducer_Contact__c, Funding_Specialist__c from Opportunity where Funding_Specialist__r.ProfileId=:fundingSpecialistProfileId and Introducer_new__c != null and Introducer_new__r.Name != 'Capitalise' and RecordTypeId=:fundingSearchRecordTypeId and DAY_ONLY(CreatedDate) = LAST_N_DAYS:30 Group By Introducer_new__c, Introducer_Contact__c, Funding_Specialist__c, Id, DAY_ONLY(CreatedDate) order by DAY_ONLY(CreatedDate) desc];
        for(AggregateResult item : items)
        {
            Id introducer = (Id)item.get('Introducer_new__c');
            Id introducer_contact = (Id)item.get('Introducer_Contact__c');
            Id specialist = (Id)item.get('Funding_Specialist__c');
            if(funding_specialist_ids.contains(specialist))
            {
                if(!introducers_specialist_recent.containsKey(introducer)) 
                {
                    Map<Id, Id> contact_specialist = new Map<Id, Id>();
                    contact_specialist.put(introducer_contact, Specialist);
                    introducers_specialist_recent.put(introducer, contact_specialist);
                }
                else
                {
                    Map<Id, Id> contact_specialist = introducers_specialist_recent.get(introducer);
                    if(!contact_specialist.containsKey(introducer_contact)) contact_specialist.put(introducer_contact, specialist);
                }
            }
        }

        for(Opportunity opportunityRecord : newList)
        {
            String intro_name = introducers_name.get(opportunityRecord.Introducer_new__c);
            if(opportunityRecord.Introducer_new__c == null)
            {
                opportunityRecord.Funding_Specialist__c = null;
            }
            else if(intro_name == 'Capitalise')
            {
                opportunityRecord.Funding_Specialist__c = null;
            }
            else if(!opportunityRecord.Secured__c && opportunityRecord.RecordTypeId == fundingSearchRecordTypeId)
            {
                Boolean assigned = false;
                if(business_specialist_recent.containsKey(opportunityRecord.AccountId))
                {
                    opportunityRecord.Funding_Specialist__c = business_specialist_recent.get(opportunityRecord.AccountId);
                    assigned = true;
                    opportunityRecord.Assignment_Reason__c = 'Recent business specialist!\nBusiness-Specialist recent map:\n' + business_specialist_recent;
                    
                }
                else if(introducers_specialist_recent.containsKey(opportunityRecord.Introducer_new__c))
                {
                    Map<Id, Id> contact_specialist = introducers_specialist_recent.get(opportunityRecord.Introducer_new__c);
                    if(contact_specialist.containsKey(opportunityRecord.Introducer_Contact__c))
                    {
                        opportunityRecord.Funding_Specialist__c = contact_specialist.get(opportunityRecord.Introducer_Contact__c);
                        assigned = true;
                        opportunityRecord.Assignment_Reason__c = 'Recent introducer/contact specialist!\nIntroducer/Contact-Specialist recent map:\n' + introducers_specialist_recent;
                    }
                    else
                    {
                        opportunityRecord.Funding_Specialist__c = contact_specialist.values()[0];
                        assigned = true;
                        opportunityRecord.Assignment_Reason__c = 'Recent introducer specialist!\nIntroducer-Specialist recent map:\n' + introducers_specialist_recent;
                    }

                }

                if(!assigned)
                {
                    Id chosen_specialist = selectSpecialist(specialists_stages_count_map, funding_specialists);
                    opportunityRecord.Funding_Specialist__c = chosen_specialist;
                    opportunityRecord.Assignment_Reason__c = 'Occupancy!\nOccupancy map:\n' + specialists_stages_count_map;
                }
            }
        }
    }

    /**
     * @description Helper method to select the unsecured Funding Specialist with the least occupancy.
     */
    public static Id selectSpecialist(Map<Id, Map<String, Integer>> specialists_stages_count_map, List<User> funding_specialists)
    {
        Id chosen_specialist;
        Integer min_score = 1000000000;

        for(User specialist : funding_specialists)
        {
            if(!specialists_stages_count_map.containsKey(specialist.Id))
            {
                chosen_specialist = specialist.Id;
                min_score = 0;
            }
        }

        for(Id specialist : specialists_stages_count_map.keySet())
        {
            Map<String, Integer> stages_count = specialists_stages_count_map.get(specialist);
            Integer specialist_score = 0, incomplete = 0, awaiting_client = 0, awaiting_document = 0;
            
            if(stages_count.containsKey('Incomplete')) incomplete = stages_count.get('Incomplete');
            if(stages_count.containsKey('Awaiting Client Contact')) awaiting_client = stages_count.get('Awaiting Client Contact');
            if(stages_count.containsKey('Awaiting Documents')) awaiting_document = stages_count.get('Awaiting Documents');

            specialist_score = awaiting_document + awaiting_client*1000 + incomplete*1000000;

            if(specialist_score < min_score)
            {
                min_score = specialist_score;
                chosen_specialist = specialist;
            }
        }

        Map<String, Integer> stages_count = (specialists_stages_count_map.containsKey(chosen_specialist)) ? specialists_stages_count_map.get(chosen_specialist) : new Map<String, Integer>();
        if(stages_count.containsKey('Incomplete'))
        {
            Integer incomplete = stages_count.get('Incomplete');
            stages_count.put('Incomplete', incomplete + 1);
        }
        else
        {
            stages_count.put('Incomplete', 1);
        }
        specialists_stages_count_map.put(chosen_specialist, stages_count);

        return chosen_specialist;
    }
}