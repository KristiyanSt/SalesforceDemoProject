import { LightningElement } from 'lwc';
import getContacts from "@salesforce/apex/ContactManager.getContacts";

export default class ContactTable extends LightningElement {
    contacts;
    columns = [
    { 
        label: 'Name',
        fieldName: 'Name',
        sortable: true,
    },
    {
        label: 'Phone',
        fieldName: 'Phone',
        type: 'number',
        sortable: true,
    },
    { 
      label: 'Email',
      fieldName: 'Email',
      type: 'email',
      sortable: true
    },
    {
      label: 'Created Date',
      fieldName: 'CreatedDate',
      type: 'date'
    },
    { 
      label: 'Account',
      fieldName: 'AccountName',
      type: 'text',
      sortable: true
    },
    { 
      label: 'Is special',
      fieldName: 'IsSpecial',
      type: 'text' 
    },
    
    ]
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    isSpecialFilter = false;
    filterOptions = [{
        label: "Is special",
        value: "isSpecial"
    }];
    filterValue = [];
    
    
    async fetchContacts() {
        try {
            const contactsJsonRes = await getContacts({isSpecialFilter: this.isSpecialFilter});
            this.contacts = JSON.parse(contactsJsonRes);
        } catch (error) {
            console.log(error);
        }
    }
    async onHandleFilter(event) {
        this.isSpecialFilter = event.detail.value.includes("isSpecial") ? true : false;
        await this.fetchContacts();
    }
    sortBy(field, reverse, primer) {
        const key = primer
        ? function (x) {
            return primer(x[field]);
        }
        : function (x) {
            return x[field];
              };
              
              return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.contacts];
        
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contacts = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    async connectedCallback(){
        await this.fetchContacts();
    }
}