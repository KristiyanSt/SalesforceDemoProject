import { LightningElement } from 'lwc';

export default class Contacts extends LightningElement {
    isTableShown = true;

    toggleTableShow() {
        this.isTableShown = !this.isTableShown;
    }
}