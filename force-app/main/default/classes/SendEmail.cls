global without sharing class SendEmail {
    global class InvokeSendEmail {
        //input parameters
        @InvocableVariable(label='Related To ID' description='' required=false)
        global Id RelatedToID;

        @InvocableVariable(label='Contact/Lead ID' description='Required when using an email template' required=false)
        global Id ContactOrLeadID;

        @InvocableVariable(label='Template ID' description='Contact/Lead ID required if using this' required=false)
        global Id EmailTemplateID;

        @InvocableVariable(label='To Addresses' description='' required=false)
        global String ToAddresses;

        @InvocableVariable(label='CC Addresses' description='' required=false)
        global String ccAddresses;

        @InvocableVariable(label='BCC Addresses' description='' required=false)
        global String bccAddresses;

        @InvocableVariable(label='Save As Activity' description='' required=false)
        global Boolean SaveAsActivity;

        @InvocableVariable(label='Subject' description='' required=false)
        global String Subject;

        @InvocableVariable(label='Body (Text)' description='' required=false)
        global String TextBody;

        @InvocableVariable(label='Body (HTML)' description='' required=false)
        global String HtmlBody;

        @InvocableVariable(label='From Address' description='' required=false)
        global String FromAddress;

        @InvocableVariable(label='Treat Target Object As Recipient' description='' required=false)
        global Boolean TreatTargetObjectAsRecipient;

        @InvocableVariable(label='Treat Bodies As Template' description='Render Body, HtmlBody and Subject as a Template if true' required=false)
        global Boolean TreatBodiesAsTemplate;

        @InvocableVariable(label='Body - Use Signature' description='' required=false)
        global Boolean UseSignature;
    }

    @InvocableMethod(label='Send Email')
    global static void SendEmail(List<InvokeSendEmail> requests) {
        Send(requests, false);
    }

    global static void SendEmailForceError(List<InvokeSendEmail> requests) {
        Send(requests, true);
    }

    global static void Send(List<InvokeSendEmail> requests, Boolean forceSendEmailError) {
        List<Task> tasks = new List<Task>();
        List<String> apexErrors = new List<String>();

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<String> contactOrLeadIds = new Set<String>();
        
        for (InvokeSendEmail request : requests) {
            if(String.isNotBlank(request.ContactOrLeadID)) {
                contactOrLeadIds.add(request.ContactOrLeadID);
            }
        }


        Map<String, String> contactOrLeadEmailsById = new Map<String, String>();

        if(!contactOrLeadIds.isEmpty()) {
            for(Contact con : [select Id, Email From Contact Where Id in :contactOrLeadIds]) {
                contactOrLeadEmailsById.put(con.Id, con.Email);
            }

            for(Lead alead : [select Id, Email from Lead where Id in :contactOrLeadIds]) {
                contactOrLeadEmailsById.put(alead.Id, alead.Email);
            }
        }

        for (InvokeSendEmail request : requests) {
            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                if(String.isNotBlank(request.EmailTemplateID)) {
                    mail.setTemplateId(request.EmailTemplateID);
                } else {
                    if(String.isNotBlank(request.Subject)) mail.setSubject(request.Subject);
                    if(String.isNotBlank(request.TextBody)) mail.setplainTextBody(request.TextBody);
                    if(String.isNotBlank(request.HtmlBody)) mail.setHtmlBody(request.HtmlBody);
                }

                String[] ToAddressesSplit = (String.isBlank(request.ToAddresses) || !request.ToAddresses.contains('@')) ? new String[]{} : request.ToAddresses.split(',');
                String[] ccAddressesSplit = (String.isBlank(request.ccAddresses) || !request.ccAddresses.contains('@')) ? new String[]{} : request.ccAddresses.split(',');
                String[] BccAddressesSplit = (String.isBlank(request.bccAddresses) || !request.bccAddresses.contains('@')) ? new String[]{} : request.bccAddresses.split(',');

                if(String.isNotBlank(request.RelatedToID)) mail.setWhatId(request.RelatedToID);

                if(String.isNotBlank(request.ContactOrLeadID)) {
                    if(!contactOrLeadEmailsById.containsKey(request.ContactOrLeadID)) {
                        throw new SendEmailException('No Contact or Lead found with the Id: ' + request.ContactOrLeadID);
                    } else mail.setTargetObjectId(request.ContactOrLeadID);

                    if(request.TreatTargetObjectAsRecipient == null) request.TreatTargetObjectAsRecipient = true;

                    if(request.TreatTargetObjectAsRecipient == true) {
                        if(String.isBlank(contactOrLeadEmailsById.get(request.ContactOrLeadID))) {
                            throw new SendEmailException('No email found for Contact or Lead Id: ' + request.ContactOrLeadID);
                        } else mail.setTreatTargetObjectasRecipient(true);
                    } else mail.setTreatTargetObjectasRecipient(false);
                }

                if(!ToAddressesSplit.isEmpty()) {
                    mail.setToAddresses(ToAddressesSplit);
                } else if (String.isBlank(request.ContactOrLeadID) || !request.TreatTargetObjectAsRecipient) {
                    throw new SendEmailException('No recipient email address could be found!');
                }

                if (!ccAddressesSplit.isEmpty()) mail.setCcAddresses(ccAddressesSplit);
                if (!BccAddressesSplit.isEmpty()) mail.setBccAddresses(BccAddressesSplit);

                if(request.SaveAsActivity != null) {
                    mail.setSaveAsActivity(request.SaveAsActivity);
                }
                if(request.UseSignature != null) mail.setUseSignature(request.UseSignature);
                if(String.isNotBlank(request.FromAddress)) mail.setSenderDisplayName(request.FromAddress);

                mails.add(mail);
            } catch (Exception ex) {
                tasks.add(createTask(
                    'Failed to send email',
                    String.format('Exception Type: {0}\nException Message: {1}\nStack Trace String: {2}', new String[]{
                        ex.getTypeName(),
                        ex.getMessage(),
                        ex.getStackTraceString()
                    }),
                    request.RelatedToID,
                    request.ContactOrLeadID
                ));
            }
        }

        try {
            if (!mails.isEmpty()) {
                if(forceSendEmailError) {
                    mails.add(new Messaging.SingleEmailMessage());
                }

                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);

                Integer mailIndex = 0;
                for(Messaging.SendEmailResult result : results) {
                    if(!result.isSuccess()) {
                        tasks.add(createTask(
                            'Failed to send email',
                            String.format('Errors: \n{0}\n\nEmail Body: {1}', new String[]{
                                getSendEmailErrors(result.getErrors()),
                                mails[mailIndex].plainTextBody
                            }),
                            mails[mailIndex].WhatId,
                            mails[mailIndex].TargetObjectId
                        ));
                    }
                    mailIndex++;
                }
            }
        } catch (Exception ex) {
            tasks.add(createTask(
                'Failed to send emails',
                String.format('Exception Type: {0}\nException Message: {1}\nStack Trace String: {2}', new String[]{
                    ex.getTypeName(),
                    ex.getMessage(),
                    ex.getStackTraceString()
                }),
                null,
                null
            ));
        }

        if(!tasks.isEmpty()) insert tasks;
    }

    private static String getSendEmailErrors(Messaging.SendEmailError[] errors) {
        String errorString ='';
        for(Messaging.SendEmailError error : errors) {
            errorString += String.format(
                '{0}Error Fields: {1}\nError Message: {2}\nStatus Code: {3}\nTarget Object ID: {4}',
                new String[]{
                    String.isNotBlank(errorString) ? '\n\n' : '',
                    String.join(error.getFields(), ', '),
                    error.getMessage(),
                    String.valueOf(error.getStatusCode()),
                    error.getTargetObjectId()
                }
            );
        }
        return errorString;
    }

    private static Task createTask(String subject, String description, Id whatId, Id whoId) {
        return new Task(
            Subject = subject,
            ActivityDate = System.today(),
            Description = String.isNotBlank(description) ? description.left(30000) : null,
            WhatId = whatId,
            WhoId = whoId
        );
    }

    public class SendEmailException extends Exception {}
}