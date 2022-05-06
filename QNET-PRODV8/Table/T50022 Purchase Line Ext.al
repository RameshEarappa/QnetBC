tableextension 50022 "Purchase Line ext" extends "Purchase Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Integration Status"; Enum " PO Integration Status")
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "Integration Status" = "Integration Status"::Synced then
                    Error('You cannot change Integration Status');
            end;
        }
    }

    var
        myInt: Integer;
}