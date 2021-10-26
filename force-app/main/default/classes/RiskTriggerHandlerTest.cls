@isTest(seeAllData = false)
public class RiskTriggerHandlerTest {

    static Map < String, Schema.RecordTypeInfo > riskRecordTypeMap = Schema.SObjectType.Risk__c.getRecordTypeInfosByName();
    static Map < String, Schema.RecordTypeInfo > accountRecordTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
    static Map < String, Schema.RecordTypeInfo > opportunityRecordTypeMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();

    @testSetup
    static void createData() {
        //bypass validation rules for test class

        INSERT new ValidationRuleSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), Disable_Validation_Rules__c = true);

        //Create Account
        Account testAcc = new Account();
        testAcc.Name = 'TestAccountForRisk';
        testAcc.RecordTypeId = accountRecordTypeMap.get('Introducer').getRecordTypeId();

        insert testAcc;

         //Create Account
         Account testAcc1 = new Account();
         testAcc1.Name = 'RetentionRisk';
         testAcc1.RecordTypeId = accountRecordTypeMap.get('Introducer').getRecordTypeId();
 
         insert testAcc1;


        //Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'TestIntroducer';
        testContact.LastName = 'Partner';
        testContact.AccountId = testAcc.Id;
        testContact.Lessons_Completed_Core__c = 11;
        testContact.Role__c = 'Member';

        insert testContact;

        Contact testContact1 = new Contact();
        testContact1.FirstName = 'TestIntroducer';
        testContact1.LastName = 'Partner1';
        testContact1.AccountId = testAcc1.Id;
        testContact1.Lessons_Completed_Core__c = 11;
        testContact1.Role__c = 'Member';

        insert testContact1;

        //Create Pricebook
        Pricebook2 pb = new Pricebook2(Name = 'Subscription Pricing');

        insert pb;

        //Create Product
        Product2 prod = new Product2();
        prod.Name = 'TestSubscription';
        prod.Family = 'Subscription';

        insert prod;



        //Create Introducer Subscription Opp
        opportunity opp1 = new opportunity();
        opp1.AccountId = testAcc.id;
        //opp1.Introducer_Contact__c = testContact.id;
        opp1.closedate = system.today();
        opp1.name = 'TestOpportunityForRisks';
        opp1.stagename = 'Prospect';
        opp1.RecordTypeId = opportunityRecordTypeMap.get('Subscription').getRecordTypeId();
        opp1.First_SaaS_Meeting__c = system.today();
        opp1.Number_of_Clients__c = 1;
        opp1.Business_Goals__c = 'Build an additional service line';
        opp1.Type = 'New Business';
        opp1.Amount = 1000;
        insert opp1;

    }

    static testMethod void createAndProgressRisks() {
        Opportunity oppRecord = [Select Id, Name, StageName, (Select Id From Risks__r) From Opportunity Where Name = 'TestOpportunityForRisks'];
        List < Risk__c > riskRecords = [Select Id, Name from Risk__c];

        System.assert(riskRecords.size() == 0);
        System.assert(oppRecord.Risks__r.size() == 0);

        oppRecord.StageName = 'Closed Won';

        update oppRecord;

        riskRecords = [Select Id, Name, RecordTypeId, Stage__c, Date_of_handover_meeting__c, Next_Review_Date__c from Risk__c];

        System.assert(riskRecords.size() == 1, 'A new risk should have been created when the opportunity record was Closed Won');

        Risk__c riskRecordToCheck = riskRecords[0];

        System.assertEquals(riskRecordTypeMap.get('Onboarding').getRecordTypeId(), riskRecordToCheck.RecordTypeId, 'The risk was not created with the correct record type');


        riskRecordToCheck.Date_of_handover_meeting__c = System.today();
        riskRecordToCheck.Next_Review_Date__c = System.today().addDays(7);
        riskRecordToCheck.Training_Date__c = System.today();
        riskRecordToCheck.Training_Completed__c = 'Yes';
        riskRecordToCheck.Pro_3_Partner_1_Approval__c = 'Yes';
        riskRecordToCheck.Graduation_Date__c = System.Today();
        riskRecordToCheck.Stage__c = 'Won';

        update riskRecordToCheck;

        //get the initial Lauch Risk records
        List < Risk__c > riskRecordsFoundation = [SELECT Id, Name, RecordTypeId, Stage__c, Date_of_handover_meeting__c, Next_Review_Date__c from Risk__c WHERE RecordType.Name = 'Foundation'];
        system.assert(riskRecordsFoundation.size() == 1);

        riskRecordsFoundation[0].stage__c = 'Won';
        update riskRecordsFoundation;

        //get the initial Lauch Risk records
        List < Risk__c > riskRecordsInitial = [SELECT Id, Name, RecordTypeId, Stage__c, Date_of_handover_meeting__c, Next_Review_Date__c from Risk__c WHERE RecordType.Name = 'Initial Launch'];
        system.assert(riskRecordsInitial.size() == 1);

        riskRecordsInitial[0].stage__c = 'Won';
        update riskRecordsInitial;

        //get the Promote Risk records
        List < Risk__c > riskRecordsPromote = [SELECT Id, Name, RecordTypeId, Stage__c, Date_of_handover_meeting__c, Next_Review_Date__c from Risk__c WHERE RecordType.Name = 'Promote'];
        system.assert(riskRecordsPromote.size() == 1);

        riskRecordsPromote[0].stage__c = 'Won';
        riskRecordsPromote[0].FS_from_5_of_Clients__c = 'Yes';
        update riskRecordsPromote;

        System.assertEquals(riskRecordTypeMap.get('Promote').getRecordTypeId(), riskRecordsPromote[0].RecordTypeId);


        //get the Growth Risk records
        List < Risk__c > riskRecordsGrowth = [SELECT Id, Name, RecordTypeId, Stage__c, Date_of_handover_meeting__c, Next_Review_Date__c from Risk__c WHERE RecordType.Name = 'Growth'];
        system.assert(riskRecordsGrowth.size() == 1);

        riskRecordsGrowth[0].stage__c = 'Won';
  
        update riskRecordsGrowth;

        riskRecordsGrowth[0].stage__c = 'Lost';
  
        update riskRecordsGrowth;

    }

    static testMethod void createAndProgressRisksRetention() {
        //get account
        Account acc = [SELECT Id FROM Account WHERE Name = 'RetentionRisk'];

       
        Risk__c riskRetention = new Risk__c();
        riskRetention.RecordTypeId = riskRecordTypeMap.get('Retention').getRecordTypeId();
        riskRetention.Customer__c = acc.Id;
        riskRetention.Date_of_handover_meeting__c = System.today();
        riskRetention.Next_Review_Date__c = System.today().addDays(7);
        riskRetention.Training_Date__c = System.today();
        riskRetention.Training_Completed__c = 'Yes';
        riskRetention.Pro_3_Partner_1_Approval__c = 'Yes';
        riskRetention.Graduation_Date__c = System.Today();
        riskRetention.Stage__c = 'Identified';
        riskRetention.Open_Reason__c = 'Retention Risk';

        insert riskRetention;

        riskRetention.stage__c = 'Won';
        update riskRetention;
    }

}