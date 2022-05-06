table 50012 "Staging Assembly Order"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Entry No."; integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Entry Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "BC Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "FG Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Quantity; decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Assembly Item No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Assemble Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(10; "Queue Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Pending,Processed,Error,"Wait For ReAttempt";
        }
        field(11; "Error Message"; Text[259])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "EarliestStart Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Processed Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Retry Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Order Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,Created,Posted;
        }
        field(16; "Posted BC No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; "Entry No.")
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