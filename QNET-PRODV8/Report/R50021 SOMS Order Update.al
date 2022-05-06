// report 50021 "SOMS Order Batch"
// {
//     UsageCategory = Administration;
//     ApplicationArea = All;
//     ProcessingOnly = true;
//     dataset
//     {
//         dataitem(Header; "Sales Header")
//         {
//             RequestFilterFields = "No.";
//             DataItemTableView = where("Virtual Sales" = const(true));
//             dataitem(Line; "Sales Line")
//             {
//                 DataItemLink = "Document No." = FIELD("No.");
//                 DataItemLinkReference = Header;
//                 DataItemTableView = SORTING("Document No.", "Line No.") where(type = filter(Item));
//                 trigger OnAfterGetRecord()
//                 var
//                     Item: Record Item;
//                 begin
//                     if not postvirtualsales then begin
//                         if Item.Get(Line."No.") then begin
//                             if Line."Unit of Measure Code" = '' then begin
//                                 line."Unit of Measure Code" := Item."Base Unit of Measure";
//                                 line.Modify();
//                             end;
//                         end;
//                     end;
//                 end;
//             }
//             trigger OnAfterGetRecord()
//             var
//                 StagingSalesOrder: Record "Sales Order Staging";
//             begin
//                 if postvirtualsales then begin
//                     StagingSalesOrder.Reset();
//                     StagingSalesOrder.SetRange(OrderNo, Header."SOMS Order No.");
//                     StagingSalesOrder.SetRange("Import from Excel", true);
//                     if StagingSalesOrder.FindFirst() then
//                         repeat
//                             StagingSalesOrder."Queue Status" := StagingSalesOrder."Queue Status"::Pending;
//                             StagingSalesOrder."Retry Count" := 0;
//                             StagingSalesOrder."Error Message" := '';
//                             StagingSalesOrder."EarliestStart Date/Time" := 0DT;
//                             StagingSalesOrder.Modify();
//                         until StagingSalesOrder.Next() = 0;
//                 end;
//             end;
//         }
//     }
//     requestpage
//     {
//         layout
//         {
//             area(Content)
//             {
//                 group(POST)
//                 {
//                     field(postvirtualsales; postvirtualsales)
//                     {
//                         ApplicationArea = All;
//                         Caption = 'SOMS Order Line Reset';
//                     }
//                 }
//             }
//         }

//         actions
//         {

//         }
//         trigger OnOpenPage()
//         begin
//             postvirtualsales := false;
//         end;
//     }
//     var
//         postvirtualsales: Boolean;
// }