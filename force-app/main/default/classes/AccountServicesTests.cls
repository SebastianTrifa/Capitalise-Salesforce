@isTest
private class AccountServicesTests {
    @TestSetup
    static void setup(){
        List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
			acc.Name = 'Business T#' + idx;
            acc.OwnerId = UserInfo.getUserId();
			test_businesses.add(acc);
		}

		Account cap = new Account(Name='Capitalise');
		test_businesses.add(cap);
		insert test_businesses;
    }

    @isTest
    static void testFirstCasePaidOutdate() {
        List<Account> accounts = [select Id, First_CAS_Paid_Out__c from Account limit 15];
        accounts = AccountService.FindFirstCasePaidOutDate(accounts);
    }

    @isTest
    static void testSinkingHealthScoreAlert() {
        List<Account> accounts = [select Id, OwnerId, Name from Account Limit 10];
        AccountService.SinkingHealthScoreAlert(accounts);
    }

    @isTest
    static void testrefreshMonthlyDeltas() {
        List<Account> accounts = [select Id, OwnerId, Name, Managed_Clients_Connected__c, Managed_Clients_Connected_Delta__c, Managed_Clients_Connected_Snap__c, Managed_Clients__c, Managed_Clients_Delta__c, Managed_Clients_Snap__c, Managed_Clients_Connected_Snap_Monthly__c, Managed_Clients_Connected_Snap_Daily__c, Managed_Clients_Connected_Delta_Month__c, Managed_Clients_Connected_Delta_Daily__c from Account Limit 10];
        AccountService.refreshMonthlyDeltas(accounts);
    }

    @isTest
    static void testDeltas() {
        List<Account> accounts = [select Id, Managed_Clients_Connected__c, Managed_Clients_Connected_Delta__c, Managed_Clients_Connected_Snap__c, Managed_Clients__c, Managed_Clients_Delta__c, Managed_Clients_Snap__c, Managed_Clients_Connected_Snap_Monthly__c, Managed_Clients_Connected_Snap_Daily__c, Managed_Clients_Connected_Delta_Month__c, Managed_Clients_Connected_Delta_Daily__c from Account Limit 10];
        List<Account> daily = AccountService.CalculateDailyDeltas(accounts);
        List<Account> monthly = AccountService.CalculateMonthlyDeltas(accounts);
        List<Account> Weekly = AccountService.CalculateWeeklyDeltas(accounts);
    }
}