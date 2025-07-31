import { createElement } from 'lwc';
import Orders from 'c/orders';
import getTotalOrdersForAccount from '@salesforce/apex/OrderController.getTotalOrdersForAccount';

jest.mock('@salesforce/apex/OrderController.getTotalOrdersForAccount', () => {
    return {
        default: jest.fn()
    };
}, { virtual: true });

describe('c-orders', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('affiche le total des commandes si la somme est positive', async () => {
        getTotalOrdersForAccount.mockResolvedValue(350.0);

        const element = createElement('c-orders', {
            is: Orders
        });
        element.recordId = '001xx000003DGXoAAO';
        document.body.appendChild(element);

        await Promise.resolve();

        const successBox = element.shadowRoot.querySelector('.slds-theme_success');
        expect(successBox).not.toBeNull();
        expect(successBox.textContent).toContain('Total des Commandes : 350');
    });

    it('affiche un message d’erreur si aucune commande', async () => {
        getTotalOrdersForAccount.mockResolvedValue(0);

        const element = createElement('c-orders', {
            is: Orders
        });
        element.recordId = '001xx000003DGXoAAO';
        document.body.appendChild(element);

        await Promise.resolve();

        const errorBox = element.shadowRoot.querySelector('.slds-theme_error');
        expect(errorBox).not.toBeNull();
        expect(errorBox.textContent).toContain('pas de commandes rattachées');
    });

    it('affiche un message d’erreur en cas de rejet Apex', async () => {
        getTotalOrdersForAccount.mockRejectedValue(new Error('Erreur serveur'));

        const element = createElement('c-orders', {
            is: Orders
        });
        element.recordId = '001xx000003DGXoAAO';
        document.body.appendChild(element);

        await Promise.resolve();

        const errorBox = element.shadowRoot.querySelector('.slds-theme_error');
        expect(errorBox).not.toBeNull();
        expect(errorBox.textContent).toContain('Erreur serveur');
    });
});
