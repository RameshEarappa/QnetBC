codeunit 50003 "SOMS API Response"
{
    trigger OnRun()
    begin
    end;

    procedure SalesOrderInfoFromResponse(response: Text): Boolean
    var
        responseArray: JsonArray;
        json_Token: JsonToken;
        json_Object: JsonObject;
        userInfo_JsonObject: JsonObject;
        gjson_Object: JsonObject;
        i: Integer;
        EntryNo: Integer;
        SalesOrderStagingLastEntry: Record "Sales Order Staging";
    begin
        if SalesOrderStagingLastEntry.FindLast() then
            EntryNo := SalesOrderStagingLastEntry."Entry No.";
        if json_Object.ReadFrom(response) then begin
            if json_Object.Get('result', json_Token) then
                responseArray := json_Token.AsArray();
            if json_Token.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                responseArray := json_Token.AsArray();
            for i := 0 to responseArray.Count() - 1 do begin
                // Get First Array Result
                responseArray.Get(i, json_Token);
                // Convert JsonToken to JsonObject
                if json_Token.IsObject then begin
                    userInfo_JsonObject := json_Token.AsObject();
                    EntryNo += 1;
                    insertSalesOrdersInStaging(userInfo_JsonObject, EntryNo);
                end;

            end;
        end;
        exit(true);
    end;

    procedure insertSalesOrdersInStaging(userInfoJsonObject: JsonObject; entryno: integer)
    var
        SalesOrderStaging: Record "Sales Order Staging";
        SalesOrderStagingLastEntry: Record "Sales Order Staging";
        json_Methods: Codeunit JSON_Methods;
        retJsonValue: JsonValue; // this can be used when getting value from GetJsonValue method
        addressJsonObject: JsonObject;
        addressJsonToken: JsonToken;
        geoJsonObject: JsonObject;
        geoJsonToken: JsonToken;
        companyJsonObject: JsonObject;
        companyJsonToken: JsonToken;
        Time1: Time;
        orderDatetext: Text;
    begin
        SalesOrderStaging.Reset();
        SalesOrderStaging.Init();
        SalesOrderStaging.id := json_Methods.GetJsonToken(userInfoJsonObject, 'id').AsValue().AsInteger();
        SalesOrderStaging.id := json_Methods.GetJsonValueAsInteger(userInfoJsonObject, 'id');
        if json_Methods.GetJsonValue(userInfoJsonObject, 'id', retJsonValue) then
            SalesOrderStaging.id := retJsonValue.AsInteger();
        SalesOrderStaging.OrderNo := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'orderNo');
        SalesOrderStaging.SHIPNO := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'shipNo');
        SalesOrderStaging.ReceiptNo := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'receiptNo');
        SalesOrderStaging.OrderType := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'orderType');
        SalesOrderStaging.ORDERDATE := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'orderDate');
        SalesOrderStaging.CURRENCY := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'currency');
        SalesOrderStaging.PaymentMethod := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'paymentMethod');
        SalesOrderStaging.productCode := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'productCode');
        SalesOrderStaging.PLANT := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'plant');
        SalesOrderStaging."Receipt Date" := json_Methods.GetJsonValueAsDateTime(userInfoJsonObject, 'receiptDate');
        orderDatetext := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'receiptDate'), 1, 10);
        Evaluate(SalesOrderStaging."Order Date", orderDatetext);
        Evaluate(Time1, CopyStr(Format(DT2Time(SalesOrderStaging."Receipt Date")), 1, 5));
        SalesOrderStaging."Receipt Date" := CreateDateTime(DT2Date(SalesOrderStaging."Receipt Date"), Time1);
        SalesOrderStaging.SLOC := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'sloc');
        SalesOrderStaging.QTY := json_Methods.GetJsonValueAsInteger(userInfoJsonObject, 'quantity');
        SalesOrderStaging.comboProductCode := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'comboProductCode');
        SalesOrderStaging.ITEMNO := json_Methods.GetJsonValueAsInteger(userInfoJsonObject, 'itemNo');
        SalesOrderStaging.REF_SHIPNO := json_Methods.GetJsonValueAsInteger(userInfoJsonObject, 'ref_ShipNo');
        SalesOrderStaging.AMOUNT := json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'usPayAmount');
        SalesOrderStaging.OAMOUNT := json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'oamount');
        SalesOrderStaging.TCO := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'tco');
        SalesOrderStaging.EMAIL := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'eMail');
        SalesOrderStaging.SHIP_STATE := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'state');
        SalesOrderStaging.SHIP_ZIPCODE := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'zipCode');
        SalesOrderStaging.CURRENCY := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'currency');
        SalesOrderStaging.address1 := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'address1');
        SalesOrderStaging.address2 := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'address2');
        SalesOrderStaging.SHIP_CITY := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'city');
        SalesOrderStaging."Entry No." := entryno;
        SalesOrderStaging.productName := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'productName'), 1, 50);
        SalesOrderStaging.storageLocation := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'storageLocation'), 1, 50);
        SalesOrderStaging.Year := json_Methods.GetJsonValueAsInteger(userInfoJsonObject, 'year');
        SalesOrderStaging.Week := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'week');
        SalesOrderStaging.statusId := UpperCase(copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'statusId'), 1, 10));
        SalesOrderStaging.statusDesc := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'statusDesc'), 1, 150);
        SalesOrderStaging.Remarks := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'remarks'), 1, 1024);
        SalesOrderStaging.ShipFee := json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'shipFee');
        SalesOrderStaging.CountryCode := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'countryCode'), 1, 10);
        SalesOrderStaging.contactNo_Home := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'contactNo_Home');
        SalesOrderStaging.awb := copystr(json_Methods.GetJsonValueAsText(userInfoJsonObject, 'awb'), 1, 20);
        SalesOrderStaging.courierID := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'courierID');
        SalesOrderStaging.ContactNo_Mobile := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'ContactNo_Mobile');
        if NOt ((SalesOrderStaging.statusId = '23')
        OR (SalesOrderStaging.statusId = '50')
        OR (SalesOrderStaging.statusId = '102')
        OR (SalesOrderStaging.statusId = '120')
        OR (SalesOrderStaging.statusId = '54')
        OR (SalesOrderStaging.statusId = '101')) then begin
            SalesOrderStaging."Queue Status" := SalesOrderStaging."Queue Status"::Processed;
            SalesOrderStaging."Process Remarks" := 'No need to process in BC'
        end;
        SalesOrderStaging."Entry Date/Time" := CurrentDateTime;
        SalesOrderStaging.Insert(true);
    end;

    procedure ParseBOMDetails(response: Text; ParentItem: Code[50]): Boolean
    var
        responseArray: JsonArray;
        json_Token: JsonToken;
        json_Token2: JsonToken;
        json_Object: JsonObject;
        userInfo_JsonObject: JsonObject;
        gjson_Object: JsonObject;
        i: Integer;
        EntryNo: Integer;
        AssemblyBom: Record "BOM Component";
        json_Methods: Codeunit JSON_Methods;
    begin
        if json_Object.ReadFrom(response) then begin
            if not json_Methods.GetJsonValueAsBoolean(json_Object, 'isSuccess') then
                exit(false);
            //json_Object.Get('result', json_Token2);
            //Message('%1', json_Token2.AsObject());
            if json_Object.Get('result', json_Token) then
                responseArray := json_Token.AsArray();
            if json_Token.IsArray then
                responseArray := json_Token.AsArray();
            for i := 0 to responseArray.Count() - 1 do begin
                responseArray.Get(i, json_Token);
                if json_Token.IsObject then begin
                    userInfo_JsonObject := json_Token.AsObject();
                    InsertAssemblyBom(userInfo_JsonObject, ParentItem);
                end;

            end;
        end;
        exit(true);
    end;

    procedure InsertAssemblyBom(userInfoJsonObject: JsonObject; ParentItem: Code[50])
    var
        AssemblyBom: Record "BOM Component";
        AssemblyBom2: Record "BOM Component";
        json_Methods: Codeunit JSON_Methods;
        BOMItemNo: Code[20];
    begin
        BOMItemNo := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'productCode');
        AssemblyBom.Reset();
        AssemblyBom.SetRange("Parent Item No.", ParentItem);
        AssemblyBom.SetRange("No.", BOMItemNo);
        if AssemblyBom.FindFirst() then begin
            AssemblyBom.Validate("Quantity per", json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'qty'));
            AssemblyBom.Modify();
        end else begin
            AssemblyBom2.Reset();
            AssemblyBom2.SetRange("Parent Item No.", ParentItem);
            if AssemblyBom2.FindLast() then;
            AssemblyBom.Init();
            AssemblyBom."Parent Item No." := ParentItem;
            AssemblyBom.Type := AssemblyBom.Type::Item;
            AssemblyBom."Line No." := AssemblyBom2."Line No." + 10000;
            AssemblyBom.Validate("No.", BOMItemNo);
            AssemblyBom.Validate("Quantity per", json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'qty'));
            AssemblyBom.Insert();
        end;
    end;

    procedure ParseGRNInfo(response: Text): Boolean
    var
        responseArray: JsonArray;
        json_Token: JsonToken;
        json_Token2: JsonToken;
        json_Object: JsonObject;
        userInfo_JsonObject: JsonObject;
        gjson_Object: JsonObject;
        i: Integer;
        EntryNo: Integer;
        json_Methods: Codeunit JSON_Methods;
        PurchaseOrderKittingInfo: Record "Purchase Order Kitting Info";
    begin
        PurchaseOrderKittingInfo.Reset();
        if PurchaseOrderKittingInfo.FindLast() then
            EntryNo := PurchaseOrderKittingInfo."Entry No.";
        if json_Object.ReadFrom(response) then begin
            if not json_Methods.GetJsonValueAsBoolean(json_Object, 'isSuccess') then
                exit(false);
            if json_Object.Get('result', json_Token) then
                responseArray := json_Token.AsArray();
            if json_Token.IsArray then
                responseArray := json_Token.AsArray();
            for i := 0 to responseArray.Count() - 1 do begin
                responseArray.Get(i, json_Token);
                if json_Token.IsObject then begin
                    EntryNo += 1;
                    userInfo_JsonObject := json_Token.AsObject();
                    InsertGRNInfo(userInfo_JsonObject, EntryNo);
                end;

            end;
        end;
        exit(true);
    end;

    procedure InsertGRNInfo(userInfoJsonObject: JsonObject; EntryNo: Integer)
    var
        PurchaseOrderKittingInfo: Record "Purchase Order Kitting Info";
        json_Methods: Codeunit JSON_Methods;
    begin
        PurchaseOrderKittingInfo.Init();
        PurchaseOrderKittingInfo."Entry No." := EntryNo;
        PurchaseOrderKittingInfo."PO No." := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'poNo');
        PurchaseOrderKittingInfo."PO Line No." := json_Methods.GetJsonValueAsInteger(userInfoJsonObject, 'itemNo');
        PurchaseOrderKittingInfo."Item No." := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'productCode');
        PurchaseOrderKittingInfo.Quantity := json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'qty');
        PurchaseOrderKittingInfo."Putway DateTime" := json_Methods.GetJsonValueAsDateTime(userInfoJsonObject, 'putawayDate');
        PurchaseOrderKittingInfo.Insert(true);
    end;

    procedure ParseAssemblyOrderInfo(response: Text): Boolean
    var
        responseArray: JsonArray;
        json_Token: JsonToken;
        json_Token2: JsonToken;
        json_Object: JsonObject;
        userInfo_JsonObject: JsonObject;
        gjson_Object: JsonObject;
        i: Integer;
        EntryNo: Integer;
        json_Methods: Codeunit JSON_Methods;
        StagingAssemblyOrder: Record "Staging Assembly Order";
    begin
        StagingAssemblyOrder.Reset();
        if StagingAssemblyOrder.FindLast() then
            EntryNo := StagingAssemblyOrder."Entry No.";
        if json_Object.ReadFrom(response) then begin
            if not json_Methods.GetJsonValueAsBoolean(json_Object, 'isSuccess') then
                exit(false);
            if json_Object.Get('result', json_Token) then
                responseArray := json_Token.AsArray();
            if json_Token.IsArray then
                responseArray := json_Token.AsArray();
            for i := 0 to responseArray.Count() - 1 do begin
                responseArray.Get(i, json_Token);
                if json_Token.IsObject then begin
                    EntryNo += 1;
                    userInfo_JsonObject := json_Token.AsObject();
                    InsertAssemblyOrderInfo(userInfo_JsonObject, EntryNo);
                end;

            end;
        end;
        exit(true);
    end;

    procedure InsertAssemblyOrderInfo(userInfoJsonObject: JsonObject; EntryNo: Integer)
    var
        StagingAssemblyOrder: Record "Staging Assembly Order";
        json_Methods: Codeunit JSON_Methods;
    begin
        StagingAssemblyOrder.Init();
        StagingAssemblyOrder."Entry No." := EntryNo;
        StagingAssemblyOrder."FG Item No." := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'fG_ProductCode');
        StagingAssemblyOrder."Assembly Item No." := json_Methods.GetJsonValueAsText(userInfoJsonObject, 'productCode');
        StagingAssemblyOrder.Quantity := json_Methods.GetJsonValueAsDecimal(userInfoJsonObject, 'qty');
        StagingAssemblyOrder.Insert(true);
    end;


    local procedure GetLostStrValue(Var InputValue: text[100])
    begin
        l := 1;
        Lostintransit := false;
        while (l < StrLen(InputValue)) do begin
            IF UPPERCASE(COPYSTR(InputValue, l, 4)) = UPPERCASE('Lost') THEN begin
                Lostintransit := true;
                l := STRLEN(InputValue);
            end;
            l += 1;
        end;
    end;

    var
        l: Integer;
        Lostintransit: Boolean;

}