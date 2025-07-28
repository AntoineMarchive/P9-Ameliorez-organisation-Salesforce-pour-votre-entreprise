trigger UpdateAccountCA on Order (after update) {
    Set<Id> accountIds = new Set<Id>();

    // 1. Récupère tous les AccountId concernés
    for (Order ord : Trigger.new) {
        if (ord.AccountId != null) {
            accountIds.add(ord.AccountId);
        }
    }

    if (!accountIds.isEmpty()) {
        // 2. Calcule le CA total pour chaque compte
        Map<Id, Decimal> accountIdToTotal = new Map<Id, Decimal>();

        AggregateResult[] results = [
            SELECT AccountId, SUM(NetAmount__c) total
            FROM Order
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ];

        for (AggregateResult ar : results) {
            accountIdToTotal.put((Id) ar.get('AccountId'), (Decimal) ar.get('total'));
        }

        // 3. Met à jour les comptes
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Account acc = new Account(
                Id = accId,
                Chiffre_d_affaire__c = accountIdToTotal.containsKey(accId) ? accountIdToTotal.get(accId) : 0
            );
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
