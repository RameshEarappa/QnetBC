codeunit 50009 "Assembly Order Post"
{
    Permissions =
     TableData 17 = rimd,
     tabledata "Dimension Set Entry" = rimd,
     tabledata "Dimension Value" = rimd;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        CASE Rec."Parameter String" OF
            'GetBomItem':
                InvokeSOMSAPI.GetBOMDetails();
            'GetAssemblyOrderLine':
                InvokeSOMSAPI.GetAssemblyOrderInfo();
            'ICQueueOrderPost':
                ICQueueOrderPost(Rec);
            'CreateOrder':
                CreateAssemblyOrder(TempICQueueOrderPost);
            'Post_Order':
                PostAssemblyOrder(TempICQueueOrderPost);
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

        StagingAssemblyOrder.RESET;
        StagingAssemblyOrder.SETCURRENTKEY("Entry No.");
        StagingAssemblyOrder.Ascending(true);
        StagingAssemblyOrder.SETFILTER("Queue Status", '%1|%2',
          StagingAssemblyOrder."Queue Status"::Pending, StagingAssemblyOrder."Queue Status"::"Wait For ReAttempt");
        StagingAssemblyOrder.SETFILTER("EarliestStart Date/Time", '<=%1', CURRENTDATETIME);
        StagingAssemblyOrder.SETFILTER("Retry Count", '<=%1', JobQueueEntry."Maximum No. of Attempts to Run");
        if Orderno <> '' then
            StagingAssemblyOrder.SetRange("Assembly Item No.", Orderno);
        IF StagingAssemblyOrder.FINDFIRST THEN
            REPEAT
                if StagingAssemblyOrder."Order Status" = StagingAssemblyOrder."Order Status"::Open then
                    TmpJobQueueEntry."Parameter String" := 'CreateOrder'
                else
                    TmpJobQueueEntry."Parameter String" := 'Post_Order';
                JobQueueProcesses.SetIcQueueOrderPost(StagingAssemblyOrder);
                IF NOT JobQueueProcesses.RUN(TmpJobQueueEntry) THEN BEGIN
                    StagingAssemblyOrder2.RESET;
                    StagingAssemblyOrder2.SETFILTER("Queue Status", '%1|%2',
                          StagingAssemblyOrder2."Queue Status"::Pending, StagingAssemblyOrder2."Queue Status"::"Wait For ReAttempt");
                    StagingAssemblyOrder2.SETRANGE("entry no.", StagingAssemblyOrder."Entry No.");
                    IF StagingAssemblyOrder2.FINDSET THEN
                        REPEAT
                            StagingAssemblyOrder2."Retry Count" += 1;
                            StagingAssemblyOrder2."EarliestStart Date/Time" := CURRENTDATETIME + (5 * 60 * 1000);
                            IF StagingAssemblyOrder2."Retry Count" >= JobQueueEntry."Maximum No. of Attempts to Run" THEN
                                StagingAssemblyOrder2."Queue Status" := StagingAssemblyOrder2."Queue Status"::Error;
                            StagingAssemblyOrder2."Error Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
                            StagingAssemblyOrder2."Processed Date" := CURRENTDATETIME;
                            StagingAssemblyOrder2.MODIFY;
                        UNTIL StagingAssemblyOrder2.NEXT = 0;
                END;
                COMMIT;
            UNTIL StagingAssemblyOrder.NEXT = 0;
    end;

    procedure SetIcQueueOrderPost(VAR TempRecord: Record "Staging Assembly Order")
    begin
        TempICQueueOrderPost := TempRecord;
    end;

    local procedure CreateAssemblyOrder(VAR StagingAssemblyOrder_temp: Record "Staging Assembly Order" temporary)
    var
        AssemblyLine: Record "Assembly Line";
        StagingAssemblyOrder_temp_l: Record "Staging Assembly Order";
        BomComponent: Record "BOM Component";
        Item: Record Item;
    begin
        BomComponent.Reset();
        BomComponent.SetRange("Parent Item No.", StagingAssemblyOrder_temp."Assembly Item No.");
        if not BomComponent.FindFirst() then begin
            if Item.Get(StagingAssemblyOrder_temp."Assembly Item No.") then begin
                Item."Sync BOM Components" := Item."Sync BOM Components"::"To be sync";
                item.Modify();
            end;
            if StagingAssemblyOrder_temp_l.Get(StagingAssemblyOrder_temp."Entry No.") then begin
                StagingAssemblyOrder_temp_l."EarliestStart Date/Time" := CurrentDateTime;
                StagingAssemblyOrder_temp_l.Modify();
            end;
            exit;
        end;
        AssemblyHeader.Reset();
        AssemblyHeader.SetRange("Item No.", StagingAssemblyOrder_temp."Assembly Item No.");
        if not AssemblyHeader.FindFirst() then
            AssemblyHeader_Insert(StagingAssemblyOrder_temp);

        StagingAssemblyOrder_temp_l.Reset();
        StagingAssemblyOrder_temp_l.SetRange("Assembly Item No.", StagingAssemblyOrder_temp."Assembly Item No.");
        StagingAssemblyOrder_temp_l.Setrange("Order Status", StagingAssemblyOrder_temp_l."Order Status"::Open);
        StagingAssemblyOrder_temp_l.SetFilter("Queue Status", '<>%1', StagingAssemblyOrder_temp_l."Queue Status"::Processed);
        if StagingAssemblyOrder_temp_l.FindFirst() then begin
            repeat
                AssemblyHeader.Validate(Quantity, AssemblyHeader.Quantity + StagingAssemblyOrder_temp_l.Quantity);
                AssemblyHeader.Modify();
                StagingAssemblyOrder_temp_l."Order Status" := StagingAssemblyOrder_temp_l."Order Status"::Created;
                StagingAssemblyOrder_temp_l."BC Order No." := AssemblyHeader."No.";
                StagingAssemblyOrder_temp_l."Retry Count" := 0;
                StagingAssemblyOrder_temp_l."Processed Date" := CurrentDateTime;
                StagingAssemblyOrder_temp_l."Error Message" := '';
                StagingAssemblyOrder_temp_l.Modify(true);
            until StagingAssemblyOrder_temp_l.Next() = 0;
        end;
    end;

    local procedure PostAssemblyOrder(VAR StagingAssemblyOrder_temp: Record "Staging Assembly Order" temporary)
    var
        AssemblyLine: Record "Assembly Line";
        StagingAssemblyOrder_temp_l: Record "Staging Assembly Order";
        Post: Codeunit "Assembly-Post";
    begin
        AssemblyHeader.Reset();
        AssemblyHeader.SetRange("Item No.", StagingAssemblyOrder_temp."Assembly Item No.");
        AssemblyHeader.FindFirst();

        StagingAssemblyOrder_temp_l.Reset();
        StagingAssemblyOrder_temp_l.SetRange("Assembly Item No.", StagingAssemblyOrder_temp."Assembly Item No.");
        StagingAssemblyOrder_temp_l.Setrange("Order Status", StagingAssemblyOrder_temp_l."Order Status"::Created);
        StagingAssemblyOrder_temp_l.SetFilter("Queue Status", '<>%1', StagingAssemblyOrder_temp_l."Queue Status"::Processed);
        if StagingAssemblyOrder_temp_l.FindFirst() then begin
            repeat
                StagingAssemblyOrder_temp_l."Order Status" := StagingAssemblyOrder_temp_l."Order Status"::Posted;
                StagingAssemblyOrder_temp_l."Queue Status" := StagingAssemblyOrder_temp_l."Queue Status"::Processed;
                StagingAssemblyOrder_temp_l."Retry Count" := 0;
                StagingAssemblyOrder_temp_l."Processed Date" := CurrentDateTime;
                StagingAssemblyOrder_temp_l."Error Message" := '';
                StagingAssemblyOrder_temp_l.Modify(true);
            until StagingAssemblyOrder_temp_l.Next() = 0;
            Clear(Post);
            ClearLastError();
            Post.Run(AssemblyHeader);
            UpdatepostedInvoiceNo(AssemblyHeader."No.");
        end;
    end;

    local procedure AssemblyHeader_Insert(VAR StagingAssemblyOrder_temp: Record "Staging Assembly Order" temporary)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        IntegrationSetup: Record "Integration Setup";
    begin
        with StagingAssemblyOrder_temp do begin
            AssemblyHeader.INIT;
            AssemblyHeader."Document Type" := AssemblyHeader."Document Type"::Order;
            AssemblyHeader."No." := NoSeriesManagement.GetNextNo('A-ORD', Today, true);
            AssemblyHeader.INSERT(true);
            AssemblyHeader.VALIDATE("Item No.", "Assembly Item No.");
            AssemblyHeader.Modify()
        end;
    end;

    local procedure AssemblyLine_Insert(VAR StagingAssemblyOrder_temp: Record "Staging Assembly Order" temporary; var AssemblyHeaderTemp: Record "Assembly Header" temporary)
    var
        AssemblyLine2: Record "Assembly Line";
        lineno: Integer;
    begin
        AssemblyLine2.Reset();
        AssemblyLine2.SetRange("Document No.", AssemblyHeaderTemp."No.");
        if AssemblyLine2.FindLast() then
            lineno := AssemblyLine2."Line No." + 10000
        else
            lineno := 10000;
        AssemblyLine2.INIT;
        AssemblyLine2."Document Type" := AssemblyHeaderTemp."Document Type";
        AssemblyLine2."Document No." := AssemblyHeaderTemp."No.";
        AssemblyLine2."Line No." := lineno;
        AssemblyLine2.Type := AssemblyLine2.Type::Item;
        AssemblyLine2.VALIDATE("No.", StagingAssemblyOrder_temp."Assembly Item No.");
        AssemblyLine2.VALIDATE(Quantity, StagingAssemblyOrder_temp.Quantity);
        AssemblyLine2.INSERT(true);
    end;

    local procedure UpdatepostedInvoiceNo(Var OrderNo: code[50])
    var
        StagingAssemblyOrder_l: Record "Staging Assembly Order";
    begin
        StagingAssemblyOrder_l.Reset();
        StagingAssemblyOrder_l.SetRange("BC Order No.", OrderNo);
        StagingAssemblyOrder_l.SetFilter("Queue Status", '%1', StagingAssemblyOrder_l."Queue Status"::Processed);
        if StagingAssemblyOrder_l.FindFirst() then begin
            repeat
                PostedAssemblyHeader.Reset();
                PostedAssemblyHeader.SetRange("Order No.", StagingAssemblyOrder_l."BC Order No.");
                if PostedAssemblyHeader.FindLast() then begin
                    StagingAssemblyOrder_l."Posted BC No." := PostedAssemblyHeader."No.";
                    StagingAssemblyOrder_l.Modify(true);
                end;
            until StagingAssemblyOrder_l.Next() = 0;
        end;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        StagingAssemblyOrder: Record "Staging Assembly Order";
        StagingAssemblyOrder2: Record "Staging Assembly Order";
        TempICQueueOrderPost: Record "Staging Assembly Order";
        TmpJobQueueEntry: Record "Job Queue Entry";
        JobQueueProcesses: Codeunit "Assembly Order Post";
        InvokeSOMSAPI: Codeunit "Invoke SOMS API";
        OrderNo: Code[50];
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        PostedAssemblyHeader: Record "Posted Assembly Header";


}