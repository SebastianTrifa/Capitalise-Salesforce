global class ContactTaggingSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ContactTaggingBatch conbatch = new ContactTaggingBatch();
		database.executebatch(conbatch,50);
	}
}