report 50001 "Reatil Purchase"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Report\R50001 Retail Purchase.rdl';
    Caption = 'Retail Purchase';

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", "Posting Date";
            column(Tax_Area_Code; "Tax Area Code") { }
            column(CompRegNo; CompanyInfo."VAT Registration No.") { }
            column(CustomerIDNo; "Sell-to Customer No.") { }
            column(SOMS_Order_No_; "SOMS Order No.") { }
            column(ReceiptNo; StagingSalesOrder.ReceiptNo) { }
            column(Sponsor; 'HG321003') { }
            column(SponsorName; 'UAE Upline Name') { }
            column(TaxInvoiceNo; "Sales Invoice Header"."No.") { }
            column(AEDRate; '1 USD = 3.6725 AED') { }
            column(TransactionDate; "Posting Date") { }
            column(TransactionDescription; 'PURCHASE') { }
            column(CustomerName; "Sales Invoice Header"."Sell-to Customer Name") { }
            column(CustomerTRNNo; '0') { }
            column(ShippingAddress; "Sales Invoice Header"."Ship-to Address" + ' ' + "Sales Invoice Header"."Ship-to Address 2") { }
            column(ShippingContactNo; "Ship-to Contact") { }
            column(EMailAddress; customer."E-Mail") { }
            column(InvoicingAddress; "Bill-to Address" + ' ' + "Bill-to Address 2") { }
            column(CompanyAddress1; CompanyAddr[1]) { }
            column(CompanyAddress2; CompanyAddr[2]) { }
            column(CompanyAddress3; CompanyAddr[3]) { }
            column(CompanyAddress4; CompanyAddr[4]) { }
            column(CompanyAddress5; CompanyAddr[5]) { }
            column(CompanyAddress6; CompanyAddr[6]) { }
            column(CompanyAddress7; CompanyAddr[7]) { }
            column(CompanyAddress8; CompanyAddr[8]) { }
            column(HeaderDate; today) { }
            column(totalshipfeeamt; totalshipfeeamt) { }
            column(USDTotalShipFeeAmount; USDTotalShipFeeAmount) { }
            column(totalshipfeevatamt; totalshipfeevatamt) { }
            column(USDTotalShipFeeVATAmount; USDTotalShipFeeVATAmount) { }
            column(Currency_Code; CurrCode) { }
            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = "Sales Invoice Header";
                DataItemTableView = SORTING("Document No.", "Line No.") where(type = filter(Item));
                column(LineNo_Line; "Line No.") { }
                column(AmountExcludingVAT_Line; Amount) { }
                column(AmountIncludingVAT_Line; "Amount Including VAT") { }
                column(Description_Line; Description) { }
                column(LineDiscountPercent_Line; "Line Discount %") { }
                column(ItemNo_Line; "No.") { }
                column(Quantity; Quantity) { }
                column(Unit_Price; "Unit Price") { }
                column(VATPer; "Amount Including VAT" - Amount) { }
                column(LineTotal; LineTotal) { }
                column(totalUSDVAT; "Amount Including VAT" - Amount) { }
                column(totalAEDexclVAT; TotalexclVAT) { }
                column(TotalVATAED; TotalVATAED) { }
                column(TotalAEDwithVAT; TotalAEDwithVAT) { }
                column(total; total) { }
                column(totalvat; totalvat) { }
                column(subtotal; subtotal) { }
                trigger OnAfterGetRecord()
                var

                begin
                    TotalAEDwithVAT := "Amount Including VAT";
                    TotalVATAED := "Amount Including VAT" - Amount;
                    LineTotal := 0;
                    LineTotal := Quantity * "Unit Price";
                    if "Sales Invoice Header"."Currency Code" <> '' then begin
                        TotalAEDwithVAT := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate,
                                                                   "Sales Invoice Header"."Currency Code", "Amount Including VAT",
                                                                                          "Sales Invoice Header"."Currency Factor"), currency."Amount Rounding Precision");

                        TotalVATAED := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate,
                                                               "Sales Invoice Header"."Currency Code", "Amount Including VAT" - Amount,
                                                                                      "Sales Invoice Header"."Currency Factor"), currency."Amount Rounding Precision");

                    end;
                    TotalexclVAT := TotalAEDwithVAT - TotalVATAED;
                    subtotal += Amount;
                    totalvat += "Amount Including VAT" - Amount;
                    total += "Amount Including VAT";

                end;
            }
            trigger OnAfterGetRecord()
            begin

                CompanyAddr[1] := CompanyInfo.Name;
                if CompanyInfo."Address 2" <> '' then begin
                    CompanyAddr[2] := CompanyInfo.Address + ',' + CompanyInfo."Address 2";
                    CompanyAddr[3] := CompanyInfo.City + ' ' + CompanyInfo."Post Code";
                end else begin
                    CompanyAddr[2] := CompanyInfo.Address + ',' + CompanyInfo.City + ' ' + CompanyInfo."Post Code";
                end;
                CompanyAddr[4] := 'Co. Reg. No.' + ' ' + CompanyInfo."Registration No.";
                IF CompanyInfo."Phone No." <> '' then
                    CompanyAddr[5] := 'Tel: ' + CompanyInfo."Phone No." + '  ';
                if CompanyInfo."E-Mail" <> '' then
                    CompanyAddr[6] := 'Email: ' + CompanyInfo."E-Mail" + '  ';
                CompressArray(CompanyAddr);
                Customer.get("Sell-to Customer No.");
                SalesShipmentHeader.Reset();
                SalesShipmentHeader.SetRange("Order No.", "Order No.");
                if SalesShipmentHeader.FindLast() then;
                StagingSalesOrder.Reset();
                StagingSalesOrder.SetRange(OrderNo, "SOMS Order No.");
                if StagingSalesOrder.FindFirst() then;
                totalshipfeeamt := 0;
                totalvat := 0;
                subtotal := 0;
                total := 0;
                USDTotalShipFeeAmount := 0;
                USDTotalShipFeeVATAmount := 0;
                totalshipfeeamt := 0;
                Integrationsetup.Get();
                SalesInvLine.Reset();
                SalesInvLine.SetRange("Document No.", "No.");
                SalesInvLine.SetRange(Type, SalesInvLine.Type::"G/L Account");
                SalesInvLine.SetRange("No.", Integrationsetup."Ship Fee GL");
                if SalesInvLine.FindSet() then begin
                    repeat
                        totalshipfeeamt += SalesInvLine.Amount;
                        totalshipfeevatamt += SalesInvLine."Amount Including VAT" - SalesInvLine.Amount;
                        USDTotalShipFeeAmount += SalesInvLine.Amount;
                        USDTotalShipFeeVATAmount += SalesInvLine."Amount Including VAT" - SalesInvLine.Amount;
                    until SalesInvLine.Next() = 0;
                end;
                if "Sales Invoice Header"."Currency Code" <> '' then begin
                    totalshipfeeamt := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate,
                                                               "Sales Invoice Header"."Currency Code", USDTotalShipFeeAmount,
                                                                                      "Sales Invoice Header"."Currency Factor"), currency."Amount Rounding Precision");
                    totalshipfeevatamt := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate, "Sales Invoice Header"."Currency Code", USDTotalShipFeeVATAmount,
                    "Sales Invoice Header"."Currency Factor"), currency."Amount Rounding Precision");
                end;
                if "Sales Invoice Header"."Currency Code" <> '' then
                    CurrCode := "Sales Invoice Header"."Currency Code"
                else begin
                    generalledgersetup.Reset();
                    CurrCode := generalledgersetup."LCY Code";
                end;
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
    end;

    var
        TotalAEDwithVAT: Decimal;
        SalesInvLine: Record "Sales Invoice Line";
        TotalVATAED: Decimal;
        myInt: Integer;
        CompanyInfo: Record "company information";
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        CompanyAddr: array[8] of Text[100];

        subtotal: Decimal;
        totalvat: Decimal;
        total: Decimal;
        Integrationsetup: Record "Integration Setup";
        StagingSalesOrder: Record "Sales Order Staging";
        LineTotal: decimal;
        TotalexclVAT: Decimal;
        AEDTotalshipFeeamt: Decimal;
        AEDSubtotal: Decimal;
        AEDTotalVAT: Decimal;
        USDTotalShipFeeAmount: Decimal;
        USDTotalShipFeeVATAmount: Decimal;
        totalshipfeeamt: Decimal;
        totalshipfeevatamt: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
        currency: Record Currency;
        generalledgersetup: Record "General Ledger Setup";
        CurrCode: Code[10];



}