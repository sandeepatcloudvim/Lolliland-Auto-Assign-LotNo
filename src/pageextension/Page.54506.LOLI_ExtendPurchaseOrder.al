pageextension 54506 "LOLI_ExtendPurchaseOrder" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Create Inventor&y Put-away/Pick")
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
        myInt: Integer;
        recReservationEntry: Record "Reservation Entry";

    local procedure InsertTrackingLines()
    var
        RecPurchaseLine: Record "Purchase Line";
        PurchDocStatus: Enum "Purchase Document Status";
        ReservationEntry: Record "Reservation Entry";
        ErrorTable: Record "Error Message";
        ItemRec: Record Item;
        invSetup: Record "Inventory Setup";
        Text001: Label 'Item Tracking Lines for the Order: %1  has been created successfully.';
        Text002: Label 'Would you like to auto fill the tracking line for the Order No %1';
    begin
        Rec.TestField(Status, 0);
        IF NOT CONFIRM(Text002, FALSE, Rec."No.") THEN
            EXIT;
        invSetup.Get();
        LOLIDeleteReservationEntry(Rec);

        RecPurchaseLine.RESET;
        RecPurchaseLine.SETRANGE("Document Type", RecPurchaseLine."Document Type"::Order);
        RecPurchaseLine.SETRANGE("Document No.", Rec."No.");
        RecPurchaseLine.SETRANGE(Type, RecPurchaseLine.Type::Item);
        RecPurchaseLine.SETFILTER("Qty. to Receive", '>%1', 0);
        IF RecPurchaseLine.FINDSET THEN
            REPEAT
                if RecPurchaseLine."Location Code" IN ['WA', 'SA', 'NSW', 'QLD', 'VIC', 'TAS', 'AUCK NZ', 'CHRISTC NZ'] then begin
                    IF ItemRec.GET(RecPurchaseLine."No.") THEN BEGIN
                        IF ItemRec.Type = ItemRec.Type::Inventory THEN BEGIN
                            LOLICreateReservationEntry(RecPurchaseLine);
                        END;
                    END;
                end;
            UNTIL RecPurchaseLine.NEXT = 0;

        MESSAGE('Tracking lines for Purchase order : %1 have been created successfully', Rec."No.");

    end;

    procedure LOLIDeleteReservationEntry(PurchHead: Record "Purchase Header")
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.RESET;
        ReservEntry.SETRANGE("Source Type", DATABASE::"purchase Line");
        ReservEntry.SETRANGE("Source ID", PurchHead."No.");
        IF ReservEntry.FINDSET THEN
            ReservEntry.DELETEALL;
    end;

    local procedure LOLICreateReservationEntry(PurchLine: Record "Purchase Line")
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InvSetup: Record "Inventory Setup";
        ReservEntry: Record "Reservation Entry";
        VarLotNo: Code[20];
    begin
        CLEAR(VarLotNo);
        InvSetup.GET;
        ReservEntry."Entry No." := GetLastEntryNo() + 1;
        ReservEntry.validate("Item No.", PurchLine."No.");
        ReservEntry.validate("Location Code", PurchLine."Location Code");
        ReservEntry.SetSource(DATABASE::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.", '', 0);
        ReservEntry.VALIDATE("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        ReservEntry."Creation Date" := WorkDate();
        ReservEntry."Created By" := UserId;
        ReservEntry.TestField("Qty. per Unit of Measure");
        ReservEntry.VALIDAte("Qty. per Unit of Measure", PurchLine."Qty. per Unit of Measure");
        ReservEntry.Quantity := CreateReservEntry.SignFactor(ReservEntry) * PurchLine."Qty. to Receive";
        ReservEntry.VALIDATE("Quantity (Base)", CreateReservEntry.SignFactor(ReservEntry) * PurchLine."Qty. to Receive");
        NoSeriesMgt.InitSeries(InvSetup."LOLI_LotNo. Series", '', WORKDATE(), VarLotNo, InvSetup."LOLI_LotNo. Series");
        ReservEntry.Validate("Lot No.", VarLotNo);
        ReservEntry.Validate("Expiration Date", CALCDATE('12M', TODAY));
        ReservEntry.VALIDATE("Expected Receipt Date", PurchLine."Expected Receipt Date");
        ReservEntry.Positive := true;
        ReservEntry.Insert();
    end;

    local procedure GetLastEntryNo(): Integer;
    var
        ResEntry: Record "Reservation Entry";
    begin
        IF ResEntry.Findlast() then
            EXIT(ResEntry."Entry No." + 10000)
        else
            EXIt(10000);

    end;


}