page 50007 "Staging Assembly Order"
{
    PageType = List;
    Caption = 'Staging Assembly Order';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Staging Assembly Order";

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
                field("BC Order No."; Rec."BC Order No.")
                {
                    ApplicationArea = All;
                }
                field("Posted BC No."; Rec."Posted BC No.")
                {
                    ApplicationArea = all;
                }
                field("Order Status"; Rec."Order Status")
                {
                    ApplicationArea = all;
                }
                field("FG Item No."; Rec."FG Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Assembly Item No."; Rec."Assembly Item No.")
                {
                    ApplicationArea = all;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }

                field("Assemble Quantity"; rec."Assemble Quantity")
                {
                    ApplicationArea = all;
                    Visible = false;
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
    }
}