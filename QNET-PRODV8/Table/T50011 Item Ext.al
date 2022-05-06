tableextension 50011 "Item ext." extends Item
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Description 3"; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50000; "Sync BOM Components"; Enum " PO Integration Status")
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "Sync BOM Components" = "Sync BOM Components"::Synced then
                    Error('You cannot change Integration Status');
            end;
        }
    }


}