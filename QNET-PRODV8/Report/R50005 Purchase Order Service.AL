report 50005 "Purchase Order Service"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    AccessByPermission = tabledata "Purchase header" = IDR;
    DefaultLayout = RDLC;
    RDLCLayout = 'Report\R50005 Purchase Order Service.rdl';
    PreviewMode = PrintLayout;
    Caption = 'Purchase Order Service';
    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = filter('Order'));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Purchase Order';
            column(No_; "No.") { }
            column(Picture; CompanyInfo.Picture) { }
            column(Posting_Date; "Posting Date") { }
            column(Buy_from_County; "Buy-from County") { }
            column(Buy_from_Address; "Buy-from Address") { }
            column(Buy_from_Contact_No_; "Buy-from Contact No.") { }
            column(Buy_from_City; "Buy-from City") { }
            column(Buy_from_Vendor_No_; "Buy-from Vendor No.") { }
            column(Buy_from_Vendor_Name; "Buy-from Vendor Name") { }
            column(Buy_from_Address_2; "Buy-from Address 2") { }
            column(Pay_to_Address; "Pay-to Address") { }
            column(Pay_to_Contact_No_; "Pay-to Contact No.") { }
            column(Pay_to_County; "Pay-to County") { }
            column(Nameofsupplier; "Buy-from Vendor Name") { }
            column(CountryOfSupplier; "Buy-from County") { }
            column(FullAddressOfSupplier; vendor.Address + ', ' + Vendor."Address 2") { }
            column(FullAddressOfSupplier2; vendor.City + ', ' + Vendor."Post Code") { }
            column(VendAddr8; VendAddr[8]) { }
            column(VendAddr7; VendAddr[7]) { }
            column(VendAddr6; VendAddr[6]) { }
            column(VendAddr5; VendAddr[5])
            { }
            column(VendAddr4; VendAddr[4])
            {
            }
            column(VendAddr3; VendAddr[3])
            {
            }
            column(VendAddr2; VendAddr[2])
            {
            }
            column(VendAddr1; VendAddr[1])
            {
            }
            column(BuyFromAddr1; BuyFromAddr[1])
            {
            }
            column(BuyFromAddr2; BuyFromAddr[2])
            {
            }
            column(BuyFromAddr3; BuyFromAddr[3])
            {
            }
            column(BuyFromAddr4; BuyFromAddr[4])
            {
            }
            column(BuyFromAddr5; BuyFromAddr[5])
            {
            }
            column(BuyFromAddr6; BuyFromAddr[6])
            {
            }
            column(BuyFromAddr7; BuyFromAddr[7])
            {
            }
            column(BuyFromAddr8; BuyFromAddr[8])
            {
            }
            column(ShipToAddr1; ShipToAddr[1])
            {
            }
            column(ShipToAddr2; ShipToAddr[2])
            {
            }
            column(ShipToAddr3; ShipToAddr[3])
            {
            }
            column(ShipToAddr4; ShipToAddr[4])
            {
            }
            column(ShipToAddr5; ShipToAddr[5])
            {
            }
            column(ShipToAddr6; ShipToAddr[6])
            {
            }
            column(ShipToAddr7; ShipToAddr[7])
            {
            }
            column(ShipToAddr8; ShipToAddr[8])
            {
            }
            column(Currency_Code; CurrencyCode) { }
            column(Payment_Terms_Code; PaymentTerms.Description) { }
            column(TaxRegNo; CompanyInfo."VAT Registration No.") { }
            column(VendorTaxRegNo; vendor."VAT Registration No.") { }
            dataitem(Purchase_Line; "Purchase Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemLinkReference = "Purchase Header";
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                column(No; "No.") { }
                column(Description; Description)
                { }
                column(Quantity; Quantity)
                { }
                column(Unit_Price__LCY_; "Unit Price (LCY)")
                { }
                column(Line_Discount__; "Line Discount %")
                { }
                column(Line_Amount; "Line Amount")
                { }
                column(Shortcut_Dimension_1_Code; "Shortcut Dimension 1 Code")
                { }
                column(AmountVAT; "Amount Including VAT" - Amount) { }
                column(subtotal; subtotal) { }
                column(g_subtotal; g_subtotal) { }
                column(g_total; g_total) { }
                column(g_totalvat; g_totalvat) { }
                column(Amount_Including_VAT; "Amount Including VAT") { }

                trigger OnAfterGetRecord()
                var
                    CurrExchRate: Record "Currency Exchange Rate";
                    currency: Record Currency;
                begin
                    total := 0;
                    totalvat := 0;
                    subtotal := 0;
                    total := "Amount Including VAT";
                    totalvat := "Amount Including VAT" - Amount;
                    subtotal := Amount;
                    if "Purchase Header"."Currency Code" <> '' then begin
                        total := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate,
                                                                   "Purchase Header"."Currency Code", total,
                                                                                          "Purchase Header"."Currency Factor"), currency."Amount Rounding Precision");

                        totalvat := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate,
                                                               "Purchase Header"."Currency Code", totalvat,
                                                                                      "Purchase Header"."Currency Factor"), currency."Amount Rounding Precision");
                        subtotal := round(CurrExchRate.ExchangeAmtFCYToLCY(WorkDate, "Purchase Header"."Currency Code", subtotal,
                                                     "Purchase Header"."Currency Factor"), currency."Amount Rounding Precision");

                    end;
                    g_subtotal += subtotal;
                    g_totalvat += totalvat;
                    g_total += total;
                end;

            }
            trigger OnAfterGetRecord()
            begin
                FormatAddressFields("Purchase Header");
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

                VendAddr[1] := "Buy-from Vendor Name";
                VendAddr[2] := "Buy-from County";
                if vendor.Get("Buy-from Vendor No.") then;
                if PaymentTerms.Get("Payment Terms Code") then;
                GeneralLedgerSetup.get;
                if "Purchase Header"."Currency Code" <> '' then
                    CurrencyCode := "Purchase Header"."Currency Code"
                else
                    CurrencyCode := GeneralLedgerSetup."LCY Code";
                g_subtotal := 0;
                g_totalvat := 0;
                g_total := 0;
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
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    local procedure FormatAddressFields(var PurchaseHeader: Record "Purchase Header")
    var
        CountryRegion: Record "Country/Region";
    begin
        //FormatAddr.GetCompanyAddr(PurchaseHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
        //FormatAddr.PurchHeaderBuyFrom(BuyFromAddr, PurchaseHeader);
        BuyFromAddr[1] := CompanyInfo.Name;
        BuyFromAddr[2] := CompanyInfo.Address;
        BuyFromAddr[3] := CompanyInfo."Address 2";
        BuyFromAddr[4] := CompanyInfo.City + ', ' + CompanyInfo."Post Code";
        if CountryRegion.Get(CompanyInfo."Country/Region Code") then;
        BuyFromAddr[5] := CompanyInfo."Country/Region Code";
        BuyFromAddr[6] := CountryRegion.Name;
        CompressArray(BuyFromAddr);
        //if PurchaseHeader."Buy-from Vendor No." <> PurchaseHeader."Pay-to Vendor No." then
        //FormatAddr.PurchHeaderPayTo(VendAddr, PurchaseHeader);
        FormatAddr.PurchHeaderShipTo(ShipToAddr, PurchaseHeader);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: code[10];
        subtotal: Decimal;
        g_subtotal: Decimal;
        myInt: Integer;
        totalvat: Decimal;
        g_totalvat: Decimal;
        total: Decimal;
        g_total: Decimal;
        CompanyInfo: Record "Company Information";
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        BuyFromAddr: array[8] of Text[100];
        FormatAddr: Codeunit "Format Address";
        VendAddr: array[8] of Text[100];
        PaymentTerms: Record "Payment Terms";
        vendor: Record Vendor;


}