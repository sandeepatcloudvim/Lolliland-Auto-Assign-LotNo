tableextension 54508 "LOLI_ExtendInventorySetup" extends "Inventory Setup"
{
    fields
    {

        field(54508; "LOLI_LotNo. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Lot No. Series';
            TableRelation = "No. Series".Code;
        }
        field(54509; "LOLI_Loc Filter"; Text[200])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Filter for Auto Assign';
        }
    }

    var
        myInt: Integer;
}