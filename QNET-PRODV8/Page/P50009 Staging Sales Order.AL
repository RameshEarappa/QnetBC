page 50009 "Sales Order Staging"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Order Staging";
    Caption = 'Staging Sales Order';
    DeleteAllowed = true;
    SourceTableView = WHERE("Import from Excel" = FILTER(false));
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Type"; rec.OrderType)
                {
                    ApplicationArea = all;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = all;

                }
                field("Receipt Date"; rec."Receipt Date")
                {
                    ApplicationArea = all;

                }

                field(OrderNo; rec.OrderNo)
                {
                    ApplicationArea = All;
                    Caption = 'SOMS Order No.';


                }
                field(ITEMNO; rec.ITEMNO)
                {
                    ApplicationArea = All;
                    Caption = 'SOMS Line No.';

                }

                field(SHIPNO; rec.SHIPNO)
                {
                    ApplicationArea = All;
                    Caption = 'SOMS Ship No.';
                }
                field(productCode; rec.productCode)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                }
                field(productName; rec.productName)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(QTY; rec.QTY)
                {
                    ApplicationArea = All;
                    Caption = 'Qunatity';
                }

                field(AMOUNT; rec.AMOUNT)
                {
                    ApplicationArea = All;

                }
                field(ShipFee; rec.ShipFee)
                {
                    ApplicationArea = all;
                    Caption = 'Ship Fee';
                }

                field("BC Document No."; Rec."BC Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posted BC Document No."; Rec."Posted BC Document No.")
                {
                    ApplicationArea = All;
                }
                field(statusId; rec.statusId)
                {
                    ApplicationArea = all;
                    Caption = 'Status ID';
                }
                field(IRID; Rec.IRID)
                {
                    ApplicationArea = all;
                }
                field("IR Name"; Rec."IR Name")
                {
                    ApplicationArea = all;
                }

                field(Remarks; rec.Remarks)
                {
                    ApplicationArea = all;
                    Caption = 'SOMS Remark';
                }
                field("Lost IN Transit"; rec."Lost IN Transit")
                {
                    ApplicationArea = all;
                }
                field(InfoType; Rec.InfoType)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(SOMSCreatedDate; rec.SOMSCreatedDate)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(RefID; rec.RefID)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(OrderType; rec.OrderType)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Order Status"; rec."Order Status")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(TRCTDATE; rec.TRCTDATE)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(ORDER_REASON; rec.ORDER_REASON)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(TCO; rec.TCO)
                {
                    ApplicationArea = All;

                }

                field(TRCTNO; rec.TRCTNO)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ORDERDATE; rec.ORDERDATE)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(REF_DOC; rec.REF_DOC)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ReceiptNo; rec.ReceiptNo)
                {
                    ApplicationArea = All;

                }

                field(CURRENCY; rec.CURRENCY)
                {
                    ApplicationArea = All;

                }
                field(PaymentMethod; rec.PaymentMethod)
                {
                    ApplicationArea = All;

                }
                field(OCURRENCY; rec.OCURRENCY)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(PICKUP_D2D; rec.PICKUP_D2D)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ATTRIBUTE_CODE; rec.ATTRIBUTE_CODE)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(CG3; rec.CG3)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(CG4; rec.CG4)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(CG5; rec.CG5)
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field(PLANT; rec.PLANT)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(SLOC; rec.SLOC)
                {
                    ApplicationArea = All;
                    Visible = false;
                }


                field(UOM; rec.UOM)
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field(comboProductCode; rec.comboProductCode)
                {
                    ApplicationArea = All;
                    Visible = false;
                }


                field(COND_TYPE; rec.COND_TYPE)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(OAMOUNT; rec.OAMOUNT)
                {
                    ApplicationArea = All;

                }
                field(COND_ITEMID; rec.COND_ITEMID)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(TCO_NAME; rec.TCO_NAME)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(address1; rec.address1)
                {
                    ApplicationArea = All;
                    Caption = 'Address';

                }
                field(address2; rec.address2)
                {
                    ApplicationArea = All;
                    Caption = 'Address 2';

                }
                field(LOCATION; rec.LOCATION)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';

                }
                field(SHIP_CITY; rec.SHIP_CITY)
                {
                    ApplicationArea = All;
                    Caption = 'City';

                }
                field(SHIP_STATE; rec.SHIP_STATE)
                {
                    ApplicationArea = All;
                    Caption = 'State';

                }

                field(SHIP_ZIPCODE; rec.SHIP_ZIPCODE)
                {
                    ApplicationArea = All;
                    Caption = 'Pin Code';

                }
                field(CountryCode1; rec.CountryCode)
                {
                    ApplicationArea = All;
                    Caption = 'Coutry ';
                }
                field(TELNO; rec.TELNO)
                {
                    ApplicationArea = All;

                }
                field(EMAIL; rec.EMAIL)
                {
                    ApplicationArea = All;

                }

                field("EarliestStart Date/Time"; rec."EarliestStart Date/Time")
                {
                    ApplicationArea = All;

                }
                field(statusDesc; rec.statusDesc)
                {
                    ApplicationArea = all;
                }

                field("Queue Status"; rec."Queue Status")
                {
                    ApplicationArea = All;

                }
                field("Process Remarks"; rec."Process Remarks")
                {
                    ApplicationArea = all;

                }
                field("Error Message"; rec."Error Message")
                {
                    Caption = 'Error Remarks';
                    ApplicationArea = All;
                }
                field("Processed Date"; rec."Processed Date")
                {
                    ApplicationArea = All;

                }
                field("Retry Count"; rec."Retry Count")
                {
                    ApplicationArea = All;

                }
                field(ID; rec.ID)
                {
                    ApplicationArea = All;

                }

                field(storageLocation; rec.storageLocation)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Year; rec.Year)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Week; rec.Week)
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field(CountryCode; rec.CountryCode)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(ContactNo_Home; rec.ContactNo_Home)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(ContactNo_Mobile; rec.ContactNo_Mobile)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(awb; rec.awb)
                {
                    ApplicationArea = all;
                    Caption = 'AWB';
                }
                field(CourierID; rec.CourierID)
                {
                    ApplicationArea = all;
                }
                field("Entry Date/Time"; Rec."Entry Date/Time")
                {
                    ApplicationArea = all;
                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                Caption = 'Virtual Sales Import';
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction();
                begin
                    Xmlport.Run(50000, false, true);
                end;
            }
            action(GetUsersFromAPI)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Post Orders';
                RunObject = report "Post Batch";
            }
            action(GetUsersFromAPI1)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Get Orders';
                Visible = true;
                RunObject = codeunit "Invoke SOMS API";
            }
        }
        area(Reporting)
        {
            action(StagingOrderSummary)
            {
                ApplicationArea = all;
                Image = Print;
                Caption = 'Staging Order Summary';
                RunObject = report "Staging Order Summary";
            }
        }
    }
}