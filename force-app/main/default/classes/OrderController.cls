public with sharing class OrderController {

    /**
     * Retourne la somme des montants des commandes ACTIVÉES pour un compte donné.
     * @param accountId l'Id du compte en cours
     * @return Total des commandes avec le statut 'Activated'
     */
    @AuraEnabled(cacheable=true)
    public static Decimal getActivatedOrdersSumByAccount(Id accountId) {
        if (accountId == null) return 0;

        AggregateResult result = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId AND Status = 'Activated'
        ];

        return (Decimal) result.get('total');
    }
}


// en replacement de MyTeamOrdersController.cls
