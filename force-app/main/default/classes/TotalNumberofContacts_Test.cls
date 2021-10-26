/** 
(c) 2018 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date 06/2018 
@author Miguel Sampaio 

@description Test Class of Count the total number of contacts on delete.

*/
@isTest
public class TotalNumberofContacts_Test {

    @isTest static void test_method_one() {
		Account intro = new Account ();
        intro.name= 'Introducer';
        insert intro;
        
        contact con = new contact ();
        con.LastName = 'test';
        con.AccountId = intro.id;
        con.Certification_Status_Core__c = 'Complete';
        insert con;
        
        contact con1 = new contact ();
        con1.LastName = 'test';
        con1.AccountId = intro.id;
        con1.Certification_Status_Core__c = 'Complete';
        insert con1;
        
 
     delete con1;

        
	}
    
}