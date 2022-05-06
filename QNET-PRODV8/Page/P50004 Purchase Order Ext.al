pageextension 50004 "Purchase Order Ext" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("VAT Bus. Posting Group."; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = all;
            }

            field("Sync with SOMS"; Rec."Sync with SOMS")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action(ServicePurchaseOrder)
            {
                ApplicationArea = All;
                Caption = '&Service Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Category10;
                ToolTip = 'Prepare to print the document. The report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader := Rec;
                    PurchaseHeader.SetRange("No.", Rec."No.");
                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                    if PurchaseHeader.FindFirst() then
                        Report.Run(50005, true, false, PurchaseHeader);
                end;
            }
        }
    }

    var
        myInt: Integer;
}