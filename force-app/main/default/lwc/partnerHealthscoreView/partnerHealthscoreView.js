import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ATTACHMENT_FIELD from '@salesforce/schema/Account.Attachment__c';
import CONVERSION_FIELD from '@salesforce/schema/Account.Conversion_Rate__c';
import ENGAGEMENT_FIELD from '@salesforce/schema/Account.Engagement__c';
import PENETRATION_FIELD from '@salesforce/schema/Account.Penetration__c';
import SPREAD_FIELD from '@salesforce/schema/Account.Spread__c';
import RECENCY_FIELD from '@salesforce/schema/Account.Recency__c';
import HEALTHSCORE_FIELD from '@salesforce/schema/Account.HealthScore__c';
import SECURED_MONETARY_FIELD from '@salesforce/schema/Account.Monetary_Secured__c';
import UNSECURED_MONETARY_FIELD from '@salesforce/schema/Account.Monetary_Unsecured__c';

const ACCOUNT_FIELDS = [ID_FIELD,
    NAME_FIELD,
    ENGAGEMENT_FIELD,
    CONVERSION_FIELD,
    SECURED_MONETARY_FIELD, 
    UNSECURED_MONETARY_FIELD, 
    PENETRATION_FIELD, 
    SPREAD_FIELD,
    RECENCY_FIELD,
    HEALTHSCORE_FIELD,
    ATTACHMENT_FIELD
];

export default class partnerHealthscoreView extends LightningElement {
    @api recordId;
    
    @track partner = '';
    @track error = 'Error';
    @track errorCode = '';

    @wire(getRecord, {recordId: '$recordId', fields: ACCOUNT_FIELDS}) loadPartner({data, error}) {
        if (data) {
            this.partner = data;
            this.error = null;
        } else if (error) {
            this.error = error.body.message;
            this.errorCode = error.body.errorCode;
            this.partner = null;
        }
    }

    get partnerRadar() {
        if(this.partner) {
            return [this.partner.fields.Attachment__c.value,
                this.partner.fields.Conversion_Rate__c.value,
                this.partner.fields.Engagement__c.value,
                this.partner.fields.Monetary_Secured__c.value,
                this.partner.fields.Monetary_Unsecured__c.value,
                this.partner.fields.Penetration__c.value,
                this.partner.fields.Recency__c.value,
                this.partner.fields.Spread__c.value];
        }
        return [0,0,0,0,0,0,0,0];
    }

    get partnerHealthy() {
        if(this.partner) {
            return (this.partner.fields.HealthScore__c.value >= 70);
        }
        return false;
    }

    get partnerWeak() {
        if(this.partner) {
            return (this.partner.fields.HealthScore__c.value < 60);
        }
        return false;
    }

    get partner() {
        return this.partner;
    }

    get partnerName() {
        if(this.partner) {
            return this.partner.fields.Name.value;
        }
        return this.errorCode;
    }

    get partnerAttachment() {
        if(this.partner) {
            return this.partner.fields.Attachment__c.value;
        }
        return this.error;
    }

    get partnerHealthscore() {
        if(this.partner) {
            return this.partner.fields.HealthScore__c.value / 100;
        }
        return this.error;
    }

    get partnerEngagement() {
        if(this.partner) {
            return this.partner.fields.Engagement__c.value;
        }
        return this.error;
    }

    get partnerConversionRate() {
        if(this.partner) {
            return this.partner.fields.Conversion_Rate__c.value;
        }
        return this.error;
    }

    get partnerPenetration() {
        if(this.partner) {
            return this.partner.fields.Penetration__c.value;
        }
        return this.error;
    }

    get partnerRecency() {
        if(this.partner) {
            return this.partner.fields.Recency__c.value;
        }
        return this.error;
    }

    get partnerSpread() {
        if(this.partner) {
            return this.partner.fields.Spread__c.value;
        }
        return this.error;
    }

    get partnerSecuredMonetary() {
        if(this.partner) {
            return this.partner.fields.Monetary_Secured__c.value;
        }
        return this.error;
    }

    get partnerUnsecuredMonetary() {
        if(this.partner) {
            return this.partner.fields.Monetary_Unsecured__c.value;
        }
        return this.error;
    }
}