tableextension 50019 "Sales Credit Memo Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        // Add changes to table fields here
        field(50100; Reference_Id; integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50101; Integrated_order; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "SOMS Order No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50103; "Virtual Sales"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50104; IRID; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50105; "Receipt No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}