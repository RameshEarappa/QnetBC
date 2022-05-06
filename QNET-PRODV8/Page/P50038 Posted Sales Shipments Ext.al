pageextension 50038 "Posted Sales Shipments" extends "Posted Sales Shipments"
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