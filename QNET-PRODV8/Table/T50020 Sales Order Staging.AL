table 50020 "Sales Order Staging"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; InfoType; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(4; OrderNo; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(5; ITEMNO; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Receipt Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Receipt Date (IST Time)"; DateTime)
        {
            DataClassification = ToBeClassified;

        }
        field(6; Brand; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(7; comboProductCode; Code[20])
        {
            DataClassification = ToBeClassified;

        }

        field(8; productCode; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }
        field(9; productName; Text[64])
        {
            DataClassification = ToBeClassified;
        }

        field(10; SOMSCreatedDate; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(11; RefID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(12; OrderType; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; TRCTNO; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; ORDER_REASON; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; TCO; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(16; TRCTDATE; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(17; ORDERDATE; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; REF_DOC; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(19; ReceiptNo; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(20; CURRENCY; code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(21; PaymentMethod; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(22; OCURRENCY; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(23; PICKUP_D2D; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(24; ATTRIBUTE_CODE; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(25; CG3; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(26; CG4; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(27; CG5; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(28; PLANT; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(29; SLOC; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(30; QTY; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(31; UOM; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(32; SHIPNO; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(33; REF_SHIPNO; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(34; COND_TYPE; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(35; AMOUNT; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(36; OAMOUNT; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(37; COND_ITEMID; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(38; TCO_NAME; Code[150])
        {
            DataClassification = ToBeClassified;
        }
        field(39; address1; Code[150])
        {
            DataClassification = ToBeClassified;
        }
        field(40; address2; Code[150])
        {
            DataClassification = ToBeClassified;
        }
        field(41; LOCATION; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(42; SHIP_CITY; code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(43; SHIP_STATE; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(44; SHIP_ZIPCODE; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(45; SAP_COUNTRYKEY; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(46; TELNO; code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(47; EMAIL; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(48; "EarliestStart Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Queue Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Pending,Processed,Error,"Wait For ReAttempt";
        }
        field(50; "Error Message"; Text[259])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Processed Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Retry Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(53; ID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Order Status"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(57; storageLocation; Text[64])
        {
            DataClassification = ToBeClassified;
        }
        field(58; Year; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(59; Week; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(60; statusId; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(61; statusDesc; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(62; Remarks; Text[1024])
        {
            DataClassification = ToBeClassified;
        }
        field(63; ShipFee; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(64; CountryCode; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(65; ContactNo_Home; Text[32])
        {
            DataClassification = ToBeClassified;
        }
        field(66; ContactNo_Mobile; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(67; awb; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(68; CourierID; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(69; "Process Remarks"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(70; quantity; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(71; "Import from Excel"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(72; "Entry Date/Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }

        field(73; "BC Document No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(74; "Posted BC Document No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(75; "Lost IN Transit"; boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(76; "GST Rate (%)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77; "GST Value"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(78; "Total MRP"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(79; "Pay Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(80; HSN; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(81; "IRID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(82; "IR Name"; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(83; "Virtual File Code"; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(84; "Order Date"; date)
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