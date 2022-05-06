pageextension 50033 "VAT Entries" extends "VAT Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {
            field("Control Sales"; Rec."Control Sales")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}