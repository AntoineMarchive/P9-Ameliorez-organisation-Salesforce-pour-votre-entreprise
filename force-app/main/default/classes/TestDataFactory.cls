@isTest
public class TestDataFactory {

    public static Id createProductAndPricebookEntry() {
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        return pbe.Id;
    }

    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    public static Order createOrder(Id accountId, Id pricebookId, String status, Decimal totalAmount, Decimal shipmentCost) {
        Order ord = new Order(
            AccountId = accountId,
            Status = status,
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId,
            TotalAmount = totalAmount,
            ShipmentCost__c = shipmentCost
        );
        insert ord;
        return ord;
    }

    public static OrderItem createOrderItem(Id orderId, Id pbeId, Integer quantity, Decimal unitPrice) {
        OrderItem item = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pbeId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
        insert item;
        return item;
    }

    public static Map<String, Object> createCompleteOrderData(Boolean activatedStatus) {
        Account acc = createAccount('Account - ' + (activatedStatus ? 'Active' : 'Draft'));
        Id pbeId = createProductAndPricebookEntry();
        String status = activatedStatus ? 'Activated' : 'Draft';
        Order ord = createOrder(acc.Id, Test.getStandardPricebookId(), status, 200, 20);
        OrderItem item = createOrderItem(ord.Id, pbeId, 1, 200);

        return new Map<String, Object>{
            'Account' => acc,
            'Order' => ord,
            'OrderItem' => item
        };
    }
}
