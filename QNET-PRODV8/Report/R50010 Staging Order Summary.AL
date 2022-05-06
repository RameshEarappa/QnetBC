report 50010 "Staging Order Summary"
{
    Caption = 'Sales Order Summary';
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'QNET-PRODV8\Report\R50010 Sales Order Summary.rdl';
    dataset
    {
        dataitem("Sales Order Staging"; "Sales Order Staging")
        {
            RequestFilterFields = OrderNo, "Receipt Date", "Order Date";
            DataItemTableView = sorting(OrderNo);
            column(Receipt_Date; "Receipt Date") { }
            column(Order_Date; "Order Date") { }
            column(PostingDate; PostingDate) { }
            column(companylogo; CompanyInfo.Picture) { }
            column(CompanyAddress1; CompanyAddr[1]) { }
            column(CompanyAddress2; CompanyAddr[2]) { }
            column(CompanyAddress3; CompanyAddr[3]) { }
            column(CompanyAddress4; CompanyAddr[4]) { }
            column(CompanyAddress5; CompanyAddr[5]) { }
            column(CompanyAddress6; CompanyAddr[6]) { }
            column(OrderNo; OrderNo) { }
            column(PaymentMethod; PaymentMethod) { }
            column(Invoice_Amount; SalesInvoiceLine.Amount) { }
            column(DocNo; BankLedgerEntry."SOMS Order No.") { }
            column(postedinvno; postedinvno) { }
            column(PostedInvAmt; PostedInvAmt) { }
            column(CMNo; CMNo) { }
            column(CMAmt; CMAmt) { }
            column(PGDocPayment; PGDocPayment) { }
            column(PGDocRefund; PGDocRefund) { }

            column(PaymentPostive; PaymentPostive) { }
            column(PaymentNegative; PaymentPostive) { }
            column(RefundPostive; RefundPostive) { }
            column(RefundNegative; RefundNegative) { }
            column(APIAMount; APIAMount) { }
            column(APIAmountVAT; APIAmountVAT) { }
            trigger OnAfterGetRecord()
            var
                SOMSshipno: Code[50];
                SOMSshipline: Integer;
            begin
                if LastOrderNo <> OrderNo then begin
                    LastOrderNo := OrderNo;
                    postedinvno := '';
                    PostedInvAmt := 0;
                    CMNo := '';
                    CMAmt := 0;
                    PGDocPayment := '';
                    PGDocRefund := '';
                    PaymentPostive := 0;
                    RefundNegative := 0;
                    RefundPostive := 0;
                    PaymentNegative := 0;
                    APIAMount := 0;
                    APIAmountVAT := 0;
                    SOMSshipno := '';
                    SOMSshipline := 0;
                    PostingDate := 0D;
                    StagingSalesOrder.Reset();
                    StagingSalesOrder.SetCurrentKey(SHIPNO, ITEMNO);
                    StagingSalesOrder.SetRange(OrderNo, OrderNo);
                    StagingSalesOrder.Setrange("Receipt Date", "Receipt Date");
                    if StagingSalesOrder.FindFirst() then begin
                        repeat
                            if (SOMSshipno <> StagingSalesOrder.SHIPNO) or (SOMSshipline <> StagingSalesOrder.ITEMNO) then begin
                                SOMSshipno := StagingSalesOrder.SHIPNO;
                                SOMSshipline := StagingSalesOrder.ITEMNO;
                                APIAMount += StagingSalesOrder.AMOUNT;
                            end;
                        until StagingSalesOrder.Next() = 0;
                    end;
                    APIAmountVAT := APIAMount + Round(((APIAMount * 5) / 100), 0.01, '=');
                    SalesInvoiceHeader.Reset();
                    SalesInvoiceHeader.SetRange("SOMS Order No.", OrderNo);
                    if SalesInvoiceHeader.FindFirst() then
                        repeat
                            SalesInvoiceHeader.CalcFields("Amount Including VAT");
                            if postedinvno = '' then
                                Postedinvno := SalesInvoiceHeader."No."
                            else
                                postedinvno := postedinvno + ' ,' + SalesInvoiceHeader."No.";

                            PostedInvAmt += SalesInvoiceHeader."Amount Including VAT";
                            PostingDate := SalesInvoiceHeader."Posting Date";
                        until SalesInvoiceHeader.Next() = 0;

                    PostedCreditMemo.Reset();
                    PostedCreditMemo.SetRange("SOMS Order No.", OrderNo);
                    if PostedCreditMemo.FindFirst() then
                        repeat
                            PostedCreditMemo.CalcFields("Amount Including VAT");
                            if CMNo = '' then
                                CMNo := PostedCreditMemo."No."
                            else
                                CMNo := CMNo + ' ,' + PostedCreditMemo."No.";

                            CMAmt += PostedCreditMemo."Amount Including VAT";
                            PostingDate := PostedCreditMemo."Posting Date";
                        until PostedCreditMemo.Next() = 0;

                    BankLedgerEntry.reset;
                    //BankLedgerEntry.SetRange("Document Type",BankLedgerEntry."Document Type"::Payment);
                    BankLedgerEntry.setrange("SOMS Order No.", OrderNo);
                    BankLedgerEntry.CalcFields("Payment Gateway");
                    BankLedgerEntry.SetRange("Payment Gateway", true);
                    If BankLedgerEntry.Findfirst then
                        repeat
                            if BankLedgerEntry."Document Type" = BankLedgerEntry."Document Type"::Payment then begin
                                if BankLedgerEntry.Amount > 0 then
                                    PaymentPostive += BankLedgerEntry.Amount
                                else
                                    PaymentNegative += BankLedgerEntry.Amount;

                                if PGDocPayment = '' then
                                    PGDocPayment := BankLedgerEntry."Document No."
                                else
                                    PGDocPayment := PGDocPayment + ' ,' + BankLedgerEntry."Document No.";
                            end;

                            if BankLedgerEntry."Document Type" = BankLedgerEntry."Document Type"::Refund then begin
                                if BankLedgerEntry.Amount > 0 then
                                    RefundPostive += BankLedgerEntry.Amount
                                else
                                    RefundNegative += BankLedgerEntry.Amount;

                                if PGDocRefund = '' then
                                    PGDocRefund := BankLedgerEntry."Document No."
                                else
                                    PGDocRefund := PGDocRefund + ' ,' + BankLedgerEntry."Document No.";

                            end;

                        until BankLedgerEntry.Next() = 0;
                end else
                    CurrReport.Skip();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {

            }
        }

        actions
        {

        }
    }
    trigger OnPreReport()
    begin
        CompanyInfo.get;
        CompanyInfo.CalcFields(Picture);
        CompanyAddr[1] := CompanyInfo.Name;
        CompanyAddr[2] := CompanyInfo.Address;
        CompanyAddr[3] := CompanyInfo."Address 2";
        CompanyAddr[4] := CompanyInfo.City + ', ' + CompanyInfo."Post Code";
        if CountryRegion.get(CompanyInfo."Country/Region Code") then
            CompanyAddr[5] := CountryRegion.Name;
        CompressArray(CompanyAddr);
    end;

    var
        CompanyInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
        CompanyAddr: array[8] of Text[100];
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Header";
        BankLedgerEntry: Record "Bank Account Ledger Entry";
        PostedCreditMemo: Record "Sales Cr.Memo Header";
        PostedCreditMemoLine: Record "Sales Cr.Memo Line";
        StagingSalesOrder: Record "Sales Order Staging";
        postedinvno: Text[100];
        PostedInvAmt: Decimal;
        CMNo: Text[100];
        CMAmt: Decimal;
        PGDocPayment: Text[100];
        PGDocRefund: Text[100];
        PaymentPostive: Decimal;
        RefundNegative: Decimal;
        RefundPostive: Decimal;
        PaymentNegative: Decimal;
        LastOrderNo: Code[50];
        APIAMount: Decimal;
        APIAmountVAT: Decimal;
        PostingDate: Date;

}