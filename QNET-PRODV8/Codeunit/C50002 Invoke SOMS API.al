codeunit 50002 "Invoke SOMS API"
{
    trigger OnRun()
    begin
        GetSalesOrderInfo('');
        //StoreNewPO();
    end;


    procedure GetSalesOrderInfo(erroMsg: Text): Text
    var
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        gResponseMsg: Text;
        gRequestMsg: Text;
        AddJson: JsonObject;
        IntegrationSetup: Record "Integration Setup";
        FunctionEnum: Enum "Integration Function";
        Intgration: Codeunit "Invoke Service";
        Status: Option " ",Success,Failed;
        IsSuccess: Boolean;
        Response: Text;
        Bearervalue: Text;
        EndingDatetime: DateTime;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Get Sales Order URL");
        Bearervalue := 'Bearer ' + Get_Token();
        erroMsg := '';
        gRequestMsg := '';
        if IntegrationSetup."Last Get Order  Datet/Time" + (2 * 60 * 60 * 1000) < CurrentDateTime then
            EndingDatetime := IntegrationSetup."Last Get Order  Datet/Time" + (2 * 60 * 60 * 1000)
        else
            EndingDatetime := CurrentDateTime + (5 * 60 * 60 * 1000);
        AddJson.Add('StartDate', IntegrationSetup."Last Get Order  Datet/Time");
        AddJson.Add('EndDate', EndingDatetime);
        AddJson.WriteTo(gRequestMsg);
        Message(gRequestMsg);
        LogEntryNo := Utility.InsertLog(TypeEnum::"SOMS To BC", FunctionEnum::"Insert Sales Orders", gRequestMsg, IntegrationSetup."Get Sales Order URL");
        ClearLastError();
        gContent.WriteFrom(gRequestMsg);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gHttpClient.DefaultRequestHeaders().Add('Authorization', Bearervalue);
        if gHttpClient.Post(IntegrationSetup."Get Sales Order URL", gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                Message(gResponseMsg);
                Utility.ModifyLog(LogEntryNo, Status::Success, '', gResponseMsg);
                apiResponseHandler.SalesOrderInfoFromResponse(gResponseMsg);
                IntegrationSetup."Last Get Order  Datet/Time" := EndingDatetime;
                IntegrationSetup.Modify();
                Commit();
                erroMsg := 'Records Sent Successfully!';
            end else begin
                Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(gResponseMsg, 1, 250), gResponseMsg);
                erroMsg := '1-Something went wrong while connecting SOMS. Please check Log Register.';
                Message(erroMsg);
            end;
        end else begin
            Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
            erroMsg := 'Something went wrong while connecting SOMS. Please check Log Register.';
            Message(erroMsg);
        end;
    end;

    procedure StoreNewPO()
    var
        AddJson: JsonObject;
        IntegrationSetup: Record "Integration Setup";
        FunctionEnum: Enum "Integration Function";
        Intgration: Codeunit "Invoke Service";
        Status: Option " ",Success,Failed;
        IsSuccess: Boolean;
        Vendor: Record Vendor;
        Item: Record Item;
        VJsonArray: JsonArray;
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        gResponseMsg: Text;
        gRequestMsg: Text;
        Bearervalue: Text;
        IntQty: Integer;
        PurchaseHeader2: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Store New PO URL");
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange(Status, PurchaseHeader.Status::Released);
        PurchaseHeader.SetRange("Sync with SOMS", PurchaseHeader."Sync with SOMS"::"To be sync");
        if PurchaseHeader.FindFirst() then begin
            repeat
                PurchaseLine.Reset();
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SetFilter("Integration Status", '<>%1', PurchaseLine."Integration Status"::Synced);
                PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                if PurchaseLine.FindFirst() then begin
                    repeat
                        Clear(AddJson);
                        Bearervalue := 'Bearer ' + Get_Token();
                        Message(Bearervalue);
                        gRequestMsg := '';
                        gResponseMsg := '';
                        vendor.Get(PurchaseLine."Buy-from Vendor No.");
                        AddJson.add('poNo', PurchaseHeader."No.");
                        AddJson.Add('vendorCode', PurchaseHeader."Buy-from Vendor No.");
                        AddJson.Add('vendorName', PurchaseHeader."Buy-from Vendor Name");
                        AddJson.Add('address', PurchaseHeader."Buy-from Address");
                        AddJson.Add('address2', PurchaseHeader."Buy-from Address 2");
                        AddJson.Add('city', PurchaseHeader."Buy-from City");
                        if Vendor.contact <> '' then
                            AddJson.Add('contact', PurchaseHeader."Buy-from Contact")
                        else
                            AddJson.Add('contact', 'NA');
                        AddJson.Add('postalCode', PurchaseHeader."Buy-from Post Code");
                        if CountryRegion.Get(PurchaseHeader."Buy-from Country/Region Code") then;

                        AddJson.Add('country', CountryRegion.Name);
                        AddJson.Add('countryCode', PurchaseHeader."Buy-from Country/Region Code");
                        AddJson.Add('itemNo', PurchaseLine."Line No.");
                        if PurchaseLine."Location Code" <> '' then
                            AddJson.Add('storageLocation', PurchaseHeader."Location Code")
                        else
                            AddJson.Add('storageLocation', 'AE');
                        addjson.Add('courierId', 'NA');
                        AddJson.Add('awb', 'NA');
                        AddJson.Add('productCode', PurchaseLine."No.");
                        AddJson.Add('productDesc', PurchaseLine.Description);
                        AddJson.Add('productDesc2', PurchaseLine."Description 2");
                        AddJson.Add('unitMeasure', PurchaseLine."Unit of Measure Code");
                        IntQty := PurchaseLine.Quantity;
                        AddJson.Add('quantity', IntQty);
                        AddJson.Add('directUnitCost', PurchaseLine."Direct Unit Cost");
                        AddJson.Add('amount', PurchaseLine.Amount);
                        AddJson.Add('updatedBy', UserId);
                        AddJson.WriteTo(gRequestMsg);
                        Message(gRequestMsg);
                        LogEntryNo := Utility.InsertLog(TypeEnum::"BC To SOMS", FunctionEnum::"Send Store PO", gRequestMsg, IntegrationSetup."Store New PO URL");
                        ClearLastError();
                        Commit();
                        gContent.WriteFrom(gRequestMsg);
                        gContent.GetHeaders(gContentHeaders);
                        gContentHeaders.Clear();
                        gContentHeaders.Add('Content-Type', 'application/json');
                        gHttpClient.Clear();
                        gHttpClient.DefaultRequestHeaders().Add('Authorization', Bearervalue);
                        if gHttpClient.Post(IntegrationSetup."Store New PO URL", gContent, gHttpResponseMsg) then begin
                            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
                            if gHttpResponseMsg.IsSuccessStatusCode then begin
                                Message(gResponseMsg);
                                Utility.ModifyLog(LogEntryNo, Status::Success, '', gResponseMsg);
                                PurchaseLine."Integration Status" := PurchaseLine."Integration Status"::Synced;
                                PurchaseLine.Modify();
                                Commit();
                            end else begin
                                Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(gResponseMsg, 1, 250), gResponseMsg);
                                Message(gResponseMsg);
                            end;
                        end else begin
                            Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
                        end;
                    until PurchaseLine.Next() = 0;
                end;
                PurchaseLine.Reset();
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                PurchaseLine.SetFilter("Integration Status", '<>%1', PurchaseLine."Integration Status"::Synced);
                if not PurchaseLine.FindFirst() then begin
                    PurchaseHeader."Sync with SOMS" := PurchaseHeader."Sync with SOMS"::Synced;
                    PurchaseHeader.Modify();
                    Commit();
                end;
            until PurchaseHeader.Next() = 0;
        end;
    end;

    procedure GetBOMDetails()
    var
        AddJson: JsonObject;
        IntegrationSetup: Record "Integration Setup";
        FunctionEnum: Enum "Integration Function";
        Intgration: Codeunit "Invoke Service";
        Status: Option " ",Success,Failed;
        Item: Record Item;
        VJsonArray: JsonArray;
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        gResponseMsg: Text;
        gRequestMsg: Text;
        Bearervalue: Text;
        IntQty: Integer;
        PurchaseHeader2: Record "Purchase Header";
        Item2: Record Item;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Get BOM Details URL");
        Item.Reset();
        Item.SetRange("Sync BOM Components", Item."Sync BOM Components"::"To be sync");
        if Item.FindFirst() then begin
            repeat
                Clear(AddJson);
                Bearervalue := 'Bearer ' + Get_Token();
                gRequestMsg := '';
                gResponseMsg := '';
                AddJson.add('fG_ProductCode', Item."No.");
                AddJson.WriteTo(gRequestMsg);
                Message(gRequestMsg);
                LogEntryNo := Utility.InsertLog(TypeEnum::"SOMS To BC", FunctionEnum::"Sync Kitting Product", gRequestMsg, IntegrationSetup."Get BOM Details URL");
                ClearLastError();
                Commit();
                gContent.WriteFrom(gRequestMsg);
                gContent.GetHeaders(gContentHeaders);
                gContentHeaders.Clear();
                gContentHeaders.Add('Content-Type', 'application/json');
                gHttpClient.Clear();
                gHttpClient.DefaultRequestHeaders().Add('Authorization', Bearervalue);
                if gHttpClient.Post(IntegrationSetup."Get BOM Details URL", gContent, gHttpResponseMsg) then begin
                    gHttpResponseMsg.Content.ReadAs(gResponseMsg);
                    if gHttpResponseMsg.IsSuccessStatusCode then begin
                        Message(gResponseMsg);
                        Utility.ModifyLog(LogEntryNo, Status::Success, '', gResponseMsg);
                        if apiResponseHandler.ParseBOMDetails(gResponseMsg, Item."No.") then begin
                            Item2.Get(Item."No.");
                            Item2."Sync BOM Components" := Item2."Sync BOM Components"::Synced;
                            Item2.Modify();
                            Commit();
                        end;
                    end else begin
                        Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(gResponseMsg, 1, 250), gResponseMsg);
                        Message(gResponseMsg);
                    end;
                end else begin
                    Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
                end;
            until Item.Next() = 0;
        end;
    end;

    procedure GetGRNInfo()
    var
        AddJson: JsonObject;
        IntegrationSetup: Record "Integration Setup";
        FunctionEnum: Enum "Integration Function";
        Intgration: Codeunit "Invoke Service";
        Status: Option " ",Success,Failed;
        Item: Record Item;
        VJsonArray: JsonArray;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        gResponseMsg: Text;
        gRequestMsg: Text;
        Bearervalue: Text;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Get GRN Info");
        Clear(AddJson);
        Bearervalue := 'Bearer ' + Get_Token();
        gRequestMsg := '';
        gResponseMsg := '';
        AddJson.add('poNo', '');
        AddJson.add('startDate', format(IntegrationSetup."Start DateTime", 0, 9));
        AddJson.add('endDate', format(IntegrationSetup."End DateTime", 0, 9));
        AddJson.WriteTo(gRequestMsg);
        Message(gRequestMsg);
        LogEntryNo := Utility.InsertLog(TypeEnum::"BC To SOMS", FunctionEnum::"Get GRN Info", gRequestMsg, IntegrationSetup."Get GRN Info");
        ClearLastError();
        Commit();
        gContent.WriteFrom(gRequestMsg);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gHttpClient.Clear();
        gHttpClient.DefaultRequestHeaders().Add('Authorization', Bearervalue);
        if gHttpClient.Post(IntegrationSetup."Get GRN Info", gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                Message(gResponseMsg);
                Utility.ModifyLog(LogEntryNo, Status::Success, '', gResponseMsg);
                if apiResponseHandler.ParseGRNInfo(gResponseMsg) then begin
                    IntegrationSetup."Start DateTime" := IntegrationSetup."End DateTime";
                    IntegrationSetup."End DateTime" := CurrentDateTime + (5 * 60 * 60 * 1000);
                    IntegrationSetup.Modify();
                    Commit();
                end;
            end else begin
                Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(gResponseMsg, 1, 250), gResponseMsg);
                Message(gResponseMsg);
            end;
        end else begin
            Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
        end;
    end;

    procedure GetAssemblyOrderInfo()
    var
        AddJson: JsonObject;
        IntegrationSetup: Record "Integration Setup";
        FunctionEnum: Enum "Integration Function";
        Intgration: Codeunit "Invoke Service";
        Status: Option " ",Success,Failed;
        Item: Record Item;
        VJsonArray: JsonArray;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        gResponseMsg: Text;
        gRequestMsg: Text;
        Bearervalue: Text;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Get GRN Info");
        Clear(AddJson);
        Bearervalue := 'Bearer ' + Get_Token();
        gRequestMsg := '';
        gResponseMsg := '';
        AddJson.add('startDate', format(IntegrationSetup."Get Assembly Start DateTime", 0, 9));
        AddJson.add('endDate', format(IntegrationSetup."Get Assembly End DateTime", 0, 9));
        AddJson.WriteTo(gRequestMsg);
        Message(gRequestMsg);
        LogEntryNo := Utility.InsertLog(TypeEnum::"SOMS To BC", FunctionEnum::"Get Assembly Order Info", gRequestMsg, IntegrationSetup."Get Assembly Order URL");
        ClearLastError();
        Commit();
        gContent.WriteFrom(gRequestMsg);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gHttpClient.Clear();
        gHttpClient.DefaultRequestHeaders().Add('Authorization', Bearervalue);
        if gHttpClient.Post(IntegrationSetup."Get Assembly Order URL", gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                Message(gResponseMsg);
                Utility.ModifyLog(LogEntryNo, Status::Success, '', gResponseMsg);
                if apiResponseHandler.ParseAssemblyOrderInfo(gResponseMsg) then begin
                    IntegrationSetup."Get Assembly Start DateTime" := IntegrationSetup."Get Assembly End DateTime";
                    IntegrationSetup."Get Assembly End DateTime" := CurrentDateTime + (5 * 60 * 60 * 1000);
                    IntegrationSetup.Modify();
                    Commit();
                end;
            end else begin
                Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(gResponseMsg, 1, 250), gResponseMsg);
                Message(gResponseMsg);
            end;
        end else begin
            Utility.ModifyLog(LogEntryNo, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
        end;
    end;

    procedure Get_Token(): Text
    var
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        gResponseMsg: Text;
        gRequestMsg: Text;
        AddJson: JsonObject;
        IntegrationSetup: Record "Integration Setup";
        FunctionEnum: Enum "Integration Function";
        Intgration: Codeunit "Invoke Service";
        Status: Option " ",Success,Failed;
        IsSuccess: Boolean;
        Response: Text;
        LogEntryNo1: Integer;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Token Url");
        IntegrationSetup.TestField("Encryption Key");
        IntegrationSetup.TestField("User Name");
        IntegrationSetup.TestField("Email Id");
        AddJson.add('encryptionKey', IntegrationSetup."Encryption Key");
        AddJson.Add('userName', IntegrationSetup."User Name");
        AddJson.Add('email', IntegrationSetup."Email Id");
        AddJson.WriteTo(gRequestMsg);
        LogEntryNo1 := Utility.InsertLog(TypeEnum::" ", FunctionEnum::Token, gRequestMsg, IntegrationSetup."Token Url");
        ClearLastError();
        Commit();
        gContent.WriteFrom(gRequestMsg);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        if gHttpClient.Post(IntegrationSetup."Token Url", gContent, gHttpResponseMsg) then begin
            if gHttpResponseMsg.IsSuccessStatusCode() then begin
                gHttpResponseMsg.Content.ReadAs(gResponseMsg);
                Utility.ModifyLog(LogEntryNo1, Status::Success, '', gResponseMsg);
                exit(gResponseMsg);
            end else begin
                Utility.ModifyLog(LogEntryNo1, Status::Failed, CopyStr(gResponseMsg, 1, 250), Response);
            end;
        end else begin
            Utility.ModifyLog(LogEntryNo1, Status::Failed, CopyStr(GetLastErrorText, 1, 250), GetLastErrorText);
        end;

    end;




    var
        TypeEnum: Enum "Integration Type";
        Utility: Codeunit "Integration Utility";
        LogEntryNo: Integer;
        apiResponseHandler: Codeunit "SOMS API Response";

}