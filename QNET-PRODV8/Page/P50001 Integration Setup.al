page 50027 "Integration Setup"
{

    Caption = 'Integration Setup';
    PageType = Card;
    SourceTable = "Integration Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate';
    layout
    {
        area(content)
        {
            group(General)
            {

                field("Get Sales Order URL"; Rec."Get Sales Order URL")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Get BOM Details URL"; Rec."Get BOM Details URL")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field("Store New PO URL"; Rec."Store New PO URL")
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field("Token Url"; Rec."Token Url")
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field("Get PO Kitting Info"; Rec."Get GRN Info")
                {
                    Caption = 'Get GRN Info URL';
                    ApplicationArea = all;
                    MultiLine = true;
                }
                field("Get Assembly Order URL"; Rec."Get Assembly Order URL")
                {
                    ApplicationArea = all;
                    MultiLine = true;
                }
            }
            group(Token)
            {
                field("Encryption Key"; Rec."Encryption Key")
                {
                    ApplicationArea = all;

                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = all;
                }
                field("Email Id"; Rec."Email Id")
                {
                    ApplicationArea = all;
                }
            }
            group("SOMS Sales Order")
            {
                field("Ship Free GL"; Rec."Ship Fee GL")
                {
                    ApplicationArea = All;
                }
                field("Last Get Order  Datet/Time"; Rec."Last Get Order  Datet/Time")
                {
                    ApplicationArea = all;
                }
                field("SOMS Journal Templ. Name"; Rec."SOMS Journal Templ. Name")
                {
                    ApplicationArea = all;
                }
                field("SOMS Journal Batch Name"; Rec."SOMS Journal Batch Name")
                {
                    ApplicationArea = all;
                }
                field("Retail Customer No."; Rec."Retail Customer No.")
                {
                    ApplicationArea = all;
                }
                field("EV GL Acc."; rec."EV GL Acc.")
                {
                    ApplicationArea = all;
                }
                field("LOST In Transit Acc."; Rec."LOST In Transit Acc.")
                {
                    ApplicationArea = all;
                }
                field("NR GL Acc."; Rec."NR GL Acc.")
                {
                    ApplicationArea = all;
                }
            }
            group("KITTING PO")
            {

                field("Start DateTime"; Rec."Start DateTime")
                {
                    ApplicationArea = all;
                }
                field("End DateTime"; Rec."End DateTime")
                {
                    ApplicationArea = all;
                }
            }
            group("Assembly Order")
            {
                field("Get Assembly Start DateTime"; Rec."Get Assembly Start DateTime")
                {
                    Caption = 'Start DateTime';
                    ApplicationArea = all;
                }
                field("Get Assembly End DateTime"; Rec."Get Assembly End DateTime")
                {
                    Caption = 'End DateTime';
                    ApplicationArea = all;
                }
            }
            group("Sales GV Post")
            {
                field("Last Post GV DateTime"; Rec."Last Post GV DateTime")
                {
                    ApplicationArea = All;
                }
                group(Postive)
                {
                    field("SOMS Pos. Journal Templ. Name"; Rec."SOMS Pos. Journal Templ. Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template Name';
                    }
                    field("SOMS Pos. Journal Batch Name"; Rec."SOMS Pos. Journal Batch Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Batch Name';
                    }
                }
                group(Negative)
                {

                    field("SOMS Neg. Journal Templ. Name"; Rec."SOMS Neg. Journal Templ. Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template Name';
                    }
                    field("SOMS Neg. Journal Batch Name"; Rec."SOMS Neg. Journal Batch Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Batch Name';
                    }
                }
                group("Control Accounts")
                {
                    field("QE Control Account"; Rec."QE Control Account")
                    {
                        ApplicationArea = All;
                    }
                    field("QA Control Account"; Rec."QA Control Account")
                    {
                        ApplicationArea = All;
                    }
                    field("CC Control Account"; Rec."CC Control Account")
                    {
                        ApplicationArea = All;
                    }
                    field("Control Ship Fee GL"; Rec."Control Ship Fee GL")
                    {
                        ApplicationArea = All;
                    }
                    field("Control Customer Posting Group"; Rec."Control Customer Posting Group")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Posting Group';
                    }
                    field("Control VAT Prod. Posting Grp"; Rec."Control VAT Prod. Posting Grp")
                    {
                        ApplicationArea = All;
                    }
                    field("Control Gen. Prod. Posting Grp"; Rec."Control Gen. Prod. Posting Grp")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin

    end;

    trigger OnOpenPage()
    var
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;

    var
        SoapEnvelop: Text;
}
