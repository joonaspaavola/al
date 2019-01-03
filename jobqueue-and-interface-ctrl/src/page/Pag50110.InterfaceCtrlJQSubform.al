page 50110 "Interface Ctrl JQ Subform"
{
    Caption = 'Job Queue List';
    PageType = ListPart;
    SourceTable = "Interface Ctrl Setup Line";
    SourceTableView = WHERE (InterfaceType = FILTER ("Job Queue"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(JobID; JobID)
                {
                    ApplicationArea = All;
                }
                field(ObjectTypeToRun; ObjectTypeToRun)
                {
                    ApplicationArea = All;
                }
                field(ObjectIDToRun; ObjectIDToRun)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(EarliestStartTimeDate; EarliestStartTimeDate)
                {
                    ApplicationArea = All;
                }
                field(IsJobControlOn; IsJobControlOn)
                {
                    ApplicationArea = All;
                }
                field(CheckJobQueueRecurrence; CheckJobQueueRecurrence)
                {
                    ApplicationArea = All;
                }
                field(IsInProcessControlOn; IsInProcessControlOn)
                {
                    ApplicationArea = All;
                }
                field(MaxInProcessTime; MaxInProcessTime)
                {
                    ApplicationArea = All;
                    Editable = IsInProcessControlOn;
                }
                field(LastSuccessTimeControlOn; LastSuccessTimeControlOn)
                {
                    ApplicationArea = All;
                }
                field(MaxPastLastSuccessTime; MaxPastLastSuccessTime)
                {
                    ApplicationArea = All;
                    Editable = LastSuccessTimeControlOn;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetLineNo("HeaderNo.", InterfaceType);
    end;
}