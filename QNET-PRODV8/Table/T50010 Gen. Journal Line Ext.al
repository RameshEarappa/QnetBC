tableextension 50010 "Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(50101; "SOMS Order No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Customer Posting Group"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50103; "Virtual File Code"; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50104; "SOMS Create DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(50105; "Control Sales"; boolean)
        {
            DataClassification = ToBeClassified;
        }

    }

    var
        myInt: Integer;
}