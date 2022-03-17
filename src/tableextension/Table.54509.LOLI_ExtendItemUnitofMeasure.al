tableextension 54509 "LOLI_ItemUnitOfMeasure" extends "Item Unit of Measure"
{
    fields
    {
        modify(Cubage)
        {
            trigger OnAfterValidate()
            var
                recItem: Record Item;
            begin
                recItem.Reset();
                recItem.SetRange("No.", Rec."Item No.");
                recItem.SetRange("Base Unit of Measure", Rec.Code);
                if recItem.FindFirst() then begin
                    recItem."Unit Volume" := Rec.Cubage;
                    recItem.Modify(false);
                end;
            end;
        }
        modify(Weight)
        {
            trigger OnAfterValidate()
            var
                itemRec: Record Item;
            begin
                itemRec.Reset();
                itemRec.SetRange("No.", Rec."Item No.");
                itemRec.SetRange("Base Unit of Measure", Rec.Code);
                if itemRec.FindFirst() then begin
                    itemRec."Gross Weight" := Rec.Weight;
                    itemRec.Modify(false);
                end;
            end;
        }
    }

    var
        myInt: Integer;

}