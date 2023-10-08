public with sharing class MA_ShipmentService {
    // public MA_ShipmentService() {}

    // we have two options for retrieving data
    // so we overload the method
    public static List<MA_Shipment__c> retrieveData() {
        return [
            SELECT Id, Name, Status__c, CreatedDate, Tracking_Number__c
            FROM MA_Shipment__c
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<MA_Shipment__c> retrieveData(List<String> input) {
        List<Id> qwhere = new List<Id>();
        for (String variable : input) {
            qwhere.add((Id)variable);
        }
        return [
            SELECT Id, Name, Status__c, CreatedDate, Tracking_Number__c
            FROM MA_Shipment__c WHERE Id IN :qwhere
            WITH SECURITY_ENFORCED
        ];
    }

    public static String upudateStatuses(List<MA_Shipment__c> scope) {
        List<MA_Shipment__c> shipments = new List<MA_Shipment__c>();
        String base = 'https://merzcommunities--mel.sandbox.my.salesforce-sites.com';
        String resource = '/services/apexrest/';
        String endpoint = 'mockShipmentStatus';
        for (MA_Shipment__c shpment : scope) {
            System.debug('::::::::::::::::::: MA_ShipmentService > upudateStatuses (payload) ' + shpment.Tracking_Number__c);
            RestClient restClient = new RestClient(base, resource);
            Map<String, String> payload = new Map<String, String>();
            payload.put('trackingNumber', shpment.Tracking_Number__c);
            HttpResponse response = restClient.doGet(endpoint, payload);
            String result = restClient.parseResponse(response);
            shpment.Status__c = result;
            shipments.add(shpment);
            System.debug('::::::::::::::::::: MA_ShipmentService > upudateStatuses (result) ' + result);
        }
        if (!shipments.isEmpty()) {
            update shipments;
            return 'Successfully updated shipment statuses.';
        } else {
            return 'No shipments to update.';
        }
    }
}