report 50009 "Post Batch"
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
                        Caption = 'StatusId';

                    }
                    field(SOMSOrderNO; SOMSOrderNO)
                    {
                        ApplicationArea = All;
                        Caption = 'SOMS Order No.';

                    }
                    field(postvirtualsales; postvirtualsales)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Virtual Sales';
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
        IF CONFIRM('Do you want to run paremeter in JOB=ICQueueOrderPost', FALSE) THEN BEGIN
            JQEntries.RESET;
            JQEntries.SETRANGE("Parameter String", 'ICQueueOrderPost');
            IF JQEntries.FIND('-') THEN BEGIN
                Sales_Order.SetStatusId(statusId, SOMSOrderNO, postvirtualsales);
                Sales_Order.Run(JQEntries);//
                //CODEUNIT.RUN(CODEUNIT::"Sales Order Processing", JQEntries);
            END;
        END;
    end;

    var
        myInt: Integer;
        statusId: Text[10];
        SOMSOrderNO: code[20];
        postvirtualsales: Boolean;
        GlobalParemeter: Text;
        JQEntries: Record "Job Queue Entry";
        Sales_Order: Codeunit "Sales Post Job Batch";
}