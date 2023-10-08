import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import retrieveShipments from "@salesforce/apex/MA_ShipmentController.retrieveShipments";
import updateShipmentsStatus from "@salesforce/apex/MA_ShipmentController.updateShipmentsStatus";
import updateShipmentsStatusQueueable from "@salesforce/apex/MA_ShipmentController.updateShipmentsStatusQueueable";

const columns = [
    // { label: "shipmentId", fieldName: "shipmentId" },
    { label: "Name", fieldName: "shipmentName" },
    { label: "Tracking Number", fieldName: "trackingNumber" },
    { label: "Date", fieldName: "shipmentDate", type: "date" },
    { label: "Status", fieldName: "shipmentStatus" }
];

export default class MaShipments extends LightningElement {
    // PROPERTIES
    data = [];
    columns = columns;
    isLoading = false;
    statusUpdateMessage = "";
    selectedRows = [];

    // GETTERS & SETTERS
    get idsFromWholeData() {
        // for all retrived shipments regardless count that is displayed
        return this.data.map((v) => v.shipmentId);
    }
    get isRowsSelected() {
        return this.selectedRows && Array.isArray(this.selectedRows) && this.selectedRows.length;
    }
    get updateShipmentsDisabled() {
        return this.isLoading;
    }
    get updateSelectedShipmentsDisabled() {
        return this.isRowsSelected ? this.isLoading : !this.isRowsSelected;
    }
    get updateSelectedLabel() {
        return this.isRowsSelected ? `Update selected shipments (${this.selectedRows.length})` : "Select Shipments...";
    }
    get updateShipmentsStatusPayload() {
        const input = this.isRowsSelected ? this.selectedRows : this.idsFromWholeData;
        return { input };
    }

    // LIFECYCLE HOOKS
    connectedCallback() {
        this.retrieveShipmentsHelper();
    }

    // HANDLERS
    handleUpdateShipmentsStatus() {
        this.clearSelectionHelper();
        this.updateSelectedShipmentsStatusHelper();
    }
    handleUpdateSelectedShipmentsStatus() {
        this.updateSelectedShipmentsStatusHelper();
    }
    handleUpdateShipmentsStatusQueueable() {
        this.updateShipmentsStatusQueueable();
    }
    handleUpdateShipmentsStatusSchedule() {
        this.showToast('warning', 'warning', 'warning', 'sticky');
    }
    handleCancelSelection() {
        this.clearSelectionHelper();
    }
    handleRefresh() {
        this.retrieveShipmentsHelper();
    }
    handleRowSelection(event) {
        console.log("handleRowSelection:", event.detail.selectedRows);
        const rows = event.detail.selectedRows;
        const isRows = rows && Array.isArray(rows) && rows.length;
        this.selectedRows = isRows ? event.detail.selectedRows.map((v) => v.shipmentId) : [];
    }

    // HELPER METHODS
    clearSelectionHelper() {
        this.selectedRows = [];
        this.template.querySelector("lightning-datatable").selectedRows = [];
    }
    async retrieveShipmentsHelper() {
        this.isLoading = true;
        this.data = [];
        this.data = await this.retrieveShipments();
        this.showToast('success', 'success', 'Retrieve Shipments');
        this.isLoading = false;
    }
    async updateSelectedShipmentsStatusHelper() {
        this.isLoading = true;
        // we have to keep sequence here in order to garantee that the shipments
        // are updated before we retrieve them again
        this.statusUpdateMessage = await this.updateShipmentsStatus();
        this.data = await this.retrieveShipments();
        this.clearSelectionHelper();
        this.showToast('success', 'success', 'Update Shipments Status');
        this.isLoading = false;
    }

    // APEX METHODS
    async retrieveShipments() {
        try {
            let result = await retrieveShipments();
            return result;
        } catch (error) {
            console.log("error:", error);
            this.isLoading = false;
            // compose error title
            // compose error message
            this.showToast('error', 'error', 'error', 'sticky');
            return [];
        }
    }

    async updateShipmentsStatus() {
        try {
            let result = await updateShipmentsStatus(this.updateShipmentsStatusPayload);
            return result;
        } catch (error) {
            console.log("error:", error);
            this.isLoading = false;
            // compose error title
            // compose error message
            this.showToast('error', 'error', 'error', 'sticky');
            return [];
        }
    }

    async updateShipmentsStatusQueueable() {
        try {
            let result = await updateShipmentsStatusQueueable();
            this.showToast('success', 'info', result, 'sticky');
            return result;
        } catch (error) {
            console.log("error:", error);
            this.isLoading = false;
            // compose error title
            // compose error message
            this.showToast('error', 'error', 'error', 'sticky');
            return [];
        }
    }

    // EVENTS
    showToast(title, variant, message, mode = "pester") {
        const event = new ShowToastEvent({ title, variant, message, mode});
        this.dispatchEvent(event);
    }
}