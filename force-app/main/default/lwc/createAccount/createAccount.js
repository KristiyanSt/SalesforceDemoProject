import { LightningElement } from 'lwc';
import createAccount from '@salesforce/apex/AccountManager.createAccount';

export default class CreateAccountComponent extends LightningElement {
    account = {};
    handleChange(event) {
        const fieldName = event.target.fieldName;
        const value = event.target.value;
        this.account[fieldName] = value;
    }
    async handleSubmit() {
        try {
            const response = await createAccount({accountObj: JSON.stringify(this.account)});
            const createdAccount = JSON.parse(response);
            this.dispatchEvent(new CustomEvent('add',{detail: createdAccount}));
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }
    handleHideForm() {
        this.dispatchEvent(new CustomEvent('hideform'));
    }
}