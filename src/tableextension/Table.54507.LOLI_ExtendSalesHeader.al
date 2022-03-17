tableextension 50507 LOLI_ExtendSalesHeader extends "Sales Header"
{
    fields
    {
        field(54500; "PO Number"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'PO Number';
        }
    }

    var
        myInt: Integer;
}