/** 
(c) 2018 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date 09/2018
@author Miguel Sampaio 

@modifications 08/06/2020 [KT] - Added testsetup method
                                - Added tests for automatic assignment of funding specialist. And determination of secured/unsecured checkbox field.

*/
@isTest
private class rsOpportunityChangeContactStage_Test {

	private class CapAPPMock_Success implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('https://prod')) {
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJERTJSRGxEUmtNMU5EUXhNVGs0TlRneE1FTXhNREk1TVVJeFJqTkJPRUl6TmpoRk56aEJRZyJ9.eyJodHRwczovL2NhcGl0YWxpc2UuY29tL2VtYWlsIjoic2FsZXNmb3JjZS5hcGkudXNlckBuby1yZXBseS5jYXBpdGFsaXNlLmNvbSIsImh0dHBzOi8vY2FwaXRhbGlzZS5jb20vYXBwX21ldGFkYXRhIjp7ImlzQWRtaW4iOnRydWUsInVzZXJUeXBlIjoiaW50cm9kdWNlciIsImVudGl0eUlkIjoyMTY5OSwiZmVhdHVyZXMiOnsidXNlclByb2ZpbGUiOmZhbHNlLCJyZXBvcnRpbmciOmZhbHNlLCJ0ZWFtcyI6ZmFsc2UsImxlYXJuaW5nIjp0cnVlLCJsZWFybmluZ19saWNlbnNlIjpmYWxzZSwibW9uaXRvciI6ZmFsc2UsImluc3RhbnRPZmZlcnMiOnRydWUsInBsYXlib29rIjpmYWxzZX0sInJvbGVzIjpbIlJPTEVfSU5UUk9EVUNFUiIsIlJPTEVfQ09NUEFOWV9NRU1CRVIiLCJST0xFX1RFQU1fTUVNQkVSIiwiUk9MRV9DT01QQU5ZX01BTkFHRVIiLCJST0xFX01FTUJFUlNISVBfTEVWRUxfTElHSFQiLCJST0xFX1NPTkFUQV9BRE1JTiIsIlJPTEVfVVNFUiJdfSwiaXNzIjoiaHR0cHM6Ly9jYXBpdGFsaXNlLmV1LmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw1ZjA4NmQ3OWM0ODgwMTAwMTNjNjVmYTIiLCJhdWQiOlsiaHR0cHM6Ly9jYXBpdGFsaXNlLmV1LmF1dGgwLmNvbS9hcGkvdjIvIiwiaHR0cHM6Ly9jYXBpdGFsaXNlLmV1LmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE1OTUzNTcyNTEsImV4cCI6MTU5NTQ0MzY1MSwiYXpwIjoiczZHMWJ4MTFabElGRHVEcHBIRXdBYURKcGVGQnFFVG8iLCJzY29wZSI6Im9wZW5pZCBlbWFpbCBwcm9maWxlIHJlYWQ6Y3VycmVudF91c2VyIHVwZGF0ZTpjdXJyZW50X3VzZXJfbWV0YWRhdGEgZGVsZXRlOmN1cnJlbnRfdXNlcl9tZXRhZGF0YSBjcmVhdGU6Y3VycmVudF91c2VyX21ldGFkYXRhIGNyZWF0ZTpjdXJyZW50X3VzZXJfZGV2aWNlX2NyZWRlbnRpYWxzIGRlbGV0ZTpjdXJyZW50X3VzZXJfZGV2aWNlX2NyZWRlbnRpYWxzIHVwZGF0ZTpjdXJyZW50X3VzZXJfaWRlbnRpdGllcyIsImd0eSI6InBhc3N3b3JkIn0.fAmcuPV352q9vhbP_i8nEBK0z3vliej2mMqRZn_VvlARBNWjVRwnKp25OVecd73z7zaYU4_OVF9g-pijx_nGPFzzbBa8tYGc7HoH05HTK0Y0n7Q9uYcOUmGi9gWPR4gKjvN_YHvbBlf3UCDqFeZFtu2V00yNUrY7aE8rRb-LRU8ly1AtixEuGDDt99uhXe-471KWxSRpiKMAoe2HBIHsEgRNWcPeL8XhyWmH7puUp7AF0a8RHzYcbFNozeU30qTcWX5kyjKulxsNNm8pnH7aLeqpbTD7L3MYHeVOFFzmkf-PiqGNMd3Zcxn-s4uaMvce1Eh9Mf8uRvyGGT6KJafnZA","id_token":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlJERTJSRGxEUmtNMU5EUXhNVGs0TlRneE1FTXhNREk1TVVJeFJqTkJPRUl6TmpoRk56aEJRZyJ9.eyJlbWFpbCI6InNhbGVzZm9yY2UuYXBpLnVzZXJAbm8tcmVwbHkuY2FwaXRhbGlzZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5pY2tuYW1lIjoic2FsZXNmb3JjZS5hcGkudXNlciIsIm5hbWUiOiJzYWxlc2ZvcmNlLmFwaS51c2VyQG5vLXJlcGx5LmNhcGl0YWxpc2UuY29tIiwicGljdHVyZSI6Imh0dHBzOi8vcy5ncmF2YXRhci5jb20vYXZhdGFyLzkxYTE3YzEyNjQ3MjEyMjBmMTVkZGMzZjk3NTk1N2FhP3M9NDgwJnI9cGcmZD1odHRwcyUzQSUyRiUyRmNkbi5hdXRoMC5jb20lMkZhdmF0YXJzJTJGc2EucG5nIiwidXBkYXRlZF9hdCI6IjIwMjAtMDctMjFUMTg6NDc6MzAuNzgwWiIsImlzcyI6Imh0dHBzOi8vY2FwaXRhbGlzZS5ldS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NWYwODZkNzljNDg4MDEwMDEzYzY1ZmEyIiwiYXVkIjoiczZHMWJ4MTFabElGRHVEcHBIRXdBYURKcGVGQnFFVG8iLCJpYXQiOjE1OTUzNTcyNTEsImV4cCI6MTU5NTM5MzI1MX0.Q6VedVFxLzlJeTjv6ut5_o-LU2h1C0jX4xMLSgsnV3kSF2Waol0eErES8VVFsW8PppM-F5ufE59ucpcTbuwgxZYiMr9fhN1Vi38XH3JEv4XuJ6hz1OX5VtjQ3a0jWWdvak9Wp7JDKIQL7DmNWwHS_5M9GypretxidvAYILMP_H-EPPCXaxszoWNZ9ZOd2UqtfpMEOkLDB3xtGnJ9bCUv0sn3Pho79R5tKMePU3ab8XEt7NLhgiXT-mY95Vd7Pva-3p8crsQfkAP1HYnjJrhSq0PbmhkOfIOel3n_6jWoDK5GCfc09hDEBAje-sDH3mN7ifHJO9xzb3cfA4gvwrL0Dg","scope":"openid email profile read:current_user update:current_user_metadata delete:current_user_metadata create:current_user_metadata create:current_user_device_credentials delete:current_user_device_credentials update:current_user_identities","expires_in":86400,"token_type":"Bearer"}');
                res.setStatusCode(200);
                return res;
            } else {
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"id":13655,"status":10,"amount":"150000.00","matches":[{"id":56335,"offer":{"id":"56ff0a0c-2aef-485f-a617-99a4cedc65c4","type":"MANUAL_OFFER","status":"FINAL","productType":16,"reference":"13655/56335","publicComment":"UW approved.  Insurers need latest MI which the client will provide in due course.  all checks undertaken and legal documents have been issued.","invoiceFinance":{"maximumCreditLine":250000,"contractLength":36},"createdAt":"2020-04-06T08:24:21.271Z","fromEntityId":{"id":16171,"entityId":16171,"companyName":"Optimum SME Finance Limited","logo":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/logo/9eea38ee-0087-45d3-9a76-9add7f76ec99.jpeg","icon":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/icon/4bddc1fa-a352-47a9-90e9-8e0399100bcf.jpeg"},"toEntityId":{"id":15443,"entityId":15443,"companyName":"Capitalise"},"user":{"id":16461,"name":"Andy Christiansen"}},"products":[16],"statusReason":null,"statusComment":"CID facility now live with client. Total Track and ExcelR8 BTCC to be added once trading resumes.","canUseInstantOffer":null,"canUseInstantApplication":null,"lender":{"id":277,"entityId":16171,"companyName":"Optimum SME Finance Limited","companyNumber":null,"entityType":2,"createdAt":"2019-12-07T17:53:53.000Z","updatedAt":"2019-12-07T17:53:53.000Z","contentAvailable":null,"logo":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/logo/9eea38ee-0087-45d3-9a76-9add7f76ec99.jpeg","icon":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/icon/4bddc1fa-a352-47a9-90e9-8e0399100bcf.jpeg","type":1,"description":"Optimum Finance is a specialist lender focused on the receivables finance space, and the team will work with you to unlock cash in your business, enabling you to focus on business growth. A tailored invoice finance facility, which will grow as your business grows, is a flexible cash flow solution.","hasInstantOffer":true,"hasInstantApplication":true,"phoneNumber":null,"smallPrint":null,"otherInformation":null,"preRequestDetails":null,"fees":{"earlyRepaymentFees":0,"exitFees":0},"documents":["1 year of filed accounts","Management accounts","Aged debtor report"],"features":["All assets debenture","Personal Guarantee","Directors credit check"]},"status":3,"matchCompletion":100},{"id":64223,"offer":{},"products":[1],"statusReason":null,"statusComment":null,"canUseInstantOffer":null,"canUseInstantApplication":null,"lender":{"id":27,"entityId":123,"companyName":"Nucleus Commercial Finance Ltd","companyNumber":null,"entityType":2,"createdAt":null,"updatedAt":"2019-03-18T10:49:09.000Z","contentAvailable":null,"logo":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/logo/7da715a5-e5c3-45b9-8d33-09b54152cdf2.png","icon":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/icon/90cf6e1a-e29c-4459-bc8a-c7fb014fc884.png","type":1,"description":"At Nucleus Commercial Finance, we combine the financial expertise and credit facilities of a traditional high street banks with the speed, flexibility and transparency of alternative business lending, to offer your business a solutions-based approach.","hasInstantOffer":false,"hasInstantApplication":false,"phoneNumber":null,"smallPrint":null,"otherInformation":null,"preRequestDetails":null,"fees":{"earlyRepaymentFees":0,"exitFees":0},"documents":["1 year of filed accounts","Management accounts","Last 6 months bank statements"],"features":["Directors personal guarantee required","Directors credit check","All assets debenture"]},"status":11,"matchCompletion":0},{"id":60813,"offer":{},"products":[1],"statusReason":null,"statusComment":"Hi Alice, Thank you for applying for a Funding Circle CBILS loan on behalf of your client. Unfortunately we are unable to continue this application, as your client already had an active application with Funding Circle recently which was declined.  Kind regards, The Funding Circle Team","canUseInstantOffer":null,"canUseInstantApplication":null,"lender":{"id":92,"entityId":1517,"companyName":"Funding Circle","companyNumber":null,"entityType":2,"createdAt":null,"updatedAt":"2020-05-01T17:51:15.000Z","contentAvailable":null,"logo":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/logo/8e7b3a4c-48e6-4873-a580-d454a904667c.png","icon":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/icon/19c2c70c-ab80-4cf4-b154-83c8585b3f08.png","type":1,"description":"Funding Circle is the world’s leading lending platform for small businesses. To date, investors have lent £4bn to 40,000 businesses in the UK, USA, Germany and the Netherlands. Businesses can borrow directly from a wide range of investors, including more than 70,000 people, the UK Government, local councils, universities and a number of financial organisations such as pension funds.","hasInstantOffer":false,"hasInstantApplication":false,"phoneNumber":null,"smallPrint":null,"otherInformation":null,"preRequestDetails":null,"fees":{"earlyRepaymentFees":0,"exitFees":0},"documents":["2 years of filed accounts","Last 6 months bank statements","Management accounts"],"features":["Directors credit check","Personal Guarantee"]},"status":4,"matchCompletion":100},{"id":62557,"offer":{},"products":[1],"statusReason":"","statusComment":"Hi, Unfortunately this application was rejected as a rejected payment was noted within the last 3months. Kind regards, Harley Market Finance","canUseInstantOffer":null,"canUseInstantApplication":null,"lender":{"id":22,"entityId":87,"companyName":"MarketFinance","companyNumber":null,"entityType":2,"createdAt":null,"updatedAt":"2019-11-15T12:07:27.000Z","contentAvailable":null,"logo":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/logo/61d22c99-6334-40a1-8ff0-24c000047d01.png","icon":"https://capitaliselive.blob.core.windows.net/capitalise-com/lender/icon/2a133af6-ed10-41f7-a3cd-fbb17ba789cf.png","type":1,"description":"Take control of your cash flow quickly and easily with our invoice finance and business loan solutions.","hasInstantOffer":false,"hasInstantApplication":false,"phoneNumber":null,"smallPrint":null,"otherInformation":null,"preRequestDetails":null,"fees":{"earlyRepaymentFees":0,"exitFees":0},"documents":["1 year of filed accounts","Last 6 months bank statements","Management accounts"],"features":["Personal Guarantee"]},"status":4,"matchCompletion":0}],"period":36,"statusLabel":"Paid out","author":{"id":14401,"name":"Kipp Noble","email":"kipp.noble@capitalise.com","userType":"introducer","entity":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"champion":true,"team":{"id":3423,"name":"No Team"}},"manager":{"id":14401,"name":"Kipp Noble","email":"kipp.noble@capitalise.com","userType":"introducer","entity":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"champion":true,"team":{"id":3423,"name":"No Team"}},"useOfFunds":"Day to day cashflow","urgency":"ASAP","governmentBacked":false,"contactTime":0,"client":{"id":4088,"entityId":4088,"companyName":"EXCELR8 MOTORSPORT LLP","companyNumber":"OC352448","entityType":0,"createdAt":null,"updatedAt":null,"contentAvailable":null,"businessId":3368,"companyType":2,"companyAddress":{"address":"Unit 1 Roy Humphrey Site A140 Norwich Ipswich Road, Brome, Brome, Eye","postalCode":"IP23 8AW"},"contactName":"Antony Williams","contactEmail":"antony@excelr8motorsport.com","contactPhone":"01379 870880","contactPosition":null,"userLastInvitedAt":null,"revenue":"1602815","profitNet":"63537","netAssets":null,"fixedAssets":"450346","integratedFrom":null,"integratedCompanyName":null},"introducer":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"communicationPreference":2,"isTest":false,"requireDisclosureCommission":false,"disclosureCommissionConfirmedOn":null,"disclosureCommissionConfirmedBy":null,"consultant":{"id":14401,"name":"Kipp Noble","email":"kipp.noble@capitalise.com","userType":"introducer","entity":{"id":15443,"entityId":15443,"companyName":"Capitalise","companyNumber":null,"entityType":1,"createdAt":1574075168,"updatedAt":1574075168,"contentAvailable":null,"introducerId":2303,"introducerType":3},"champion":true,"team":{"id":3423,"name":"No Team"}},"profileCompletion":100,"profileDocumentTypes":[{"id":18,"name":"1 year of filed accounts","required":true,"other":false},{"id":19,"name":"Management accounts","required":false,"other":false},{"id":44,"name":"Aged debtor report","required":true,"other":false},{"id":29,"name":"Last 6 months bank statements","required":true,"other":false},{"id":41,"name":"Sample invoice(s)","required":false,"other":false},{"id":25,"name":"2 years of filed accounts","required":false,"other":false},{"id":39,"name":"Supporting information","required":false,"other":false}],"followers":[],"private":false,"createdAt":1584719084,"updatedAt":1593766807,"statusMatchesCount":2,"allMatchesCount":4}');
                res.setStatusCode(200);
                return res;
            }
        }
    }

	@TestSetup
	static void Setup()
	{
		Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
		Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;
		
		List<User> test_users = new List<User>();
		User test_user1 = new User(LastName = 'TestUser',
		FirstName='#1',
		Alias = 'tusr1',
		Email = 'test1@CapUAT.com',
		Username = 'test1@CapUAT.com',
		ProfileId = fundingSpecialistProfileId,
		TimeZoneSidKey = 'GMT',
		LanguageLocaleKey = 'en_US',
		EmailEncodingKey = 'UTF-8',
		LocaleSidKey = 'en_US');
		test_users.add(test_user1);

		User test_user2 = new User(LastName = 'TestUser',
		FirstName='#2',
		Alias = 'tusr2',
		Email = 'test2@CapUAT.com',
		Username = 'test2@CapUAT.com',
		ProfileId = fundingSpecialistProfileId,
		TimeZoneSidKey = 'GMT',
		LanguageLocaleKey = 'en_US',
		EmailEncodingKey = 'UTF-8',
		LocaleSidKey = 'en_US');
		test_users.add(test_user2);

		insert test_users;

		List<Contact> intro_contacts = new List<Contact>();
		Introducer__c intro = new Introducer__c();
		intro.name = 'Introducer Test';
		insert intro;

		List<Account> test_businesses = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
			acc.Name = 'Business T#' + idx;
			test_businesses.add(acc);
		}

		Account cap = new Account(Name='Capitalise');
		test_businesses.add(cap);
		insert test_businesses;

		contact con = new contact();
		con.LastName = 'test contact';
		con.Introducer__c = intro.id;
		intro_contacts.add(con);

		contact con1 = new contact();
		con1.LastName = 'test contact 1';
		con1.Introducer__c = intro.id;
		intro_contacts.add(con1);

		insert intro_contacts;

		List<User> funding_specialists = [select Id, Name from User where ProfileId=:fundingSpecialistProfileId limit 2];
		List<Account> test_introducers = new List<Account>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			Account acc = new Account();
			acc.Name = 'Introducer T#' + idx;
			test_introducers.add(acc);
		}
		insert test_introducers;

		List<Opportunity> previous_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 5; idx++)
		{
			opportunity opp = new opportunity();
			opp.Introducer__c = intro.id;
			opp.AccountId = test_businesses[idx].Id;
			opp.Introducer_new__c = test_introducers[idx].Id;
			opp.Introducer_contact__c = intro_contacts[math.mod(idx, 2)].Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search prev#' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';
			opp.Owner_Locked__c = false;
			opp.SearchedAmount__c = 250000;
			opp.Funding_Specialist__c = funding_specialists[math.mod(idx,2)].Id;
			previous_searches.add(opp);
		}

		insert previous_searches;
	}

	@isTest static void test_method_one() {
		// Implement test code

		Contact con = [select Id, LastName from Contact where LastName = 'test contact' limit 1];
		Contact con1 = [select Id, LastName from Contact where LastName = 'test contact 1' limit 1];
		Introducer__c intro = [select Id, Name from Introducer__c where Name = 'Introducer Test' limit 1];
		
		test.startTest();
		Test.setMock(HttpCalloutMock.class, new CapAPPMock_Success());
		opportunity opp = new opportunity();
		opp.Introducer__c = intro.id;
		opp.Introducer_contact__c = con.id;
		opp.closedate = system.today();
		opp.name = 'test';
		opp.stagename = 'Pending';
		insert opp;

		opp.stagename = 'Paid Out';
		update opp;

		/*opportunity opp = new opportunity();
		opp.Introducer__c = intro.id;
		opp.Introducer_contact__c = con.id;
		opp.closedate = system.today();
		opp.name = 'test';
		opp.stagename = 'Pending';
		insert opp;

		delete opp;*/
        delete opp;

		/*opportunity opp2 = new opportunity();
		opp2.Introducer__c = intro.id;
		opp2.Introducer_contact__c = con.id;
		opp2.business_contact__c = con.id;
		opp2.closedate = system.today();
		opp2.name = 'test';
		opp2.stagename = 'Paid Out';
		insert opp2;*/

		//opp2.has_invoice_finance__c = true;
		//update opp2;
		Test.stopTest();


	}

	@isTest static void test_invoiceFinanceAssignment()
	{
		Contact con = [select Id, LastName from Contact where LastName = 'test contact' limit 1];
		Contact con1 = [select Id, LastName from Contact where LastName = 'test contact 1' limit 1];
		Account intro = [select Id, Name from Account where Name='Introducer T#5' limit 1];
		Id invoiceFinanceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Invoice Finance').getRecordTypeId();
		
		opportunity opp = new opportunity();
		opp.AccountId = intro.Id;
		opp.Introducer_new__c = intro.Id;
		opp.Introducer_contact__c = con.Id;
		opp.closedate = system.today() + 7;
		opp.name = 'test IF Case';
		opp.stagename = 'Incomplete';
		opp.Owner_Locked__c = false;
		opp.SearchedAmount__c = 250000;
		insert opp;

		opp = [select Id, Name, RecordTypeId from Opportunity where Name='test IF Case' limit 1];
		system.AssertEquals(opp.RecordTypeId, invoiceFinanceRecordTypeId);
		
	}

	@isTest static void test_isFundingSearchSecured()
	{
        Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();

		Contact con = [select Id, LastName from Contact where LastName = 'test contact' limit 1];
		Contact con1 = [select Id, LastName from Contact where LastName = 'test contact 1' limit 1];
		Introducer__c intro = [select Id, Name from Introducer__c where Name = 'Introducer Test' limit 1];

		List<Opportunity> funding_searches = new List<Opportunity>();

		for(Integer idx = 0; idx < 6; idx++)
		{
			opportunity opp = new opportunity();
			opp.Introducer__c = intro.id;
			opp.Introducer_contact__c = con.id;
			opp.Business_Contact__c = con.id;
			opp.closedate = system.today() + 7;
			opp.name = 'test search #' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = 'Incomplete';

			switch on idx{
				when 0 {
					opp.SearchedAmount__c = 550000;
				}
				when 1 {
					opp.SearchedAmount__c = 250000;
					opp.Asset_Types__c = 'Transportation, Business';
				}
				when 2 {
					opp.SearchedAmount__c = 350000;
					opp.Asset_Types__c = 'Transportation, Stock';
				}
				when 3 {
					opp.SearchedAmount__c = 350000;
				}
				when 4 {
					opp.SearchedAmount__c = 250000;
				}
				when 5 {
					opp.SearchedAmount__c = 250000;
					opp.Name += ' PF';
				}
			}

			funding_searches.add(opp);
		}

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CapAPPMock_Success());
		insert funding_searches;
		Test.stopTest();
		Integer secured = 0, unsecured = 0;
		List<Id> opp_ids = new List<Id>();
		for(Opportunity opp : funding_searches)
			opp_ids.add(opp.Id);

		for(Opportunity opp : [select Id, SearchedAmount__c, Name, Secured__c from Opportunity where Id In :opp_ids])
		{
			system.debug(opp);
			if(opp.Secured__c) secured++;
			else unsecured++;
		}
		system.AssertEquals(secured, 3);
		system.AssertEquals(unsecured, 3);
	}

	@isTest static void test_subscriptions()
	{
		Id subscriptionRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
		Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
		Contact con = [select Id, LastName from Contact where LastName = 'test contact' limit 1];
		Contact con1 = [select Id, LastName from Contact where LastName = 'test contact 1' limit 1];
		Introducer__c intro = [select Id, Name from Introducer__c where Name = 'Introducer Test' limit 1];
		Account intro_acc = [select Id, Name from Account where Name='Introducer T#5' limit 1];
		List<Opportunity> opps = new List<Opportunity>();

		for(Integer idx = 0; idx < 2; idx++)
		{
			opportunity opp = new opportunity();
			opp.Introducer__c = intro.id;
			opp.Introducer_new__c = intro_acc.Id;
			opp.Introducer_contact__c = con.id;
			opp.First_SaaS_Meeting__c = system.today() + 7;
			opp.Number_of_Clients__c = 25;
			opp.closedate = system.today() + 7;
			opp.Business_Goals__c = 'Build a new revenue stream';
			opp.name = 'Subscription test';
			opp.Confirmed_Commission_Ex_VAT__c = 37.5;
			if(math.mod(idx, 2) == 0) opp.StageName = 'Paid Out';
			else opp.StageName = 'Closed Won';
			opp.SearchedAmount__c = 60000;
			opp.RecordTypeId = subscriptionRecordTypeId;
			opp.Type = 'New Business';
			opps.add(opp);
		}

		for(Integer idx = 0; idx < 2; idx++)
		{
			opportunity opp = new opportunity();
			opp.Introducer__c = intro.id;
			opp.Introducer_new__c = intro_acc.Id;
			opp.Introducer_contact__c = con.Id;
			opp.closedate = system.today() + 7;
			opp.name = 'test awaiting documents #' + idx;
			opp.RecordTypeId = fundingSearchRecordTypeId;
			opp.stagename = (math.mod(idx, 2) == 0) ? 'Awaiting Documents' : 'Incomplete';
			opp.SearchedAmount__c = 250000;
			opps.add(opp);
		}
		
		insert opps;
	}

	@isTest static void test_unsecuredFundingSearchAssignment()
	{
		Id fundingSearchRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Funding Search').getRecordTypeId();
		Id fundingSpecialistProfileId = [select Id from Profile where Name='Capitalise Funding Specialist'].Id;

		Contact con = [select Id, LastName from Contact where LastName = 'test contact' limit 1];
		Contact con1 = [select Id, LastName from Contact where LastName = 'test contact 1' limit 1];
		Introducer__c intro = [select Id, Name from Introducer__c where Name = 'Introducer Test' limit 1];
		Account intro_acc = [select Id, Name from Account where Name='Introducer T#5' limit 1];
		Account prev_intro = [select Id, Name from Account where Name='Introducer T#0' limit 1];
		Account prev_intro1 = [select Id, Name from Account where Name='Introducer T#1' limit 1];
		Account prev_business = [select Id, Name from Account where Name='Business T#1' limit 1];
		List<User> funding_specialists = [select Id, isActive from User where ProfileId=:fundingSpecialistProfileId];
		List<Id> funding_specialist_ids = new List<Id>();
		
		for(user a_user : funding_specialists)
            funding_specialist_ids.add(a_user.Id);

		Map<Id, Map<String, Integer>> specialists_stages_count_map = new Map<Id, Map<String, Integer>>();
        for(AggregateResult item : [select Count(Id), StageName, Funding_Specialist__c From Opportunity Where Funding_Specialist__c != null and Funding_Specialist__r.ProfileId=:fundingSpecialistProfileId and RecordTypeId=:fundingSearchRecordTypeId and StageName In ('Incomplete', 'Awaiting Client Contact', 'Awaiting Documents')  Group By Funding_Specialist__c, StageName, RecordTypeId])
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

        Map<Id, Map<Id, Id>> introducers_specialist_recent = new Map<Id, Map<Id, Id>>();
        for(AggregateResult item : [select Id, DAY_ONLY(LastModifiedDate), Introducer_new__c, Introducer_Contact__c, Funding_Specialist__c from Opportunity where Funding_Specialist__r.ProfileId=:fundingSpecialistProfileId and Introducer_new__c != null and Introducer_new__r.Name != 'Capitalise' and RecordTypeId=:fundingSearchRecordTypeId and DAY_ONLY(LastModifiedDate) = LAST_N_DAYS:30 Group By Introducer_new__c, Introducer_Contact__c, Funding_Specialist__c, Id, DAY_ONLY(LastModifiedDate) order by DAY_ONLY(LastModifiedDate) desc])
        {
            Id introducer = (Id)item.get('Introducer_new__c');
            Id introducer_contact = (Id)item.get('Introducer_Contact__c');
            Id specialist = (Id)item.get('Funding_Specialist__c');
            if(funding_specialist_ids.contains(specialist))
            {
                if(!introducers_specialist_recent.containsKey(introducer)) 
                {
                    Map<Id, Id> contact_specialist = new Map<Id, Id>();
                    contact_specialist.put(introducer_contact, specialist);
                    introducers_specialist_recent.put(introducer, contact_specialist);
                }
                else
                {
                    Map<Id, Id> contact_specialist = introducers_specialist_recent.get(introducer);
                    if(!contact_specialist.containsKey(introducer_contact)) contact_specialist.put(introducer_contact, specialist);
                }
            }
        }
		system.debug(introducers_specialist_recent);

		Map<Id, Id> business_specialist_recent = new Map<Id, Id>();
        for(AggregateResult item : [select Id, DAY_ONLY(LastModifiedDate), AccountId, Funding_Specialist__c from Opportunity where Funding_Specialist__r.ProfileId=:fundingSpecialistProfileId and AccountId != null and RecordTypeId=:fundingSearchRecordTypeId Group By AccountId, Funding_Specialist__c, Id, DAY_ONLY(LastModifiedDate) order by DAY_ONLY(LastModifiedDate) desc])
        {
            Id business_id = (Id)item.get('AccountId');
            Id specialist = (Id)item.get('Funding_Specialist__c');
            if(funding_specialist_ids.contains(specialist) && !business_specialist_recent.containsKey(business_id))
                business_specialist_recent.put(business_id, specialist);
		}
		system.debug(business_specialist_recent);

		opportunity opp = new opportunity();
		opp.Introducer_new__c = intro_acc.Id;
		opp.Introducer_contact__c = con.id;
		opp.closedate = system.today() + 7;
		opp.name = 'assignment test diva';
		opp.SearchedAmount__c = 60000;
        opp.RecordTypeId = fundingSearchRecordTypeId;
		opp.stagename = 'Incomplete';
		
		Opportunity opp1 = new Opportunity();
		opp1.Introducer_new__c = prev_intro.Id;
		opp1.Introducer_contact__c = con.id;
		opp1.closedate = system.today() + 7;
		opp1.name = 'test diva partner';
		opp1.SearchedAmount__c = 70000;
    	opp1.RecordTypeId = fundingSearchRecordTypeId;
		opp1.stagename = 'Incomplete';

		Id partner_specialist = introducers_specialist_recent.get(prev_intro.Id).get(con.Id);

		Opportunity opp2 = new Opportunity();
		opp2.Introducer_new__c = prev_intro1.Id;
		opp2.Introducer_contact__c = con1.id;
		opp2.closedate = system.today() + 7;
		opp2.name = 'test diva chaperone';
		opp2.SearchedAmount__c = 54321;
        opp2.RecordTypeId = fundingSearchRecordTypeId;
		opp2.stagename = 'Incomplete';

		Id chaperone_specialist = introducers_specialist_recent.get(prev_intro1.Id).get(con1.Id);

		Opportunity opp3 = new Opportunity();
		opp3.Introducer_new__c = prev_intro1.Id;
		opp3.Introducer_contact__c = con.id;
		opp3.closedate = system.today() + 7;
		opp3.name = 'test diva driver';
		opp3.SearchedAmount__c = 54321;
        opp3.RecordTypeId = fundingSearchRecordTypeId;
		opp3.stagename = 'Incomplete';

		Id driver_specialist = introducers_specialist_recent.get(prev_intro1.Id).get(con1.Id);

		Opportunity opp4 = new Opportunity();
		opp4.Introducer_new__c = prev_intro1.Id;
		opp4.Introducer_contact__c = con.id;
		opp4.closedate = system.today() + 7;
		opp4.AccountId = prev_business.Id;
		opp4.name = 'test diva business';
		opp4.SearchedAmount__c = 54321;
        opp4.RecordTypeId = fundingSearchRecordTypeId;
		opp4.stagename = 'Incomplete';

		Id business_specialist = business_specialist_recent.get(prev_business.Id);
		
		List<String> test_opps = new List<String>();
		test_opps.add(opp.Name);
		test_opps.add(opp1.Name);
		test_opps.add(opp2.Name);
		test_opps.add(opp3.Name);
		test_opps.add(opp4.Name);

		Id chosenId = rsOpportunityChangeContactStageHelper.Selectspecialist(specialists_stages_count_map, funding_specialists);

		List<Opportunity> test_inserts = new List<Opportunity>();
		test_inserts.add(opp);
		test_inserts.add(opp1);
		test_inserts.add(opp2);
		test_inserts.add(opp3);
		test_inserts.add(opp4);

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CapAPPMock_Success());
		insert test_inserts;
		Test.stopTest();

		for(Opportunity oppRecord: [select Id, Name, Funding_Specialist__c from Opportunity where Name in :test_opps])
		{
			switch on oppRecord.Name {
				when 'assignment test diva' {
					system.AssertEquals(oppRecord.Funding_Specialist__c, chosenId);
				}
				when 'test diva partner' {
					system.AssertEquals(oppRecord.Funding_Specialist__c, partner_specialist);
				}
				when 'test diva chaperone' {
					system.AssertEquals(oppRecord.Funding_Specialist__c, chaperone_specialist);
				}
				when 'test diva driver' {
					system.AssertEquals(oppRecord.Funding_Specialist__c, driver_specialist);
				}
				when 'test diva business' {
					system.AssertEquals(oppRecord.Funding_Specialist__c, business_specialist);
				}
			}
		}
	}
}