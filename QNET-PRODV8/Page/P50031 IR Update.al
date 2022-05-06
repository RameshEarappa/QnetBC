page 50031 "IR Update"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IR Update";
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No"; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("SOMS Order No."; Rec."SOMS Order No.")
                {
                    ApplicationArea = All;

                }
                field("IR Name"; Rec."IR Name")
                {
                    ApplicationArea = All;

                }
                field(IRID; Rec.IRID)
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
                Caption = ' Import Excel Sheet';
                Image = Import;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(50004, false, true);
                    CurrPage.Update();
                end;
            }
        }
    }
}