/** 
(c) 2020 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date Date of creation 02.2020 
@author Miguel Sampaio

@description Test class for OpportunityLineItemSchedule

@modifications 
*/
@isTest
public class OpportunityLineItemScheduleTrigger_Test {

    @TestSetup
    static void makeData() {

        Product2 Prod = new Product2();
        Prod.Name = 'NewProd';
        Prod.CanUseRevenueSchedule = true;
        Prod.NumberOfRevenueInstallments = 12;
        Prod.RevenueScheduleType = 'Divide';
        Prod.RevenueInstallmentPeriod = 'Monthly';
        Prod.IsActive = True;
        insert Prod;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = Prod.Id;
        pbe.IsActive = True;
        pbe.UnitPrice = 70;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UseStandardPrice = false;
        insert pbe;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Closed Won';
        opp.CloseDate = DateTime.now().Date();
        opp.First_SaaS_Meeting__c = system.today();
        opp.Number_of_Clients__c = 1;
        opp.Business_Goals__c = 'Build an additional service line';
        opp.Type = 'Existing Business';
        insert opp;

        OpportunityLineItem opli = new OpportunityLineItem();
        opli.UnitPrice = 57;
        opli.Quantity = 12;
        opli.OpportunityId = opp.Id;
        opli.PricebookEntryId = pbe.id;
        opli.Product2Id = prod.Id;
        insert opli;

        OpportunityLineItemSchedule oppSchedule = new OpportunityLineItemSchedule();
        oppSchedule.OpportunityLineItemId = opli.Id;
        oppSchedule.Revenue = 1000;
        oppSchedule.ScheduleDate = system.today();
        oppSchedule.Type = 'Revenue';
        insert oppSchedule;

        

    }

    @isTest static void MMRandARRValuesMethod_Test() {

        List<OpportunityLineItem> listOppLine = [SELECT Id, UnitPrice, Quantity FROM OpportunityLineItem];
        try{
        OpportunityLineItemSchedule oppSchedule = [SELECT Id, Revenue FROM OpportunityLineItemSchedule LIMIT 1];
        oppSchedule.Revenue = 10000;
        update oppSchedule;
        }
        catch(exception e){
            
        }
    }






}