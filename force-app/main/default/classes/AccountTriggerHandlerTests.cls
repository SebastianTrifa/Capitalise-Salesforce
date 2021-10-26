@isTest
private class AccountTriggerHandlerTests {
    @isTest static void testAccountMembershipNull()
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        Account acc = new Account(Name='Temp Test', RecordTypeId=introducerRecordTypeId, Membership_Level__c=null);

        try{
            insert acc;
            System.AssertEquals(true, false);
        }
        catch (Exception e)
        {
            System.Assert(e.getMessage().contains('Membership Level cannot be null or blank for Introducer accounts'));
        }
    }

    @isTest static void testAccountMembershipBlank()
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        Account acc = new Account(Name='Temp Test', RecordTypeId=introducerRecordTypeId, Membership_Level__c='');

        try{
            insert acc;
            System.AssertEquals(true, false);
        }
        catch (Exception e)
        {
            System.Assert(e.getMessage().contains('Membership Level cannot be null or blank for Introducer accounts'));
        }
    }

    @isTest static void testUpdateAccountMembershipNull()
    {
        Id introducerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Introducer').getRecordTypeId();
        Account acc = new Account(Name='Temp Test', RecordTypeId=introducerRecordTypeId);

        insert acc;

        Account acc_refreshed = [select Id, RecordTypeId, Membership_Level__c from Account where Id=:acc.Id];

        acc_refreshed.Membership_Level__c = null;

        try{
            update acc_refreshed;
            System.AssertEquals(true, false);
        }
        catch (Exception e)
        {
            System.Assert(e.getMessage().contains('Membership Level cannot be null or blank for Introducer accounts'));
        }
    }
}