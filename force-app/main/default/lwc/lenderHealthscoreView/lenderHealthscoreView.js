import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import LENDER_CONVERSION_FIELD from '@salesforce/schema/Account.Lender_Conversion__c';
import LENDER_MONETARY_FIELD from '@salesforce/schema/Account.Lender_Monetary__c';
import ACTIVE_CONTACTS_FIELD from '@salesforce/schema/Account.Active_Contacts__c';
import PLATFORM_USE_FIELD from '@salesforce/schema/Account.Platform_Use_API__c';
import FEEDBACK_FIELD from '@salesforce/schema/Account.Feedback__c';
import HEALTHSCORE_FIELD from '@salesforce/schema/Account.HealthScore__c';

const ACCOUNT_FIELDS = [ID_FIELD,
    NAME_FIELD,
    LENDER_CONVERSION_FIELD,
    LENDER_MONETARY_FIELD,
    ACTIVE_CONTACTS_FIELD, 
    PLATFORM_USE_FIELD, 
    FEEDBACK_FIELD,
    HEALTHSCORE_FIELD,
];

export default class lenderHealthscoreView extends LightningElement {
    @api recordId;
    
    @track partner = '';
    @track error = 'Error';
    @track errorCode = '';

    @wire(getRecord, {recordId: '$recordId', fields: ACCOUNT_FIELDS}) loadPartner({data, error}) {
        if (data) {
            this.lender = data;
            this.error = null;
        } else if (error) {
            this.error = error.body.message;
            this.errorCode = error.body.errorCode;
            this.lender = null;
        }
    }

    get lenderRadar() {
        if(this.lender) {
            return [this.lender.fields.Lender_Conversion__c.value,
                this.lender.fields.Lender_Monetary__c.value,
                this.lender.fields.Active_Contacts__c.value,
                this.lender.fields.Platform_Use_API__c.value,
                this.lender.fields.Feedback__c.value];
        }
        return [0,0,0,0,0];
    }

    get lenderHealthy() {
        if(this.lender) {
            return (this.lender.fields.HealthScore__c.value >= 70);
        }
        return false;
    }

    get lenderWeak() {
        if(this.lender) {
            return (this.lender.fields.HealthScore__c.value < 60);
        }
        return false;
    }

    get lender() {
        return this.lender;
    }

    get lenderName() {
        if(this.lender) {
            return this.lender.fields.Name.value;
        }
        return this.errorCode;
    }

    get lenderLenderConversion() {
        if(this.lender) {
            return this.lender.fields.Lender_Conversion__c.value;
        }
        return this.error;
    }

    get lenderHealthscore() {
        if(this.lender) {
            return this.lender.fields.HealthScore__c.value / 100;
        }
        return this.error;
    }

    get lenderLenderMonetary() {
        if(this.lender) {
            return this.lender.fields.Lender_Monetary__c.value;
        }
        return this.error;
    }

    get lenderActiveContacts() {
        if(this.lender) {
            return this.lender.fields.Active_Contacts__c.value;
        }
        return this.error;
    }

    get lenderPlatformUse() {
        if(this.lender) {
            return this.lender.fields.Platform_Use_API__c.value;
        }
        return this.error;
    }

    get lenderFeedback() {
        if(this.lender) {
            return this.lender.fields.Feedback__c.value;
        }
        return this.error;
    }
}