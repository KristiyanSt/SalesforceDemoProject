import { LightningElement } from 'lwc';
import getContacts from "@salesforce/apex/ContactManager.getContacts";

export default class ContactTable extends LightningElement {
    contacts;
    columns = [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Phone',
            fieldName: 'Phone',
            type: 'number'
        },
        {
            label: 'Email',
            fieldName: 'Email',
            type: 'email'
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date'
        },
        {
            label: 'Account',
            fieldName: 'AccountName',
            type: 'text'
        },
        {
            label: 'Is special',
            fieldName: 'IsSpecial',
            type: 'text'
        },

    ]
    sortParams = {
        sortBy: null,
        sortDirection: null
    }
    filterParams = {
        isSpecial: null,
        Name: null,
        Phone: null,
        Email: null,
        AccountName: null
    }
    isSpecialFilter = null;
    isSpecialOptions = [{
        label: "Is special",
        value: "isSpecial"
    }];
    filterValues = [];
    sortOptions = [
        {
            label: "Name",
            value: "Name"
        },
        {
            label: "Phone",
            value: "Phone"
        },
        {
            label: "Email",
            value: "Email"
        },
        {
            label: "Account name",
            value: "Account.Name"
        }
    ];
    sortDirectionOptions = [
        {
            label: "Ascending",
            value: "ASC"
        },
        {
            label: "Descending",
            value: "DESC"
        }
    ]
    async handleSortChange(event) {
        const selectedOption = event.detail.value;

        if(this.sortOptions.some(option => option.value === selectedOption)) {
            this.sortParams.sortBy = selectedOption;
        }

        if(this.sortDirectionOptions.some(option => option.value === selectedOption)) {
            this.sortParams.sortDirection = selectedOption;
        }
        await this.fetchContacts();
    }
    async handleFilterChange(event) {
        const fieldName = event.target.fieldName;
        const value = event.target.value;

        if(this.filterParams.hasOwnProperty(fieldName)){

            if(typeof value !== 'string'){
                this.filterParams.isSpecial = value.includes("isSpecial") ? true : null;
            }else {
                this.filterParams[fieldName] = value;
            }
        }
        await this.fetchContacts();
    }

    async fetchContacts() {
        try {
            const params = JSON.stringify({...this.sortParams, ...this.filterParams });
            const contactsJsonRes = await getContacts({queryString: params});
            this.contacts = JSON.parse(contactsJsonRes);
        } catch (error) {
            console.log(error);
        }
    }

    async connectedCallback() {
        await this.fetchContacts();
    }
}