tableextension 50001 "Sales Header Ext." extends "Sales Header"
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
        field(50106; "Virtual File Code"; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50107; "Control Sales"; boolean)
        {
            DataClassification = ToBeClassified;
        }

    }

    var
        myInt: Integer;
}