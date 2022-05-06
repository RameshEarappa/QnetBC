/// <summary>
/// Codeunit Process Staging Activitie (ID 60100).
/// </summary>
codeunit 50007 "Process Payment Gatway Trans."
{
    TableNo = "Payment Gateway Trans.";
    trigger OnRun()
    begin
        TempStagingGenjournal_g.TransferFields(Rec);
        TempStagingGenjournal_g.Insert();

        IntegrationSetup.Get();
        IntegrationSetup.TestField("Retail Customer No.");
        IntegrationSetup.TestField("SOMS Journal Templ. Name");
        IntegrationSetup.TestField("SOMS Journal Batch Name");

        SetJournalBatch(IntegrationSetup."SOMS Journal Templ. Name", IntegrationSetup."SOMS Journal Batch Name");
        InsertGenJournalLine();
        StagingGenjournal_g.Get(TempStagingGenjournal_g."Entry No.");
        StagingGenjournal_g."Process Status" := StagingGenjournal_g."Process Status"::Created;
        StagingGenjournal_g.Modify();
        TempStagingGenjournal_g.DeleteAll();
        Commit();
    end;

    /// <summary>
    /// ProcessStagingGenJournal. 
    /// </summary>
    procedure InsertGenJournalLine()
    var
        Lcyamt: Decimal;
        LcyAmt1: Decimal;
        StagingSalesOrder: record "Sales Order Staging";
    begin
        /* IT-RK
        //customer-1
        GenJournalLine_g.Init();
        GenJournalLine_g."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJournalLine_g."Journal Batch Name" := GenJnlBatch.Name;
        GenJournalLine_g."Line No." := FindLineNo;
        if TempStagingGenjournal_g.Amount > 0 then
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Payment
        else
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Refund;
        GenJournalLine_g."Document No." := TempStagingGenjournal_g.Tx_Id;
        GenJournalLine_g."Posting Date" := TempStagingGenjournal_g.Date;
        GenJournalLine_g.validate("Account Type", GenJournalLine_g."Account Type"::Customer);
        GenJournalLine_g.validate("Account No.", IntegrationSetup."Retail Customer No.");
        GenJournalLine_g."SOMS Order No." := TempStagingGenjournal_g."Order No.";
        if GenJournalLine_g."SOMS Order No." <> '' then begin
            StagingSalesOrder.Reset();
            StagingSalesOrder.SetRange(OrderNo, GenJournalLine_g."SOMS Order No.");
            StagingSalesOrder.SetFilter(PaymentMethod, '<>%1', '');
            if StagingSalesOrder.FindFirst() then begin
                GenJournalLine_g.Validate("Posting Group", StagingSalesOrder.PaymentMethod);
            end;
        end;
        if TempStagingGenjournal_g.Currency <> '' then
            GenJournalLine_g.validate("Currency Code", TempStagingGenjournal_g.Currency);
        GenJournalLine_g.Validate(Amount, TempStagingGenjournal_g.Amount * -1);
        if TempStagingGenjournal_g."Country Code" <> '' then
            GenJournalLine_g.Validate("Shortcut Dimension 1 Code", TempStagingGenjournal_g."Country Code");
        GenJournalLine_g."Virtual File Code" := TempStagingGenjournal_g."Virtual File Code";
        GenJournalLine_g.Insert;

        //Customer Bank Payment Line-2
        GenJournalLine_g.Init();
        GenJournalLine_g."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJournalLine_g."Journal Batch Name" := GenJnlBatch.Name;
        GenJournalLine_g."Line No." := FindLineNo;
        if TempStagingGenjournal_g.Amount > 0 then
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Payment
        else
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Refund;
        GenJournalLine_g."Document No." := TempStagingGenjournal_g.Tx_Id;
        GenJournalLine_g."Posting Date" := TempStagingGenjournal_g.Date;
        GenJournalLine_g.validate("Account Type", GenJournalLine_g."Account Type"::"Bank Account");
        GenJournalLine_g.validate("Account No.", TempStagingGenjournal_g."PG Bank");
        GenJournalLine_g."SOMS Order No." := TempStagingGenjournal_g."Order No.";
        if TempStagingGenjournal_g.Currency <> '' then
            GenJournalLine_g.validate("Currency Code", TempStagingGenjournal_g.Currency);
        GenJournalLine_g.Validate(Amount, TempStagingGenjournal_g.Amount);
        if TempStagingGenjournal_g."Country Code" <> '' then
            GenJournalLine_g.Validate("Shortcut Dimension 1 Code", TempStagingGenjournal_g."Country Code");
        GenJournalLine_g."Virtual File Code" := TempStagingGenjournal_g."Virtual File Code";
        GenJournalLine_g.Insert;
*/
        // Settlment Payment Line-3
        GenJournalLine_g.Init();
        GenJournalLine_g."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJournalLine_g."Journal Batch Name" := GenJnlBatch.Name;
        GenJournalLine_g."Line No." := FindLineNo;
        if TempStagingGenjournal_g.Amount > 0 then
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Payment
        else
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Refund;
        GenJournalLine_g."Document No." := TempStagingGenjournal_g.Tx_Id;
        GenJournalLine_g."Posting Date" := TempStagingGenjournal_g.Date;
        GenJournalLine_g.validate("Account Type", GenJournalLine_g."Account Type"::"Bank Account");
        GenJournalLine_g.validate("Account No.", TempStagingGenjournal_g."PG Bank");
        GenJournalLine_g."SOMS Order No." := TempStagingGenjournal_g."Order No.";
        if TempStagingGenjournal_g.Currency <> '' then
            GenJournalLine_g.validate("Currency Code", TempStagingGenjournal_g.Currency);
        GenJournalLine_g.validate(Amount, TempStagingGenjournal_g.Amount * -1);
        Lcyamt := 0;
        Lcyamt := GenJournalLine_g."Amount (LCY)";
        if TempStagingGenjournal_g."Country Code" <> '' then
            GenJournalLine_g.Validate("Shortcut Dimension 1 Code", TempStagingGenjournal_g."Country Code");
        GenJournalLine_g."Virtual File Code" := TempStagingGenjournal_g."Virtual File Code";
        GenJournalLine_g.Insert;

        // local cureency payment line-4
        GenJournalLine_g.Init();
        GenJournalLine_g."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJournalLine_g."Journal Batch Name" := GenJnlBatch.Name;
        GenJournalLine_g."Line No." := FindLineNo;
        if TempStagingGenjournal_g.Amount > 0 then
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Payment
        else
            GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Refund;
        GenJournalLine_g."Document No." := TempStagingGenjournal_g.Tx_Id;
        GenJournalLine_g."Posting Date" := TempStagingGenjournal_g.Date;
        GenJournalLine_g.validate("Account Type", GenJournalLine_g."Account Type"::"Bank Account");
        GenJournalLine_g.validate("Account No.", TempStagingGenjournal_g."Settlement Bank");
        GenJournalLine_g."SOMS Order No." := TempStagingGenjournal_g."Order No.";
        if TempStagingGenjournal_g."Settlement Currency " <> '' then begin
            GenJournalLine_g.validate("Currency Code", TempStagingGenjournal_g."Settlement Currency ");
            //GenJournalLine_g.Validate("Currency Factor", TempStagingGenjournal_g."Currency Factor");
        end;
        GenJournalLine_g.Validate(Amount, TempStagingGenjournal_g."Settlement Amount");
        LcyAmt1 := 0;
        LcyAmt1 := GenJournalLine_g."Amount (LCY)";
        if TempStagingGenjournal_g."Country Code" <> '' then
            GenJournalLine_g.Validate("Shortcut Dimension 1 Code", TempStagingGenjournal_g."Country Code");
        GenJournalLine_g."Virtual File Code" := TempStagingGenjournal_g."Virtual File Code";
        GenJournalLine_g.Insert;

        // Line 5 for currency-5
        if Lcyamt <> LcyAmt1 then begin
            GenJournalLine_g.Init();
            GenJournalLine_g."Journal Template Name" := GenJnlBatch."Journal Template Name";
            GenJournalLine_g."Journal Batch Name" := GenJnlBatch.Name;
            GenJournalLine_g."Line No." := FindLineNo;
            if TempStagingGenjournal_g.Amount > 0 then
                GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Payment
            else
                GenJournalLine_g."Document Type" := GenJournalLine_g."Document Type"::Refund;
            GenJournalLine_g."Document No." := TempStagingGenjournal_g.Tx_Id;
            GenJournalLine_g."Posting Date" := TempStagingGenjournal_g.Date;
            GenJournalLine_g.validate("Account Type", GenJournalLine_g."Account Type"::"G/L Account");
            GenJournalLine_g.validate("Account No.", '671500');
            GenJournalLine_g."SOMS Order No." := TempStagingGenjournal_g."Order No.";
            GenJournalLine_g.Validate(Amount, (Lcyamt + LcyAmt1) * -1);
            if TempStagingGenjournal_g."Country Code" <> '' then
                GenJournalLine_g.Validate("Shortcut Dimension 1 Code", TempStagingGenjournal_g."Country Code");
            GenJournalLine_g."Virtual File Code" := TempStagingGenjournal_g."Virtual File Code";
            GenJournalLine_g.Insert;
        end;
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
    procedure SetJournalBatch(JournalTemplateName_p: code[50]; JournalBatchName_p: Code[50])
    begin
        GenJnlBatch.Get(JournalTemplateName_p, JournalBatchName_p);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterCode', '', true, true)]
    local procedure "Gen. Jnl.-Post Batch_OnAfterCode"
    (
        var GenJournalLine: Record "Gen. Journal Line";
        PreviewMode: Boolean
    )
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        if CompanyInfo.Name <> 'QNET MIDDLE EAST GENERAL TRADING LLC' then begin
            repeat
                if not PreviewMode then begin
                    StagingGenjournal_g.Reset();
                    StagingGenjournal_g.SetRange("Process Status", StagingGenjournal_g."Process Status"::Created);
                    StagingGenjournal_g.modifyall("Process Status", StagingGenjournal_g."Process Status"::Processed);
                end;
            until GenJournalLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnBeforeInsertGlobalGLEntryo"
    (
        var GlobalGLEntry: Record "G/L Entry";
        GenJournalLine: Record "Gen. Journal Line";
        GLRegister: Record "G/L Register"
    )
    begin
        GlobalGLEntry."SOMS Order No." := GenJournalLine."SOMS Order No.";
    end;


    var
        TempStagingGenjournal_g: Record "Payment Gateway Trans." temporary;
        StagingGenjournal_g: Record "Payment Gateway Trans.";
        StagingGenjournal_g2: Record "Payment Gateway Trans.";
        GenJournalLine_g: Record "Gen. Journal Line";
        GenJournalLine_g2: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        GenJnlBatch: Record "Gen. Journal Batch";
        FindDocGenJournalLine_g: Record "Gen. Journal Line";
        DocumentNo: code[20];
        LineNo: Integer;
        IntegrationSetup: Record "Integration Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";

}