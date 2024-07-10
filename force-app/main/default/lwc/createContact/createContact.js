import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/AccountManager.getAccounts';
import createContact from '@salesforce/apex/ContactManager.createContact';

export default class CreateContact extends LightningElement {
    @track contact = {
        FirstName: "",
        LastName: "",
        Email: "",
        Phone: "",
        AccountId: ""
    };
    accountOptions;

    handleChange(event) {
        const value = event.target.value;
        const field = event.target.fieldName;

        if(this.contact.hasOwnProperty(field)){
            this.contact[field] = value;
        }
    }
    async handleCreateContact() {
        try {
            const contactJsonRes = await createContact({contactJSON: JSON.stringify(this.contact)});
            const createdContact = JSON.parse(contactJsonRes);
            this.dispatchEvent(new ShowToastEvent({
                label: "Success",
                message: `Successfully created contact ${createdContact.FirstName}`,
                variant: "success"
            }));
        } catch (error) {
            console.log(JSON.stringify(error));
            this.dispatchEvent(new ShowToastEvent({
                label: "Error",
                message: "There was an error while creating contact",
                variant: "error"
            }));
        }
    }
    async connectedCallback() {
        try {
            const accounts = JSON.parse(await getAccounts());
            this.accountOptions = accounts.map(acc => ({label: acc.Name, value: acc.Id}));
        }  catch (error) {
            console.log(JSON.stringify(error));
        }
    }
}