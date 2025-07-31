trigger OrderTrigger on Order (before update, after update) {
	if(trigger.isBefore && trigger.isUpdate) {
		OrderTriggerController.CalculateTotalWithShipment(Trigger.new);
	}
	if(trigger.isAfter && trigger.isUpdate) {
		OrderTriggerController.UpdateAccountCA(Trigger.new, Trigger.oldMap);
	}
}