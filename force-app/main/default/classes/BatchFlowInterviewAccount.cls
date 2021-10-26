global class BatchFlowInterviewAccount implements Database.Batchable<sObject> {
    
    String query;
    String flowInterview;
    global BatchFlowInterviewAccount(string a_query) {
        query = a_query;
        flowInterview = 'Introducer Commission';
    }

    global BatchFlowInterviewAccount(string a_query, string a_flowInterview) {
        query = a_query;
        flowInterview = a_flowInterview;
    }

    global BatchFlowInterviewAccount()
    {
        query = 'select Id from Account';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        for(Account acc : scope)
        {
            switch on flowInterview {
                when 'Introducer Commission' {
                    Map<String, Object> inputs = new Map<String, Object>();
                    inputs.put('IntroducerAccount', acc);
                    Flow.Interview.Introducer_Commissions_Calculation aFlow = new Flow.Interview.Introducer_Commissions_Calculation(inputs);
                    aFlow.start();
                }
                when 'Last Paid Out Close Date' {
                    Map<String, Object> inputs = new Map<String, Object>();
                    inputs.put('introducerRecord', acc);
                    Flow.Interview.Introducer_Get_last_Paid_Out_Search_Date aFlow = new Flow.Interview.Introducer_Get_last_Paid_Out_Search_Date(inputs);
                    aFlow.start();
                }
                when 'Account NPS Score' {
                    Map<String, Object> inputs = new Map<String, Object>();
                    inputs.put('accountRecord', acc);
                    Flow.Interview.NPS_Score_Aggregation aFlow = new Flow.Interview.NPS_Score_Aggregation(inputs);
                    aFlow.start();
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}