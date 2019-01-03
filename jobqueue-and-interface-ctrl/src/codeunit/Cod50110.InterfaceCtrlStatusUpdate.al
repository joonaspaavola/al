codeunit 50110 "Interface Ctrl Status Update"
{
    trigger OnRun()
    begin
    end;

    var
        tInterfaceCtrlSetupHeader: Record "Interface Ctrl Setup Header";
        tInterfaceCtrlStatus: Record "Interface Ctrl Status";
        tInterfaceCtrlSetupLine: Record "Interface Ctrl Setup Line";
        tJobQueueLogEntry: Record "Job Queue Log Entry";
        tJobQueueEntry: Record "Job Queue Entry";
        tJobQueueEntryScheduled: Record "Job Queue Entry";
        Text001Msg: Label 'Interface control is not enabled.';
        Errors: Boolean;
        ErrorDescription: Text[250];
        Text002Msg: Label 'The following Job Queues are in error state or have been In Process longer than is allowed: ';
        NotActive: Boolean;
        Text003Msg: Label 'Interface Control is enabled, no errors were encountered.';
        OutsideScheduled: Boolean;
        DayOfWeek: Integer;

    procedure CheckActive()
    begin
        //Deletes all content from Interface Ctrl Status table
        EmptyInterfaceStatusTable();
        ResetVariables();

        //If Interface Ctrl is not enabled, status is set accordingly and no further processing is done, otherwise function CheckJobQueueStatus() is called
        tInterfaceCtrlSetupHeader.Reset();
        tInterfaceCtrlSetupHeader.SetRange(Status, tInterfaceCtrlSetupHeader.Status::Enabled);
        if not tInterfaceCtrlSetupHeader.FindFirst() then begin
            NotActive := true;
            InsertInterfaceStatus();
            exit;
        end
        else
            CheckJobQueueStatus();
    end;

    local procedure EmptyInterfaceStatusTable()
    begin
        tInterfaceCtrlStatus.Reset();
        tInterfaceCtrlStatus.DeleteAll();
    end;

    local procedure CheckJobQueueStatus()
    begin
        //This functions checks if errors are present in Job Queue Entries
        tInterfaceCtrlSetupHeader.Reset();
        tInterfaceCtrlSetupHeader.SetRange(Status, tInterfaceCtrlSetupHeader.Status::Enabled);
        tInterfaceCtrlSetupHeader.SetRange(Type, tInterfaceCtrlSetupHeader.Type::"Job Queue");
        if tInterfaceCtrlSetupHeader.FindFirst() then
            repeat
                tInterfaceCtrlSetupLine.Reset();
                tInterfaceCtrlSetupLine.SetRange(InterfaceType, tInterfaceCtrlSetupHeader.Type);
                tInterfaceCtrlSetupLine.SetRange("HeaderNo.", tInterfaceCtrlSetupHeader."No.");
                if tInterfaceCtrlSetupLine.FindFirst() then
                    repeat
                        OutsideScheduled := false;
                        CheckOutsideScheduled();
                        if not OutsideScheduled then begin
                            if tInterfaceCtrlSetupLine.IsJobControlOn then
                                if tJobQueueEntry.Get(tInterfaceCtrlSetupLine.JobID) then
                                    if tJobQueueEntry.Status = tJobQueueEntry.Status::Error then begin
                                        Errors := true;
                                        tJobQueueEntry.CalcFields("Object Caption to Run");
                                        SetErrorDescription();
                                    end;
                            //Function CheckInProcessDuration() checks if Job Queues have been "In Process" for an extended period of time
                            if tInterfaceCtrlSetupLine.IsInProcessControlOn then
                                CheckInProcessDuration();
                            //Function CheckLastSuccessfulRunTime checks if Job Queues' last successful run is too far in the past, i.e., if one or more scheduled run(s) have been skipped
                            if tInterfaceCtrlSetupLine.LastSuccessTimeControlOn then
                                CheckLastSuccessfulRunTime();
                        end;
                    until tInterfaceCtrlSetupLine.Next() = 0;
            until tInterfaceCtrlSetupHeader.Next() = 0;

        InsertInterfaceStatus();
    end;

    local procedure ResetVariables()
    begin
        Errors := false;
        ErrorDescription := '';
        NotActive := false;
    end;

    local procedure InsertInterfaceStatus()
    begin
        tInterfaceCtrlStatus.Init();
        tInterfaceCtrlStatus.Validate("No.", Format(10000));
        tInterfaceCtrlStatus.Validate(Time, CurrentDateTime());
        if not Errors then begin
            tInterfaceCtrlStatus.Validate(Status, tInterfaceCtrlStatus.Status::OK);
            if NotActive then
                tInterfaceCtrlStatus.Validate(Description, Text001Msg)
            else
                tInterfaceCtrlStatus.Validate(Description, Text003Msg);
        end
        else begin
            tInterfaceCtrlStatus.Validate(Status, tInterfaceCtrlStatus.Status::Error);
            tInterfaceCtrlStatus.Validate(Description, ErrorDescription);
        end;
        tInterfaceCtrlStatus.Insert();
    end;

    local procedure CheckInProcessDuration()
    begin
        //Allowed "In Process" duration is set separately for each of the monitored Job Queues
        if tJobQueueEntry.Get(tInterfaceCtrlSetupLine.JobID) then
            if tJobQueueEntry.Status = tJobQueueEntry.Status::"In Process" then
                if tJobQueueEntry."Earliest Start Date/Time" < CurrentDateTime() then
                    if Abs(tJobQueueEntry."Earliest Start Date/Time" - CurrentDateTime()) > tInterfaceCtrlSetupLine.MaxInProcessTime then begin
                        Errors := true;
                        tJobQueueEntry.CalcFields("Object Caption to Run");
                        SetErrorDescription();
                    end;
    end;

    local procedure CheckLastSuccessfulRunTime()
    begin
        //Allowed delay is set separately for each of the monitored Job Queues
        if tJobQueueEntry.Get(tInterfaceCtrlSetupLine.JobID) then
            if tJobQueueEntry.Status = tJobQueueEntry.Status::Ready then begin
                tJobQueueLogEntry.Reset();
                tJobQueueLogEntry.SetRange(ID, tInterfaceCtrlSetupLine.JobID);
                tJobQueueLogEntry.SetRange(Status, tJobQueueLogEntry.Status::Success);
                if tJobQueueLogEntry.FindLast() then
                    if Abs(tJobQueueLogEntry."End Date/Time" - CurrentDateTime()) > tInterfaceCtrlSetupLine.MaxPastLastSuccessTime then begin
                        Errors := true;
                        tJobQueueEntry.CalcFields("Object Caption to Run");
                        SetErrorDescription();
                    end;
            end;
    end;

    local procedure SetErrorDescription()
    begin
        //Object Caption is included in error text to provide user with more spesific information
        if ErrorDescription = '' then
            ErrorDescription := CopyStr(Text002Msg + tJobQueueEntry."Object Caption to Run", 1, 250)
        else
            ErrorDescription := CopyStr(ErrorDescription + ', ' + tJobQueueEntry."Object Caption to Run", 1, 250);
    end;

    local procedure CheckOutsideScheduled()
    begin
        if not tInterfaceCtrlSetupLine.CheckJobQueueRecurrence then
            exit
        else
            if tJobQueueEntryScheduled.Get(tInterfaceCtrlSetupLine.JobID) then
                if (tJobQueueEntryScheduled."Starting Time" <> 0T) and (tJobQueueEntryScheduled."Ending Time" <> 0T) then begin
                    if (Time() < tJobQueueEntryScheduled."Starting Time") or (Time() > tJobQueueEntryScheduled."Ending Time") then begin
                        OutsideScheduled := true;
                        exit;
                    end
                    else begin
                        CheckDayOfWeek();
                        exit;
                    end;
                end
                else
                    CheckDayOfWeek();
    end;

    local procedure CheckDayOfWeek()
    begin
        DayOfWeek := Date2DWY(Today(), 1);
        with tJobQueueEntryScheduled do
            case DayOfWeek of
                1:
                    if not "Run on Mondays" then OutsideScheduled := true;
                2:
                    if not "Run on Tuesdays" then OutsideScheduled := true;
                3:
                    if not "Run on Wednesdays" then OutsideScheduled := true;
                4:
                    if not "Run on Thursdays" then OutsideScheduled := true;
                5:
                    if not "Run on Fridays" then OutsideScheduled := true;
                6:
                    if not "Run on Saturdays" then OutsideScheduled := true;
                7:
                    if not "Run on Sundays" then OutsideScheduled := true;
            end;
    end;
}

