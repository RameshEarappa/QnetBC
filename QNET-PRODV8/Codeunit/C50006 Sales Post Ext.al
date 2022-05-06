/// Codeunit Gen. Jnl. Post Event Trigger (ID 50500).

codeunit 50006 "Gen. Jnl. Post Event Trigger"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnAfterCopyFromGenJnlLine', '', true, true)]
    local procedure "Bank Account Ledger Entry_OnAfterCopyFromGenJnlLine"
    (
        var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line"
    )
    begin
        BankAccountLedgerEntry."SOMS Order No." := GenJournalLine."SOMS Order No.";

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitBankAccLedgEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInitBankAccLedgEntry"
    (
        var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line"
    )
    begin
        BankAccountLedgerEntry."SOMS Order No." := GenJournalLine."SOMS Order No.";
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnBeforeInsertGlobalGLEntry"
    (
        var GlobalGLEntry: Record "G/L Entry";
        GenJournalLine: Record "Gen. Journal Line";
        GLRegister: Record "G/L Register"
    )
    begin
        GlobalGLEntry."SOMS Order No." := GenJournalLine."SOMS Order No.";
        GlobalGLEntry."Customer Posting Group" := GenJournalLine."Customer Posting Group";
        GlobalGLEntry."Virtual File Code" := GenJournalLine."Virtual File Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', true, true)]
    local procedure "Gen. Journal Line_OnAfterCopyGenJnlLineFromSalesHeader"
    (
        SalesHeader: Record "Sales Header";
        var GenJournalLine: Record "Gen. Journal Line"
    )
    begin
        GenJournalLine."SOMS Order No." := SalesHeader."SOMS Order No.";
        GenJournalLine."Customer Posting Group" := SalesHeader."Customer Posting Group";
        GenJournalLine."Virtual File Code" := SalesHeader."Virtual File Code";
    end;

    local procedure PostGenJournalLine()
    var
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", IntegrationSetup."SOMS Journal Templ. Name");
        GenJournalLine.SetRange("Journal Batch Name", IntegrationSetup."SOMS Journal Batch Name");
        if GenJournalLine.FindSet() then
            GenJnlPostBatch.Run(GenJournalLine);
    end;

    local procedure GetLastLineNo() LineNo: Integer;
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", IntegrationSetup."SOMS Journal Templ. Name");
        GenJournalLine.SetRange("Journal Batch Name", IntegrationSetup."SOMS Journal Batch Name");
        if GenJournalLine.FindLast() then
            exit(GenJournalLine."Line No." + 10000)
        else
            exit(10000)
    end;
    //20211130+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertVATOnAfterAssignVATEntryFields', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnInsertVATOnAfterAssignVATEntryFields"
    (
        GenJnlLine: Record "Gen. Journal Line";
        var VATEntry: Record "VAT Entry";
        CurrExchRate: Record "Currency Exchange Rate"
    )
    begin
        VATEntry."Control Sales" := GenJnlLine."Control Sales";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeRunGenJnlPostLine', '', true, true)]
    local procedure "Sales-Post_OnBeforeRunGenJnlPostLine"
    (
        var GenJnlLine: Record "Gen. Journal Line";
        SalesInvHeader: Record "Sales Invoice Header"
    )
    begin
        GenJnlLine."Control Sales" := SalesInvHeader."Control Sales";
    end;

    //20211130-

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesLine', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromSalesLine(SalesLine: Record "Sales Line"; var ItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine."SOMS Order No." := SalesLine."SOMS Order No.";
        ItemJnlLine."SOMS Ship No" := SalesLine."SOMS Ship No";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnAfterCopyTrackingFromItemJnlLine', '', false, false)]
    local procedure OnAfterCopyTrackingFromItemJnlLine(ItemJnlLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry."SOMS Order No." := ItemJnlLine."SOMS Order No.";
        ItemLedgerEntry."SOMS Ship No" := ItemJnlLine."SOMS Ship No";
    end;

    var
        Item: Record Item;
        IntegrationSetup: Record "Integration Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        SalesInvLine1: Record "Sales Invoice Line";
        TempSalesInvLine: Record "Sales Invoice Line" temporary;
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
}