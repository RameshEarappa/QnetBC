tableextension 50002 "Sales Line Ext" extends "Sales Line"
{
    fields
    {
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
        field(50107; "SOMS Status"; Enum " SOMS Sales Line Status")
        {
            DataClassification = ToBeClassified;
        }
        // modify("VAT Base Amount")
        // {
        //     //Editable = true;
        //     trigger OnBeforeValidate()
        //     var
        //         myInt: Integer;
        //     begin
        //     end;
        // }
    }


    var
        myInt: Integer;
}