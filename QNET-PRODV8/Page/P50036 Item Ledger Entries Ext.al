pageextension 50036 "Item Ledger Entries" extends "Item Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("SOMS Order No."; "SOMS Order No.")
            {
                ApplicationArea = All;
            }
            field("SOMS Ship No"; "SOMS Ship No")
            {
                ApplicationArea = All;
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