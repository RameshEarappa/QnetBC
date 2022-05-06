tableextension 50017 "Bank Account Ext" extends "Bank Account"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Payment Gateway"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}