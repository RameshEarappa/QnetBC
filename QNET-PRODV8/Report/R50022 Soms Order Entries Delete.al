report 50022 "Posted Sales Entries Delete"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions = tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Cr.Memo Header" = RIMD,
    tabledata "G/L Entry" = rimd,
    tabledata "VAT Entry" = rimd,
    tabledata "Sales Invoice Line" = rimd,
    tabledata "Cust. Ledger Entry" = rimd,
    tabledata "Detailed Cust. Ledg. Entry" = rimd;
    dataset
    {
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Delete Posted Entries")
                {
                    field(SalesInvoiceNo; SalesInvoiceNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                    }
                }
            }
        }

        actions
        {

        }
        trigger OnOpenPage()
        begin
            SalesInvoiceNo := '';
        end;
    }
    trigger OnPostReport()
    begin
        if SalesInvoiceNo <> '' then begin
            SalesInvHeader.Reset();
            SalesInvHeader.SetRange("No.", SalesInvoiceNo);
            SalesInvHeader.DeleteAll();

            SalesInvoiceLine.Reset();
            SalesInvoiceLine.SetRange("Document No.", SalesInvoiceNo);
            SalesInvoiceLine.DeleteAll();

            GLEntry.Reset();
            GLEntry.SetRange("Document No.", SalesInvoiceNo);
            GLEntry.DeleteAll();

            VATEntry.Reset();
            VATEntry.SetRange("Document No.", SalesInvoiceNo);
            VATEntry.DeleteAll();

            CustLedgerEntry.Reset();
            CustLedgerEntry.SetRange("Document No.", SalesInvoiceNo);
            CustLedgerEntry.DeleteAll();

            DetailedCustLedgEntry.Reset();
            DetailedCustLedgEntry.SetRange("Document No.", SalesInvoiceNo);
            DetailedCustLedgEntry.DeleteAll();

        end;
    end;

    var
        SalesInvHeader: record "sales invoice header";
        postvirtualsales: Boolean;
        SCMH: record "Sales Cr.Memo Header";
        GLEntry: record "G/L Entry";
        VATEntry: record "VAT Entry";
        SalesInvoiceLine: record "Sales Invoice Line";
        CustLedgerEntry: record "Cust. Ledger Entry";
        DetailedCustLedgEntry: record "Detailed Cust. Ledg. Entry";
        SalesInvoiceNo: code[50];
}