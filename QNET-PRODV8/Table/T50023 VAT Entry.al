tableextension 50023 "VAT Entry Ext" extends "VAT Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50107; "Control Sales"; boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    
    var
        myInt: Integer;
}