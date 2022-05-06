tableextension 50009 "Bank Account Ledger Entry Ext" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(50101; "SOMS Order No."; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Payment Gateway"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Bank Account"."Payment Gateway" where("No." = field("Bank Account No."), "Payment Gateway" = const(true)));
            Editable = false;
        }
    }

    var
        myInt: Integer;
}