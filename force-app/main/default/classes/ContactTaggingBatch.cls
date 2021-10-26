global class ContactTaggingBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global ContactTaggingBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select InfusionSoftExtId__c, CapitaliseExtID__c, tagsID__c, network__c, LeadSource, person_type__c, LeadSourceExtID__c from Contact';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Tags__c> tags = [select CapitaliseExtID__c, Name, field1__c, field1_value__c, field2__c, field2_value__c, field3__c, field3_value__c, 
                              field4__c, field4_value__c, field5__c, field5_value__c 
                              from Tags__c];
        List<Lead_Source__c> leadsources = [select CapitaliseExtID__c, Name, field_1__c, field_1_value__c, field_2__c, field_2_value__c, field_3__c, field_3_value__c, 
                                            field_4__c, field_4_value__c
                                            from Lead_Source__c];
        
        Map<string, tags__c> mt = new Map<string, tags__c>();
        for(tags__c t : tags){
            mt.put(t.CapitaliseExtID__c, t);            
        }
        system.debug('aa '+ mt);
        
        Map<string, Lead_Source__c> lsmap = new Map<string, Lead_Source__c>();
        for(Lead_Source__c l : leadsources) {
            lsmap.put(l.CapitaliseExtID__c, l);
        }
        
        Map<string, Contact> mc = new Map<string, contact>();
        Map<string, Contact> cptlsmap = new Map<string, contact>();
        for(contact c : scope){
            if(c.InfusionSoftExtId__c != null){
                mc.put(c.InfusionSoftExtId__c, c);
            }
            if(c.CapitaliseExtID__c != null) {
                cptlsmap.put(c.CapitaliseExtID__c, c);  
            }            
        }
        system.debug('ff '+ mc);
        
        for(contact c1 : scope)
        {
            if(string.isNotBlank(c1.TagsID__c))
            {
                list<string> ls = c1.tagsID__c.split('\\, ');
                set<string> sc = new set<string>(ls);
                system.debug('vvvv '+sc);
                for(string cc : sc)
                {
                    tags__c tags1 = mt.get(cc);  
                    system.debug(tags1);
                    
                    if(tags1!= null)
                    {
                        Contact cUpdate = new Contact();
                        if(c1.InfusionSoftExtId__c != null) {
                            if(mc.containsKey(c1.InfusionSoftExtId__c)) {
                                cUpdate = mc.get(c1.InfusionSoftExtId__c);
                            }
                        }
                        else {
                            if(cptlsmap.containsKey(c1.CapitaliseExtID__c)) {
                                cUpdate = cptlsmap.get(c1.CapitaliseExtID__c);
                            }
                        }
                        
                        
                        if(string.isNotBlank(tags1.Field1__c))
                        {
                            if(tags1.Field1__c=='Network')
                                cUpdate.Network__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='User Acquired by Landing Page')
                                cUpdate.User_Acquired_by_Landing_Page__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='User Acquired by')
                                cUpdate.User_Acquired_By__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Data Cleansing')
                                cUpdate.Data_Cleansing__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Person Type' && cUpdate.Person_Type__c == null)
                                cUpdate.Person_Type__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Lead Capture Content')
                                cUpdate.Lead_Capture_Content__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Business Sector')
                                cUpdate.Business_Sector__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Communication History')
                                cUpdate.Communication_History__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Communication Category')
                                cUpdate.Communication_Category__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Lead Source')
                                cUpdate.LeadSource=tags1.field1_value__c;
                            if(tags1.Field1__c=='Signup As')
                                cUpdate.Signup_As__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Funding Search Status')
                                cUpdate.Funding_Search_Status__c=tags1.field1_value__c;
                            if(tags1.Field1__c=='Referred to')
                                cUpdate.Referred_to__c=tags1.field1_value__c;
                        }
                        if(string.isNotBlank(tags1.Field2__c))
                        {
                            //if(tags1.Field1__c=='Contact Owner')
                            //  cUpdate.=tags1.field1_value__c;
                            if(tags1.Field2__c=='Lead Source Detail')
                                cUpdate.Lead_Source_Detail__c=tags1.field2_value__c;
                            if(tags1.Field2__c=='Introducer Type')
                                cUpdate.Introducer_Type__c=tags1.field2_value__c;
                            if(tags1.Field2__c=='Lead Source')
                                cUpdate.LeadSource=tags1.field2_value__c;
                            if(tags1.Field2__c=='Person Type' && cUpdate.Person_Type__c == null )
                                cUpdate.Person_Type__c=tags1.field2_value__c;
                        }
                        if(string.isNotBlank(tags1.Field3__c))
                        {
                            //if(tags1.Field3__c=='Contact Owner')
                            //  cUpdate.=tags1.field3_value__c;
                            if(tags1.Field3__c=='Lead Source Detail')
                                cUpdate.Lead_Source_Detail__c=tags1.field3_value__c;
                            if(tags1.Field3__c=='Introducer Type')
                                cUpdate.Introducer_Type__c=tags1.field3_value__c;
                            
                            if(tags1.Field3__c=='Person Type' && cUpdate.Person_Type__c == null )
                                cUpdate.Person_Type__c=tags1.field3_value__c;
                        }
                        
                        if(string.isNotBlank(tags1.Field4__c))
                        {
                            //if(tags1.Field4__c=='Contact Owner')
                            //  cUpdate.=tags1.field4_value__c;
                            
                            if(tags1.Field4__c=='Introducer Type')
                                cUpdate.Introducer_Type__c=tags1.field4_value__c;
                            if(tags1.Field4__c=='Lead Source')
                                cUpdate.LeadSource=tags1.field4_value__c;
                            if(tags1.Field4__c=='Person Type' && cUpdate.Person_Type__c == null )
                                cUpdate.Person_Type__c=tags1.field4_value__c;
                        }
                        if(string.isNotBlank(tags1.Field5__c))
                        {
                            //if(tags1.Field5__c=='Contact Owner')
                            //  cUpdate.=tags1.field5_value__c;
                            
                            if(tags1.Field5__c=='Introducer Type')
                                cUpdate.Introducer_Type__c=tags1.field5_value__c;
                        }
                    }
                }
            }
            
            if(string.isNotBlank(c1.LeadSourceExtID__c)){
                
                if(lsmap.containsKey(c1.LeadSourceExtId__c)){
                    
                    Lead_Source__c lsobject = lsmap.get(c1.LeadSourceExtID__c);
                    system.debug('lsobject '+ lsobject);
                    Contact cUpdate = new Contact();
                    if(c1.InfusionSoftExtId__c != null) {
                        if(mc.containsKey(c1.InfusionSoftExtId__c)) {
                            cUpdate = mc.get(c1.InfusionSoftExtId__c);
                        }
                    }
                    else {
                        if(cptlsmap.containsKey(c1.CapitaliseExtID__c)) {
                            cUpdate = cptlsmap.get(c1.CapitaliseExtID__c);
                        }
                    }
                    
                    
                    if(string.isNotBlank(lsobject.Field_1__c))
                    {
                        if(lsobject.Field_1__c=='Network')
                            cUpdate.Network__c=lsobject.field_1_value__c;
                        if(lsobject.Field_1__c=='Lead Source')
                            cUpdate.LeadSource=lsobject.field_1_value__c;
                        if(lsobject.Field_1__c=='Person Type' && cUpdate.Person_Type__c == null)
                            cUpdate.Person_Type__c=lsobject.field_1_value__c;
                    }
                    if(string.isNotBlank(lsobject.Field_2__c))
                    {
                        if(lsobject.Field_2__c=='Lead Source Detail')
                            cUpdate.Lead_Source_Detail__c=lsobject.field_2_value__c;
                        if(lsobject.Field_2__c=='Introducer Type')
                            cUpdate.Introducer_Type__c =lsobject.field_2_value__c;
                    }
                    if(string.isNotBlank(lsobject.Field_3__c))
                    {
                        if(lsobject.Field_3__c=='Contact Owner')
                            cUpdate.Contact_Owner__c=lsobject.field_3_value__c;
                        if(lsobject.Field_3__c=='Person Type' && cUpdate.Person_Type__c == null)
                            cUpdate.Person_Type__c=lsobject.field_3_value__c;
                    }
                    
                    if(string.isNotBlank(lsobject.Field_4__c))
                    {
                        if(lsobject.Field_4__c=='Introducer Type')
                            cUpdate.Introducer_Type__c=lsobject.field_4_value__c;
                        if(lsobject.Field_4__c=='Lead Source')
                            cUpdate.LeadSource=lsobject.field_4_value__c;
                    }
                }
            }
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}