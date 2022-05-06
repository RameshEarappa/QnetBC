pageextension 50014 "General Ledger Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                Editable = false;
            }
            field("Customer Posting Group"; Rec."Customer Posting Group")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Virtual File Code"; Rec."Virtual File Code")
            {
                ApplicationArea = all;
                Editable = false;
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