pageextension 50023 "Purchase Order Subform Ext" extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Depreciation Book Code"; rec."Depreciation Book Code")
            {
                ApplicationArea = all;

            }
            field("Integration Status"; Rec."Integration Status")
            {
                ApplicationArea = all;
            }
            field("VAT Prod. Posting Group."; Rec."VAT Prod. Posting Group")
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