// tableextension 50007 "Sales & Receivables Setup Ext" extends "Sales & Receivables Setup"
// {
//     fields
//     {
//         // Add changes to table fields here

//         field(50100; "Ship Fee GL"; code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "G/L Account";
//         }
//         field(50101; "Last Get Order  Datet/Time"; DateTime)
//         {
//             DataClassification = ToBeClassified;

//         }

//         field(50102; "SOMS Journal Templ. Name"; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "Gen. Journal Template";
//             Caption = 'Journal Template Name';
//         }
//         field(50103; "SOMS Journal Batch Name"; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("SOMS Journal Templ. Name"));
//             Caption = 'Journal Batch Name';
//         }
//         field(50104; "Retail Customer No."; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = Customer;

//         }
//         field(50105; "EV GL Acc."; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "G/L Account";
//         }
//         field(50106; "LOST In Transit Acc."; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "G/L Account";
//         }
//         field(50107; "NR GL Acc."; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "G/L Account";
//         }

//     }

//     var
//         myInt: Integer;
// }