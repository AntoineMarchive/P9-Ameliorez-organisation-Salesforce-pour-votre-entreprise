@isTest
private class OrderControllerTest {
    
    @isTest
    static void test_getActivatedOrdersSumByAccount() {
        // 1. Créer un compte
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // 2. Créer un produit et pricebook
        Product2 p = new Product2(Name = 'Test Product', IsActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = p.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // 3. Créer une commande avec statut 'Activated'
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Activated',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id
        );
        insert oi;

        // 4. Appeler la méthode à tester
        Test.startTest();
        Decimal total = OrderController.getActivatedOrdersSumByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(100, total, 'La somme des commandes activées devrait être 100');
    }

    @isTest
    static void test_getActivatedOrdersSumByAccount_nullId() {
        Test.startTest();
        Decimal total = OrderController.getActivatedOrdersSumByAccount(null);
        Test.stopTest();

        System.assertEquals(0, total, 'Si l\'ID est null, on attend 0');
    }
}
