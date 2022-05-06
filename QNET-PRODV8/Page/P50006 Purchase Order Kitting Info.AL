page 50006 "Purchase Order Kitting Info"
{
    PageType = List;
    Caption = 'SOMS GRN ';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purchase Order Kitting Info";

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
                field("PO No."; rec."PO No.")
                {
                    ApplicationArea = All;
                }
                field("PO Line No."; rec."PO Line No.")
                {
                    ApplicationArea = All;
                }
                field("Posted BC Document No."; rec."Posted BC Document No.")
                {
                    ApplicationArea = all;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Putway DateTime"; Rec."Putway DateTime")
                {
                    ApplicationArea = all;
                }
                field("Entry Date/Time"; Rec."Entry Date/Time")
                {
                    ApplicationArea = all;
                }
                field("Queue Status"; Rec."Queue Status")
                {
                    ApplicationArea = all;
                }
                field("Retry Count"; Rec."Retry Count")
                {
                    ApplicationArea = all;
                }
                field("EarliestStart Date/Time"; Rec."EarliestStart Date/Time")
                {
                    ApplicationArea = all;
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ApplicationArea = all;
                }
                field("Error Message"; Rec."Error Message")
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

        }
    }
}