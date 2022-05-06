codeunit 50101 "Manual Run Job"
{
    trigger OnRun()
    begin
        ///GlobalParemeter := 'ICQueueOrderPost';
        //MAnualJQ;
        IntegrationApi();
    end;

    LOCAL procedure MAnualJQ()
    begin
        IF CONFIRM('Do you want to run paremeter in JOB=' + FORMAT(GlobalParemeter), FALSE) THEN BEGIN
            JQEntries.RESET;
            JQEntries.SETRANGE("Parameter String", 'ICQueueOrderPost');
            IF JQEntries.FIND('-') THEN BEGIN
                CODEUNIT.RUN(CODEUNIT::"Sales Post Job Batch", JQEntries);
            END;
        END;
    end;

    procedure IntegrationApi()
    begin
        response := apiCodeunit.GetSalesOrderInfo(errorMsg);
        if errorMsg <> '' then
            Error(errorMsg)
        else
            Message('Your API Call Response: \' + response);

        if response <> '' then begin
            if apiResponseHandler.SalesOrderInfoFromResponse(response) then
                Message('Records inserted Successfully!');
        end;
    end;

    var

        apiCodeunit: Codeunit "Invoke SOMS API";
        response: Text;
        errorMsg: Text;
        apiResponseHandler: Codeunit "SOMS API Response";
        GlobalParemeter: Text;
        JQEntries: Record "Job Queue Entry";
}