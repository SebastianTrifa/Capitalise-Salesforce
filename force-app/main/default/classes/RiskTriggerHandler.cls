public class RiskTriggerHandler {
    static Map < String, Schema.RecordTypeInfo > riskRecordTypeMap = Schema.SObjectType.Risk__c.getRecordTypeInfosByName();
    static Map < Id, Schema.RecordTypeInfo > riskRecordTypeByIdMap = Schema.SObjectType.Risk__c.getRecordTypeInfosById();

    public static void handleAfterUpdate(Map<Id, Risk__c > newMap, Map<Id, Risk__c > oldMap)
    {
        List < Risk__c > risksToInsert = new List < Risk__c > ();

        for (Risk__c risk: newMap.values()) 
        {
            Risk__c oldRisk = oldMap.get(risk.Id);
            if (risk.Stage__c == 'Won' && oldRisk.Stage__c != 'Won') 
            {
                
                switch on riskRecordTypeByIdMap.get(risk.RecordTypeId).getName() 
                {
                    when 'Onboarding' {
                        Risk__c riskToInsert = risk.clone();
                        riskToInsert.Close_Date__c = null;
                        riskToInsert.Start_Date__c = System.today();
                        riskToInsert.Stage__c = 'Identified';
                        riskToInsert.RecordTypeId = riskRecordTypeMap.get('Foundation').getRecordTypeId();
                        riskToInsert.Name = risk.Name.replace('Onboarding', 'Foundation');
                        riskToInsert.Graduation_Date__c = Date.today().addDays(60);
                        riskToInsert.Identified_Stage_Duration__c = 0;
                        riskToInsert.Handover_Stage_Duration__c = 0;
                        riskToInsert.Team_Demo_Stage_Duration__c = 0;
                        riskToInsert.Training_Stage_Duration__c = 0;
                        riskToInsert.Cohort_Stage_Duration__c = 0;
                        riskToInsert.Planning_Stage_Duration__c = 0;
                        riskToInsert.Communication_Stage_Duration__c = 0;
                        riskToInsert.Creation_Stage_Duration__c = 0;
                        riskToInsert.Market_Stage_Duration__c = 0;
                        riskToInsert.Marketing_Stage_Duration__c = 0;
                        riskToInsert.FivePercent_Stage_Duration__c = 0;
                        riskToInsert.Discovery_Stage_Duration__c = 0;
                        riskToInsert.Action_Stage_Duration__c = 0;
                        riskToInsert.Implementation_Stage_Duration__c = 0;
                        riskToInsert.Review_Stage_Duration__c = 0;
                        riskToInsert.Above_Five_Percent_Stage_Duration__c = 0;
                        risksToInsert.add(riskToInsert);
                    }
                    when 'Foundation' {
                        Risk__c riskToInsert = risk.clone();
                        riskToInsert.Close_Date__c = null;
                        riskToInsert.Start_Date__c = System.today();
                        riskToInsert.Stage__c = 'Identified';
                        riskToInsert.RecordTypeId = (risk.Membership_Level__c == 'Starter') ? riskRecordTypeMap.get('Promote').getRecordTypeId() : riskRecordTypeMap.get('Initial Launch').getRecordTypeId();
                        riskToInsert.Name = (risk.Membership_Level__c == 'Starter') ? risk.Name.replace('Foundation', 'Promote') : risk.Name.replace('Foundation', 'Initial Launch');
                        riskToInsert.Graduation_Date__c = Date.today().addDays(60);
                        riskToInsert.Identified_Stage_Duration__c = 0;
                        riskToInsert.Handover_Stage_Duration__c = 0;
                        riskToInsert.Team_Demo_Stage_Duration__c = 0;
                        riskToInsert.Training_Stage_Duration__c = 0;
                        riskToInsert.Cohort_Stage_Duration__c = 0;
                        riskToInsert.Planning_Stage_Duration__c = 0;
                        riskToInsert.Communication_Stage_Duration__c = 0;
                        riskToInsert.Creation_Stage_Duration__c = 0;
                        riskToInsert.Market_Stage_Duration__c = 0;
                        riskToInsert.Marketing_Stage_Duration__c = 0;
                        riskToInsert.FivePercent_Stage_Duration__c = 0;
                        riskToInsert.Discovery_Stage_Duration__c = 0;
                        riskToInsert.Action_Stage_Duration__c = 0;
                        riskToInsert.Implementation_Stage_Duration__c = 0;
                        riskToInsert.Review_Stage_Duration__c = 0;
                        riskToInsert.Above_Five_Percent_Stage_Duration__c = 0;
                        risksToInsert.add(riskToInsert);
                    }
                    when 'Initial Launch' 
                    {
                        Risk__c riskToInsert = risk.clone();
                        riskToInsert.Close_Date__c = null;
                        riskToInsert.Start_Date__c = System.today();
                        riskToInsert.Stage__c = 'Identified';
                        riskToInsert.RecordTypeId = riskRecordTypeMap.get('Promote').getRecordTypeId();
                        riskToInsert.Name = risk.Name.replace('Initial Launch', 'Promote');
                        riskToInsert.Graduation_Date__c = Date.today().addDays(60);
                        riskToInsert.Identified_Stage_Duration__c = 0;
                        riskToInsert.Handover_Stage_Duration__c = 0;
                        riskToInsert.Team_Demo_Stage_Duration__c = 0;
                        riskToInsert.Training_Stage_Duration__c = 0;
                        riskToInsert.Cohort_Stage_Duration__c = 0;
                        riskToInsert.Planning_Stage_Duration__c = 0;
                        riskToInsert.Communication_Stage_Duration__c = 0;
                        riskToInsert.Creation_Stage_Duration__c = 0;
                        riskToInsert.Market_Stage_Duration__c = 0;
                        riskToInsert.Marketing_Stage_Duration__c = 0;
                        riskToInsert.FivePercent_Stage_Duration__c = 0;
                        riskToInsert.Discovery_Stage_Duration__c = 0;
                        riskToInsert.Action_Stage_Duration__c = 0;
                        riskToInsert.Implementation_Stage_Duration__c = 0;
                        riskToInsert.Review_Stage_Duration__c = 0;
                        riskToInsert.Above_Five_Percent_Stage_Duration__c = 0;
                        risksToInsert.add(riskToInsert);
                    }
                    when 'Promote' {
                        Risk__c riskToInsert = risk.clone();
                        riskToInsert.Close_Date__c = null;
                        riskToInsert.Start_Date__c = System.today();
                        riskToInsert.Stage__c = 'Identified';
                        riskToInsert.RecordTypeId = riskRecordTypeMap.get('Growth').getRecordTypeId();
                        riskToInsert.Name = risk.Name.replace('Promote', 'Growth');
                        riskToInsert.Graduation_Date__c = Date.today().addDays(60);
                        riskToInsert.Identified_Stage_Duration__c = 0;
                        riskToInsert.Handover_Stage_Duration__c = 0;
                        riskToInsert.Team_Demo_Stage_Duration__c = 0;
                        riskToInsert.Training_Stage_Duration__c = 0;
                        riskToInsert.Cohort_Stage_Duration__c = 0;
                        riskToInsert.Planning_Stage_Duration__c = 0;
                        riskToInsert.Communication_Stage_Duration__c = 0;
                        riskToInsert.Creation_Stage_Duration__c = 0;
                        riskToInsert.Market_Stage_Duration__c = 0;
                        riskToInsert.Marketing_Stage_Duration__c = 0;
                        riskToInsert.FivePercent_Stage_Duration__c = 0;
                        riskToInsert.Discovery_Stage_Duration__c = 0;
                        riskToInsert.Action_Stage_Duration__c = 0;
                        riskToInsert.Implementation_Stage_Duration__c = 0;
                        riskToInsert.Review_Stage_Duration__c = 0;
                        riskToInsert.Above_Five_Percent_Stage_Duration__c = 0;
                        risksToInsert.add(riskToInsert);
                    }
                    /* when 'Growth' {
                        risk.Close_Date__c = System.today();
                    } */
                    when 'Retention' {
                        Risk__c riskToInsert = risk.clone();
                        riskToInsert.Close_Date__c = null;
                        riskToInsert.Start_Date__c = System.today();
                        riskToInsert.RecordTypeId = riskRecordTypeMap.get('Foundation').getRecordTypeId();
                        riskToInsert.Name = risk.Name.replace('Retention', 'Foundation');
                        riskToInsert.Graduation_Date__c = Date.today().addDays(60);
                        riskToInsert.Stage__c = 'Identified';
                        riskToInsert.Open_Reason__c = 'Successful retention';
                        riskToInsert.Identified_Stage_Duration__c = 0;
                        riskToInsert.Handover_Stage_Duration__c = 0;
                        riskToInsert.Team_Demo_Stage_Duration__c = 0;
                        riskToInsert.Training_Stage_Duration__c = 0;
                        riskToInsert.Cohort_Stage_Duration__c = 0;
                        riskToInsert.Planning_Stage_Duration__c = 0;
                        riskToInsert.Communication_Stage_Duration__c = 0;
                        riskToInsert.Creation_Stage_Duration__c = 0;
                        riskToInsert.Market_Stage_Duration__c = 0;
                        riskToInsert.Marketing_Stage_Duration__c = 0;
                        riskToInsert.FivePercent_Stage_Duration__c = 0;
                        riskToInsert.Discovery_Stage_Duration__c = 0;
                        riskToInsert.Action_Stage_Duration__c = 0;
                        riskToInsert.Implementation_Stage_Duration__c = 0;
                        riskToInsert.Review_Stage_Duration__c = 0;
                        riskToInsert.Above_Five_Percent_Stage_Duration__c = 0;
                        risksToInsert.add(riskToInsert);
                    }
                }
            }
            /* else if (risk.Stage__c == 'Lost' && oldRisk.Stage__c != 'Lost' &&
                riskRecordTypeByIdMap.get(risk.RecordTypeId).getName() != 'Retention') {
                risk.Close_Date__c = System.today();

                Risk__c riskToInsert = risk.clone();
                riskToInsert.Close_Date__c = null;
                riskToInsert.Start_Date__c = System.today();
                riskToInsert.RecordTypeId = riskRecordTypeMap.get('Retention').getRecordTypeId();
                riskToInsert.Stage__c = 'Identified';
                riskToInsert.Open_Reason__c = 'Retention risk';
                riskToInsert.Identified_Stage_Duration__c = 0;
                riskToInsert.Handover_Stage_Duration__c = 0;
                riskToInsert.Team_Demo_Stage_Duration__c = 0;
                riskToInsert.Training_Stage_Duration__c = 0;
                riskToInsert.Cohort_Stage_Duration__c = 0;
                riskToInsert.Planning_Stage_Duration__c = 0;
                riskToInsert.Communication_Stage_Duration__c = 0;
                riskToInsert.Creation_Stage_Duration__c = 0;
                riskToInsert.Market_Stage_Duration__c = 0;
                riskToInsert.Marketing_Stage_Duration__c = 0;
                riskToInsert.FivePercent_Stage_Duration__c = 0;
                riskToInsert.Discovery_Stage_Duration__c = 0;
                riskToInsert.Action_Stage_Duration__c = 0;
                riskToInsert.Implementation_Stage_Duration__c = 0;
                riskToInsert.Review_Stage_Duration__c = 0;
                riskToInsert.Above_Five_Percent_Stage_Duration__c = 0;

                risksToInsert.add(riskToInsert);

            } */
        }

        if (!risksToInsert.isEmpty()) {
            insert risksToInsert;
        }
    }

    public static void handleBeforeUpdate(Map < Id, Risk__c > newMap, Map < Id, Risk__c > oldMap) 
    {
        
        for (Risk__c risk: newMap.values()) 
        {
            Risk__c oldRisk = oldMap.get(risk.Id);
            if (risk.Stage__c != oldRisk.Stage__c)
            {
                if(risk.Stage__c == 'Won')
                    risk.Close_Date__c = System.today();
                
                switch on oldRisk.Stage__c 
                {
                    when 'Subscription' {
                        risk.Subscribed_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Identified' {
                        risk.Identified_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Handover' {
                        risk.Handover_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Team demo' {
                        risk.Team_Demo_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Training' {
                        risk.Training_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when '1st Cohort' {
                        risk.Cohort_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Planning Call/Meet' {
                        risk.Planning_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Internal Communications' {
                        risk.Communication_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Creation/Materials Value Prop' {
                        risk.Creation_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Go to market' {
                        risk.Market_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Marketing review' {
                        risk.Marketing_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Getting to 5%' {
                        risk.FivePercent_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Discovery' {
                        risk.Discovery_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Action plan' {
                        risk.Action_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Implementation' {
                        risk.Implementation_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Review' {
                        risk.Review_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                    when 'Staying above 5%' {
                        risk.Above_Five_Percent_Stage_Duration__c = oldRisk.Stage_Duration_List_View__c;
                    }
                }
            }
        } 
    }

    //added by Miguel 22/01
    //Description : Fire errors according the validation rules implemented.
    public static void handleBeforeInsertAndUpdateValidationRules(List < Risk__c > newList) {
        //
        for (Risk__c risk: newList) {
            if (risk.Stage__c == 'Won') {
                string errorMessage = 'You must fill the field(s):';
                switch on riskRecordTypeByIdMap.get(risk.RecordTypeId).getName() {
                    when 'Foundation' {
                        if (risk.Date_of_handover_meeting__c == null) errorMessage += ' Date of Sponsor meeting;';
                        if (risk.Next_Review_Date__c == null) errorMessage += ' Next Review Date;';
                        if (risk.Training_Date__c == null) errorMessage += ' Training Date;';
                        if (risk.Training_Completed__c == null) errorMessage += ' Training Completed;';
                        if (risk.Pro_3_Partner_1_Approval__c == null) errorMessage += ' Pro 3 /Partner 1 approval?;';
                        if (risk.Graduation_Date__c == null) errorMessage += ' Graduation date;';
                    }

                    when 'Initial Launch' {
                        if (risk.Graduation_Date__c == null) errorMessage += ' Graduation date;';

                    }
                    when 'Promote' {
                        if (risk.FS_from_5_of_Clients__c == null && risk.Membership_Level__c != 'Starter') errorMessage += ' FS from 5% of Clients;';
                    }
                }
                if (errorMessage != 'You must fill the field(s):') {
                    risk.addError(errorMessage);
                }
            }
        }
    }
}