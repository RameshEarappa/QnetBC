codeunit 50008 "Purchase Post Job Batch"
{
    Permissions =
     TableData 17 = rimd,
     tabledata "Dimension Set Entry" = rimd,
     tabledata "Dimension Value" = rimd;

    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        CASE Rec."Parameter String" OF
            'GetGRNInfo':
                InvokeSOMSAPI.GetGRNInfo();
            'PostStorePO':
                InvokeSOMSAPI.StoreNewPO();
            'ICQueueOrderPost':
                ICQueueOrderPost(Rec);
            'Post_POReceipt':
                PostPurchaseOrder(TempICQueueOrderPost);
            ELSE
                ERROR('Invalid Parameter String: %1', Rec."Parameter String");
        END;

    end;

    procedure SetStatusId(OrderNoP: code[20])
    begin
        OrderNo := OrderNoP;
    end;

    procedure ICQueueOrderPost(var JobQueueEntry: Record "Job Queue Entry")
    begin
        PurchaseOrderKittingInfo.RESET;
        PurchaseOrderKittingInfo.SETCURRENTKEY("Entry No.");
        PurchaseOrderKittingInfo.Ascending(true);
        PurchaseOrderKittingInfo.SETFILTER("Queue Status", '%1|%2',
          PurchaseOrderKittingInfo."Queue Status"::Pending, PurchaseOrderKittingInfo."Queue Status"::"Wait For ReAttempt");
        PurchaseOrderKittingInfo.SETFILTER("EarliestStart Date/Time", '<=%1', CURRENTDATETIME);
        PurchaseOrderKittingInfo.SETFILTER("Retry Count", '<=%1', JobQueueEntry."Maximum No. of Attempts to Run");
        if Orderno <> '' then
            PurchaseOrderKittingInfo.SetRange("PO No.", Orderno);
        IF PurchaseOrderKittingInfo.FINDFIRST THEN
            REPEAT
                TmpJobQueueEntry."Parameter String" := 'Post_POReceipt';
                JobQueueProcesses.SetIcQueueOrderPost(PurchaseOrderKittingInfo);
                IF NOT JobQueueProcesses.RUN(TmpJobQueueEntry) THEN BEGIN
                    PurchaseOrderKittingInfo2.RESET;
                    PurchaseOrderKittingInfo2.SETFILTER("Queue Status", '%1|%2',
                          PurchaseOrderKittingInfo2."Queue Status"::Pending, PurchaseOrderKittingInfo2."Queue Status"::"Wait For ReAttempt");
                    PurchaseOrderKittingInfo2.SETRANGE("PO No.", PurchaseOrderKittingInfo."PO No.");
                    IF PurchaseOrderKittingInfo2.FINDSET THEN
                        REPEAT
                            PurchaseOrderKittingInfo2."Retry Count" += 1;
                            PurchaseOrderKittingInfo2."EarliestStart Date/Time" := CURRENTDATETIME + (5 * 60 * 1000);
                            IF PurchaseOrderKittingInfo2."Retry Count" >= JobQueueEntry."Maximum No. of Attempts to Run" THEN
                                PurchaseOrderKittingInfo2."Queue Status" := PurchaseOrderKittingInfo2."Queue Status"::Error;
                            PurchaseOrderKittingInfo2."Error Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
                            PurchaseOrderKittingInfo2."Processed Date" := CURRENTDATETIME;
                            PurchaseOrderKittingInfo2.MODIFY;
                        UNTIL PurchaseOrderKittingInfo2.NEXT = 0;
                END;
                COMMIT;
            UNTIL PurchaseOrderKittingInfo.NEXT = 0;
    end;

    procedure SetIcQueueOrderPost(VAR TempRecord: Record "Purchase Order Kitting Info")
    begin
        TempICQueueOrderPost := TempRecord;
    end;

    local procedure PostPurchaseOrder(VAR PurchaseOrderKittingInfo_temp: Record "Purchase Order Kitting Info" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseOrderKittingInfo_l: Record "Purchase Order Kitting Info";
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", PurchaseOrderKittingInfo_temp."PO No.");
        if PurchaseHeader.FindFirst() then begin
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            if PurchaseLine.FindFirst() then begin
                repeat
                    PurchaseLine."Qty. to Receive" := 0;
                    PurchaseLine."Qty. to Invoice" := 0;
                    PurchaseLine.Modify;
                until PurchaseLine.Next() = 0;
            end;
            PurchaseOrderKittingInfo_l.Reset();
            PurchaseOrderKittingInfo_l.SetRange("PO No.", PurchaseOrderKittingInfo_temp."PO No.");
            PurchaseOrderKittingInfo_l.SetFilter("Queue Status", '<>%1', PurchaseOrderKittingInfo_temp."Queue Status"::Processed);
            if PurchaseOrderKittingInfo_l.FindFirst() then begin
                repeat
                    PurchaseLine.Reset();
                    PurchaseLine.SetRange("Document No.", PurchaseOrderKittingInfo_l."PO No.");
                    PurchaseLine.SetRange("Line No.", PurchaseOrderKittingInfo_l."PO Line No.");
                    PurchaseLine.FindFirst();
                    PurchaseLine."Qty. to Receive" := PurchaseOrderKittingInfo_l.Quantity;
                    PurchaseLine."Qty. to Invoice" := 0;
                    PurchaseLine.Modify;
                    PurchaseOrderKittingInfo_l."Queue Status" := PurchaseOrderKittingInfo_l."Queue Status"::Processed;
                    PurchaseOrderKittingInfo_l."Retry Count" := 0;
                    PurchaseOrderKittingInfo_l."Processed Date" := CurrentDateTime;
                    PurchaseOrderKittingInfo_l."Error Message" := '';
                    PurchaseOrderKittingInfo_l.Modify(true);
                until PurchaseOrderKittingInfo_l.Next() = 0;
            end;
            PurchaseHeader.Receive := true;
            PurchaseHeader.Invoice := false;
            PurchaseHeader.Modify(true);
            Commit();
            if CODEUNIT.Run(CODEUNIT::"Purch.-Post", PurchaseHeader) then
                Error(GetLastErrorText());
            UpdatepostedInvoiceNo(PurchaseOrderKittingInfo_temp."PO No.");
        end;
    end;


    local procedure UpdatepostedInvoiceNo(Var OrderNo: code[50])
    var
        PurchaseOrderKittingInfo_l: Record "Purchase Order Kitting Info";
        PostedPurchaseInvoice: Record "Purch. Rcpt. Line";
    begin
        PurchaseOrderKittingInfo_l.Reset();
        PurchaseOrderKittingInfo_l.SetRange("PO No.", OrderNo);
        PurchaseOrderKittingInfo_l.SetFilter("Queue Status", '%1', PurchaseOrderKittingInfo_l."Queue Status"::Processed);
        if PurchaseOrderKittingInfo_l.FindFirst() then begin
            repeat
                PostedPurchaseInvoice.Reset();
                PostedPurchaseInvoice.SetRange("Order No.", PurchaseOrderKittingInfo_l."PO No.");
                PostedPurchaseInvoice.SetRange("Order Line No.", PurchaseOrderKittingInfo_l."PO Line No.");
                if PostedPurchaseInvoice.FindLast() then begin
                    PurchaseOrderKittingInfo_l."Posted BC Document No." := PostedPurchaseInvoice."Document No.";
                    PurchaseOrderKittingInfo_l.Modify(true);
                end;
            until PurchaseOrderKittingInfo_l.Next() = 0;
        end;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PurchaseOrderKittingInfo: Record "Purchase Order Kitting Info";
        PurchaseOrderKittingInfo2: Record "Purchase Order Kitting Info";
        TempICQueueOrderPost: Record "Purchase Order Kitting Info";
        TmpJobQueueEntry: Record "Job Queue Entry";
        JobQueueProcesses: Codeunit "Purchase Post Job Batch";
        InvokeSOMSAPI: Codeunit "Invoke SOMS API";
        OrderNo: Code[50];


}