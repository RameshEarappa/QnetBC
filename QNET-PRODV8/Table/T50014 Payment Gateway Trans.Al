table 50014 "Payment Gateway Trans."
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
        field(3; Tx_Id; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(4; "Order No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Date; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(6; Time; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "PG Bank"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Currency; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Settlement Bank"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Settlement Currency "; code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(12; "Settlement Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(13; "Country Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(14; "Process Status"; Option)
        {
            OptionMembers = Open,Created,Processed,Error,Deleted;
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if ("Process Status" <> "Process Status"::Open) then
                    Error('You cannot change the Status');
            end;
        }

        field(15; "Process Remark"; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Currency Factor"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50103; "Virtual File Code"; code[50])
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