pageextension 50010 "Posted Sales Inv. Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addafter(Closed)
        {
            field(Reference_Id; rec.Reference_Id)
            {
                ApplicationArea = all;
                Caption = 'Reference Id';
                Editable = false;
            }
            field(Integrated_order; rec.Integrated_order)
            {
                ApplicationArea = all;
                Caption = 'Integrated Order';
                Editable = false;
            }
            field("SOMS Order No."; rec."SOMS Order No.")
            {
                ApplicationArea = all;
                Caption = 'SOMS Order No.';
                Editable = false;
            }
            field(IRID; Rec.IRID)
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Receipt No."; Rec."Receipt No.")
            {
                ApplicationArea = all;
                Editable = false;
            }

        }

    }

    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action(ServicePurchaseOrder)
            {
                ApplicationArea = All;
                Caption = '&Delivery Note Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Category6;
                ToolTip = 'Prepare to print the document. The report request window for the document opens where you can specify what to include on the print-out.';
                trigger OnAction()
                begin
                    GetSalesShptLines;
                end;
            }

        }
    }
    procedure GetSalesShptLines()
    begin
        salesInvLine.Reset();
        salesInvLine.SetRange("Document No.", Rec."No.");
        salesInvLine.SetRange(Type, salesInvLine.Type::Item);
        if not salesInvLine.FindFirst then
            Error('There is no shipment document');
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", Rec."No.");
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Document Line No.", salesInvLine."Line No.");
        if ValueEntry.FindSet then;
        ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
        if ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Shipment" then;
        if SalesShptLine.Get(ItemLedgEntry."Document No.", ItemLedgEntry."Document Line No.") then begin
            SalesShipHeader.Reset();
            SalesShipHeader.SetRange("No.", SalesShptLine."Document No.");
            SalesShipHeader.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");
            SalesShipHeader.FindFirst;
            Clear(deliveryNote);
            deliveryNote.SetTableView(SalesShipHeader);
            deliveryNote.Run();
        end;
    end;


    var
        salesInvLine: Record "Sales Invoice Line";
        SalesShipHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        deliveryNote: Report "Delivery- Order";
}