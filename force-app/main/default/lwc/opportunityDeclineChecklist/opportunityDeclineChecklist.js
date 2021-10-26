import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getChecklist from '@salesforce/apex/OpportunityService.getChecklist';

import CHECKLIST_OBJECT from '@salesforce/schema/Declined_Opportunity_Checklist__c';
import CALL_LOGGED_FIELD from '@salesforce/schema/Declined_Opportunity_Checklist__c.Call_Logged__c';
import EMAIL_LOGGED_FIELD from '@salesforce/schema/Declined_Opportunity_Checklist__c.Email_Logged__c';
import NOTES_ADDED_FIELD from '@salesforce/schema/Declined_Opportunity_Checklist__c.Notes_Added__c';
import NOTES_RECEIVED_FIELD from '@salesforce/schema/Declined_Opportunity_Checklist__c.Notes_Received__c';
import OPPID_FIELD from '@salesforce/schema/Opportunity.Id';
import OPPSTAGE_FIELD from '@salesforce/schema/Opportunity.StageName';

const OPP_FIELDS = [OPPID_FIELD, OPPSTAGE_FIELD];

export default class OpportunityDeclineChecklist extends LightningElement {
    @api recordId;

    @track declinedChecklist = null;
    @track oppRecord;
    @track error = 'Error';
    @track errorCode = null;

    checklistApiName = CHECKLIST_OBJECT;
    callLoggedField = CALL_LOGGED_FIELD;
    emailLoggedField = EMAIL_LOGGED_FIELD;
    notesAddedField = NOTES_ADDED_FIELD;
    notesReceivedField = NOTES_RECEIVED_FIELD;

    @wire(getChecklist, {oppId: '$recordId'}) loadChecklist({data, error}) {
        if(data) {
            this.declinedChecklist = data;
            this.error = null;
            this.errorCode = null;
        } else if(error) {
            this.errorCode = error.body.errorCode;
            this.error = error.body.message;
            this.declinedChecklist = null;
        }
    }

    @wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS}) loadOpportunity({data, error}) {
        if(data) {
            this.oppRecord = data;
        } else if (error) {
            this.oppRecord = undefined;
            this.error = error.body.message;
            this.errorCode = error.body.errorCode;
        }
    }

    get visible() {
        if(this.oppRecord) {
            if(this.oppRecord.fields.StageName.value=='Declined') return true;
            else return false;
        }
        return false;
    }

    get checklistID() {
        if(this.declinedChecklist) return this.declinedChecklist.Id;
        return this.error;
    }
}