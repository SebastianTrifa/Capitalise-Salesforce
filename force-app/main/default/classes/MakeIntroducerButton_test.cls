@isTest 
private class MakeIntroducerButton_test {
     static testMethod void testRest() {
        
         account acc = new account ();
         acc.Name='teste';
         insert acc;
         
         contact con = new contact ();
         con.lastname = 'sampaio';
         con.AccountId =acc.id;
         insert con;
         
         opportunity opp = new opportunity ();
         opp.name = 'opp teste';
         opp.CloseDate = system.today();
         opp.stagename = 'submitted';
         opp.AccountId=acc.Id;
         insert opp;
         
         MakeIntroducerButton mib = new MakeIntroducerButton(new ApexPages.StandardController(acc));
         
         mib.IntroducerButton();
         
       
         

}
}