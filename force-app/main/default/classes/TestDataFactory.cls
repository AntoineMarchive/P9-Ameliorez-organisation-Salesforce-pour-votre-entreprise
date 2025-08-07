@isTest
public class TestDataFactory {

    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    public static List<Product2> createProducts() {
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Produit A', IsActive = true),
            new Product2(Name = 'Produit B', IsActive = true),
            new Product2(Name = 'Produit C', IsActive = true)
        };
        insert products;
        return products;
    }

    public static List<PricebookEntry> createPricebookEntries(List<Product2> products) {
        Id standardPricebookId = Test.getStandardPricebookId();

        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for (Product2 prod : products) {
            pbes.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100,
                IsActive = true
            ));
        }

        insert pbes;
        return pbes;
    }

    public static Order createOrder(Id accountId, Id pricebookId, String status) {
        Order ord = new Order(
            AccountId = accountId,
            EffectiveDate = Date.today(),
            Status = status,
            Pricebook2Id = pricebookId
        );
        insert ord;
        return ord;
    }

    public static List<Order> createMultipleOrders(Integer nb, Id accountId, Id pricebookId, String status) {
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < nb; i++) {
            orders.add(new Order(
                AccountId = accountId,
                EffectiveDate = Date.today(),
                Status = status,
                Pricebook2Id = pricebookId
            ));
        }
        insert orders;
        return orders;
    }

    public static List<OrderItem> createOrderItems(Order order, List<PricebookEntry> pbes) {
        List<OrderItem> items = new List<OrderItem>();

        for (PricebookEntry pbe : pbes) {
            items.add(new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = pbe.UnitPrice
            ));
        }

        insert items;
        return items;
    }

    public static List<OrderItem> createOrderItemsForOrders(List<Order> orders, List<PricebookEntry> pbes) {
        List<OrderItem> allItems = new List<OrderItem>();

        for (Order order : orders) {
            for (PricebookEntry pbe : pbes) {
                allItems.add(new OrderItem(
                    OrderId = order.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                ));
            }
        }

        insert allItems;
        return allItems;
    }
}
