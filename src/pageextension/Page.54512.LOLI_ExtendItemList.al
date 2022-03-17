pageextension 54512 "LOLI_ExtendItemList" extends "Item List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter(Dimensions)
        {
            action("Update Item Values")
            {
                ApplicationArea = All;
                Caption = 'Update Item Values';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "LOLI_Update Item Values";
            }
        }
    }

    var
        myInt: Integer;
}