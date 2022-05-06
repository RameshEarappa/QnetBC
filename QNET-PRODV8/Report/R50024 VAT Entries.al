report 50024 "VAT Entries Summary"
{
    Caption = 'VAT Entries Summary';
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Report\R50024 VAT Entries Summary.rdl';
    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
            RequestFilterFields = "Document No.", "Posting Date";
            DataItemTableView = sorting("Entry No.") where(Amount = filter(<> 0));
            column(companylogo; CompanyInfo.Picture) { }
            column(CompanyAddress1; CompanyAddr[1]) { }
            column(CompanyAddress2; CompanyAddr[2]) { }
            column(CompanyAddress3; CompanyAddr[3]) { }
            column(CompanyAddress4; CompanyAddr[4]) { }
            column(CompanyAddress5; CompanyAddr[5]) { }
            column(CompanyAddress6; CompanyAddr[6]) { }
            column(Posting_Date; "Posting Date") { }
            column(Document_Type; "Document Type") { }
            column(Type; Type) { }
            column(Document_No_; "Document No.") { }
            column(Base; Base) { }
            column(Amount; Amount) { }
            column(Entry_No_; "Entry No.") { }
            column(VAT_Bus__Posting_Group; "VAT Bus. Posting Group") { }
            column(VAT_Prod__Posting_Group; "VAT Prod. Posting Group") { }
            column(VAT_Calculation_Type; "VAT Calculation Type") { }
            column(VAT_Difference; "VAT Difference") { }
            column(Bill_to_Pay_to_No_; "Bill-to/Pay-to No.") { }
            column(Name; SalesInvoiceHeader."Bill-to Name") { }
            column(Addres1; SalesInvoiceHeader."Bill-to Address") { }
            column(Addres2; SalesInvoiceHeader."Bill-to Address 2") { }
            column(city; SalesInvoiceHeader."Bill-to City") { }
            column(state; SalesInvoiceHeader."Bill-to Post Code") { }
            column(CountryRegion; "VAT Entry"."Country/Region Code") { }
            column(Cost_center_Code; GLEntries."Global Dimension 2 Code") { }
            column(HideLine; HideLine) { }
            trigger OnAfterGetRecord()
            begin
                Clear(SalesInvoiceHeader);
                if SalesInvoiceHeader.get("Document No.") then;
                Clear(GLEntries);
                GLEntries.Reset();
                GLEntries.SetRange("Document No.", "Document No.");
                GLEntries.SetFilter("Global Dimension 2 Code", '<>%1', '');
                if GLEntries.FindFirst() then;
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
        GLEntries: Record "G/L Entry";
        HideLine: Integer;
}