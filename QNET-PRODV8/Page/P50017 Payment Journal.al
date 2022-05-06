pageextension 50017 "Payment Journal Ext" extends "Payment Journal"
{
    layout
    {
        addafter("Document No.")
        {
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                //Editable = false;
            }
            field(CustomerPostingGroup; CustomerPostingGroup)
            {
                ApplicationArea = all;
                Caption = 'Customer Posting Group';
                TableRelation = "Customer Posting Group";
                trigger OnValidate()
                begin
                    Rec."Posting Group" := CustomerPostingGroup;
                    Rec.Modify();
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addbefore(Post)
        {
            action(CreateLinesFrom)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ImportExcel;
                trigger OnAction()
                var
                    ImportGenLine: XmlPort "Import Gen. Journal";
                begin
                    Clear(ImportGenLine);
                    ImportGenLine.SetJournalBatch(Rec."Journal Template Name", Rec."Journal Batch Name");
                    ImportGenLine.Import();

                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        CustomerPostingGroup := Rec."Posting Group";
    end;

    var
        CustomerPostingGroup: code[50];
}