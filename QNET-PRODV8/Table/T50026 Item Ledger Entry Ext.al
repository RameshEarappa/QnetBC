tableextension 50026 "Item Ledger Entry Extension" extends "Item Ledger Entry"
{
    fields
    {
        field(50000; "SOMS Order No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "SOMS Ship No"; code[50])
        {
            DataClassification = ToBeClassified;
        }


    }

    var
        myInt: Integer;
}