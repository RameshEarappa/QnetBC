xmlport 50005 "SOMS Order Reco"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    schema
    {
        textelement(Root)
        {
            tableelement("Transaction_Report"; "Order Reconciliation")
            {
                AutoSave = false;
                fieldelement(Order_Date; Transaction_Report."Order Date") { }
                fieldelement(OrderNo; Transaction_Report."Order No.") { }
                fieldelement(Amount; Transaction_Report.Amount) { }


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

    local procedure InsertTransactionReport(var TempTransactionReport: Record "Order Reconciliation" temporary)
    var
        TransactionReport: record "Order Reconciliation";
        TransactionReport2: record "Order Reconciliation";
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