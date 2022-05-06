pageextension 50016 "General Journal Ext" extends "General Journal"
{
    layout
    {
        addafter("Document No.")
        {
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                Editable = true;
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
}