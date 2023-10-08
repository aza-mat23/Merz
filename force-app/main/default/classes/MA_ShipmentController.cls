public with sharing class MA_ShipmentController {
    // public MA_ShipmentController() {}

    @AuraEnabled
    public static List<Shipment> retrieveShipments() {
        List<Shipment> result = new List<Shipment>();
        try {
            List<MA_Shipment__c> shipments = MA_ShipmentService.retrieveData();
            for (MA_Shipment__c shipment : shipments) {
                Shipment item = new MA_ShipmentController.Shipment(
                    shipment.Id,
                    shipment.Name,
                    shipment.Status__c,
                    shipment.CreatedDate.format(),
                    shipment.Tracking_Number__c
                );
                result.add(item);
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // variation for syncronous call to update shipment status
    @AuraEnabled
    public static string updateShipmentsStatus(List<String> input) {
        try {
            List<MA_Shipment__c> shipments = MA_ShipmentService.retrieveData(input);
            if (!shipments.isEmpty()) {
                MA_ShipmentService.upudateStatuses(shipments);
                return 'Update shipment status is completed';
            } else {
                return 'No shipment to update';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // variation for asyncronous call to update shipment status
    @AuraEnabled
    public static string updateShipmentsStatusQueueable() {
        try {
            List<MA_Shipment__c> shipments = MA_ShipmentService.retrieveData();
            if (!shipments.isEmpty()) {
                MA_ShipmentStatusQueueable queueableJob = new MA_ShipmentStatusQueueable(shipments);
                System.enqueueJob(queueableJob);
                return 'Update shipment status (Asynchronously) successfully run';
            } else {
                return 'No shipment to update';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateShipmentsStatusSchedule() {
        try {
            List<MA_Shipment__c> shipments = MA_ShipmentService.retrieveData();
            if (!shipments.isEmpty()) {
                return 'Update shipment status (Schedulable) successfully run';
            } else {
                return 'No shipment to update';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Shipment {
        @AuraEnabled
        public String shipmentId { get; set; }
        @AuraEnabled
        public String shipmentName { get; set; }
        @AuraEnabled
        public String shipmentStatus { get; set; }
        @AuraEnabled
        public String shipmentDate { get; set; }
        @AuraEnabled
        public String trackingNumber { get; set; }
        public Shipment(String shipmentId, String shipmentName, String shipmentStatus, String shipmentDate, String trackingNumber) {
            this.shipmentId = shipmentId;
            this.shipmentName = shipmentName;
            this.shipmentStatus = shipmentStatus;
            this.shipmentDate = shipmentDate;
            this.trackingNumber = trackingNumber;
        }
    }
}