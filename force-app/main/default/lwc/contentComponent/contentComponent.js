import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountManager.getAccounts';
import deleteAccountById from '@salesforce/apex/AccountManager.deleteAccountById';

export default class ContentComponent extends LightningElement {
    accounts = null;
    @track isLoading = false;
    isCollectionEmpty = false;
    isFormShown = false;

    columns = [
        {
            label: "Name",
            fieldName: "Name",
        },
        {
            label: "Phone",
            fieldName: "Phone",
            type: "phone"
        },
        {
            label: "Created date",
            fieldName: "CreatedDate",
            type: "date"
        },
        {
            type: 'action',
            typeAttributes: { 
                rowActions: [ { label: 'Delete', name: 'delete'  } ] 
            }
        },
    ];
    
    handleShowForm() {
        this.isFormShown = true;
    }

    handleHideForm() {
        this.isFormShown = false;
    }

    async handleDelete(event) {
        const {Id} = event.detail.row;
        try {
            await deleteAccountById({Id});
            this.accounts = this.accounts.filter((acc) => acc.Id !== Id );
        } catch (error) {
            console.log(JSON.stringify(error))
        }
    }

    addAccount(event){
        if(this.accounts){
            this.accounts.push(event.detail);
            this.handleHideForm();
        }else{
            this.accounts = [account];
        }
    }

    async connectedCallback() {
        try {
            this.isLoading = true;
            const accountsResponse = JSON.parse(await getAccounts());
            this.accounts = accountsResponse.map(acc => {
                acc.CreatedDate = acc.CreatedDate.slice(0,10);
                return acc;
            });
            this.isCollectionEmpty = this.accounts.length === 0;
        }  catch (error) {
            console.log(JSON.stringify(error));
        } finally {
            this.isLoading = false;
        }
    }
}