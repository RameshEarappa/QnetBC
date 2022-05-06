report 50016 "Post PO Job Batch"
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

                    field(SOMSOrderNO; SOMSOrderNO)
                    {
                        ApplicationArea = All;
                        Caption = 'PO No.';

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
                Purchase_Post.SetStatusId(SOMSOrderNO);
                Purchase_Post.Run(JQEntries);
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
        Purchase_Post: Codeunit "Purchase Post Job Batch";
}