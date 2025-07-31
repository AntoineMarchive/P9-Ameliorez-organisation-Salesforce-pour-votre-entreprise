global class UpdateAllAccounts implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account
            WHERE Id IN (
                SELECT AccountId FROM Order WHERE Status = 'Activated'
            )
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Map<Id, SObject>(scope).keySet();

        List<AggregateResult> results = OrderSelector.getSumActivatedOrderByAccountIds(accountIds);

        Map<Id, Decimal> totalsByAccountId = new Map<Id, Decimal>();
        for (AggregateResult ar : results) {
            totalsByAccountId.put((Id) ar.get('AccountId'), (Decimal) ar.get('total'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Decimal newCA = totalsByAccountId.get(accId);
            accountsToUpdate.add(new Account(
                Id = accId,
                Chiffre_d_affaire__c = newCA != null ? newCA : 0
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Logique optionnelle à la fin du batch
        System.debug('UpdateAllAccounts terminé.');
    }
}
