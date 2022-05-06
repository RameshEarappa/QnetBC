report 50014 "Reset Sales Order staging"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(POST)
                {
                    field(statusId; statusId)
                    {
                        ApplicationArea = All;
                        Caption = 'Add Postfix No.';

                    }
                    field(SOMSOrderNO; SOMSOrderNO)
                    {
                        ApplicationArea = All;
                        Caption = 'SOMS Order No.';

                    }

                }
            }
        }

        actions
        {

        }
    }

    trigger OnPostReport()
    begin
        sso.Reset();
        sso.SetFilter(OrderNo, SOMSOrderNO);
        sso.SetFilter(statusId, '<>%1|<>%2', '21', '101');
        sso.FindFirst();
        repeat
            sso.OrderNo := sso.OrderNo + statusId;
            sso."Queue Status" := sso."Queue Status"::Pending;
            sso."Retry Count" := 0;
            sso.SHIPNO := sso.SHIPNO + statusId;
            sso."BC Document No." := '';
            sso."Posted BC Document No." := '';
            sso."Error Message" := '';
            sso."Process Remarks" := '';
            sso."EarliestStart Date/Time" := 0DT;
            sso.Modify();
        until sso.Next() = 0;


    end;

    var
        sso: Record "Sales Order Staging";
        myInt: Integer;
        statusId: Text[10];
        SOMSOrderNO: text;
        postvirtualsales: Boolean;
        GlobalParemeter: Text;
        JQEntries: Record "Job Queue Entry";
        Sales_Order: Codeunit "Sales Post Job Batch";
}