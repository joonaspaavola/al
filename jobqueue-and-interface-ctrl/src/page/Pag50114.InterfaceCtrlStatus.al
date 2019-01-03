page 50114 "Interface Ctrl Status"
{
    Caption = 'Interface Control Status';
    PageType = List;
    SourceTable = "Interface Ctrl Status";

    layout
    {
        area(content)
        {
            repeater(Control1000000005)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Time; Time)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        cInterfaceCtrlStatusUpdate.CheckActive();
    end;

    var
        cInterfaceCtrlStatusUpdate: Codeunit "Interface Ctrl Status Update";
}