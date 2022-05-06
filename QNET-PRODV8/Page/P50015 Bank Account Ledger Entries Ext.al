pageextension 50015 "Bank Account Ledger Entries" extends "Bank Account Ledger Entries"
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
            field("Payment Gateway"; rec."Payment Gateway")
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