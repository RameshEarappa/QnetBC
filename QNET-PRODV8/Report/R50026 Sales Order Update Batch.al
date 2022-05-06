report 50026 "SO Customer Posting Group"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {

    }

    trigger OnPostReport()
    begin
        sso.Reset();
        sso.SetRange("No.", 'SO0001164');
        if sso.FindFirst() then begin
            sso.Validate("Customer Posting Group", 'EV');
            sso.Modify();
        end;



    end;

    var
        sso: Record "Sales Header";

}