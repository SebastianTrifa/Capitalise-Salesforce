global class OverdueTaskNotifier implements Schedulable {
    global void execute(SchedulableContext context)
    {
        List<Task> tasks = [SELECT Id, WhatId, Status, ActivityDate, OwnerId from Task where Status != 'Completed' and ActivityDate < TODAY];
        EmailTemplate et = [Select Id, Name from EmailTemplate where name = 'Overdue Task Notification' limit 1];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(Task task : tasks)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setTargetObjectId(task.OwnerId);
            mail.setWhatId(task.Id);
            mails.add(mail);
        }
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
            for(Messaging.SendEmailResult result : results)
            {
                if(!result.isSuccess())
                {
                    // Operation failed, so get all errors                
                    for(Messaging.SendEmailError err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
            return;
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }
    }
}