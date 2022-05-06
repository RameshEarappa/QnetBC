pageextension 50008 ExtendNavigationArea extends "Business Manager Role Center"
{

    actions
    {
        addlast(Sections)
        {
            group(integration)
            {
                Caption = 'Integration';
                action(Setup1)
                {
                    ApplicationArea = All;
                    Caption = 'Setup';
                    RunObject = page "Integration Setup";
                }
                action(Logs)
                {
                    ApplicationArea = All;
                    Caption = 'Logs';
                    RunObject = page "Integration Log Register";
                }

                group(StagingSales)
                {
                    Caption = 'Staging Sales';
                    action(salesorderstaging)
                    {
                        ApplicationArea = All;
                        Caption = 'Staging Sales Order';
                        RunObject = page "Sales Order Staging";
                    }
                    action(SalesOrderImportExcel)
                    {
                        ApplicationArea = All;
                        Caption = 'Staging Virtual Sales Order';
                        RunObject = page "Staging Virtual Sales Order";
                    }
                }
                group(Assembly)
                {
                    Caption = 'Assembly';
                    action(StagingAO)
                    {
                        ApplicationArea = All;
                        Caption = 'Staging Assembly Order';
                        RunObject = page "Staging Assembly Order";
                    }

                }
                group(ShippingFee)
                {
                    Caption = 'Shipping Fee';
                    action("Shipping Fee Detail's")
                    {
                        ApplicationArea = All;
                        //Caption = 'Shipping Fee Details';
                        RunObject = page "Shipping Paid Detail's";
                    }

                }
                group(IR)
                {
                    Caption = 'IR';
                    action("IR Update's")
                    {
                        ApplicationArea = All;
                        RunObject = page "IR Update";
                    }

                }
                group(Reconciliation)
                {
                    Caption = 'Reconciliation';
                    action("SOMS Order Summmary")
                    {
                        ApplicationArea = All;
                        RunObject = page "SOMS Order Reconciliation";
                    }
                    action("VAT Summmary")
                    {
                        ApplicationArea = All;
                        RunObject = report "VAT Entries Summary";
                    }
                    action("Sales Summmary")
                    {
                        ApplicationArea = All;
                        RunObject = report "Sales Summary";
                    }
                    action("Credit Memo Summmary")
                    {
                        ApplicationArea = All;
                        RunObject = report "Sales-Credit Memo Summary";
                    }


                }
                group(StagingJVPost)
                {
                    Caption = 'Staging JV';
                    action(staging)
                    {
                        ApplicationArea = All;
                        Caption = 'Staging journal Voucher';
                        RunObject = page "Payment Gateway Trans";
                    }
                }
                group(SatgingPO)
                {
                    Caption = 'Staging SOMS GRN';
                    action(SOMSGRN)
                    {
                        ApplicationArea = All;
                        Caption = ' SOMS GRN';
                        RunObject = page "Purchase Order Kitting Info";
                    }
                }

                group(POSTJob)
                {
                    Caption = 'POST Job';

                    action(PostSalesjob)
                    {
                        ApplicationArea = all;
                        Caption = 'Sales Post Job';
                        RunObject = report "Post Batch";
                    }
                    action(POSendToSOMS)
                    {
                        ApplicationArea = all;
                        Caption = 'PO Send To SOMS';
                        RunObject = report "Send PO To SOMS";
                    }
                    action(GetKittingProductLineInfo)
                    {
                        ApplicationArea = all;
                        Caption = 'Get Kitting Product Lines';
                        RunObject = report "Get Kitting Product";
                    }
                    action(GetGRNLine)
                    {
                        ApplicationArea = all;
                        Caption = 'Get GRN Line';
                        RunObject = report "Get Kitting PO Info Batch";
                    }
                    action(PostBatchJob)
                    {
                        ApplicationArea = all;
                        Caption = 'Post PO Batch Job';
                        RunObject = report "Post PO Job Batch";
                    }
                    action(GetAssemblyOrderInfo)
                    {
                        ApplicationArea = all;
                        Caption = 'Get Assembly Order Info';
                        RunObject = report "Get Assembly Order Info Batch";
                    }
                    action(postAssemblyOrderInfo)
                    {
                        ApplicationArea = all;
                        Caption = 'Post Assembly Order Job';
                        RunObject = report "Post Assembly Order Job Batch";
                    }
                    action(OrderSummery)
                    {
                        ApplicationArea = all;
                        Image = Report;
                        Caption = 'SOMS Order Summery';
                        RunObject = report "Staging Order Summary";
                    }

                }
            }
        }
    }
}