import { LightningElement, wire, track, api } from 'lwc';
import getAccounts from '@salesforce/apex/BDTargetProspectsDataService.getAccounts';
import getOwners from '@salesforce/apex/BDTargetProspectsDataService.getOwners';
import createOpps from '@salesforce/apex/BDTargetProspectsDataService.createOpportunities';
import { refreshApex } from '@salesforce/apex';
import { MessageContext } from 'lightning/messageService';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import Country from '@salesforce/schema/Account.Country__c'
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class BDTargetProspectsAccountSelector extends LightningElement {
    @track accounts = [];
    @track accountsBU = [];
    @track viewSlice = [];
    @track selected = new Set();
    @track selectedSlice = [];
    @track selectedEventSlice = [];
    @track opportunities = undefined;
    @track dialogVisible = false;
    @track selectedOwner = undefined;
    @track nbStaffFilter = -1;
    @track zoneFilter = -1;
    @track nbPartnersFilter = -1;
    @track nbStaffFilterOption = 0;
    @track zoneFilterOption = 0;
    @track countryFilterOption = 'ANY';
    @track nbPartnersFilterOption = 0;
    @track closeDate = undefined;
    @track owners = [];
    @track countryFilterOptions = [];
    accountsWireResult;
    error = undefined;
    errorOwners = undefined;
    isLoading = false;
    @api sortDirection = 'asc';
    @api sortBy = 'Zone__c';

    @track page = 1;
    @track totalRecount = 0;
    @track totalPage = 0;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 50;
    @track pageChanged;
    @track initialLoad = true;

    @wire(MessageContext) messageContext;
    @wire(getObjectInfo, {objectApiName: ACCOUNT_OBJECT}) accountInfo;
    @wire(getPicklistValues, 
        {
            recordTypeId: '$accountInfo.data.defaultRecordTypeId',
            fieldApiName: Country
        }
    )wiredCountries({ error, data }) {
        if(data) {
            this.countryFilterOptions = [{label: 'Any', value: 'ANY'}].concat(data.values);
        }
        else if (error) {
            this.countryFilterOptions = [{label: 'Any', value: 'ANY'}];
        }
    }

    @track columns = [
        { label: 'Zone', fieldName: 'Zone__c', type: 'number', sortable: 'true' },
        { label: 'Account Name', fieldName: 'Name', type: 'text', sortable: 'true' },
        { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'text', sortable: 'true' },
        { label: 'Primary Contact Phone', fieldName: 'Primary_Contact_Phone__c', type: 'text', sortable: 'true' },
        { label: 'Account ID', fieldName: 'Id', type: 'text', sortable: 'true' },
        { label: 'Number of Staff', fieldName: 'Number_of_Staff__c', type: 'number', sortable: 'true' },
        { label: 'Number of Partners', fieldName: 'Number_of_partners__c', type: 'number', sortable: 'true' },
        { label: 'Country', fieldName: 'Country__c', type: 'text', sortable: 'true' }
    ];

    @track oppsColumns = [
        { label: 'Id', fieldName: 'Id', type: 'text' },
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Stage', fieldName: 'StageName', type: 'text' },
        { label: 'Owner', fieldName: 'OwnerId', type: 'text' },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
        { label: 'Lead Source', fieldName: 'LeadSource', type: 'text' },
        { label: 'Lead Source Detail', fieldName: 'Lead_Source_Detail__c', type: 'text' },
        { label: 'Record Type', fieldName: 'RecordTypeId', type: 'text' }
    ];

    @track options = [];
    @track filterOptions = [
        {label: 'Greater Than', value: '1'},
        {label: 'Equal', value: '0'},
        {label: 'Less Than', value: '-1'}
    ];

    @wire(getOwners)wiredOwners({ error, data}) {
        if(data) {
            this.owners = data;
            this.errorOwners = undefined;
            this.options = data.map(user => {
                return {label: user.Name, value: user.Id};
            });
            this.options.unshift({ label: 'BD Team Members', value: '' });
            this.selectedOwner = this.owners[0].Id;
        } else if (error) {
            this.errorOwners = error;
            this.owners = undefined;
        }
    }

    @wire(getAccounts, {sortBy: '$sortBy', sortDirection: '$sortDirection'})
    wiredAccounts(result) {
        this.accountsWireResult = result;
        const { error, data } = result;
        if(data) {
            this.accountsBU = data;
            this.accounts = this.accountsBU;
            this.calculateViewBounds();
            this.endingRecord = this.pageSize;

            this.error = undefined;
            this.isLoading = false;
            this.notifyLoading(this.isLoading);
        } else if (error) {
            this.error = error;
            this.accountsBU = undefined;
            this.accounts = undefined;
        }
    }

    calculateViewBounds() {
        this.totalRecount = this.accounts.length;
        this.totalPage = Math.ceil(this.totalRecount / this.pageSize);

        this.viewSlice = this.accounts.slice(0, this.pageSize);
        
    }

    get selectedRows() {
        
        let text = '';

        for(const row of this.selected) {
            text += row + ' ';
        }

        return text;
    }

    get selectedSliceRows() {
        let text = '';

        for(const row of this.selectedSlice) {
            text += row + ' ';
        }

        return text;
    }

    get usersCount() {
        return this.owners.length;
    }

    get optionsCount() {
        return this.options.length;
    }

    get displayPrevious() {
        return this.page === 1 ? true : false;
    }

    get displayNext() {
        return this.page === this.totalPage ? true : false;
    }

    get selectedCount() {
        return this.selectedSlice.length;
    }

    handleDatePicked(event) {
        this.closeDate = event.detail.value;
    }

    handleOwnerSelected(event) {
        this.selectedOwner = event.detail.value;
    }

    handleZoneFilterPicked(event) {
        this.zoneFilter = (event.detail.value != '') ? event.detail.value : -1;
        this.displayRecordPerPage(this.page);
    }

    handleNbPartnersFilterPicked(event) {
        this.nbPartnersFilter = (event.detail.value != '') ? event.detail.value : -1;
        this.displayRecordPerPage(this.page);
    }

    handleNbStaffFilterPicked(event) {
        this.nbStaffFilter = (event.detail.value != '') ? event.detail.value : -1;
        this.displayRecordPerPage(this.page);
    }

    handleZoneFilterOptionChanged(event) {
        this.zoneFilterOption = event.detail.value;
        this.displayRecordPerPage(this.page);
    }

    handleCountryFilterOptionChanged(event) {
        this.countryFilterOption = event.detail.value;
        this.displayRecordPerPage(this.page);
    }

    handleNbStaffFilterOptionChanged(event) {
        this.nbStaffFilterOption = event.detail.value;
        this.displayRecordPerPage(this.page);
    }

    handleNbPartnersFilterOptionChanged(event) {
        this.nbPartnersFilterOption = event.detail.value;
        this.displayRecordPerPage(this.page);
    }

    prevNavHandler() {
        if(this.page > 1) {
            this.page = this.page - 1;
            this.pageChanged = true;
            this.displayRecordPerPage(this.page);
        }
    }

    nextNavHandler() {
        if((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.pageChanged = true;
            this.displayRecordPerPage(this.page);
        }
    }

    displayRecordPerPage(page) {
        this.accounts = this.accountsBU;

        if(this.nbPartnersFilter >= 0) {
            switch(this.nbPartnersFilterOption) {
                case '-1':
                    this.accounts = this.accountsBU.filter(acc => acc.Number_of_partners__c < this.nbPartnersFilter);
                    break;
                case '0':
                    this.accounts = this.accountsBU.filter(acc => acc.Number_of_partners__c == this.nbPartnersFilter);
                    break;
                case '1':
                    this.accounts = this.accountsBU.filter(acc => acc.Number_of_partners__c > this.nbPartnersFilter);
                    break;
            }
        }
        if(this.nbStaffFilter >= 0) {
            switch(this.nbStaffFilterOption) {
                case '-1':
                    this.accounts = this.accounts.filter(acc => acc.Number_of_Staff__c < this.nbStaffFilter);
                    break;
                case '0':
                    this.accounts = this.accounts.filter(acc => acc.Number_of_Staff__c == this.nbStaffFilter);
                    break;
                case '1':
                    this.accounts = this.accounts.filter(acc => acc.Number_of_Staff__c > this.nbStaffFilter);
                    break;
            }
        }
        if(this.zoneFilter >= 0) {
            switch(this.zoneFilterOption) {
                case '-1':
                    this.accounts = this.accounts.filter(acc => acc.Zone__c < this.zoneFilter);
                    break;
                case '0':
                    this.accounts = this.accounts.filter(acc => acc.Zone__c == this.zoneFilter);
                    break;
                case '1':
                    this.accounts = this.accounts.filter(acc => acc.Zone__c > this.zoneFilter);
                    break;
            }
        }
        if(this.countryFilterOption != 'ANY') {
            this.accounts = this.accounts.filter(acc => acc.Country__c == this.countryFilterOption);
        }

        this.calculateViewBounds();

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecount) ? this.totalRecount : this.endingRecord;

        this.viewSlice = this.accounts.slice(this.startingRecord, this.endingRecord);
        let selectedSliceView = [];
        let selectedArray = Array.from(this.selected);
        for(const acc of this.viewSlice) {
            if(selectedArray.includes(acc.Id)) {
                selectedSliceView.push(acc.Id);
            }
        }
        this.selectedSlice = selectedSliceView;

        this.startingRecord = this.startingRecord + 1;
    }

    rowSelection(event) {
        if(!this.pageChanged || this.initialLoad) {
            const selectedSliceRows = event.detail.selectedRows;
            let curSelection = [];
            let allSelectedRows = [...this.selected];

            selectedSliceRows.forEach(item => curSelection.push(item.Id));

            let removedRows = [];
            this.selectedSlice.forEach(function(item) {
                if(!selectedSliceRows.includes(item)) {
                    removedRows.push(item);
                }
            });

            this.selectedSlice = curSelection;

            curSelection.forEach(item => allSelectedRows.push(item));
            this.selected = new Set(allSelectedRows);
            this.removeRows(removedRows);
            this.initialLoad = false;
        }
        else {
            this.pageChanged = false;
        }
    }

    removeRows(rowsToRemove) {
        let selectedArray = Array.from(this.selected);
        for(const row of rowsToRemove) {
            selectedArray = selectedArray.filter(function(el) {
                return el !== row;
            });
        }
        this.selected = new Set(selectedArray);
    }

    handleModal(event) {
        if(event.detail !== 1) {
            if(event.detail.status === 'confirm') {
                createOpps({accountIds: this.selectedSlice, ownerId: this.selectedOwner, closeDate: this.closeDate})
                    .then((result) => {
                        this.opportunities = result;
                        this.error = undefined;
                        return this.refreshAccounts();
                    })
                    .catch((error) => {
                        this.opportunities = undefined;
                        this.error = error;
                    });
            }
        }

        this.dialogVisible = false;
    }

    get showCreateOpportunities() {
        return (this.closeDate && this.selectedOwner && (this.selectedSlice.length > 0)) ? false : true;
    }

    get confirmationMessage() {
        return "Do you wish to proceed with the creation of " + this.selectedSlice.length + " opportunities?"; 
    }

    createOpportunities() {
        this.dialogVisible = true;
    }

    sortColumns(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        return this.refreshAccounts();
    }

    @api
    async refresh() {
        this.isLoading=true;
        this.notifyLoading(this.isLoading);
        await refreshApex(this.viewSlice);
        this.isLoading = false;
        this.notifyLoading(this.isLoading);
    }

    @api
    async refreshAccounts() {
        this.isLoading=true;
        this.notifyLoading(this.isLoading);
        await refreshApex(this.accountsWireResult);
        this.displayRecordPerPage(this.page);
        this.isLoading = false;
        this.notifyLoading(this.isLoading);
    }

    notifyLoading(isLoading) {
        if(isLoading) {
            this.dispatchEvent(new CustomEvent('loading'));
        } else {
            this.dispatchEvent(new CustomEvent('loadingDone'));
        }
    }
}