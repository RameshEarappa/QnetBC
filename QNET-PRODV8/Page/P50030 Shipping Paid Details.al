page 50030 "Shipping Paid Detail's"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Shipping Paid Detail's";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                }
                field("SOMS Order No."; Rec."SOMS Order No.")
                {
                    Visible = false;
                    ApplicationArea = All;

                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;

                }
                field("AWB No."; Rec."AWB No.")
                {
                    ApplicationArea = All;
                }
                field("Courier ID"; Rec."Courier ID")
                {
                    ApplicationArea = All;
                }
                field(Shipper; Rec.Shipper)
                {
                    ApplicationArea = All;
                }
                field(Consignee; Rec.Consignee)
                {
                    ApplicationArea = All;
                }
                field(Origin; Rec.Origin)
                {
                    ApplicationArea = All;
                }
                field(Dest; Rec.Dest)
                {
                    ApplicationArea = All;
                }
                field(Prod; Rec.Prod)
                {
                    ApplicationArea = All;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                }
                field(Duty; Rec.Duty)
                {
                    ApplicationArea = All;
                }
                field("VAT @5%"; Rec."VAT @5%")
                {
                    ApplicationArea = All;
                }
                field("Shipping Fee Paid"; Rec."Shipping Fee Paid")
                {
                    ApplicationArea = All;

                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ShippingFeeDetail)
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Print';
                Image = Print;
                ApplicationArea = All;
                RunObject = report "Shipping Fee Detail's";

            }
            action(ImportShippingFeeDetail)
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = ' Import Excel Sheet';
                Image = Import;
                ApplicationArea = All;
                // RunObject = xmlport "Shipping Paid Detail's";
                trigger OnAction()
                begin
                    Xmlport.Run(50003, false, true);
                    CurrPage.Update();
                end;
            }

        }
    }
}