@isTest
private class OrderTriggerControllerTest {

    @isTest
    static void test_CalculateTotalWithShipment() {
        // Créer un compte
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Créer une commande avec TotalAmount et ShipmentCost__c
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            ShipmentCost__c = 50
        );
        insert ord;

        // Modifier un champ pour forcer le BEFORE UPDATE
        ord.Status = 'Draft'; // déclenche le trigger sans changer de statut
        update ord;

        // Vérifier que NetAmount__c a bien été calculé
        Order updated = [SELECT NetAmount__c FROM Order WHERE Id = :ord.Id];
        System.assertEquals(250, updated.NetAmount__c);
    }

    @isTest
    static void test_UpdateAccountCA_whenStatusBecomesActivated() {
        // Créer un compte
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;

        // Créer un produit et pricebook
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 200,
            IsActive = true
        );
        insert pbe;

        // Créer une commande avec statut initial Draft
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            ShipmentCost__c = 20
        );
        insert ord;

        // Ajouter un OrderItem
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            UnitPrice = 200,
            PricebookEntryId = pbe.Id
        );
        insert oi;

        // Mettre à jour la commande avec statut 'Activated' pour déclencher le AFTER
        ord.Status = 'Activated';
        update ord;

        // Vérifier que le CA a bien été mis à jour sur le compte
        Account updatedAcc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(180, updatedAcc.Chiffre_d_affaire__c); // 200 - 20
    }
}
