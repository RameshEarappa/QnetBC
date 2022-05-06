table 50024 "IR Update"
{
    DataClassification = ToBeClassified;
    Caption = 'IR Update';
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
        field(3; "IR Name"; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; IRID; code[50])
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