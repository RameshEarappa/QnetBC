table 50015 "Shipping Paid Detail's"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "SOMS Order No."; code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(4; "AWB No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Courier ID"; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Shipping Fee Paid"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Shipper; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Consignee; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; Origin; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(11; Dest; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(12; Prod; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Weight; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(14; Duty; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "VAT @5%"; Decimal)
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