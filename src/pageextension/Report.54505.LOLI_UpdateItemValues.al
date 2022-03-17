report 54505 "LOLI_Update Item Values"
{
    Caption = 'Update Item Values';
    ProcessingOnly = true;
    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            trigger OnAfterGetRecord()
            begin
                ItemUOM.Reset();
                ItemUOM.SetRange("Item No.", "No.");
                ItemUOM.SetRange(Code, "Base Unit of Measure");
                if ItemUOM.FindFirst() then begin
                    "Gross Weight" := ItemUOM.Weight;
                    "Unit Volume" := ItemUOM.Cubage;
                    Modify();
                end;

            end;

            trigger OnPostDataItem()
            begin
                Message('Completed');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    var
        ItemUOM: Record "Item Unit of Measure";
}
