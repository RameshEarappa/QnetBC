tableextension 50000 "Purchase Header EXt" extends "Purchase Header"
{
    fields
    {
        field(50000; "Sync with SOMS"; Enum " PO Integration Status")
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if "Sync with SOMS" = "Sync with SOMS"::Synced then
                    Error('You cannot change Integration Status');
                TestField("Buy-from Vendor No.");
                TestField("Buy-from Vendor Name");
                TestField("Buy-from Address");
                TestField("Buy-from Address 2");
                TestField("Buy-from City");
                TestField("Buy-from Country/Region Code");
                TestField("Buy-from Post Code");
            end;
        }


    }

    var
        myInt: Integer;
}