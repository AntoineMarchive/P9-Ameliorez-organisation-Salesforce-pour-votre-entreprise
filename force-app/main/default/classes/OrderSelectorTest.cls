@isTest
private class OrderSelectorTest {

    @isTest
    static void test_getSumActivatedOrderByAccountIds() {
        // 1. Créer deux comptes
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');
        insert new List<Account>{ acc1, acc2 };

        // 2. Créer un produit et pricebook
        Product2 prod = new Product2(Name = 'Produit Test', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 150,
            IsActive = true
        );
        insert pbe;

        // 3. Créer deux commandes activées
        Order ord1 = new Order(
            AccountId = acc1.Id,
            Status = 'Activated',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        Order ord2 = new Order(
            AccountId = acc2.Id,
            Status = 'Activated',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert new List<Order>{ ord1, ord2 };

        // 4. Ajouter des OrderItems
        insert new List<OrderItem>{
            new OrderItem(OrderId = ord1.Id, Quantity = 1, UnitPrice = 150, PricebookEntryId = pbe.Id),
            new OrderItem(OrderId = ord2.Id, Quantity = 2, UnitPrice = 150, PricebookEntryId = pbe.Id)
        };

        // 5. Appel de la méthode à tester
        Set<Id> accountIds = new Set<Id>{ acc1.Id, acc2.Id };

        Test.startTest();
        List<AggregateResult> results = OrderSelector.getSumActivatedOrderByAccountIds(accountIds);
        Test.stopTest();

        // 6. Vérification des résultats
        System.assertEquals(2, results.size(), 'Deux comptes doivent être retournés');
        
        Map<Id, Decimal> resultMap = new Map<Id, Decimal>();
        for (AggregateResult ar : results) {
            resultMap.put((Id) ar.get('AccountId'), (Decimal) ar.get('total'));
        }

        System.assertEquals(150, resultMap.get(acc1.Id));
        System.assertEquals(300, resultMap.get(acc2.Id));
    }
}
