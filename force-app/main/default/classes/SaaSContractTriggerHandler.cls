public with sharing class SaaSContractTriggerHandler {
    public static Boolean hasRan = false;
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < Saas_Contract__c > newList,
        Map < Id, Saas_Contract__c > newMap,
        List < Saas_Contract__c > oldList,
        Map < Id, Saas_Contract__c > oldMap
    ) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                SetProduct(newList);
            }
        }
    }

    private static void SetProduct(List<Saas_Contract__c> newList)
    {
        Set<Id> oppIds = new Set<Id>();
        for(Saas_Contract__c contract : newList)
        {
            if(contract.Opportunity__c != null) oppIds.add(contract.Opportunity__c);
        }

        List<OpportunityLineItem> products = [select Id, OpportunityId, Product2Id from OpportunityLineItem where OpportunityId IN :oppIds];

        Map<Id, OpportunityLineItem> productsMap = new Map<Id, OpportunityLineItem>();

        for(OpportunityLineItem product : products)
        {
            productsMap.put(product.OpportunityId, product);
        }

        for(Saas_Contract__c contract : newList)
        {
            contract.Opportunity_Product__c = (productsMap.containsKey(contract.Opportunity__c)) ? productsMap.get(contract.Opportunity__c).Product2Id : null;
        }
    }
}