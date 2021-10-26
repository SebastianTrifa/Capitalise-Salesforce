global class AccountHealthScoreSorter implements Comparable {

    public Account acc;
    private String sortKey; 

    public AccountHealthScoreSorter(Account a_acc, String a_sortKey) {
        acc = a_acc;
        sortKey = a_sortKey;
    }

    global Integer compareTo(Object ante) {
        AccountHealthScoreSorter anteWrapped = (AccountHealthScoreSorter)ante;

        Integer result = 0;

        switch on sortKey {
            when 'Monetary Secured' {
                if(acc.Monetary_Key_Secured__c > anteWrapped.acc.Monetary_Key_Secured__c) {
                    result = 1;
                } else if(acc.Monetary_Key_Secured__c < anteWrapped.acc.Monetary_Key_Secured__c) {
                    result = -1;
                } else if((acc.Monetary_Key_Secured__c == null) && (anteWrapped.acc.Monetary_Key_Secured__c != null)) {
                    result = -1;
                } else if((Acc.Monetary_Key_Secured__c != null) && (anteWrapped.acc.Monetary_Key_Secured__c == null)) {
                    result = 1;
                }
            }
            when 'Monetary Unsecured' {
                if(acc.Monetary_Key_Unsecured__c > anteWrapped.acc.Monetary_Key_Unsecured__c) {
                    result = 1;
                } else if(acc.Monetary_Key_Unsecured__c < anteWrapped.acc.Monetary_Key_Unsecured__c) {
                    result = -1;
                } else if((acc.Monetary_Key_Unsecured__c == null) && (anteWrapped.acc.Monetary_Key_Unsecured__c != null)) {
                    result = -1;
                } else if((Acc.Monetary_Key_Unsecured__c != null) && (anteWrapped.acc.Monetary_Key_Unsecured__c == null)) {
                    result = 1;
                }
            }
            when 'Recency' {
                if(acc.Recent_Searches__c > anteWrapped.acc.Recent_Searches__c) {
                    result = 1;
                } else if (acc.Recent_Searches__c < anteWrapped.acc.Recent_Searches__c) {
                    result = -1;
                } else if((acc.Recent_Searches__c == null) && (anteWrapped.acc.Recent_Searches__c != null)) {
                    result = -1;
                } else if((acc.Recent_Searches__c != null) && (anteWrapped.acc.Recent_Searches__c == null)) {
                    result = 1;
                }
            }
            when 'Attachment' {
                if(acc.Managed_Clients_Connected__c > anteWrapped.acc.Managed_Clients_Connected__c) {
                    result = 1;
                } else if (acc.Managed_Clients_Connected__c < anteWrapped.acc.Managed_Clients_Connected__c) {
                    result = -1;
                } else if((acc.Managed_Clients_Connected__c == null) && (anteWrapped.acc.Managed_Clients_Connected__c != null)) {
                    result = -1;
                } else if((acc.Managed_Clients_Connected__c != null) && (anteWrapped.acc.Managed_Clients_Connected__c == null)) {
                    result = 1;
                }
            }
            when 'Penetration' {
                if(acc.Penetration_Key__c > anteWrapped.acc.Penetration_Key__c) {
                    result = 1;
                } else if (acc.Penetration_Key__c < anteWrapped.acc.Penetration_Key__c) {
                    result = -1;
                } else if((acc.Penetration_Key__c == null) && (anteWrapped.acc.Penetration_Key__c != null)) {
                    result = -1;
                } else if((acc.Penetration_Key__c != null) && (anteWrapped.acc.Penetration_Key__c == null)) {
                    result = 1;
                }
            }
            when 'Conversion' {
                if(acc.Conversion_Rate_Key__c > anteWrapped.acc.Conversion_Rate_Key__c) {
                    result = 1;
                } else if (acc.Conversion_Rate_Key__c < anteWrapped.acc.Conversion_Rate_Key__c) {
                    result = -1;
                } else if((acc.Conversion_Rate_Key__c == null) && (anteWrapped.acc.Conversion_Rate_Key__c != null)) {
                    result = -1;
                } else if((acc.Conversion_Rate_Key__c != null) && (anteWrapped.acc.Conversion_Rate_Key__c == null)) {
                    result = 1;
                }
            }
            when 'Engagement' {
                if(acc.Engagement_Key__c > anteWrapped.acc.Engagement_Key__c) {
                    result = 1;
                } else if (acc.Engagement_Key__c < anteWrapped.acc.Engagement_Key__c) {
                    result = -1;
                } else if((acc.Engagement_Key__c == null) && (anteWrapped.acc.Engagement_Key__c != null)) {
                    result = -1;
                } else if((acc.Engagement_Key__c != null) && (anteWrapped.acc.Engagement_Key__c == null)) {
                    result = 1;
                }
            }
            when 'Spread' {
                if(acc.Spread_Key__c > anteWrapped.acc.Spread_Key__c) {
                    result = 1;
                } else if (acc.Spread_Key__c < anteWrapped.acc.Spread_Key__c) {
                    result = -1;
                } else if((acc.Spread_Key__c == null) && (anteWrapped.acc.Spread_Key__c != null)) {
                    result = -1;
                } else if((acc.Spread_Key__c != null) && (anteWrapped.acc.Spread_Key__c == null)) {
                    result = 1;
                }
            }
        }

        return result;
    }
}