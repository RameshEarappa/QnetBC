xmlport 50002 "Payment GateWay Trans"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = UTF8;
    UseRequestPage = false;
    schema
    {
        textelement(Root)
        {
            tableelement("Transaction_Report"; "Payment Gateway Trans.")
            {
                AutoSave = false;

                fieldelement(Tx_Id; Transaction_Report.Tx_Id) { }
                fieldelement("Order_No."; Transaction_Report."Order No.") { }
                fieldelement(Date1; Transaction_Report.Date) { }
                fieldelement(Time1; Transaction_Report.Time) { }
                fieldelement(Pg_bank; Transaction_Report."PG Bank") { }
                fieldelement(Currency; Transaction_Report.Currency) { }
                fieldelement(Amount; Transaction_Report.Amount) { }
                fieldelement(SettlementBankac; Transaction_Report."Settlement Bank") { }
                fieldelement(SettlementCurrency; Transaction_Report."Settlement Currency ") { }
                fieldelement(SettlementAmt; Transaction_Report."Settlement Amount") { }
                // fieldelement(CurrencyFactor; Transaction_Report."Currency Factor") { }
                fieldelement(Country; Transaction_Report."Country Code") { }
                trigger OnAfterInsertRecord()
                begin
                    InsertTransactionReport(Transaction_Report)
                end;
            }
        }
    }
    trigger OnInitXmlPort()
    begin
        recordcount := 0;
    end;

    local procedure InsertTransactionReport(var TempTransactionReport: Record "Payment Gateway Trans." temporary)
    var
        TransactionReport: record "Payment Gateway Trans.";
        TransactionReport2: record "Payment Gateway Trans.";
        EntryNo: Integer;

    begin
        TransactionReport.Reset();
        if TransactionReport.FindLast() then
            EntryNo := TransactionReport."Entry No." + 1
        else
            EntryNo := 1;
        TransactionReport.Init();
        TransactionReport.TransferFields(TempTransactionReport);
        TransactionReport."Entry No." := EntryNo;
        TransactionReport."Entry Date/Time" := CurrentDateTime;
        TransactionReport."Virtual File Code" := 'P-' + format(Today, 8, '<Year4><Month,2><Day,2>');
        TransactionReport.Insert();
    end;

    var
        recordcount: Integer;

}