tableextension 50021 "Sales Credit Memo Line Ext" extends "Sales Cr.Memo Line"
{
    fields
    {
        // Add changes to table fields here
        // Add changes to table fields here
        field(50100; "SOMS Ship No"; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "SOMS Order No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50103; "SOMS Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50104; TCO; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50105; AWB; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50106; "Courier ID"; code[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}