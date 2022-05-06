table 50013 "Purchase Order Kitting Info"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "PO No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "PO Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Putway DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Entry Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "EarliestStart Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Queue Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Pending,Processed,Error,"Wait For ReAttempt";
        }
        field(10; "Error Message"; Text[259])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Processed Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Retry Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Posted BC Document No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}