pageextension 50027 "Posted Sales Cr Memo Lines Ext" extends "Posted Sales Credit Memo Lines"
{
    layout
    {
        // Add changes to page layout here
        addafter(Amount)
        {
            field(ShipNo; rec."SOMS Ship No")
            {
                ApplicationArea = all;
                Editable = false;
            }

            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                Editable = false;
            }
            field("SOMS Line No."; Rec."SOMS Line No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field(TCO; rec.TCO)
            {
                ApplicationArea = all;
                Caption = 'TCO';
                Editable = false;
            }
            field("Courier ID"; rec."Courier ID")
            {
                ApplicationArea = all;
                Caption = 'Courier ID';
                Editable = false;
            }
            field(AWB; rec.AWB)
            {
                ApplicationArea = all;
                Caption = 'AWB';
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