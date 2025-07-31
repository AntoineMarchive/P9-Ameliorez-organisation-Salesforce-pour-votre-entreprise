@isTest
private class testUpdateAllAccounts {
    @isTest static void test() {
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte', Family = 'Chemise');
        insert pd1;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Order ord = new Order(
            AccountId = acc1.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 100
        );
        insert oi;

        // Mise à jour du statut pour déclencher l’update du CA
        ord.Status = 'Activated';
        update ord;

        // Requête pour vérifier la mise à jour du CA
        Account updated = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc1.Id];
        System.assertEquals(200, updated.Chiffre_d_affaire__c);
    }
}
