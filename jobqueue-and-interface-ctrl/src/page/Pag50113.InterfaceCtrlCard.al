page 50113 "Interface Ctrl Card"
{
    Caption = 'Interface Control Setup Card';
    PageType = Card;
    SourceTable = "Interface Ctrl Setup Header";

    layout
    {
        area(content)
        {
            group("General Setup")
            {
                Caption = 'General Setup';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
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
                    LookupPageID = Users;
                }
            }
            part(Control1000000003; "Interface Ctrl JQ Subform")
            {
                ApplicationArea = All;
                SubPageLink = InterfaceType = FIELD (Type), "HeaderNo." = FIELD ("No.");
                Visible = Type = 1;
            }
            part(Control1000000006; "Interface Ctrl IF Subform")
            {
                ApplicationArea = All;
                SubPageLink = InterfaceType = FIELD (Type), "HeaderNo." = FIELD ("No.");
                Visible = Type = 2;
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

    var
        JobQueuesVisible: Boolean;
}