public with sharing class OrderTriggerController {

    /**
     * Calcule le montant NetAmount__c pour chaque commande en fonction de :
     * TotalAmount - ShipmentCost__c
     * Appelé lors du trigger BEFORE UPDATE
     */
    public static void CalculateTotalWithShipment(List<Order> orders) {
        if (orders == null || orders.isEmpty()) return;

        for (Order ord : orders) {
            // Vérifie que les champs nécessaires sont renseignés
            if (ord.TotalAmount != null && ord.ShipmentCost__c != null) {
                ord.NetAmount__c = ord.TotalAmount - ord.ShipmentCost__c;
            } else {
                // Valeur par défaut si les champs sont incomplets
                ord.NetAmount__c = 0;
            }
        }
    }


    /**
     * Met à jour le champ personnalisé Chiffre_d_affaire__c sur les comptes,
     * en recalculant la somme des NetAmount__c des commandes ACTIVÉES
     * Appelé lors du trigger AFTER UPDATE
     */
    public static void UpdateAccountCA(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        if (newOrders == null || newOrders.isEmpty()) return;

        Set<Id> accountIdsToUpdate = new Set<Id>();

        for (Order ord : newOrders) {
            Order oldOrd = oldOrderMap != null ? oldOrderMap.get(ord.Id) : null;

            // Détecter les commandes dont le statut est passé à "Activated"
            Boolean isNowActivated = ord.Status == 'Activated';
            Boolean wasAlreadyActivated = oldOrd != null && oldOrd.Status == 'Activated';

            if (isNowActivated && !wasAlreadyActivated && ord.AccountId != null) {
                accountIdsToUpdate.add(ord.AccountId);
            }
        }

        if (accountIdsToUpdate.isEmpty()) return;

        // Récupérer la somme des NetAmount__c pour les comptes concernés
        Map<Id, Decimal> accountIdToTotal = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId, SUM(NetAmount__c) total
            FROM Order
            WHERE Status = 'Activated' AND AccountId IN :accountIdsToUpdate
            GROUP BY AccountId
        ]) {
            accountIdToTotal.put((Id) ar.get('AccountId'), (Decimal) ar.get('total'));
        }

        // Préparer la mise à jour des comptes
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIdsToUpdate) {
            Decimal newTotal = accountIdToTotal.containsKey(accId) ? accountIdToTotal.get(accId) : 0;
            accountsToUpdate.add(new Account(
                Id = accId,
                Chiffre_d_affaire__c = newTotal
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
