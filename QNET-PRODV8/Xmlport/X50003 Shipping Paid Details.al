xmlport 50003 "Shipping Paid Detail's"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    schema
    {
        textelement(Root)
        {
            tableelement("Transaction_Report"; "Shipping Paid Detail's")
            {
                AutoSave = false;
                fieldelement(Order_Date; Transaction_Report."Order Date") { }
                fieldelement(AWB; Transaction_Report."AWB No.") { }
                fieldelement(Shipper; Transaction_Report.Shipper) { }
                fieldelement(Consignee; Transaction_Report.Consignee) { }
                fieldelement(Origin; Transaction_Report.Origin) { }
                fieldelement(Dest; Transaction_Report.Dest) { }
                fieldelement(Prod; Transaction_Report.Prod) { }
                fieldelement(Weight; Transaction_Report.Weight) { }
                fieldelement(Amount; Transaction_Report."Shipping Fee Paid") { }
                fieldelement(Duty; Transaction_Report.Duty) { }
                fieldelement(vat_per; Transaction_Report."VAT @5%") { }

                trigger OnAfterInsertRecord()
                begin
                    InsertTransactionReport(Transaction_Report)
                end;
            }
        }
    }
    trigger OnInitXmlPort()
    begin
        recordcount := 0;
    end;

    local procedure InsertTransactionReport(var TempTransactionReport: Record "Shipping Paid Detail's" temporary)
    var
        TransactionReport: record "Shipping Paid Detail's";
        TransactionReport2: record "Shipping Paid Detail's";
        EntryNo: Integer;

    begin
        TransactionReport.Reset();
        if TransactionReport.FindLast() then
            EntryNo := TransactionReport."Entry No." + 1
        else
            EntryNo := 1;
        TransactionReport.Init();
        TransactionReport.TransferFields(TempTransactionReport);
        TransactionReport."Entry No." := EntryNo;
        TransactionReport.Insert();
    end;

    var
        recordcount: Integer;

}