page 50111 "Interface Ctrl List"
{
    // This object is the entry point to Interface Ctrl
    Caption = 'Interface and Job Queue Control';
    CardPageID = "Interface Ctrl Card";
    PageType = List;
    SourceTable = "Interface Ctrl Setup Header";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(LastModified; LastModified)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(LastModifiedBy; LastModifiedBy)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SetEnabled)
            {
                ApplicationArea = All;
                Caption = 'Set Enabled';
                Image = ResetStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    SetEnabled();
                end;
            }
            action(SetDisabled)
            {
                ApplicationArea = All;
                Caption = 'Set Disabled';
                Image = Pause;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    SetDisabled();
                end;
            }
            action(ControlStatus)
            {
                ApplicationArea = All;
                Caption = 'Interface Control Status';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Interface Ctrl Status";
            }
        }
    }
}