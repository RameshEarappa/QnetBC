/// <summary>
/// XmlPort Import Purchase Invoice (ID 60101).
/// </summary>
xmlport 50001 "Import Gen. Journal"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = Legacy;
    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                UseTemporary = true;
                textelement(Posting_Date) { }
                textelement(Document_No) { }
                textelement(Account_Type) { }
                textelement(Account_No) { }
                textelement(Description) { }
                textelement(Currency_Code) { }
                textelement(Amount) { }
                textelement(ExternalDocumentNo) { }
                trigger OnPreXmlItem()
                begin

                end;

                trigger OnAfterInsertRecord()
                begin
                    if RecordCount <> 0 then begin
                        InsertGenJournalLine();
                    end;
                    RecordCount += 1;
                end;

                trigger OnAfterInitRecord()
                begin
                    Int1 += 1;
                    Integer.Number := Int1;
                end;

            }

        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    /*field(Name; SourceExpression)
                    {

                    }
                    */
                }
            }
        }

        actions
        {

        }
    }

    trigger OnPreXmlPort()
    begin

    end;

    /// <summary>
    /// ProcessStagingGenJournal. 
    /// </summary>
    procedure InsertGenJournalLine()
    begin
        FindGenJournalDocNo(DocumentNo);
        GenJournalLine_g.Init();
        GenJournalLine_g."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJournalLine_g."Journal Batch Name" := GenJnlBatch.Name;
        GenJournalLine_g."Line No." := FindLineNo;
        if DocumentNo <> '' then
            GenJournalLine_g."Document No." := DocumentNo
        else
            if GenJnlBatch."No. Series" <> '' then
                GenJournalLine_g."Document No." := NoSeriesManagement.GetNextNo(GenJnlBatch."No. Series", Today, true);
        GenJournalLine_g."Posting Date" := Today;
        Evaluate(GenJournalLine_g."Account Type", Account_Type);
        GenJournalLine_g.validate("Account Type");
        GenJournalLine_g.validate("Account No.", Account_No);
        GenJournalLine_g.Description := Description;
        GenJournalLine_g.validate("Currency Code", Currency_Code);
        Evaluate(GenJournalLine_g.Amount, Amount);
        GenJournalLine_g.Validate(Amount);
        GenJournalLine_g.Insert;
    end;

    local procedure FindGenJournalDocNo(Var DoumentNo_p: Code[50])
    begin
        Clear(DocumentNo);
        GenJournalLine_g2.reset;
        GenJournalLine_g2.SetCurrentKey("Journal Template Name", "Journal Batch Name");
        GenJournalLine_g2.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJournalLine_g2.SetRange("Journal Batch Name", GenJnlBatch.Name);
        if GenJournalLine_g2.FindFirst() then
            DocumentNo := GenJournalLine_g2."Document No.";

    end;

    local procedure FindLineNo() LineNo: Integer;
    begin
        GenJournalLine_g2.reset;
        GenJournalLine_g2.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJournalLine_g2.SetRange("Journal Batch Name", GenJnlBatch.Name);
        if GenJournalLine_g2.FindLast() then
            exit(GenJournalLine_g2."Line No." + 10000)
        else
            exit(10000);
    end;

    /// <summary>
    /// SetJournalBatch.
    /// </summary>
    /// <param name="JournalTemplateName_p">VAR code[50].</param>
    /// <param name="JournalBatchName_p">VAR Code[50].</param>
    procedure SetJournalBatch(var JournalTemplateName_p: code[50]; var JournalBatchName_p: Code[50])
    begin
        GenJnlBatch.Get(JournalTemplateName_p, JournalBatchName_p);
    end;


    var
        Int1: Integer;
        GenJournalLine_g: Record "Gen. Journal Line";
        GenJournalLine_g2: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GenJnlBatch: Record "Gen. Journal Batch";
        FindDocGenJournalLine_g: Record "Gen. Journal Line";
        DocumentNo: code[20];
        LineNo: Integer;
        RecordCount: Integer;
        TransactionNo: Integer;
}