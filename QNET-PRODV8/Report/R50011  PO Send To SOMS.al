report 50011 "Send PO To SOMS"
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

            }
        }

        actions
        {

        }
    }

    trigger OnInitReport()
    begin
        somsapinvoke.StoreNewPO();

    end;

    var
        myInt: Integer;
        statusId: Text[10];
        SOMSOrderNO: code[20];
        postvirtualsales: Boolean;
        GlobalParemeter: Text;
        JQEntries: Record "Job Queue Entry";
        somsapinvoke: Codeunit "Invoke SOMS API";
        Sales_Order: Codeunit "Sales Post Job Batch";
}