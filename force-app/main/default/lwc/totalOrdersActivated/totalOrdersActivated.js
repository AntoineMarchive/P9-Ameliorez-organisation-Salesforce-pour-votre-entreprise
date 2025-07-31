import { LightningElement, api, wire } from 'lwc';
import getActivatedOrdersSumByAccount from '@salesforce/apex/OrderController.getActivatedOrdersSumByAccount';

export default class TotalOrdersActivated extends LightningElement {
    accountCA;
    message;
    noOrders;
    error;
    @api recordId;

    @wire(getActivatedOrdersSumByAccount, { accountId: '$recordId' })
    wiredTotal({ error, data }) {
        //si getAccountCA retourne un montant positif, le montant total des Orders du compte est affiché
        if (data > 0) {
            this.accountCA = data;
            this.message = 'Total of Orders is : ' + data;
            this.noOrders = undefined;
            this.error = undefined;
        //S'il est <= 0 ou undefined, un message informe l'utilisateur
        } else if ((data === undefined && !error) || data <= 0) {
            this.noOrders = 'No orders related to this account or the amount is less than zero';
            this.message = undefined;
            this.error = undefined;
        //En cas d'erreur Apex, un message informe l'utilisateur
        } else if(error) {
            this.error = 'An error occured while loading the total amount of orders';
            this.message = undefined;
            this.noOrders = undefined;
        }
    }
}
