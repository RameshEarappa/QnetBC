tableextension 50027 "Item Journal Line" extends "Item Journal Line"
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