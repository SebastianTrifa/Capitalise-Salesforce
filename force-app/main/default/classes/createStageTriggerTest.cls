@isTest
public with sharing class createStageTriggerTest {
    @isTest
    public static void createStageTriggerTest() {
        Campaign newCampaign = new Campaign();
        newCampaign.Name = 'Test Campaign Stage';
        newCampaign.Type = 'Event';
        newCampaign.CurrencyIsoCode = 'GBP';
        insert newCampaign;
    }
}