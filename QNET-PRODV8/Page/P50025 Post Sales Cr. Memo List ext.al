pageextension 50025 "Posted Sales Cr. Memo Ext" extends "Posted Sales Credit Memos"
{
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field(Reference_Id; rec.Reference_Id)
            {
                ApplicationArea = all;
                Caption = 'Reference Id';
            }
            field(Integrated_order; rec.Integrated_order)
            {
                ApplicationArea = all;
                Caption = 'Integrated Order';
            }
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
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