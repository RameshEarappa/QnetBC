report 50025 "Sales-Credit Memo Summary"
{
    Caption = 'Sales-Credit Memo Summary';
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Report\R50025 Sales Credit Memo Summary.rdl';
    dataset
    {
        dataitem(Header; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Posting Date", "Customer Posting Group";
            DataItemTableView = sorting("No.");
            column(companylogo; CompanyInfo.Picture) { }
            column(CompanyAddress1; CompanyAddr[1]) { }
            column(CompanyAddress2; CompanyAddr[2]) { }
            column(CompanyAddress3; CompanyAddr[3]) { }
            column(CompanyAddress4; CompanyAddr[4]) { }
            column(CompanyAddress5; CompanyAddr[5]) { }
            column(CompanyAddress6; CompanyAddr[6]) { }
            column(Posting_Date; "Posting Date") { }
            column(Virtual_Sales; "Virtual Sales") { }
            column(SOMS_Order_No_; "SOMS Order No.") { }
            column(Customer_Posting_Group; "Customer Posting Group") { }
            column(No_; "No.") { }
            dataitem(Line; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemLinkReference = Header;
                DataItemTableView = SORTING("Document No.", "Line No.") where(Quantity = filter('<>0'));
                column(LineNo_Line; "Line No.") { }
                column(Type; Type) { }
                column(ItemNo_Line; "No.") { }
                column(Description; Description) { }
                column(Description_Line; Description) { }
                column(Unit_of_Measure_Code; "Unit of Measure Code") { }
                column(Unit_Price; "Unit Price") { }
                column(Unit_Cost__LCY_; "Unit Cost (LCY)") { }
                column(Quantity; Quantity) { }
                column(SOMS_Ship_No; "SOMS Ship No") { }
                column(SOMS_Line_No_; "SOMS Line No.") { }
                column(TCO; TCO) { }
                column(Courier_ID; "Courier ID") { }
                column(AWB; AWB) { }
                column(Shortcut_Dimension_1_Code; "Shortcut Dimension 1 Code") { }
                column(Shortcut_Dimension_2_Code; "Shortcut Dimension 2 Code") { }
                column(Line_Amount; "Line Amount") { }
                column(Line_Discount_Amount; "Line Discount Amount") { }
                column(Amount; Amount) { }
                column(Amount_Including_VAT; "Amount Including VAT") { }

            }
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



}