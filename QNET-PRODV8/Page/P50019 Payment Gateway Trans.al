page 50019 "Payment Gateway Trans"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Payment Gateway Trans.";
    Caption = 'Staging Payment Gateway Trans';

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
                field(Tx_Id; REC."Tx_Id")
                {
                    ApplicationArea = All;

                }
                field(Date; rec.Date)
                {
                    Caption = 'Reporting Date';
                    ApplicationArea = all;
                }
                field(Time; rec.Time)
                {
                    Caption = 'Reporting Time';
                    ApplicationArea = all;
                }
                field("Order No."; REC."Order No.")
                {
                    Caption = 'SOMS Order No.';
                    ApplicationArea = all;
                }
                field("PG Bank"; Rec."PG Bank")
                {
                    ApplicationArea = All;
                }
                field(Currency; REC.Currency)
                {
                    ApplicationArea = All;
                }
                field(Amount; REC.Amount)
                {
                    ApplicationArea = All;
                }
                field("Settlement Bank"; rec."Settlement Bank")
                {
                    ApplicationArea = All;
                }
                field("Settlement Currency "; rec."Settlement Currency ")
                {
                    ApplicationArea = All;
                }
                field("Settlement Amount"; rec."Settlement Amount")
                {
                    ApplicationArea = All;

                }
                field("Virtual File Code"; Rec."Virtual File Code")
                {
                    ApplicationArea = All;
                    Caption = 'File Code';

                }
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = all;
                    Caption = 'Process Status';
                }
                field("Process Remark"; Rec."Process Remark")
                {
                    ApplicationArea = all;

                }
                field("Entry Date/Time"; Rec."Entry Date/Time")
                {
                    ApplicationArea = all;
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
            action(Import)
            {
                Caption = 'Import';
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ApplicationArea = All;
                trigger OnAction();
                begin
                    Xmlport.Run(50002, false, true);
                end;
            }
            action(CreateLine)
            {
                Caption = 'Create Reco Line';
                Promoted = true;
                PromotedCategory = Process;
                Image = Process;
                ApplicationArea = All;
                trigger OnAction();
                var
                    StagingTransactionEntry: Record "Payment Gateway Trans.";
                begin
                    StagingTransactionEntry.Reset();
                    StagingTransactionEntry.setfilter("Process Status", '%1', StagingTransactionEntry."Process Status"::Open);
                    if StagingTransactionEntry.FindFirst() then
                        repeat
                            Codeunit.Run(50007, StagingTransactionEntry);
                        until StagingTransactionEntry.Next() = 0;
                end;
            }

        }
    }
}