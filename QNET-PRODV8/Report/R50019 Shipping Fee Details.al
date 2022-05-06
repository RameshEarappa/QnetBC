report 50019 "Shipping Fee Detail's"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Report\ShippingFeeDetails.rdl';
    dataset
    {
        dataitem("Shipping Paid Detail's"; "Shipping Paid Detail's")
        {
            RequestFilterFields = "AWB No.", "Order Date", "Courier ID";
            DataItemTableView = sorting("AWB No.");
            column(companylogo; CompanyInfo.Picture) { }
            column(CompanyAddress1; CompanyAddr[1]) { }
            column(CompanyAddress2; CompanyAddr[2]) { }
            column(CompanyAddress3; CompanyAddr[3]) { }
            column(CompanyAddress4; CompanyAddr[4]) { }
            column(CompanyAddress5; CompanyAddr[5]) { }
            column(CompanyAddress6; CompanyAddr[6]) { }
            column(OrderNo; "SOMS Order No.") { }
            column(Order_Date; "Order Date") { }
            column(Courier_ID; "Courier ID") { }
            column(AWB_No_; "AWB No.") { }
            column(Shipper; Shipper) { }
            column(Consignee; Consignee) { }
            column(Origin; Origin) { }
            column(Dest; Dest) { }
            column(Prod; Prod) { }
            column(Weight; Weight) { }
            column(Duty; Duty) { }
            column(VAT__5_; "VAT @5%") { }
            column(Shipping_Fee_Paid; "Shipping Fee Paid") { }
            column(FeeAmount; FeeAmount) { }
            trigger OnAfterGetRecord()
            begin

                FeeAmount := 0;
                IntegrationSetup.Get();
                SalesInvLine.reset;
                SalesInvLine.SetRange(AWB, "AWB No.");
                if SalesInvLine.FindFirst() then begin
                    SalesInvLine2.reset;
                    SalesInvLine2.SetRange("SOMS Order No.", SalesInvLine."SOMS Order No.");
                    SalesInvLine2.SetRange(type, SalesInvLine2.Type::"G/L Account");
                    SalesInvLine2.SetRange("No.", IntegrationSetup."Ship Fee GL");
                    SalesInvLine2.SetRange(Quantity, 1);
                    SalesInvLine2.SetFilter("Amount Including VAT", '<>%1', 0);
                    if SalesInvLine2.FindFirst() then begin
                        FeeAmount := SalesInvLine2."Amount Including VAT"
                    end;
                end;


                // GLEn// tries.Reset();
                // GLEntries.SetRange("SOMS Order No.", "SOMS Order No.");
                // GLEntries.SetRange("G/L Account No.", IntegrationSetup."Ship Fee GL");
                // GLEntries.CalcSums(Amount);
                // FeeAmount := GLEntries.Amount;
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
        CountryRegion: Record "Country/Region";
        CompanyAddr: array[8] of Text[100];
        FeeAmount: Decimal;
        GLEntries: Record "G/L Entry";
        IntegrationSetup: Record "Integration Setup";
        CompanyInfo: Record "Company Information";
        SalesInvLine: Record "Sales Invoice Line";
        SalesInvLine2: Record "Sales Invoice Line";

}