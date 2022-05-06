report 50020 "Item To be Sync Batch"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                SetRange("Sync BOM Components", Item."Sync BOM Components"::" ");
                SetRange(Type, Item.Type::Inventory);
            end;

            trigger OnAfterGetRecord()
            begin
                Item."Sync BOM Components" := Item."Sync BOM Components"::"To be sync";
                Item.Modify();
                Commit();
            end;
        }
    }
}