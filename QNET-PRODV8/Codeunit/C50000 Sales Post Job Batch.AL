codeunit 50000 "Sales Post Job Batch"
{
    Permissions =
     TableData 17 = rimd,
     tabledata "Dimension Set Entry" = rimd,
     tabledata "Dimension Value" = rimd;

    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        CASE Rec."Parameter String" OF
            'GetSalesOrder':
                InvokeSOMSAPI.GetSalesOrderInfo('');
            'ICQueueOrderPost':
                ICQueueOrderPost(Rec);
            'SalesOrderCreate':
                ICreateOrder(TempICQueueOrderPost);
            'SalesOrderPost':
                PostSalesOrder(TempICQueueOrderPost);
            'ExcelSalesOrderPost':
                CreatePostExcelSalesOrder(TempICQueueOrderPost);
            'SalesReturnOrderPost':
                Post_SalesOrder_Return(TempICQueueOrderPost);
            'CancelSalesLine':
                CancelSalesLine(TempICQueueOrderPost);
            'ReshipSalesLine':
                ReShipSalesLine(TempICQueueOrderPost);
            'SalesLineItemChange':
                SalesLineItemChange(TempICQueueOrderPost);
            'POSGV':
                PostQueueGenJournalLine;
            ELSE
                ERROR('Invalid Parameter String: %1', Rec."Parameter String");
        END;

    end;

    procedure SetStatusId(var Id: Text[10]; OrderNoP: text; var Virtualsales: Boolean)
    begin
        StatusId := id;
        OrderNo := OrderNoP;
        VirtualSales_G := Virtualsales;
    end;

    procedure ICQueueOrderPost(var JobQueueEntry: Record "Job Queue Entry")
    begin
        SalesOrderStaging.RESET;
        SalesOrderStaging.SETCURRENTKEY("Entry No.");
        SalesOrderStaging.Ascending(true);
        SalesOrderStaging.SETFILTER("Queue Status", '%1|%2',
          SalesOrderStaging."Queue Status"::Pending, SalesOrderStaging."Queue Status"::"Wait For ReAttempt");
        SalesOrderStaging.SETFILTER("EarliestStart Date/Time", '<=%1', CURRENTDATETIME);
        SalesOrderStaging.SETFILTER("Retry Count", '<=%1', JobQueueEntry."Maximum No. of Attempts to Run");
        if StatusId <> '' then
            SalesOrderStaging.SetRange(statusId, StatusId);
        if Orderno <> '' then
            SalesOrderStaging.SetFilter(OrderNo, Orderno);
        if VirtualSales_G then
            SalesOrderStaging.SetRange("Import from Excel", true);
        IF SalesOrderStaging.FINDFIRST THEN
            REPEAT
                GetLostStrValue(SalesOrderStaging);
                if SalesOrderStaging.statusId = '23' then
                    TmpJobQueueEntry."Parameter String" := 'SalesOrderCreate'
                else
                    if SalesOrderStaging.statusId = '50' then
                        TmpJobQueueEntry."Parameter String" := 'SalesOrderPost'
                    else
                        if SalesOrderStaging."Import from Excel" then
                            TmpJobQueueEntry."Parameter String" := 'ExcelSalesOrderPost'
                        else
                            if SalesOrderStaging.statusId = '102' then
                                TmpJobQueueEntry."Parameter String" := 'SalesReturnOrderPost'
                            else
                                if SalesOrderStaging.statusId = '101' then
                                    TmpJobQueueEntry."Parameter String" := 'CancelSalesLine'
                                else
                                    if SalesOrderStaging.statusId = '54' then
                                        TmpJobQueueEntry."Parameter String" := 'ReshipSalesLine'
                                    else
                                        if SalesOrderStaging.statusId = '120' then
                                            TmpJobQueueEntry."Parameter String" := 'SalesLineItemChange';
                Commit();
                JobQueueProcesses.SetIcQueueOrderPost(SalesOrderStaging);
                IF NOT JobQueueProcesses.RUN(TmpJobQueueEntry) THEN BEGIN
                    SalesOrderStaging2.RESET;
                    SalesOrderStaging2.SETRANGE(SalesOrderStaging2.OrderNo, SalesOrderStaging.OrderNo);
                    //SalesOrderStaging2.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
                    SalesOrderStaging2.SetRange(statusId, SalesOrderStaging.statusId);
                    IF SalesOrderStaging2.FINDSET THEN
                        REPEAT
                            SalesOrderStaging2."Retry Count" += 1;
                            SalesOrderStaging2."EarliestStart Date/Time" := CURRENTDATETIME + (5 * 60 * 1000);
                            IF SalesOrderStaging2."Retry Count" >= JobQueueEntry."Maximum No. of Attempts to Run" THEN
                                SalesOrderStaging2."Queue Status" := SalesOrderStaging2."Queue Status"::Error;
                            SalesOrderStaging2."Error Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
                            SalesOrderStaging2."Processed Date" := CURRENTDATETIME;
                            SalesOrderStaging2.MODIFY;
                        UNTIL SalesOrderStaging2.NEXT = 0;
                END;
                COMMIT;
            UNTIL SalesOrderStaging.NEXT = 0;
    end;

    procedure SetIcQueueOrderPost(VAR TempRecord: Record "Sales Order Staging")
    begin
        TempICQueueOrderPost := TempRecord;
    end;

    local procedure ICreateOrder(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        SalesOrderStagingRec_l2: Record "Sales Order Staging";
        LineNo: Integer;
        SalesPostYNPrepmt: Codeunit "Sales-Post Prepayment (Yes/No)";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        DocumentType: Option Invoice;
        SalesLine: Record "Sales Line";
        PaymentMethod: code[20];
        PaymentReceive: Decimal;
        OrderAmount: Decimal;
        ShippingfeeAmount: Decimal;
    begin
        Clear(PaymentReceive);
        Clear(OrderAmount);
        Clear(ShippingfeeAmount);
        LineNo := 0;
        LostInTransit := false;
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Entry No.", '<%1', SalesOrderStaging2."Entry No.");
        SalesOrderStagingRec_l.SetRange("Lost IN Transit", true);
        if SalesOrderStagingRec_l.FindFirst() then
            LostInTransit := True;
        //sales order header creation+
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("SOMS Order No.", "Document Type");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("SOMS Order No.", SalesOrderStaging2.OrderNo);
        SalesHeader.SetRange("Virtual Sales", false);
        if not SalesHeader.FindFirst() then
            SalesHeader_Insert(SalesOrderStaging2, 'Order');
        //sales order header creation+

        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Receipt Date", '%1', SalesOrderStaging2."Receipt Date");
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange(statusId, '23');
        SalesOrderStagingRec_l.SetRange("Import from Excel", false);
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesLine.Reset();
                SalesLine.SetRange("SOMS Ship No", SalesOrderStagingRec_l.SHIPNO);
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("SOMS Line No.", SalesOrderStagingRec_l.ITEMNO);
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                if SalesLine.FindFirst() then
                    SalesOrderStagingRec_l."Process Remarks" := 'Order line is already processed with SOMS Order No. ' + SalesLine."SOMS Order No." + 'SOMS Line No. ' + format(SalesLine."SOMS Line No.")
                else begin
                    PaymentReceive += SalesLine_Insert(SalesOrderStagingRec_l, LineNo, SalesHeader);
                    ShippingfeeAmount += SalesOrderStagingRec_l.ShipFee;
                    OrderAmount += (SalesOrderStagingRec_l.AMOUNT - SalesOrderStagingRec_l.ShipFee);
                end;
                SalesOrderStagingRec_l."BC Document No." := SalesHeader."No.";
                SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                SalesOrderStagingRec_l."Retry Count" := 0;
                SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                SalesOrderStagingRec_l."Error Message" := '';
                SalesOrderStagingRec_l.Modify(true);
            until SalesOrderStagingRec_l.Next() = 0;
            PaymentMethod := SalesOrderStaging2.PaymentMethod;
            if PaymentMethod = '' then begin
                SalesOrderStagingRec_l2.Reset();
                SalesOrderStagingRec_l2.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
                SalesOrderStagingRec_l2.SetFilter(PaymentMethod, '<>%1', '');
                if SalesOrderStagingRec_l2.FindFirst() then
                    PaymentMethod := SalesOrderStagingRec_l2.PaymentMethod;
            end;
            if PaymentMethod = 'EV' then
                InsertE_VoucherLines(SalesOrderStaging2, LineNo, SalesHeader);
            if PaymentMethod = 'NR' then
                Insert_NR_Lines(SalesOrderStaging2, LineNo, SalesHeader);
            //Check In lost in transit 
            if LostInTransit then
                CheckLostIntransit_SalesLine(SalesOrderStaging2, SalesHeader);
            //20211108
            Clear(ControlPaymentMethod);
            if SalesOrderStaging2.PaymentMethod <> '' then
                ControlPaymentMethod := DelChr(SalesOrderStaging2.PaymentMethod, '=', '');
            if ((ControlPaymentMethod = 'QA') or (ControlPaymentMethod = 'QE') or (ControlPaymentMethod = 'CC')) then begin
                Insert_SalesPosGV(SalesHeader, PaymentReceive, ControlPaymentMethod);
                Insert_SalesJV(SalesHeader, OrderAmount, ShippingfeeAmount, true, ControlPaymentMethod, '23', SalesOrderStaging2);
            end;
            //20211108
        end;
    end;


    local procedure PostSalesOrder(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        SalesHeader: Record "Sales Header";
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        GeneralLedgerEntries: Record "G/L Entry";
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesPost: Codeunit "Sales-Post";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "SOMS Order No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("SOMS Order No.", SalesOrderStaging2.OrderNo);
        SalesHeader.SetRange("Virtual Sales", false);
        if SalesHeader.FindFirst() then begin
            SalesLieQtytoShipZero(SalesHeader);
            SalesOrderStagingRec_l.Reset();
            SalesOrderStagingRec_l.SetRange(OrderNo, SalesHeader."SOMS Order No.");
            SalesOrderStagingRec_l.SetRange(statusId, '50');
            SalesOrderStagingRec_l.SetFilter("Receipt Date", '%1', SalesOrderStaging2."Receipt Date");
            SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
            SalesOrderStagingRec_l.SetRange("Import from Excel", false);
            if SalesOrderStagingRec_l.FindFirst() then begin
                repeat
                    SalesLine.Reset();
                    SalesLine.SetRange("SOMS Ship No", SalesOrderStagingRec_l.SHIPNO);
                    SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                    SalesLine.SetRange("SOMS Line No.", SalesOrderStagingRec_l.ITEMNO);
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                    if SalesLine.FindFirst() then begin
                        SalesLine.validate("Qty. to Ship", SalesOrderStagingRec_l.QTY);
                        SalesLine.validate("Qty. to Invoice", SalesOrderStagingRec_l.QTY);
                        SalesLine."Courier ID" := SalesOrderStagingRec_l.CourierID;
                        SalesLine.AWB := SalesOrderStagingRec_l.awb;
                        SalesLine.Modify(true);
                        if SalesOrderStagingRec_l.ShipFee > 0 then
                            ValidatePostQty(SalesOrderStagingRec_l);
                        SalesOrderStagingRec_l."BC Document No." := SalesHeader."No.";
                        SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                        SalesOrderStagingRec_l."Retry Count" := 0;
                        SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                        SalesOrderStagingRec_l."Error Message" := '';
                        SalesOrderStagingRec_l.Modify(true);
                    end;
                until SalesOrderStagingRec_l.Next() = 0;
                SalesHeader."External Document No." := SalesOrderStaging2.statusId;
                SalesHeader."Posting Date" := SalesOrderStaging2."Order Date";
                SalesHeader.Ship := true;
                SalesHeader.Invoice := true;
                SalesHeader.Modify(true);
                Commit();
                SalesPost.Run(SalesHeader);
                UpdatepostedInvoiceNo(SalesOrderStaging2.OrderNo, SalesHeader);
            end;

        end;
    end;


    local procedure SalesHeader_Insert(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary; DocType: text[50])
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        IntegrationSetup: Record "Integration Setup";
        SalesOrderStagingRec_l: Record "Sales Order Staging";
    begin
        with SalesOrderStaging2 do begin
            SalesReceivablesSetup.get;
            SalesHeader.INIT;
            if DocType = 'Order' then begin
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                SalesReceivablesSetup.TestField("Order Nos.");
                SalesHeader."No." := NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Order Nos.", Today, true);
            end else
                if DocType = 'Return' then begin
                    SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
                    SalesReceivablesSetup.TestField("Return Order Nos.");
                    SalesHeader."No." := NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Return Order Nos.", Today, true);
                end;
            IntegrationSetup.Get();
            SalesHeader."SOMS Order No." := SalesOrderStaging2.OrderNo;
            SalesHeader.IRID := SalesOrderStaging2.IRID;
            SalesHeader."Receipt No." := SalesOrderStaging2.ReceiptNo;
            IntegrationSetup.TestField("Retail Customer No.");
            Customer.get(IntegrationSetup."Retail Customer No.");
            SalesHeader.VALIDATE("Sell-to Customer No.", Customer."No.");
            SalesHeader."Ship-to Name" := copystr(SalesOrderStaging2."IR Name", 1, 50);
            SalesHeader."Ship-to Address" := copystr(SalesOrderStaging2.address1, 1, 100);
            SalesHeader."Ship-to Address 2" := copystr(SalesOrderStaging2.address2, 1, 50);
            SalesHeader."Ship-to City" := copystr(SalesOrderStaging2.SHIP_CITY, 1, 30);
            SalesHeader."Ship-to Post Code" := SalesOrderStaging2.SHIP_ZIPCODE;
            SalesHeader."Ship-to County" := copystr(SalesOrderStaging2.CountryCode, 30);
            SalesHeader."Bill-to Name" := copystr(SalesOrderStaging2."IR Name", 1, 50);
            SalesHeader."Bill-to Address" := copystr(SalesOrderStaging2.address1, 1, 100);
            SalesHeader."Bill-to Address 2" := copystr(SalesOrderStaging2.address2, 1, 50);
            SalesHeader."Bill-to City" := copystr(SalesOrderStaging2.SHIP_CITY, 1, 30);
            SalesHeader."Bill-to Post Code" := SalesOrderStaging2.SHIP_ZIPCODE;
            SalesHeader."Bill-to County" := copystr(SalesOrderStaging2.CountryCode, 30);
            SalesHeader."Sell-to Customer Name" := copystr(SalesOrderStaging2."IR Name", 1, 50);
            SalesHeader."Sell-to Address" := copystr(SalesOrderStaging2.address1, 1, 100);
            SalesHeader."Sell-to Address 2" := copystr(SalesOrderStaging2.address2, 1, 50);
            SalesHeader."Sell-to City" := copystr(SalesOrderStaging2.SHIP_CITY, 1, 30);
            SalesHeader."Sell-to Post Code" := SalesOrderStaging2.SHIP_ZIPCODE;
            SalesHeader."Sell-to County" := copystr(SalesOrderStaging2.CountryCode, 30);
            SalesHeader."Document Date" := DT2Date(SalesOrderStaging2."Receipt Date");
            SalesHeader."Order Date" := DT2Date(SalesOrderStaging2."Receipt Date");
            SalesHeader."Posting Date" := DT2Date(SalesOrderStaging2."Receipt Date");
            SalesHeader.Reference_Id := SalesOrderStaging2.RefID;
            SalesHeader.Integrated_order := true;
            SalesHeader.Validate("Currency Code", 'USD');
            SalesHeader."Location Code" := LOCATION;
            SalesHeader."External Document No." := SalesOrderStaging2.statusId;
            SalesHeader."Virtual File Code" := SalesOrderStaging2."Virtual File Code";
            if SalesOrderStaging2.PaymentMethod <> '' then
                SalesHeader.Validate("Customer Posting Group", SalesOrderStaging2.PaymentMethod)
            else begin
                SalesOrderStagingRec_l.Reset();
                SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
                SalesOrderStagingRec_l.SetFilter(PaymentMethod, '<>%1', '');
                if SalesOrderStagingRec_l.FindFirst() then
                    SalesHeader.Validate("Customer Posting Group", SalesOrderStagingRec_l.PaymentMethod)
            end;

            Clear(ControlPaymentMethod);
            if SalesOrderStaging2.PaymentMethod <> '' then
                ControlPaymentMethod := DelChr(SalesOrderStaging2.PaymentMethod, '=', '');

            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                if not SalesOrderStaging2."Import from Excel" then
                    if ((ControlPaymentMethod = 'CC') or (ControlPaymentMethod = 'QE') or (ControlPaymentMethod = 'QA')) then begin
                        IntegrationSetup.TestField("Control Customer Posting Group");
                        SalesHeader.Validate("Customer Posting Group", IntegrationSetup."Control Customer Posting Group");
                        SalesHeader."Control Sales" := true;
                    end;

            if LostInTransit then
                SalesHeader.Validate("Customer Posting Group", 'LT');
            if SalesOrderStaging2."Import from Excel" then
                SalesHeader."Virtual Sales" := true;
            SalesHeader.INSERT(true);
            if not DimensionValue.Get('COUNTRY', SalesOrderStaging2.CountryCode) then begin
                DimensionValue.Init();
                DimensionValue."Dimension Code" := 'COUNTRY';
                DimensionValue.Code := SalesOrderStaging2.CountryCode;
                DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
                DimensionValue.Insert();
                SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code", 'AE');
            end else
                SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code", SalesOrderStaging2.CountryCode);

            if SalesOrderStaging2."Import from Excel" then
                SalesHeader.Validate("Posting Date", DT2Date(SalesOrderStaging2."Receipt Date"))
            else
                SalesHeader.Validate("Posting Date", SalesOrderStaging2."Order Date");

            SalesHeader.Modify(true);
        end;
    end;

    local procedure SalesLine_Insert(VAR SalesOrderStaging: Record "Sales Order Staging" temporary; var lineno: Integer; var SalesHeaderTemp: Record "Sales Header" temporary): Decimal
    var
        IntegrationSetup: Record "Integration Setup";
        BOM_component: Record "BOM Component";
        DefaultDimension: Record "Default Dimension";
        SalesLine: Record "Sales Line";
        LineAmount_l: Decimal;
    begin
        Clear(LineAmount_l);
        IntegrationSetup.Get;
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
        if SalesLine.FindLast() then
            lineno := SalesLine."Line No." + 10000
        else
            lineno := 10000;
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", SalesOrderStaging.productCode);
        SalesLine.VALIDATE(Quantity, SalesOrderStaging.qty);
        if not SalesOrderStaging."Import from Excel" then begin
            salesLine.Validate("Qty. to Ship", 0);
            SalesLine.Validate("Qty. to Invoice", 0);
        end;
        if SalesOrderStaging.AMOUNT = 0 then begin
            SalesCrMemoHeader.Reset();
            SalesCrMemoHeader.SetRange("SOMS Order No.", SalesOrderStaging.OrderNo);
            if SalesCrMemoHeader.FindFirst() then begin
                SalesCrMemoLine.Reset();
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine.SetRange(Type, SalesLine.Type::Item);
                if SalesCrMemoLine.FindFirst() then begin
                    SalesLine.Validate("Unit Price", SalesCrMemoLine."Unit Price");
                end;
            end;
        end else
            SalesLine.Validate("Unit Price", SalesOrderStaging.AMOUNT - SalesOrderStaging.ShipFee);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.TCO := SalesOrderStaging.TCO;
        SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        if DefaultDimension.Get(27, SalesLine."No.", 'PRODLINE') then
            SalesLine.ValidateShortcutDimCode(5, DefaultDimension."Dimension Value Code");

        if SalesOrderStaging."Import from Excel" then begin
            if SalesOrderStaging."GST Value" <> 0 then
                SalesLine.Validate("VAT Prod. Posting Group", 'VAT5')
            else
                SalesLine.Validate("VAT Prod. Posting Group", 'VAT0');
        end else begin

            Clear(ControlPaymentMethod);
            if SalesOrderStaging.PaymentMethod <> '' then
                ControlPaymentMethod := DelChr(SalesOrderStaging.PaymentMethod, '=', '');

            if SalesLine."Document Type" = SalesLine."Document Type"::Order then
                if not SalesOrderStaging."Import from Excel" then begin
                    if ((ControlPaymentMethod = 'CC') or (ControlPaymentMethod = 'QA') or (ControlPaymentMethod = 'QE')) then begin
                        IntegrationSetup.TestField("Control Gen. Prod. Posting Grp");
                        IntegrationSetup.TestField("Control VAT Prod. Posting Grp");
                        SalesLine.Validate("Gen. Prod. Posting Group", IntegrationSetup."Control Gen. Prod. Posting Grp");
                        SalesLine.Validate("VAT Prod. Posting Group", IntegrationSetup."Control VAT Prod. Posting Grp");
                    end;
                end;
        end;
        SalesLine.INSERT(true);
        LineAmount_l := SalesLine."Amount Including VAT";
        //GL Line  
        if not LostInTransit then
            if SalesOrderStaging.ShipFee > 0 then begin
                IntegrationSetup.TestField("Ship Fee GL");
                SalesLine.INIT;
                SalesLine."Document Type" := SalesHeaderTemp."Document Type";
                SalesLine."Document No." := SalesHeaderTemp."No.";
                SalesLine."Line No." := lineno + 10000;
                SalesLine.Type := SalesLine.Type::"G/L Account";
                SalesLine.INSERT;
                SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
                SalesLine.Validate("No.", IntegrationSetup."Ship Fee GL");

                Clear(ControlPaymentMethod);
                if SalesOrderStaging.PaymentMethod <> '' then
                    ControlPaymentMethod := DelChr(SalesOrderStaging.PaymentMethod, '=', '');

                if SalesLine."Document Type" = SalesLine."Document Type"::Order then
                    if not SalesOrderStaging."Import from Excel" then
                        if ((ControlPaymentMethod = 'CC') or (ControlPaymentMethod = 'QA') or (ControlPaymentMethod = 'QE')) then begin
                            IntegrationSetup.TestField("Control Ship Fee GL");
                            IntegrationSetup.TestField("Control Gen. Prod. Posting Grp");
                            IntegrationSetup.TestField("Control VAT Prod. Posting Grp");
                            SalesLine.Validate("No.", IntegrationSetup."Control Ship Fee GL");
                            SalesLine.Validate("Gen. Prod. Posting Group", IntegrationSetup."Control Gen. Prod. Posting Grp");
                            SalesLine.Validate("VAT Prod. Posting Group", IntegrationSetup."Control VAT Prod. Posting Grp");
                        end;

                SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
                SalesLine.VALIDATE(Quantity, 1);
                SalesLine.Validate("Unit Price", SalesOrderStaging.ShipFee);
                SalesLine."Location Code" := SalesHeaderTemp."Location Code";
                SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
                SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
                SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
                SalesLine.MODIFY;
                LineAmount_l += SalesLine."Amount Including VAT";
            end;
        // GL Line
        exit(LineAmount_l);
    end;


    local procedure InsertE_VoucherLines(VAR SalesOrderStaging: Record "Sales Order Staging" temporary; var lineno: Integer; var SalesHeaderTemp: Record "Sales Header" temporary)
    var
        IntegrationSetup: Record "Integration Setup";
        salesLine2: Record "Sales Line";
        Item: Record Item;
        TotalUnitcost: Decimal;
        SalesLine: Record "Sales Line";
        CheckPrice: Boolean;
    begin
        IntegrationSetup.Get;
        IntegrationSetup.TestField("EV GL Acc.");
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
        SalesLine.SetRange("No.", IntegrationSetup."EV GL Acc.");
        if SalesLine.FindFirst() then
            exit;
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
        if SalesLine.FindLast() then
            lineno := SalesLine."Line No." + 10000
        else
            lineno := 10000;
        TotalUnitcost := 0;
        CheckPrice := false;
        SalesLine2.Reset();
        SalesLine2.SetRange("Document No.", SalesHeaderTemp."No.");
        // salesLine2.SetRange(Type, salesLine2.Type::Item);
        if SalesLine2.FindFirst() then
            repeat
                SalesLine2.Validate("Unit Price", 0);
                SalesLine2.Modify();
                if Item.Get(salesLine2."No.") then;
                TotalUnitcost += Item."Unit Cost";
            // if Item."Unit Cost" = 0 then
            //     CheckPrice := true;
            until (salesLine2.Next() = 0);//or (CheckPrice = true);
        //For VAT
        //if CheckPrice then
        //    exit;
        if currency.get('USD') then;
        if TotalUnitcost <> 0 then
            TotalUnitcost := round(TotalUnitcost / 3.6725, currency."Amount Rounding Precision");
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.INSERT;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Validate("No.", IntegrationSetup."EV GL Acc.");
        SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        SalesLine.VALIDATE(Quantity, 1);
        SalesLine.Validate("Unit Price", TotalUnitcost);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.MODIFY;
        //For VAT
        //For NO VAT
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno + 10000;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.INSERT;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Validate("No.", IntegrationSetup."EV GL Acc.");
        SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        SalesLine.Validate("VAT Prod. Posting Group", 'VAT0');
        SalesLine.VALIDATE(Quantity, -1);
        SalesLine.Validate("Unit Price", TotalUnitcost);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.MODIFY;
        //For NO VAT
    end;

    local procedure Insert_NR_Lines(VAR SalesOrderStaging: Record "Sales Order Staging" temporary; var lineno: Integer; var SalesHeaderTemp: Record "Sales Header" temporary)
    var
        IntegrationSetup: Record "Integration Setup";
        salesLine2: Record "Sales Line";
        Item: Record Item;
        TotalUnitcost: Decimal;
        SalesLine: Record "Sales Line";
    begin
        IntegrationSetup.Get;
        IntegrationSetup.TestField("NR GL Acc.");
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
        SalesLine.SetRange("No.", IntegrationSetup."NR GL Acc.");
        if SalesLine.FindFirst() then
            exit;

        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
        if SalesLine.FindLast() then
            lineno := SalesLine."Line No." + 10000
        else
            lineno := 10000;
        TotalUnitcost := 0;
        SalesLine2.Reset();
        SalesLine2.SetRange("Document No.", SalesHeaderTemp."No.");
        //salesLine2.SetRange(Type, salesLine2.Type::Item);
        if SalesLine2.FindFirst() then
            repeat
                SalesLine2.Validate("Unit Price", 0);
                SalesLine2.Modify();
                if Item.Get(salesLine2."No.") then
                    TotalUnitcost += Item."Unit Cost";
            until salesLine2.Next() = 0;
        //For VAT
        if currency.get('USD') then;
        if TotalUnitcost <> 0 then
            TotalUnitcost := round(TotalUnitcost / 3.6725, currency."Amount Rounding Precision");
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.INSERT;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Validate("No.", IntegrationSetup."NR GL Acc.");
        SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        SalesLine.VALIDATE(Quantity, 1);
        SalesLine.Validate("Unit Price", TotalUnitcost);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.MODIFY;
        //For VAT
        //For NO VAT
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno + 10000;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.INSERT;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Validate("No.", IntegrationSetup."NR GL Acc.");
        SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        SalesLine.Validate("VAT Prod. Posting Group", 'VAT0');
        SalesLine.VALIDATE(Quantity, -1);
        SalesLine.Validate("Unit Price", TotalUnitcost);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.MODIFY;
        //For NO VAT
    end;

    procedure CreatePostExcelSalesOrder(VAR SalesOrderStaging: Record "Sales Order Staging" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        LineNo: Integer;
        SalesPostYNPrepmt: Codeunit "Sales-Post Prepayment (Yes/No)";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesPost: Codeunit "Sales-Post";
        DocumentType: Option Invoice;
        SalesLine: Record "Sales Line";
        TempAmt: Decimal;
    begin
        clear(TempAmt);
        //exclude NR and EV+
        LostInTransit := false;
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetCurrentKey(OrderNo, productCode);
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(ProductCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange("Import from Excel", true);
        SalesOrderStagingRec_l.SetFilter(PaymentMethod, '%1|%2', 'EV', 'NR');
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesOrderStagingRec_l."Process Remarks" := 'No Need to process in BC';
                SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                SalesOrderStagingRec_l."Retry Count" := 0;
                SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                SalesOrderStagingRec_l."Error Message" := '';
                SalesOrderStagingRec_l.Modify(true);
            until SalesOrderStagingRec_l.next = 0;
            exit;
        End;
        //exclude NR and EV-
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("SOMS Order No.", "Document Type");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("SOMS Order No.", SalesOrderStaging.OrderNo);
        SalesHeader.SetRange("Virtual Sales", true);
        if not SalesHeader.FindFirst() then
            SalesHeader_Insert(SalesOrderStaging, 'Order');
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetCurrentKey(OrderNo, productCode);
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(ProductCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange("Import from Excel", true);
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesLine.Reset();
                SalesLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                SalesLine.SetRange("SOMS Line No.", SalesOrderStagingRec_l.ITEMNO);
                if not SalesLine.FindFirst() then
                    TempAmt += SalesLine_Insert(SalesOrderStagingRec_l, LineNo, SalesHeader);
                if SalesOrderStagingRec_l.ShipFee > 0 then
                    ValidatePostQty(SalesOrderStagingRec_l);
                SalesOrderStagingRec_l."BC Document No." := SalesHeader."No.";
                SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                SalesOrderStagingRec_l."Retry Count" := 0;
                SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                SalesOrderStagingRec_l."Error Message" := '';
                SalesOrderStagingRec_l.Modify(true);
            until SalesOrderStagingRec_l.Next() = 0;
        end;
        // if SalesOrderStaging.PaymentMethod = 'EV' then
        //     InsertE_VoucherLines(SalesOrderStaging, LineNo, SalesHeader);
        // if SalesOrderStaging.PaymentMethod = 'NR' then
        //     Insert_NR_Lines(SalesOrderStaging, LineNo, SalesHeader);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify(true);
        SalesPost.Run(SalesHeader);
        // if CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader) then
        //     Error(GetLastErrorText());
        UpdatepostedInvoiceNo(SalesOrderStaging.OrderNo, SalesHeader);
    end;

    procedure Post_SalesOrder_Return(VAR SalesOrderStaging: Record "Sales Order Staging" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        LineNo: Integer;
        SalesPostYNPrepmt: Codeunit "Sales-Post Prepayment (Yes/No)";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesLine: Record "Sales Line";
        ReturnAmount_l: Decimal;
    begin
        Clear(ReturnAmount_l);
        LostInTransit := false;
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("SOMS Order No.", "Document Type");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("SOMS Order No.", SalesOrderStaging.OrderNo);
        SalesHeader.SetRange("Virtual Sales", false);
        if not SalesHeader.FindFirst() then
            SalesHeader_Insert(SalesOrderStaging, 'Return');
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging.OrderNo);
        SalesOrderStagingRec_l.SetRange("Receipt Date", SalesOrderStaging."Receipt Date");
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange(statusId, '102');
        SalesOrderStagingRec_l.SetRange("Import from Excel", false);
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("SOMS Line No.", SalesOrderStagingRec_l.ITEMNO);
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if not SalesLine.FindFirst() then
                    ReturnAmount_l += SalesLine_Insert(SalesOrderStagingRec_l, LineNo, SalesHeader);
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("SOMS Line No.", SalesOrderStagingRec_l.ITEMNO);
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindFirst() then
                    repeat
                        SalesLine.validate("Qty. to Ship", 0);
                        SalesLine.Validate("Return Qty. to Receive", SalesOrderStagingRec_l.QTY);
                        SalesLine.validate("Qty. to Invoice", SalesOrderStagingRec_l.QTY);
                        SalesLine.Modify(true);
                        SalesOrderStagingRec_l."BC Document No." := SalesHeader."No.";
                        SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                        SalesOrderStagingRec_l."Retry Count" := 0;
                        SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                        SalesOrderStagingRec_l."Error Message" := '';
                        SalesOrderStagingRec_l.Modify(true);
                    until SalesLine.Next() = 0;
            until SalesOrderStagingRec_l.Next() = 0;
            if SalesOrderStaging.PaymentMethod = 'EV' then
                InsertE_VoucherLines(SalesOrderStaging, LineNo, SalesHeader);
            if SalesOrderStaging.PaymentMethod = 'NR' then
                Insert_NR_Lines(SalesOrderStaging, LineNo, SalesHeader);
        end;
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        SalesHeader."Posting Date" := DT2Date(SalesOrderStaging."Receipt Date");
        SalesHeader.Modify(true);
        //20211108
        if SalesOrderStaging.PaymentMethod <> '' then
            ControlPaymentMethod := DelChr(SalesOrderStaging.PaymentMethod, '=', '');
        if ((ControlPaymentMethod = 'QA') or (ControlPaymentMethod = 'QE') or (ControlPaymentMethod = 'CC')) then
            Insert_SalesNegGV(SalesHeader, ReturnAmount_l, ControlPaymentMethod, '102');
        //20211108
        CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader);
        UpdatepostedInvoiceNo(SalesOrderStagingRec_l.OrderNo, SalesHeader);
    end;

    local procedure CancelSalesLine(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        SalesLine: Record "Sales Line";
        SalesShipLine: Record "Sales Shipment Line";
        LineNo: Decimal;
        CancelAmount_l: Decimal;
        CancelOrderAmount_l: Decimal;
        CancelShipfreeamount: Decimal;
    begin
        Clear(CancelAmount_l);
        Clear(CancelOrderAmount_l);
        Clear(CancelShipfreeamount);
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "SOMS Order No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("SOMS Order No.", SalesOrderStaging2.OrderNo);
        SalesHeader.SetRange("Virtual Sales", false);
        if SalesHeader.FindFirst() then;
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange(SHIPNO, SalesOrderStaging2.SHIPNO);
        SalesOrderStagingRec_l.SetRange("Lost IN Transit", false);
        SalesOrderStagingRec_l.SetRange(statusId, '101');
        SalesOrderStagingRec_l.SetRange("Import from Excel", false);
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesLine.Reset();
                SalesLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                SalesLine.SetRange("SOMS Ship No", SalesOrderStagingRec_l.SHIPNO);
                if SalesLine.FindFirst() then begin
                    CancelOrderAmount_l += SalesLine.Amount;
                    CancelAmount_l += SalesLine."Amount Including VAT";
                end;
                SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                SalesOrderStagingRec_l."Retry Count" := 0;
                SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                SalesOrderStagingRec_l."Error Message" := '';
                SalesOrderStagingRec_l.Modify(true);
            until SalesOrderStagingRec_l.Next() = 0;
        end else begin
            SalesOrderStagingRec_l.Reset();
            SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
            SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
            SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
            SalesOrderStagingRec_l.SetRange("Lost IN Transit", true);
            SalesOrderStagingRec_l.SetRange(statusId, '101');
            SalesOrderStagingRec_l.SetRange("Import from Excel", false);
            if SalesOrderStagingRec_l.FindSet() then begin
                repeat
                    // SalesLine.Reset();
                    // SalesLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
                    // SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                    // SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                    // SalesLine.SetRange("SOMS Ship No", SalesOrderStagingRec_l.SHIPNO);
                    // if SalesLine.FindFirst() then begin
                    //     SalesLine.Validate("Unit Price", 0);
                    //     SalesLine.Modify();
                    SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                    SalesOrderStagingRec_l."Retry Count" := 0;
                    SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                    SalesOrderStagingRec_l."Error Message" := '';
                    SalesOrderStagingRec_l.Modify(true);
                // end;
                until SalesOrderStagingRec_l.Next() = 0;
                //LostInTransitLines(SalesOrderStagingRec_l, SalesLine."Line No.", SalesHeader);
            end;
        end;
        //20211108
        Clear(ControlPaymentMethod);
        if SalesOrderStaging2.PaymentMethod <> '' then
            ControlPaymentMethod := DelChr(SalesOrderStaging2.PaymentMethod, '=', '');

        if ((ControlPaymentMethod = 'QA') or (ControlPaymentMethod = 'QE') or (ControlPaymentMethod = 'CC')) then begin
            Insert_SalesNegGV(SalesHeader, CancelAmount_l, SalesOrderStaging2.PaymentMethod, '101');
            Insert_SalesJV(SalesHeader, CancelOrderAmount_l, CancelShipfreeamount, false, SalesOrderStaging2.PaymentMethod, '101', SalesOrderStaging2);
        end;
        //20211108
    end;

    local procedure CheckLostIntransit_SalesLine(VAR SalesOrderStaging: Record "Sales Order Staging" temporary; var SalesHeaderTemp: Record "Sales Header" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        SalesLine: Record "Sales Line";
        SalesShipLine: Record "Sales Shipment Line";
        LineNo: Decimal;
    begin
        SalesLine.Reset();
        SalesLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
        SalesLine.SetRange("SOMS Order No.", SalesHeaderTemp."SOMS Order No.");
        if SalesLine.FindFirst() then begin
            repeat
                SalesLine.Validate("Unit Price", 0);
                SalesLine.Modify();
            until SalesLine.Next() = 0;
        end;
        LostInTransitLines(SalesOrderStaging, SalesLine."Line No.", SalesHeaderTemp);
    end;

    local procedure LostInTransitLines(VAR SalesOrderStaging: Record "Sales Order Staging" temporary; var lineno: Integer; var SalesHeaderTemp: Record "Sales Header" temporary)
    var
        IntegrationSetup: Record "Integration Setup";
        salesLine2: Record "Sales Line";
        Item: Record Item;
        TotalUnitcost: Decimal;
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
        if SalesLine.FindLast() then
            lineno := SalesLine."Line No." + 10000
        else
            lineno := 10000;
        TotalUnitcost := 0;
        SalesLine2.Reset();
        SalesLine2.SetRange("Document No.", SalesHeaderTemp."No.");
        salesLine2.SetRange(Type, salesLine2.Type::Item);
        if SalesLine2.FindFirst() then
            repeat
                if Item.Get(salesLine2."No.") then
                    TotalUnitcost += Item."Unit Cost";
            until salesLine2.Next() = 0;
        //For VAT
        if currency.get('USD') then;
        if TotalUnitcost <> 0 then
            TotalUnitcost := round(TotalUnitcost / 3.6725, currency."Amount Rounding Precision");
        IntegrationSetup.Get;
        IntegrationSetup.TestField("LOST In Transit Acc.");
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.INSERT;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Validate("No.", IntegrationSetup."LOST In Transit Acc.");
        if SalesHeaderTemp."Currency Code" <> '' then
            SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        SalesLine.VALIDATE(Quantity, 1);
        SalesLine.Validate("Unit Price", TotalUnitcost);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.MODIFY;
        //For VAT
        //For NO VAT
        SalesLine.INIT;
        SalesLine."Document Type" := SalesHeaderTemp."Document Type";
        SalesLine."Document No." := SalesHeaderTemp."No.";
        SalesLine."Line No." := lineno + 10000;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.INSERT;
        SalesLine.VALIDATE("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesLine.Validate("No.", IntegrationSetup."LOST In Transit Acc.");
        SalesLine.Validate("Currency Code", SalesHeaderTemp."Currency Code");
        SalesLine.Validate("VAT Prod. Posting Group", 'VAT0');
        SalesLine.VALIDATE(Quantity, -1);
        SalesLine.Validate("Unit Price", TotalUnitcost);
        SalesLine."Location Code" := SalesHeaderTemp."Location Code";
        SalesLine."SOMS Ship No" := SalesOrderStaging.SHIPNO;
        SalesLine."SOMS Order No." := SalesOrderStaging.OrderNo;
        SalesLine."SOMS Line No." := SalesOrderStaging.ITEMNO;
        SalesLine.MODIFY;
        //For NO VAT
    end;

    local procedure ReShipSalesLine(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        SalesLine: Record "Sales Line";
        SalesShipLine: Record "Sales Shipment Line";
    begin
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange(SHIPNO, SalesOrderStaging2.SHIPNO);
        SalesOrderStagingRec_l.SetRange(statusId, '54');
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesLine.Reset();
                SalesLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
                SalesLine.SetRange("SOMS Ship No", SalesOrderStagingRec_l.SHIPNO);
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                if SalesLine.FindFirst() then begin
                    SalesOrderStagingRec_l."BC Document No." := SalesLine."Document No.";
                    SalesCrMemoLine.Reset();
                    SalesCrMemoLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
                    SalesCrMemoLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                    SalesCrMemoLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                    if not SalesCrMemoLine.FindFirst() then begin
                        SalesOrderStagingRec_l."Process Remarks" := 'Original Order has no returned';
                    end else begin
                        SalesOrderStagingRec_l."Process Remarks" := 'Original Order has returned';
                        SalesLine."SOMS Status" := SalesLine."SOMS Status"::Reship;
                        SalesLine.Validate(Quantity, 0);
                        SalesLine."Qty. to Ship" := 0;
                        SalesLine."Qty. to Invoice" := 0;
                        SalesLine.Validate("Unit Price", 0);
                        SalesLine.Modify();
                    end;
                end else
                    SalesOrderStagingRec_l."Process Remarks" := 'Sales Line Not Found';
                SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                SalesOrderStagingRec_l."Retry Count" := 0;
                SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                SalesOrderStagingRec_l."Error Message" := '';
                SalesOrderStagingRec_l.Modify(true);
            until SalesOrderStagingRec_l.Next() = 0;
        end;
    end;

    local procedure SalesLineItemChange(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        SalesOrderStagingRec_l2: Record "Sales Order Staging";
        SalesLine: Record "Sales Line";
        SalesShipLine: Record "Sales Shipment Line";
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange(SHIPNO, SalesOrderStaging2.SHIPNO);
        SalesOrderStagingRec_l.SetRange(statusId, '120');
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesLine.Reset();
                SalesLine.SetCurrentKey("SOMS Ship No", "SOMS Order No.");
                SalesLine.SetRange("SOMS Ship No", SalesOrderStagingRec_l.SHIPNO);
                SalesLine.SetRange("SOMS Order No.", SalesOrderStagingRec_l.OrderNo);
                SalesLine.SetRange("No.", SalesOrderStagingRec_l.productCode);
                if SalesLine.FindFirst() then begin
                    SalesLine.validate(Quantity, 1);
                    SalesLine."Qty. to Ship" := 0;
                    SalesLine."Qty. to Invoice" := 0;
                    SalesOrderStagingRec_l2.Reset();
                    SalesOrderStagingRec_l2.SetRange(OrderNo, SalesOrderStagingRec_l.OrderNo);
                    SalesOrderStagingRec_l2.SetRange(statusId, '54');
                    if SalesOrderStagingRec_l2.FindLast() then begin
                        SalesInvLine.Reset();
                        SalesInvLine.SetRange("SOMS Ship No", CopyStr(SalesOrderStagingRec_l2.Remarks, (StrLen(SalesOrderStagingRec_l2.Remarks) - 7), (StrLen(SalesOrderStagingRec_l2.Remarks))));
                        if SalesInvLine.FindFirst() then begin
                            SalesLine.validate("Unit Price", SalesInvLine."Unit Price");
                            SalesLine.Modify();
                        end;
                    end;
                    SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                    SalesOrderStagingRec_l."Retry Count" := 0;
                    SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                    SalesOrderStagingRec_l."Error Message" := '';
                    SalesOrderStagingRec_l.Modify(true);
                end;
            until SalesOrderStagingRec_l.Next() = 0;
        end;
    end;

    local procedure ValidatePostQty(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        SalesLine2: Record "Sales Line";
    begin
        SalesLine2.reset;
        SalesLine2.SetCurrentKey("SOMS Order No.", "SOMS Line No.");
        SalesLine2.SetRange("SOMS Order No.", SalesOrderStaging2.OrderNo);
        SalesLine2.SetRange("SOMS Line No.", SalesOrderStaging2.ITEMNO);
        SalesLine2.SetRange(Type, SalesLine2.Type::"G/L Account");
        SalesLine2.FindFirst();
        if SalesOrderStaging2.statusId = '50' then begin
            if SalesLine2."Quantity Shipped" = 0 Then begin
                SalesLine2.validate("Qty. to Ship", SalesLine2.Quantity);
                SalesLine2.Validate("Qty. to Invoice", SalesLine2.Quantity);
                SalesLine2.Modify(true);
            end;
            //salesline2.Validate("Return Qty. to Receive", 0);
        end else
            if SalesOrderStaging2.statusId = '102' then begin
                //  SalesLine2.validate("Qty. to Ship", 0);
                if SalesLine2."Return Qty. Received" = 0 Then begin
                    salesline2.Validate("Return Qty. to Receive", SalesLine2.Quantity);
                    SalesLine2.Validate("Qty. to Invoice", SalesLine2.Quantity);
                    SalesLine2.Modify(true);
                end;
            end;
    end;

    local procedure UpdatepostedInvoiceNo(Var SOMSOrderNo: code[50]; var SalesHeaderTemp: Record "Sales Header" temporary)
    var
        SalesOrderStagingRec_l: Record "Sales Order Staging";
        PostedSalesInvoice: Record "Sales Invoice Header";
        PostedBCDocument: Code[50];
    begin
        PostedBCDocument := '';
        if SalesHeaderTemp."Document Type" = SalesHeaderTemp."Document Type"::Order then begin
            PostedSalesInvoice.Reset();
            PostedSalesInvoice.SetRange("SOMS Order No.", SOMSOrderNo);
            PostedSalesInvoice.SetRange("Order No.", SalesHeaderTemp."No.");
            if PostedSalesInvoice.FindLast() then
                PostedBCDocument := PostedSalesInvoice."No.";
        end else
            if SalesHeaderTemp."Document Type" = SalesHeaderTemp."Document Type"::"Return Order" then begin
                SalesCrMemoHeader.Reset();
                SalesCrMemoHeader.SetRange("SOMS Order No.", SOMSOrderNo);
                SalesCrMemoHeader.SetRange("Return Order No.", SalesHeaderTemp."No.");
                if SalesCrMemoHeader.FindLast() then
                    PostedBCDocument := SalesCrMemoHeader."No.";
            end;
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SOMSOrderNo);
        SalesOrderStagingRec_l.SetRange("BC Document No.", SalesHeaderTemp."No.");
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                SalesOrderStagingRec_l."Posted BC Document No." := PostedBCDocument;
                SalesOrderStagingRec_l.Modify(true);
            until SalesOrderStagingRec_l.Next() = 0;
        end;
    end;
    //RK20211108+
    local procedure Insert_SalesPosGV(var TempSalesHeader: Record "Sales Header"; var PaymentReceive_p: decimal; CustomerPostingGroup_p: code[10])
    var
        IntegrationSetup: Record "Integration Setup";
        SalesLine: Record "Sales Line";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        if PaymentReceive_p = 0 then
            exit;
        IntegrationSetup.Get();
        GenJournalLine.LockTable();
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := IntegrationSetup."SOMS Pos. Journal Templ. Name";
        GenJournalLine."Journal Batch Name" := IntegrationSetup."SOMS Pos. Journal Batch Name";
        GenJournalLine."Line No." := GetLastLineNo(IntegrationSetup."SOMS Pos. Journal Templ. Name", IntegrationSetup."SOMS Pos. Journal Batch Name");
        GenJournalLine."Document No." := TempSalesHeader."SOMS Order No.";
        GenJournalLine."External Document No." := TempSalesHeader."External Document No.";
        GenJournalLine.Insert(true);
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment;
        GenJournalLine."SOMS Order No." := TempSalesHeader."SOMS Order No.";
        GenJournalLine."Posting Date" := TempSalesHeader."Posting Date";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine.Validate("Account No.", TempSalesHeader."Sell-to Customer No.");
        GenJournalLine.validate("Posting Group", CustomerPostingGroup_p);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        if CustomerPostingGroup_p = 'QE' then
            GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."QE Control Account")
        else
            if CustomerPostingGroup_p = 'QA' then
                GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."QA Control Account")
            else
                if CustomerPostingGroup_p = 'CC' then
                    GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."CC Control Account")
                else
                    GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."CC Control Account");
        GenJournalLine.validate("Currency Code", TempSalesHeader."Currency Code");
        GenJournalLine.Validate(Amount, PaymentReceive_p * -1);
        GenJournalLine.Validate("Shortcut Dimension 1 Code", TempSalesHeader."Shortcut Dimension 1 Code");
        GenJournalLine.Validate("Shortcut Dimension 2 Code", TempSalesHeader."Shortcut Dimension 2 Code");
        GenJournalLine.validate("Dimension Set ID", TempSalesHeader."Dimension Set ID");
        GenJournalLine."SOMS Create DateTime" := CurrentDateTime;
        GenJournalLine.Modify(true);
        GenJnlPostBatch.Run(GenJournalLine);
    end;

    local procedure Insert_SalesJV(var TempSalesHeader: Record "Sales Header"; var OrderAmount_p: decimal; var Shipfee_p: Decimal; IsInvoice: Boolean; CustomerPostingGroup_p: code[10]; Status_p: code[10]; VAR SalesOrderStaging_l: Record "Sales Order Staging" temporary)
    var
        IntegrationSetup: Record "Integration Setup";
        SalesHeader_l: Record "Sales Header";
        SalesLine_l: Record "Sales Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesPost: Codeunit "Sales-Post";
    begin
        IntegrationSetup.Get();
        // Sales Posting 
        SalesReceivablesSetup.Get();
        SalesHeader_l.Init();
        SalesHeader_l.TransferFields(TempSalesHeader);
        SalesHeader_l.Status := SalesHeader_l.Status::Open;
        SalesHeader_l."Control Sales" := false;
        SalesHeader_l.Validate("Posting Date", SalesOrderStaging_l."Order Date");
        SalesHeader_l.Validate("Customer Posting Group", CustomerPostingGroup_p);
        if TempSalesHeader."Document Type" = TempSalesHeader."Document Type"::Order then begin
            SalesReceivablesSetup.TestField("Order Nos.");
            SalesHeader_l."No." := NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Order Nos.", Today, true);
        end else
            if TempSalesHeader."Document Type" = TempSalesHeader."Document Type"::"Return Order" then begin
                SalesReceivablesSetup.TestField("Return Order Nos.");
                SalesHeader_l."No." := NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Return Order Nos.", Today, true);
            end;
        if IsInvoice then
            SalesHeader_l."Document Type" := SalesHeader_l."Document Type"::Invoice
        else begin
            SalesHeader_l."Document Type" := SalesHeader_l."Document Type"::"Credit Memo";
            SalesHeader_l.Validate("Payment Method Code", ' ');
            SalesHeader_l.validate("Pmt. Discount Date", 0D);
        end;
        SalesHeader_l."External Document No." := Status_p;
        SalesHeader_l.Insert();

        if OrderAmount_p <> 0 then begin
            SalesLine_l.INIT;
            SalesLine_l."Document Type" := SalesHeader_l."Document Type";
            SalesLine_l."Document No." := SalesHeader_l."No.";
            SalesLine_l."Line No." := 10000;
            SalesLine_l.VALIDATE("Sell-to Customer No.", SalesHeader_l."Sell-to Customer No.");
            SalesLine_l.Type := SalesLine_l.Type::"G/L Account";
            SalesLine_l.Validate("No.", '502000');
            SalesLine_l.VALIDATE(Quantity, 1);
            SalesLine_l.Validate("Currency Code", SalesHeader_l."Currency Code");
            SalesLine_l.Validate("Unit Price", OrderAmount_p);
            SalesLine_l."Location Code" := SalesHeader_l."Location Code";
            SalesLine_l."SOMS Order No." := SalesHeader_l."SOMS Order No.";
            SalesLine_l.Validate("VAT Prod. Posting Group", 'VAT5');
            SalesLine_l.INSERT(true);
        end;
        if Shipfee_p <> 0 then begin
            SalesLine_l.INIT;
            SalesLine_l."Document Type" := SalesHeader_l."Document Type";
            SalesLine_l."Document No." := SalesHeader_l."No.";
            SalesLine_l."Line No." := 20000;
            SalesLine_l.VALIDATE("Sell-to Customer No.", SalesHeader_l."Sell-to Customer No.");
            SalesLine_l.Type := SalesLine_l.Type::"G/L Account";
            SalesLine_l.Validate("No.", IntegrationSetup."Ship Fee GL");
            SalesLine_l.VALIDATE(Quantity, 1);
            SalesLine_l.Validate("Currency Code", SalesHeader_l."Currency Code");
            SalesLine_l.Validate("Unit Price", Shipfee_p);
            SalesLine_l."Location Code" := SalesHeader_l."Location Code";
            SalesLine_l."SOMS Order No." := SalesHeader_l."SOMS Order No.";
            SalesLine_l.Validate("VAT Prod. Posting Group", 'VAT5');
            SalesLine_l.INSERT(true);
        end;
        if (OrderAmount_p <> 0) or (Shipfee_p <> 0) then begin
            SalesHeader_l.Invoice := true;
            //Commit();
            Clear(SalesPost);
            SalesPost.Run(SalesHeader_l);
        end;
    end;

    local procedure Insert_SalesNegGV(var TempSalesHeader: Record "Sales Header"; var PaymentReceive_p: decimal; CustomerPostingGroup_p: code[10]; status: code[20])
    var
        IntegrationSetup: Record "Integration Setup";
        SalesLine: Record "Sales Line";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        if PaymentReceive_p = 0 then
            exit;
        IntegrationSetup.Get();
        GenJournalLine.LockTable();
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := IntegrationSetup."SOMS Pos. Journal Templ. Name";
        GenJournalLine."Journal Batch Name" := IntegrationSetup."SOMS Pos. Journal Batch Name";
        GenJournalLine."Line No." := GetLastLineNo(IntegrationSetup."SOMS Pos. Journal Templ. Name", IntegrationSetup."SOMS Pos. Journal Batch Name");
        GenJournalLine."Document No." := TempSalesHeader."SOMS Order No.";
        GenJournalLine."External Document No." := status;
        GenJournalLine.Insert(true);
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Refund;
        GenJournalLine."SOMS Order No." := TempSalesHeader."SOMS Order No.";
        GenJournalLine."Posting Date" := TempSalesHeader."Posting Date";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine.Validate("Account No.", TempSalesHeader."Sell-to Customer No.");
        GenJournalLine.validate("Posting Group", CustomerPostingGroup_p);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        if CustomerPostingGroup_p = 'QE' then
            GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."QE Control Account")
        else
            if CustomerPostingGroup_p = 'QA' then
                GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."QA Control Account")
            else
                if CustomerPostingGroup_p = 'CC' then
                    GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."CC Control Account")
                else
                    GenJournalLine.Validate("Bal. Account No.", IntegrationSetup."CC Control Account");
        GenJournalLine.validate("Currency Code", TempSalesHeader."Currency Code");
        GenJournalLine.Validate(Amount, PaymentReceive_p);
        GenJournalLine.Validate("Shortcut Dimension 1 Code", TempSalesHeader."Shortcut Dimension 1 Code");
        GenJournalLine.Validate("Shortcut Dimension 2 Code", TempSalesHeader."Shortcut Dimension 2 Code");
        GenJournalLine.validate("Dimension Set ID", TempSalesHeader."Dimension Set ID");
        GenJournalLine."SOMS Create DateTime" := CurrentDateTime;
        GenJournalLine.Modify(true);
        GenJnlPostBatch.Run(GenJournalLine);
    end;

    local procedure PostQueueGenJournalLine()
    var
        IntegrationSetup: Record "Integration Setup";
        PostDatetime_l: DateTime;
    begin
        PostDatetime_l := 0DT;
        IntegrationSetup.Get();
        PostDatetime_l := IntegrationSetup."Last Post GV DateTime";
        IntegrationSetup.TestField("SOMS Pos. Journal Templ. Name");
        IntegrationSetup.TestField("SOMS Pos. Journal Batch Name");
        PostGenJournalLine(IntegrationSetup."SOMS Pos. Journal Templ. Name", IntegrationSetup."SOMS Pos. Journal Batch Name", PostDatetime_l);
        // IntegrationSetup.TestField("SOMS Neg. Journal Templ. Name");
        // IntegrationSetup.TestField("SOMS Neg. Journal Batch Name");
        // PostGenJournalLine(IntegrationSetup."SOMS Neg. Journal Templ. Name", IntegrationSetup."SOMS Neg. Journal Batch Name", PostDatetime_l);
    end;

    local procedure PostGenJournalLine(var JournalTemplateName: code[50]; var JournalBatchName: code[50]; var PostDatetime: DateTime)
    var
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        IntegrationSetup: Record "Integration Setup";
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJournalLine.SetFilter("SOMS Create DateTime", '%1..%2', PostDatetime, PostDatetime + (2 * 60 * 60 * 1000));
        if GenJournalLine.FindSet() then
            GenJnlPostBatch.Run(GenJournalLine);
        IntegrationSetup.Get();
        IntegrationSetup."Last Post GV DateTime" := PostDatetime + (2 * 60 * 60 * 1000);
        IntegrationSetup.Modify();
    end;

    local procedure GetLastLineNo(var JournalTemplateName: code[50]; var JournalBatchName: code[50]): Integer;
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if GenJournalLine.FindLast() then
            exit(GenJournalLine."Line No." + 10000)
        else
            exit(10000)
    end;
    //RK20211108+

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptHeaderInsert', '', true, true)]
    local procedure "Sales-Post_OnBeforeSalesShptHeaderInsert"
    (
        var SalesShptHeader: Record "Sales Shipment Header";
        SalesHeader: Record "Sales Header";
        CommitIsSuppressed: Boolean;
        var IsHandled: Boolean
    )
    begin
        SalesShptHeader."SOMS Order No." := SalesHeader."SOMS Order No.";
        SalesShptHeader.Reference_Id := SalesHeader.Reference_Id;
        SalesShptHeader.Integrated_order := SalesHeader.Integrated_order;
        SalesShptHeader."Virtual Sales" := SalesHeader."Virtual Sales";
        SalesShptHeader."Receipt No." := SalesHeader."Receipt No.";
        SalesShptHeader.IRID := SalesHeader.IRID;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptLineInsert', '', true, true)]
    local procedure "Sales-Post_OnBeforeSalesShptLineInsert"
    (
        var SalesShptLine: Record "Sales Shipment Line";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesLine: Record "Sales Line";
        CommitIsSuppressed: Boolean;
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        SalesHeader: Record "Sales Header";
        WhseShip: Boolean;
        WhseReceive: Boolean;
        ItemLedgShptEntryNo: Integer;
        xSalesLine: Record "Sales Line";
        var TempSalesLineGlobal: Record "Sales Line";
        var IsHandled: Boolean
    )
    begin
        SalesShptLine."SOMS Ship No" := SalesLine."SOMS Ship No";
        SalesShptLine."SOMS Order No." := SalesLine."SOMS Order No.";
        SalesShptLine."SOMS Line No." := SalesLine."SOMS Line No.";
        SalesShptLine.TCO := SalesLine.TCO;
        SalesShptLine.AWB := SalesLine.AWB;
        SalesShptLine."Courier ID" := SalesLine."Courier ID";
    end;

    local procedure GetLostStrValue(VAR SalesOrderStaging2: Record "Sales Order Staging" temporary)
    var
        l: Integer;
        SalesOrderStagingRec_l: Record "Sales Order Staging";
    begin
        SalesOrderStagingRec_l.Reset();
        SalesOrderStagingRec_l.SetRange(OrderNo, SalesOrderStaging2.OrderNo);
        SalesOrderStagingRec_l.SetFilter("Queue Status", '<>%1', SalesOrderStaging2."Queue Status"::Processed);
        SalesOrderStagingRec_l.SetFilter(productCode, '<>%1', '');
        SalesOrderStagingRec_l.SetRange(statusId, '101');
        if SalesOrderStagingRec_l.FindSet() then begin
            repeat
                l := 1;
                while (l < StrLen(SalesOrderStagingRec_l.Remarks)) do begin
                    IF UPPERCASE(COPYSTR(SalesOrderStagingRec_l.Remarks, l, 4)) = UPPERCASE('Lost') THEN begin
                        l := STRLEN(SalesOrderStagingRec_l.Remarks);
                        SalesOrderStagingRec_l."Queue Status" := SalesOrderStagingRec_l."Queue Status"::Processed;
                        SalesOrderStagingRec_l."Error Message" := '';
                        SalesOrderStagingRec_l."Retry Count" := 0;
                        SalesOrderStagingRec_l."Processed Date" := CurrentDateTime;
                        SalesOrderStagingRec_l."Lost IN Transit" := true;
                        SalesOrderStagingRec_l.Modify(true);
                        Commit();
                    end;
                    l += 1;
                end;
            until SalesOrderStagingRec_l.Next() = 0;
        end;
    end;

    local procedure SalesLieQtytoShipZero(TempSalesHeader: Record "Sales Header" temporary)
    var
        SalesLine_l: Record "Sales Line";
    begin
        SalesLine_l.Reset();
        SalesLine_l.SetRange("Document No.", TempSalesHeader."No.");
        SalesLine_l.SetRange(Type, SalesLine_l.Type::Item);
        salesline_l.setfilter("Qty. to Ship", '<>%1', 0);
        SalesLine_l.ModifyAll("Qty. to Ship", 0);
        SalesLine_l.ModifyAll("Qty. to Invoice", 0);
    end;

    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesHeader: Record "Sales Header";
        // SalesLine: Record "Sales Line";
        SalesOrderStaging: Record "Sales Order Staging";
        SalesOrderStaging2: Record "Sales Order Staging";
        TempICQueueOrderPost: Record "Sales Order Staging";
        TmpJobQueueEntry: Record "Job Queue Entry";
        JobQueueProcesses: Codeunit "Sales Post Job Batch";
        Customer: Record Customer;
        StatusId: Text[10];
        Orderno: Text;
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionValue: Record "Dimension Value";
        VirtualSales_G: Boolean;
        LostInTransit: Boolean;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        InvokeSOMSAPI: Codeunit "Invoke SOMS API";
        CurrExchRate: Record "Currency Exchange Rate";
        currency: Record Currency;
        ControlPaymentMethod: code[10];


}