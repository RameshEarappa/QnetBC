codeunit 50005 "Integration Utility"
{
    Permissions = tabledata 6550 = RIMD;
    trigger OnRun()
    begin

    end;

    procedure InsertLog(IntegrationType: Enum "Integration Type"; IntegrationFn: Enum "Integration Function"; RequestData: Text; URL: Text): Integer
    var
        EntryNo: Integer;
        RecLog: Record "Integration Log Register";
    begin
        Clear(RecLog);
        if RecLog.FindLast() then
            EntryNo := RecLog."Entry No." + 1
        else
            EntryNo := 1;
        RecLog.Init();
        RecLog."Entry No." := EntryNo;
        RecLog."Integration Type" := IntegrationType;
        RecLog."Integration Function" := IntegrationFn;
        RecLog.SetRequestData(RequestData);
        RecLog."Request Time" := CurrentDateTime;
        RecLog.URL := URL;
        RecLog.Status := RecLog.Status::Failed;
        RecLog.Insert();
        exit(EntryNo);
    end;

    procedure ModifyLog(EntryNo: Integer; Status: Option " ",Success,Failed; ErrorText: Text; Response: Text)
    var
        RecLog: Record "Integration Log Register";
    begin
        If RecLog.GET(EntryNo) then begin
            RecLog.SetResponseData(Response);
            RecLog.Status := Status;
            RecLog."Error Text" := ErrorText;
            RecLog."Response Time" := CurrentDateTime;
            RecLog.Modify();
        end;
    end;
}