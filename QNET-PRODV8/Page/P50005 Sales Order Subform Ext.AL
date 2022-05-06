pageextension 50005 "Sales Order Subform ext" Extends "Sales Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("VAT Prod. Posting Group. 0612"; Rec."VAT Prod. Posting Group")
            {
                Caption = 'VAT Prod. Posting Group';
                ApplicationArea = all;
            }
            field("Gen. Prod. Posting Group 0612"; Rec."Gen. Prod. Posting Group")
            {
                ApplicationArea = all;
                Caption = 'Gen. Prod. Posting Group';
            }
            field("SOMS Status"; Rec."SOMS Status")
            {
                ApplicationArea = all;
                //Editable = false;
            }
            field(ShipNo; Rec."SOMS Ship No")
            {
                ApplicationArea = All;
                //Editable = false;

            }
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                //Editable = false;
            }
            field("SOMS Line No."; Rec."SOMS Line No.")
            {
                ApplicationArea = all;
                //Editable = false;
            }
            field(TCO; rec.TCO)
            {
                ApplicationArea = all;
                Caption = 'TCO';
                //Editable = false;
            }
            field("Courier ID"; rec."Courier ID")
            {
                ApplicationArea = all;
                Caption = 'Courier ID';
                //Editable = false;
            }
            field(AWB; rec.AWB)
            {
                ApplicationArea = all;
                Caption = 'AWB';
                //Editable = false;
            }
            field(vatbaseamount; vatbaseamount)
            {
                ApplicationArea = all;
                Caption = 'VAT Base Amount.';
                trigger OnValidate()
                var
                    salesline: Record "Sales Line";
                begin
                    salesline.Reset();
                    salesline.SetRange("Document No.", Rec."Document No.");
                    salesline.SetRange("Line No.", Rec."Line No.");
                    if salesline.FindFirst() then begin
                        repeat
                            salesline.Validate("VAT Base Amount", vatbaseamount);
                            Salesline.Validate("VAT %");
                            salesline.Modify(true);
                        until salesline.Next() = 0;
                    end;
                end;
            }
        }
    }
    var
        vatbaseamount: Decimal;
}