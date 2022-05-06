pageextension 50000 Sales_Order extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("VAT Bus. Posting Group."; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = all;
            }
            field(Integrated_order; Rec.Integrated_order)
            {
                ApplicationArea = all;
                Caption = 'Integrated_order';
                Editable = false;
            }
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                //Editable = false;
            }
            field("Virtual Sales"; Rec."Virtual Sales")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field(IRID; Rec.IRID)
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Receipt No."; Rec."Receipt No.")
            {
                ApplicationArea = all;
                //Editable = false;
            }
            //15.04.2022 committed based on the requriment
            // field("Customer Posting Group"; Rec."Customer Posting Group")
            // {
            //     ApplicationArea = all;

            // }
            field(CustomerPostingGroup; CustomerPostingGroup)
            {
                ApplicationArea = all;
                Caption = 'Customer Posting Group-1';
                TableRelation = "Customer Posting Group";
                trigger OnValidate()
                begin
                    Rec."Customer Posting Group" := CustomerPostingGroup;
                    Rec.Modify();
                end;
            }
        }

    }

    actions
    {
        addafter(Post)
        {
            action(GetUsersFromAPI)
            {
                ApplicationArea = All;
                Caption = 'Integrate Sales Order';

                trigger OnAction();
                var
                    apiCodeunit: Codeunit "Invoke SOMS API";
                    response: Text;
                    errorMsg: Text;
                    apiResponseHandler: Codeunit "SOMS API Response";
                begin
                    response := apiCodeunit.GetSalesOrderInfo(errorMsg);
                    if errorMsg <> '' then
                        Error(errorMsg)
                    else
                        Message('Your API Call Response: \' + response);

                    if response <> '' then begin
                        if apiResponseHandler.SalesOrderInfoFromResponse(response) then
                            Message('Records inserted Successfully!');
                    end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        CustomerPostingGroup := Rec."Customer Posting Group";
    end;

    var
        vatbaseamount: Decimal;
        CustomerPostingGroup: code[50];
}