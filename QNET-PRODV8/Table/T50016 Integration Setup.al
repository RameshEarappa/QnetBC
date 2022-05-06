table 50016 "Integration Setup"
{
    Caption = 'Integration Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(2; "Get Sales Order URL"; Text[250])
        {
            Caption = 'Get Sales Order URL';
            DataClassification = ToBeClassified;
        }

        field(5; "Get BOM Details URL"; Text[250])
        {
            Caption = 'Get BOM Details URL';
            DataClassification = ToBeClassified;
        }
        field(6; "Ship Fee GL"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(7; "Last Get Order  Datet/Time"; DateTime)
        {
            DataClassification = ToBeClassified;

        }

        field(8; "SOMS Journal Templ. Name"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template";
            Caption = 'Journal Template Name';
        }
        field(9; "SOMS Journal Batch Name"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("SOMS Journal Templ. Name"));
            Caption = 'Journal Batch Name';
        }
        field(10; "Retail Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;

        }
        field(11; "EV GL Acc."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(50106; "LOST In Transit Acc."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(12; "NR GL Acc."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(13; "Store New PO URL"; text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Token Url"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Encryption Key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "User Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Email Id"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Get GRN Info"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Start DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "End DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Get Assembly Order URL"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Get Assembly Start DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Get Assembly End DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "SOMS Pos. Journal Templ. Name"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template";
            Caption = 'SOMS Pos. Journal Templ. Name';
        }
        field(25; "SOMS Pos. Journal Batch Name"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("SOMS Pos. Journal Templ. Name"));
            Caption = 'SOMS Pos. Journal Batch Name';
        }
        field(26; "SOMS Neg. Journal Templ. Name"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template";
            Caption = 'SOMS Neg. Journal Templ. Name';
        }
        field(27; "SOMS Neg. Journal Batch Name"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("SOMS Neg. Journal Templ. Name"));
            Caption = 'SOMS Neg. Journal Batch Name';
        }
        field(28; "Last Post GV DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "QE Control Account"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(30; "QA Control Account"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(31; "CC Control Account"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(32; "Control Customer Posting Group"; code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Customer Posting Group";
        }
        field(33; "Control VAT Prod. Posting Grp"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(34; "Control Gen. Prod. Posting Grp"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(35; "Control Ship Fee GL"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }

    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
