pageextension 50021 "Vendo List Ext" extends "Vendor List"
{
    layout
    {
        // Add changes to page layout here
        addafter(Name)
        {
            field("Search Name."; Rec."Search Name")
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