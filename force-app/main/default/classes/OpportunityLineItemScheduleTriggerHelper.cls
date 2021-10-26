/** 
(c) 2020 Rolling-Space
Developed by Rolling-Space, Braga (Portugal)
@date 01/2020 
@author Miguel Sampaio 

*/
public with sharing class OpportunityLineItemScheduleTriggerHelper {

    // Trigger entry point
    public static void entry(
        System.TriggerOperation triggerEvent,
        List < OpportunityLineItemSchedule > newList,
        Map < Id, OpportunityLineItemSchedule > newMap,
        List < OpportunityLineItemSchedule > oldList,
        Map < Id, OpportunityLineItemSchedule > oldMap
    ) {
        // Dispatch trigger event to corresponding methods 
        switch on triggerEvent {
            when AFTER_INSERT {
                // Processing for after insert an opportunitylineItemSchedule
                MMRandARRValues(newList);

            }
            when AFTER_UPDATE {
                // Processing for after update an opportunitylineItemSchedule
                MMRandARRValues(newList);


            }

            when BEFORE_UPDATE {
                // Processing for after insert an opportunitylineItemSchedule
                opportunityLineItemScheduleValidationRule(newList);

            }

        }
    }


    public static void opportunityLineItemScheduleValidationRule(List < OpportunityLineItemSchedule > newList) {

        Map < Id, List < OpportunityLineItemSchedule >> mapNumberOfInstallments = new Map < Id, List < OpportunityLineItemSchedule >> ();
        Map < Id, List < Date >> mapScheduleDates = new Map < Id, List < Date >> ();


        for (OpportunityLineItemSchedule OpportunityLineItemScheduleRecord: newList) {

            List < OpportunityLineItemSchedule > opportunityLineItemScheduleList = new List < OpportunityLineItemSchedule > ();
            if (mapNumberOfInstallments.containskey(opportunitylineItemScheduleRecord.OpportunityLineItemId)) {
                opportunityLineItemScheduleList = mapNumberOfInstallments.get(opportunitylineItemScheduleRecord.OpportunityLineItemId);
            } else {
                mapNumberOfInstallments.put(opportunitylineItemScheduleRecord.OpportunityLineItemId, opportunityLineItemScheduleList);
            }
            opportunityLineItemScheduleList.add(opportunitylineItemScheduleRecord);

            List < Date > dateList = new List < Date > ();
            if (mapScheduleDates.containskey(opportunitylineItemScheduleRecord.OpportunityLineItemId)) {
                dateList = mapScheduleDates.get(opportunitylineItemScheduleRecord.OpportunityLineItemId);
                dateList.sort();
            } else {
                dateList.sort();
                mapScheduleDates.put(opportunitylineItemScheduleRecord.OpportunityLineItemId, dateList);
            }
            dateList.add(opportunitylineItemScheduleRecord.ScheduleDate);
        }


        for (OpportunityLineItemSchedule OpportunityLineItemScheduleRecord: newList) {
            if (mapNumberOfInstallments.containskey(OpportunityLineItemScheduleRecord.OpportunityLineItemId)) {
                system.debug(mapNumberOfInstallments.get(OpportunityLineItemScheduleRecord.OpportunityLineItemId).size());
                if (math.mod(mapNumberOfInstallments.get(OpportunityLineItemScheduleRecord.OpportunityLineItemId).size(), 12) != 0) {
                    OpportunityLineItemScheduleRecord.addError('You must choose 12/24 months!');
                }
               
                if (mapScheduleDates.get(OpportunityLineItemScheduleRecord.OpportunityLineItemId).size() > 1) {
                    Date firstScheduleDate = mapScheduleDates.get(OpportunityLineItemScheduleRecord.OpportunityLineItemId)[0];
                    Date secondScheduleDate = mapScheduleDates.get(OpportunityLineItemScheduleRecord.OpportunityLineItemId)[1];
                  
                    Date firstPlusOneMonth = firstScheduleDate.addMonths(1);
        
                    if (secondScheduleDate != firstPlusOneMonth) {
                        OpportunityLineItemScheduleRecord.addError('You must choose the Month Option');
                    }
                } else {
                    OpportunityLineItemScheduleRecord.addError('You must choose 12/24 months!');
                }
            }
        }
    }

    public static void MMRandARRValues(List < OpportunityLineItemSchedule > newList) {

        Set < Id > setOpportunityLineIds = new Set < Id > ();
        for (OpportunityLineItemSchedule opportunitylineItemScheduleRecord: newList) {
            setOpportunityLineIds.add(opportunitylineItemScheduleRecord.OpportunityLineItemId);
        }

        //set a map to relate the OpportunityLine to associated Schedules.
        Map < Id, List < OpportunityLineItemSchedule >> mapOpportunityLines = new Map < Id, List < OpportunityLineItemSchedule >> ();

        for (OpportunityLineItemSchedule opportunitylineItemScheduleRecord: [SELECT Id, OpportunityLineItemId, OpportunityLineItem.OpportunityId, Revenue FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN: setOpportunityLineIds]) {
            List < OpportunityLineItemSchedule > opportunityLineItemScheduleList = new List < OpportunityLineItemSchedule > ();
            if (mapOpportunityLines.containskey(opportunitylineItemScheduleRecord.OpportunityLineItemId)) {
                opportunityLineItemScheduleList = mapOpportunityLines.get(opportunitylineItemScheduleRecord.OpportunityLineItemId);
            } else {
                mapOpportunityLines.put(opportunitylineItemScheduleRecord.OpportunityLineItemId, opportunityLineItemScheduleList);
            }
            opportunityLineItemScheduleList.add(opportunitylineItemScheduleRecord);
        }

        List < Opportunity > opportunityList = new List < Opportunity > ();
        for (OpportunityLineItem opportunitylineItemRecord: [SELECT Id, OpportunityId, Product2.NumberOfRevenueInstallments, Product2.RevenueInstallmentPeriod, Product2.RevenueScheduleType, Product2.QuantityScheduleType, Product2.QuantityInstallmentPeriod, Product2.NumberOfQuantityInstallments FROM OpportunityLineItem WHERE Id IN: mapOpportunityLines.keyset()]) {

            if (mapOpportunityLines.containskey(opportunitylineItemRecord.Id)) {
                decimal totalRevenue = 0;
                integer count = 0;
                for (OpportunityLineItemSchedule opportunitylineItemScheduleRecord: mapOpportunityLines.get(opportunitylineItemRecord.Id)) {
                    totalRevenue = totalRevenue + opportunitylineItemScheduleRecord.Revenue;
                    count = count + 1;
                }
                Opportunity opportunityRecord = new Opportunity();
                opportunityRecord.Id = opportunitylineItemRecord.OpportunityId;
                opportunityRecord.Sub_MRR__c = totalRevenue / count;
                opportunityRecord.Sub_ARR__c = (totalRevenue / count) * 12;
                opportunityList.add(opportunityRecord);
            }
        }

        update opportunityList;

    }

}