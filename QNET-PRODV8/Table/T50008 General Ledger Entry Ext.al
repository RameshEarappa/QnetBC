tableextension 50008 "General Ledger Entry Ext" extends "G/L Entry"
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
    }

    var
        myInt: Integer;
}