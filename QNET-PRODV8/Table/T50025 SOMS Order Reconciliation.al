table 50025 "Order Reconciliation"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Order No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Available In BC"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Posted Invoice"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Posted Invoice Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Posted Return"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Posted Return Amount"; Decimal)
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