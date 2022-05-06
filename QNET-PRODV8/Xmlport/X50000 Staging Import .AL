xmlport 50000 "Staging Import"
{
    Caption = 'DD Virtual Sales Import';
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;

    schema
    {
        textelement(Root)
        {
            tableelement("Sales_Order_Staging"; "Sales Order Staging")
            {
                AutoSave = false;
                fieldelement(OrderType; Sales_Order_Staging.OrderType) { }
                fieldelement(ReceiptDate; Sales_Order_Staging."Receipt Date") { }
                fieldelement(OrderNo; Sales_Order_Staging.OrderNo) { }
                fieldelement(ItemNo; Sales_Order_Staging.ITEMNO) { }
                fieldelement(HSN; Sales_Order_Staging.HSN) { }
                fieldelement(Brand; Sales_Order_Staging.Brand) { }
                fieldelement(comboProductCode; Sales_Order_Staging.comboProductCode) { }
                fieldelement(productCode; Sales_Order_Staging.productCode) { }
                fieldelement(productName; Sales_Order_Staging.productName) { }
                fieldelement(quantity; Sales_Order_Staging.QTY) { }
                textelement(CUV) { }
                fieldelement(paymentMethod; Sales_Order_Staging.paymentMethod) { }
                textelement(DDNumber) { }
                textelement(Warehouse) { }
                fieldelement(shipNo; Sales_Order_Staging.shipNo) { }
                fieldelement(year; Sales_Order_Staging.year) { }
                fieldelement(week; Sales_Order_Staging.week) { }
                fieldelement(IRID; Sales_Order_Staging.IRID) { }
                textelement(TCEXT) { }
                textelement(IRName) { }
                textelement(Ship_Status) { }
                //fieldelement(statusId; Sales_Order_Staging.statusId)
                //{ }
                // fieldelement(statusDesc; Sales_Order_Staging.statusDesc)
                //{ }
                // textelement(TransactionId)
                // { }
                // textelement(Shipment_StatusId)
                // { }

                fieldelement(remarks; Sales_Order_Staging.remarks)
                {
                }
                fieldelement(FullPrice; Sales_Order_Staging.AMOUNT)
                { }
                fieldelement(Ship_Fee; Sales_Order_Staging.ShipFee)
                { }
                fieldelement(GST_Rate; Sales_Order_Staging."GST Rate (%)")
                { }
                fieldelement(GST_Value; Sales_Order_Staging."GST Value")
                { }
                fieldelement(Total_MRP; Sales_Order_Staging."Total MRP")
                { }
                fieldelement(Pay_Amount; Sales_Order_Staging."Pay Amount")
                { }

                fieldelement(currency; Sales_Order_Staging.currency)
                { }
                fieldelement(address1; Sales_Order_Staging.address1)
                {
                }
                fieldelement(address2; Sales_Order_Staging.address2)
                { }
                fieldelement(city; Sales_Order_Staging.SHIP_CITY)
                { }
                fieldelement(state; Sales_Order_Staging.SHIP_STATE)
                { }
                fieldelement(zipCode; Sales_Order_Staging.SHIP_ZIPCODE)
                {

                }
                fieldelement(countryCode; Sales_Order_Staging.countryCode)
                { }
                fieldelement(contactNo_Home; Sales_Order_Staging.contactNo_Home)
                { }
                fieldelement(contactNo_Mobile; Sales_Order_Staging.contactNo_Mobile)
                { }
                textelement(ContactNo_Office)
                { }
                fieldelement(receiptNo; Sales_Order_Staging.receiptNo)
                {

                }
                fieldelement(eMail; Sales_Order_Staging.eMail)
                { }


                /*fieldelement(storageLocation; Sales_Order_Staging.storageLocation)
                {

                }
                
            
                fieldelement(tco; Sales_Order_Staging.tco)
                {

                }*/


                // fieldelement(payAmount; Sales_Order_Staging.AMOUNT)
                //{ }
                // fieldelement(usPayAmount; Sales_Order_Staging.OAMOUNT)
                // { }



                /*fieldelement(awb; Sales_Order_Staging.awb)
                { }
                fieldelement(courierID; Sales_Order_Staging.courierID)
                { }*/
                trigger OnAfterInsertRecord()
                begin
                    InsertSalesOrderStaging(Sales_Order_Staging);

                end;




            }


        }
    }

    local procedure InsertSalesOrderStaging(var TempSalesOrderStaging: Record "Sales Order Staging" temporary)
    var
        StagingSalesOrder: record "Sales Order Staging";
        StagingSalesOrder2: record "Sales Order Staging";
        EntryNo: Integer;
    begin
        StagingSalesOrder.Reset();
        if StagingSalesOrder.FindLast() then
            EntryNo := StagingSalesOrder."Entry No." + 1
        else
            EntryNo := 1;
        StagingSalesOrder.Init();
        StagingSalesOrder.TransferFields(TempSalesOrderStaging);
        if TempSalesOrderStaging.CountryCode = 'United Arab Emirates' then
            StagingSalesOrder.CountryCode := 'AE';
        if TempSalesOrderStaging.ShipFee <> 0 then
            StagingSalesOrder.AMOUNT := StagingSalesOrder.AMOUNT + TempSalesOrderStaging.ShipFee;
        StagingSalesOrder."Entry No." := EntryNo;
        StagingSalesOrder."Import from Excel" := true;
        StagingSalesOrder."Entry Date/Time" := CurrentDateTime;
        StagingSalesOrder."IR Name" := CopyStr(IRName, 1, 50);
        StagingSalesOrder."Virtual File Code" := 'V-' + format(Today, 8, '<Year4><Month,2><Day,2>');
        StagingSalesOrder.Insert()

    end;


}