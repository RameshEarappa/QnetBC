pageextension 50026 "Posted Sales Credit Memo Ext" extends "Posted Sales Credit Memo"
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
                Editable = false;
            }
            field(Integrated_order; rec.Integrated_order)
            {
                ApplicationArea = all;
                Caption = 'Integrated Order';
                Editable = false;
            }
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                Editable = false;
            }
            field(IRID; Rec.IRID)
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Receipt No."; Rec."Receipt No.")
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