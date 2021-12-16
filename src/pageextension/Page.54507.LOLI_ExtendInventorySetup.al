pageextension 54507 "LOLI_InventorySetup" extends "Inventory Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter("Copy Item Descr. to Entries")
        {
            field("LotNo. Series"; Rec."LOLI_LotNo. Series")
            {
                ToolTip = 'Specifies the value of the Lot No. Series field.';
                ApplicationArea = All;
                Caption = 'Purch Lot No. Series';
            }
            field("Loc Filter"; Rec."LOLI_Loc Filter")
            {
                ToolTip = 'Specifies the value of the Location Filter for Auto Assign field.';
                ApplicationArea = All;
                Caption = 'Location Filter for Auto Assign';
                Visible = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}