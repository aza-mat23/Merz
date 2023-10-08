global class MA_ShipmentStatusBatchable implements Database.Batchable<sObject>, Schedulable {
    // Database.Stateful, Database.AllowsCallouts,
    // global MA_ShipmentStatusBatchable() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Tracking_Number__c, Status__c FROM MA_Shipment__c WITH SECURITY_ENFORCED]);
        // best to keep SOQL query with filtration criteria in the start method]
        // e.g. ... WHERE Status__c = 'Pending' ...
    }

    global void execute(Database.BatchableContext BC, List<MA_Shipment__c> scope) {
        MA_ShipmentService.upudateStatuses(scope);
    }

    // Finish method: Perform post-processing or cleanup
    global void finish(Database.BatchableContext BC) {
        // Perform any post-processing or cleanup if needed.
    }

    // Schedulable Interface Method: Define how to schedule the batch job
    global void execute(SchedulableContext SC) {
        MA_ShipmentStatusBatchable batchJob = new MA_ShipmentStatusBatchable();
        Database.executeBatch(batchJob);
    }
}