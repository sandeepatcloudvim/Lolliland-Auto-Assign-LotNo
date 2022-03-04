pageextension 54510 "LOLI_ExtendWarehouseReceipt" extends "Warehouse Receipt"
{
    layout
    {
        // Add changes to page layout here

    }

    actions
    {

        addafter("Autofill Qty. to Receive")
        {
            action("LOLI_Auto Assign Item Tracking")
            {
                ApplicationArea = All;
                Caption = 'Auto Assign Item Tracking Lot';
                Promoted = true;
                Image = Track;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    InsertTrackingLines();
                end;
            }

        }
    }
    var
        ShowMessage: Boolean;

    local procedure InsertTrackingLines()
    var
        RecWarehouserecptLine: Record "Warehouse Receipt Line";
        ReservationEntry: Record "Reservation Entry";
        ErrorTable: Record "Error Message";
        ItemRec: Record Item;
        InvSetup: Record "Inventory Setup";

        Text001: Label 'Item Tracking Lines for the Order: %1  has been created successfully';
        Text002: Label 'Would you like to auto fill the tracking line for the Order No %1';
    begin

        IF NOT CONFIRM(Text002, FALSE, Rec."No.") THEN
            EXIT;
        ShowMessage := false;
        RecWarehouserecptLine.RESET;
        RecWarehouserecptLine.SETRANGE("No.", Rec."No.");
        RecWarehouserecptLine.SETFILTER(Quantity, '>%1', 0);
        IF RecWarehouserecptLine.FINDSET THEN begin
            if RecWarehouserecptLine."Location Code" IN ['WA', 'SA', 'NSW', 'QLD', 'VIC', 'TAS', 'AUCK NZ', 'CHRISTC NZ'] then begin
                LOLIDeleteReservationEntries(RecWarehouserecptLine);
                REPEAT
                    IF ItemRec.GET(RecWarehouserecptLine."Item No.") THEN BEGIN
                        IF ItemRec.Type = ItemRec.Type::Inventory THEN BEGIN
                            LOLICreateReservationEntry(RecWarehouserecptLine);
                        END;
                    END;
                UNTIL RecWarehouserecptLine.NEXT = 0;
            end;
        end;
        if ShowMessage then
            MESSAGE('Tracking lines for Order : %1 have been created successfully', Rec."No.");
    end;

    local procedure LOLICreateReservationEntry(WarehouseRecptLineLine: Record "Warehouse Receipt Line")
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InvSetup: Record "Inventory Setup";
        LocPurchLine: Record "Purchase Line";
        ReservEntry: Record "Reservation Entry";
        VarLotNo: Code[20];

    begin
        CLEAR(VarLotNo);
        InvSetup.GET;
        LocPurchLine.get(LocPurchLine."Document Type"::Order, WarehouseRecptLineLine."Source No.", WarehouseRecptLineLine."Source Line No.");

        InvSetup.TestField("LOLI_LotNo. Series");
        ReservEntry.Init();
        ReservEntry."Entry No." := GetLastEntryNo() + 1;
        ReservEntry.validate("Item No.", WarehouseRecptLineLine."Item No.");
        ReservEntry.validate("Location Code", WarehouseRecptLineLine."Location Code");
        ReservEntry.SetSource(DATABASE::"Purchase Line", LocPurchLine."Document Type".AsInteger(), LocPurchLine."Document No.", LocPurchLine."Line No.", '', 0);
        ReservEntry.VALIDATE("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        ReservEntry."Creation Date" := WorkDate();
        ReservEntry."Created By" := UserId;
        ReservEntry.TestField("Qty. per Unit of Measure");
        ReservEntry.VALIDAte("Qty. per Unit of Measure", LocPurchLine."Qty. per Unit of Measure");
        ReservEntry.Quantity := CreateReservEntry.SignFactor(ReservEntry) * LocPurchLine."Qty. to Receive";
        ReservEntry.VALIDATE("Quantity (Base)", CreateReservEntry.SignFactor(ReservEntry) * LocPurchLine."Qty. to Receive");
        NoSeriesMgt.InitSeries(InvSetup."LOLI_LotNo. Series", '', WORKDATE(), VarLotNo, InvSetup."LOLI_LotNo. Series");
        ReservEntry.Validate("Lot No.", VarLotNo);
        ReservEntry.Validate("Expiration Date", CALCDATE('12M', TODAY));
        ReservEntry.VALIDATE("Expected Receipt Date", LocPurchLine."Expected Receipt Date");
        ReservEntry.Positive := true;
        if ReservEntry.Insert() then
            ShowMessage := true;
    end;

    local procedure GetLastEntryNo(): Integer;
    var
        ResEntry: Record "Reservation Entry";
    begin
        ResEntry.Reset();
        IF ResEntry.FindLast() then
            EXIT(ResEntry."Entry No." + 10000)
        else
            EXIt(10000);

    end;

    procedure LOLIDeleteReservationEntries(warehousRecptLine: Record "Warehouse Receipt Line")
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Source Type", DATABASE::"purchase Line");
        ReservEntry.SETRANGE("Source ID", warehousRecptLine."Source No.");
        ReservEntry.SETRANGE("Location Code", warehousRecptLine."Location Code");
        IF ReservEntry.FINDSET THEN
            ReservEntry.DELETEALL;
    end;


}