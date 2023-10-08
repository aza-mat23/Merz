public class MA_ShipmentStatusQueueable implements Queueable, Database.AllowsCallouts {
    private List<MA_Shipment__c> shipmentsToUpdate = new List<MA_Shipment__c>();

    // Constructor to accept a list of MA_Shipment__c records
    public MA_ShipmentStatusQueueable(List<MA_Shipment__c> shipments) {
        this.shipmentsToUpdate = shipments;
    }

    // Implement the execute method for Queueable logic
    public void execute(QueueableContext context) {
        if (!shipmentsToUpdate.isEmpty()) {
            MA_ShipmentService.upudateStatuses(this.shipmentsToUpdate);
        }
    }
}