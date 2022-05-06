pageextension 50037 "PostedSalesInvoices" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Sell-to Customer No.")
        {
            field("SOMS Order No."; Rec."SOMS Order No.")
            {
                ApplicationArea = All;
            }
        }
    }
}