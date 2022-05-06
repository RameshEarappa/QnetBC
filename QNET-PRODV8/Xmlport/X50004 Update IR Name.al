xmlport 50004 "IR Update's"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    Permissions = tabledata "Sales Invoice Header" = rimd, tabledata "Sales Cr.Memo Header" = RIMD;
    schema
    {
        textelement(Root)
        {
            tableelement("Transaction_Report"; "IR Update")
            {
                AutoSave = false;
                fieldelement(SOMSOrderNo; Transaction_Report."SOMS Order No.") { }
                textelement(IRName) { }
                textelement(IRID) { }
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

    local procedure InsertTransactionReport(var TempTransactionReport: Record "IR Update" temporary)
    var
        TransactionReport: record "IR Update";
        TransactionReport2: record "IR Update";
        EntryNo: Integer;
        StagingSalesOrder: Record "Sales Order Staging";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesShtHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        TransactionReport.Reset();
        if TransactionReport.FindLast() then
            EntryNo := TransactionReport."Entry No." + 1
        else
            EntryNo := 1;
        TransactionReport.Init();
        TransactionReport.TransferFields(TempTransactionReport);
        TransactionReport."Entry No." := EntryNo;
        TransactionReport."IR Name" := CopyStr(IRName, 1, 50);
        TransactionReport.IRID := CopyStr(IRID, 1, 20);
        TransactionReport.Insert();

        StagingSalesOrder.Reset();
        StagingSalesOrder.SetRange(OrderNo, TransactionReport."SOMS Order No.");
        if StagingSalesOrder.FindFirst() then
            repeat
                StagingSalesOrder."IR Name" := TransactionReport."IR Name";
                StagingSalesOrder.IRID := TransactionReport.IRID;
                StagingSalesOrder.Modify();
            until StagingSalesOrder.Next() = 0;

        SalesInvHeader.Reset();
        SalesInvHeader.SetRange("SOMS Order No.", TransactionReport."SOMS Order No.");
        if SalesInvHeader.FindFirst() then
            repeat
                SalesInvHeader."Ship-to Name" := TransactionReport."IR Name";
                SalesInvHeader."Bill-to Name" := TransactionReport."IR Name";
                SalesInvHeader."Sell-to Customer Name" := TransactionReport."IR Name";
                SalesInvHeader.IRID := TransactionReport.IRID;
                SalesInvHeader.Modify();
            until SalesInvHeader.Next() = 0;

        SalesCrMemoHeader.Reset();
        SalesCrMemoHeader.SetRange("SOMS Order No.", TransactionReport."SOMS Order No.");
        if SalesCrMemoHeader.FindFirst() then
            repeat
                SalesCrMemoHeader."Ship-to Name" := TransactionReport."IR Name";
                SalesCrMemoHeader."Bill-to Name" := TransactionReport."IR Name";
                SalesCrMemoHeader."Sell-to Customer Name" := TransactionReport."IR Name";
                SalesCrMemoHeader.IRID := TransactionReport.IRID;
                SalesCrMemoHeader.Modify();
            until SalesCrMemoHeader.Next() = 0;
    end;

    var
        recordcount: Integer;

}