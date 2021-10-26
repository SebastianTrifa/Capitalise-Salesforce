global class OpportunityContactSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		OpportunityContactBatch oppbatch = new OpportunityContactBatch();
		database.executebatch(oppbatch,50);
	}
}