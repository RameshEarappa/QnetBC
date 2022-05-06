pageextension 50020 "Item Card Ext" extends "Item Card"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Description 2"; Rec."Description 2")
            {
                ApplicationArea = all;
            }
            field("Description 3"; Rec."Description 3")
            {
                ApplicationArea = all;
            }
            field("Sync BOM Components"; Rec."Sync BOM Components")
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