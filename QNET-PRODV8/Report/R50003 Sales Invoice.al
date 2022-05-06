report 50003 "Sales Invoice Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Report\SalesInvoiceReport.rdl';
    Caption = 'Tax Invoice';

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            RequestFilterHeading = 'Posted Sales Invoice';
            column(No_; "No.") { }
            column(Posting_Date; "Posting Date") { }
            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyRegNo; CompanyInfo."Registration No.") { }
            column(CompanyCity; CompanyInfo.City) { }
            column(CompanyPostCode; CompanyInfo."Post Code") { }
            column(CompanyCountry; CountryRegion.Name) { }
            column(CompanyPicture; CompanyInfo.Picture) { }
            column(Sell_to_Customer_Name; "Sell-to Customer Name") { }
            column(CustomerTRNo; '') { }
            column(CustomerCity; Customer.City) { }
            column(CustomerContact; Customer.Contact) { }
            column(CustomerEmail; Customer."E-Mail") { }
            column(Currency_Code; "Currency Code") { }
            column(CurrencyAmount; CurrencyExchangeRate."Relational Exch. Rate Amount") { }

            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(SerialNo; SerialNo) { }
                column(ItemNo_; "No.") { }
                column(Description; "Description 2") { }
                column(Quantity; Quantity) { }
                column(Unit_Price; "Unit Price") { }
                column(VAT__; "VAT %") { }
                column(TotalSellingUSD; TotalSellingUSD) { }
                column(TotalUSDwithVAT; TotalUSDwithVAT) { }
                column(TotalAEDExclVAT; TotalAEDExclVAT) { }
                column(TotalVATAED; TotalVATAED) { }
                column(TotalAEDwithVAT; TotalAEDwithVAT) { }
                column(SubTotalUSD; SubTotalUSD) { }
                column(TotalVATPerUSD; TotalVATPerUSD) { }
                column(TotalAmountUSD; TotalAmountUSD) { }
                column(SubTotalAED; SubTotalAED) { }
                column(TotalVATPerAED; TotalVATPerAED) { }
                column(TotalAmountAED; TotalAmountAED) { }

                trigger OnAfterGetRecord()
                begin
                    SerialNo += 1;

                    TotalSellingUSD := Quantity * "Unit Price";
                    TotalUSDwithVAT := TotalSellingUSD + "VAT %";
                    if Header."Currency Code" <> 'AED' then begin
                        TotalAEDExclVAT := TotalSellingUSD * CurrencyExchangeRate."Relational Exch. Rate Amount";
                        TotalVATAED := "VAT %" * CurrencyExchangeRate."Relational Exch. Rate Amount";
                        TotalAEDwithVAT := TotalUSDwithVAT * CurrencyExchangeRate."Relational Exch. Rate Amount";
                    end else begin
                        TotalAEDExclVAT := TotalSellingUSD;
                        TotalVATAED := "VAT %";
                        TotalAEDwithVAT := TotalUSDwithVAT;
                    end;

                    SubTotalUSD += TotalSellingUSD;
                    TotalVATPerUSD += "VAT %";
                    TotalAmountUSD += TotalUSDwithVAT;

                    if Header."Currency Code" <> 'AED' then begin
                        SubTotalAED := SubTotalUSD * CurrencyExchangeRate."Relational Exch. Rate Amount";
                        TotalVATPerAED := TotalVATPerUSD * CurrencyExchangeRate."Relational Exch. Rate Amount";
                        TotalAmountAED := TotalAmountUSD * CurrencyExchangeRate."Relational Exch. Rate Amount";
                    end else begin
                        SubTotalAED := SubTotalUSD;
                        TotalVATPerAED := TotalVATPerUSD;
                        TotalAmountAED := TotalAmountUSD;
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                SerialNo := 0;
                TotalSellingUSD := 0;
                TotalUSDwithVAT := 0;
                TotalAEDExclVAT := 0;
                TotalVATAED := 0;
                TotalAEDwithVAT := 0;
                SubTotalUSD := 0;
                SubTotalAED := 0;
                TotalVATPerUSD := 0;
                TotalVATPerAED := 0;
                TotalAmountUSD := 0;
                TotalAmountAED := 0;
                if Customer.Get("Sell-to Customer No.") then;

                Clear(CurrencyExchangeRate);
                CurrencyExchangeRate.SetRange("Currency Code", Header."Currency Code");
                if CurrencyExchangeRate.FindLast() then;

                Clear(CountryRegion);
                if CountryRegion.Get(CompanyInfo."Country/Region Code") then;
            end;
        }
    }

    trigger OnInitReport()
    begin
        CompanyInfo.SetAutoCalcFields(Picture);
        CompanyInfo.Get;
    end;

    var
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        TotalSellingUSD: Decimal;
        TotalUSDwithVAT: Decimal;
        TotalAEDExclVAT: Decimal;
        TotalVATAED: Decimal;
        TotalAEDwithVAT: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        SubTotalUSD: Decimal;
        SubTotalAED: Decimal;
        TotalVATPerUSD: Decimal;
        TotalVATPerAED: Decimal;
        TotalAmountUSD: Decimal;
        TotalAmountAED: Decimal;
        SerialNo: Integer;
        CountryRegion: Record "Country/Region";
}