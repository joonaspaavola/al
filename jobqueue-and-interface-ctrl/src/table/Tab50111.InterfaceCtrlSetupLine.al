table 50111 "Interface Ctrl Setup Line"
{
    Caption = 'Interface Control Setup Lines';

    fields
    {
        field(1; InterfaceType; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Job Queue,Interface';
            OptionMembers = " ","Job Queue",Interface;
            DataClassification = CustomerContent;
        }
        field(2; "HeaderNo."; Code[20])
        {
            TableRelation = "Interface Ctrl Setup Header"."No.";
            DataClassification = CustomerContent;
        }
        field(3; "LineNo."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(21; JobID; Guid)
        {
            Caption = 'ID';
            TableRelation = "Job Queue Entry".ID;
            DataClassification = CustomerContent;
        }
        field(22; IsJobControlOn; Boolean)
        {
            Caption = 'Job Queue Control Active';
            DataClassification = CustomerContent;
        }
        field(23; IsInProcessControlOn; Boolean)
        {
            Caption = 'Job Queue In Process Control Active';
            DataClassification = CustomerContent;
        }
        field(24; MaxInProcessTime; Duration)
        {
            Caption = 'Maximum Allowed In Process Duration';
            DataClassification = CustomerContent;
        }
        field(25; ObjectTypeToRun; Option)
        {
            CalcFormula = Lookup ("Job Queue Entry"."Object Type to Run" WHERE (ID = FIELD (JobID)));
            Caption = 'Object Type to Run';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ',,,Report,,Codeunit';
            OptionMembers = ,,,"Report",,"Codeunit";
        }
        field(26; ObjectIDToRun; Integer)
        {
            CalcFormula = Lookup ("Job Queue Entry"."Object ID to Run" WHERE (ID = FIELD (JobID)));
            Caption = 'Object ID to Run';
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; Status; Option)
        {
            CalcFormula = Lookup ("Job Queue Entry".Status WHERE (ID = FIELD (JobID)));
            Caption = 'Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Ready,In Process,Error,On Hold,Finished';
            OptionMembers = Ready,"In Process",Error,"On Hold",Finished;
        }
        field(28; EarliestStartTimeDate; DateTime)
        {
            CalcFormula = Lookup ("Job Queue Entry"."Earliest Start Date/Time" WHERE (ID = FIELD (JobID)));
            Caption = 'Earliest Start Date/Time';
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; TableID; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type" = CONST (Table));
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupTable(TableID);
                if TableID <> 0 then
                    Validate(TableID);
            end;

            trigger OnValidate()
            begin
                if TableID = 0 then begin
                    Validate(TableField, 0);
                    CalcFields(TableDescription);
                end;
            end;
        }
        field(30; TableField; Integer)
        {
            Caption = 'Table Field';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                //This feature is yet to be implemented
                /*
                if TableID <> 0 then begin
                end;
                */
            end;

            trigger OnValidate()
            begin
                //This feature is yet to be implemented
                /*
                if TableField <> 0 then begin
                    Fields.Reset();
                    Fields.SetFilter(TableNo, Format(TableID));
                    Fields.SetFilter("No.", Format(TableField));
                    if not Fields.FindSet(false, false) then
                        Error(Text001Msg);
                end;
                CalcFields(TableFieldDescription);
                */
            end;
        }
        field(32; TableFieldDescription; Text[80])
        {
            CalcFormula = Lookup (Field."Field Caption" WHERE (TableNo = FIELD (TableID), "No." = FIELD (TableField)));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; LastSuccessTimeControlOn; Boolean)
        {
            Caption = 'Last Successful Run Control Active';
            DataClassification = CustomerContent;
        }
        field(34; MaxPastLastSuccessTime; Duration)
        {
            Caption = 'Allowed Delay from Last Successful Run';
            DataClassification = CustomerContent;
        }
        field(35; CheckJobQueueRecurrence; Boolean)
        {
            Caption = 'Check Job Queue Recurrence';
            DataClassification = CustomerContent;
        }
        field(36; TableDescription; Text[80])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Name" WHERE ("Object ID" = FIELD (TableID)));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "HeaderNo.", "LineNo.", InterfaceType)
        {
        }
    }

    trigger OnDelete()
    begin
        tInterfaceCtrlSetupHeader.SetModified("HeaderNo.", InterfaceType);
    end;

    trigger OnInsert()
    begin
        tInterfaceCtrlSetupHeader.SetModified("HeaderNo.", InterfaceType);
    end;

    trigger OnModify()
    begin
        tInterfaceCtrlSetupHeader.SetModified("HeaderNo.", InterfaceType);
    end;

    trigger OnRename()
    begin
        tInterfaceCtrlSetupHeader.SetModified("HeaderNo.", InterfaceType);
    end;

    var
        tInterfaceCtrlSetupHeader: Record "Interface Ctrl Setup Header";
        tInterfaceCtrlSetupLine: Record "Interface Ctrl Setup Line";
        //"Fields": Record "Field";
        Text001Msg: Label 'Invalid field number.';

    local procedure LookupObject(ObjectType: Integer; var ObjectID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        //Virtual table AllObjWithCaption is used to list all NAV db tables (system tables with Object ID of >=2000000000 are filtered out)
        //Similar code can also be found from RapidStart's table lookup functionality
        Clear(Objects);
        AllObjWithCaption.FilterGroup(2);
        AllObjWithCaption.SetRange("Object Type", ObjectType);
        AllObjWithCaption.SetFilter("Object ID", '..%1|%2|%3', 1999999999, DATABASE::"Permission Set", DATABASE::Permission);
        AllObjWithCaption.FilterGroup(0);
        Objects.SetTableView(AllObjWithCaption);
        Objects.LookupMode := true;
        if Objects.RunModal() = ACTION::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            ObjectID := AllObjWithCaption."Object ID";
        end;
    end;

    local procedure LookupTable(var ObjectID: Integer)
    var
        "Object": Record "Object";
    begin
        LookupObject(Object.Type::Table, ObjectID);
    end;

    procedure SetLineNo("InterfaceHeaderNo.": Code[20]; InterfaceHeaderType: Option)
    begin
        //Checks if existing lines are found and sets line number accordingly
        tInterfaceCtrlSetupLine.Reset();
        tInterfaceCtrlSetupLine.SetRange(InterfaceType, InterfaceHeaderType);
        tInterfaceCtrlSetupLine.SetFilter("HeaderNo.", "InterfaceHeaderNo.");
        if tInterfaceCtrlSetupLine.FindLast() then
            Validate("LineNo.", tInterfaceCtrlSetupLine."LineNo." + 10000)
        else
            Validate("LineNo.", 10000);
    end;
}