page 50032 "SOMS Order Reconciliation"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Order Reconciliation";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Order No."; rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field(Amount; rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Available In BC"; Rec."Available In BC")
                {
                    ApplicationArea = All;
                }
                field("Posted Invoice"; rec."Posted Invoice")
                {
                    ApplicationArea = All;
                }
                field("Posted Invoice Amount"; Rec."Posted Invoice Amount")
                {
                    ApplicationArea = All;
                }
                field("Posted Return"; Rec."Posted Return")
                {
                    ApplicationArea = All;
                }
                field("Posted Return Amount"; Rec."Posted Return Amount")
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
            action(ImportIRDetail)
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Import Excel Sheet';
                Image = Import;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(50005, false, true);
                    CurrPage.Update();
                end;
            }
            action("Get Detail's")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = GetEntries;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    GetPostedEntries;
                    CurrPage.Update();
                end;
            }
        }
    }
    local procedure GetPostedEntries()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedCreditMemo: Record "Sales Cr.Memo Header";
        StagingSalesOrder: Record "Sales Order Staging";
        postedinvno: Text[100];
        PostedInvAmt: Decimal;
        CMNo: Text[100];
        CMAmt: Decimal;
    begin
        repeat
            Clear(PostedInvAmt);
            Clear(postedinvno);
            Clear(CMNo);
            Clear(CMAmt);
            StagingSalesOrder.Reset();
            StagingSalesOrder.SetRange(OrderNo, Rec."Order No.");
            if StagingSalesOrder.FindFirst() then begin
                rec."Available In BC" := true;
                Rec.Modify();
            end;
            SalesInvoiceHeader.Reset();
            SalesInvoiceHeader.SetRange("SOMS Order No.", rec."Order No.");
            if SalesInvoiceHeader.FindFirst() then
                repeat
                    SalesInvoiceHeader.CalcFields("Amount Including VAT");
                    if postedinvno = '' then
                        Postedinvno := SalesInvoiceHeader."No."
                    else
                        postedinvno := postedinvno + ' ,' + SalesInvoiceHeader."No.";

                    PostedInvAmt += SalesInvoiceHeader."Amount Including VAT";
                until SalesInvoiceHeader.Next() = 0;

            PostedCreditMemo.Reset();
            PostedCreditMemo.SetRange("SOMS Order No.", Rec."Order No.");
            if PostedCreditMemo.FindFirst() then
                repeat
                    PostedCreditMemo.CalcFields("Amount Including VAT");
                    if CMNo = '' then
                        CMNo := PostedCreditMemo."No."
                    else
                        CMNo := CMNo + ' ,' + PostedCreditMemo."No.";
                    CMAmt += PostedCreditMemo."Amount Including VAT";
                until PostedCreditMemo.Next() = 0;
            rec."Posted Invoice" := postedinvno;
            Rec."Posted Invoice Amount" := PostedInvAmt;
            Rec."Posted Return" := CMNo;
            Rec."Posted Return Amount" := CMAmt;
            Rec.Modify();
        until rec.next = 0;
    end;
}