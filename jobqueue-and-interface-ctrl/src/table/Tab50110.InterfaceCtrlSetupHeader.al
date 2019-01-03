table 50110 "Interface Ctrl Setup Header"
{
    Caption = 'Interface Control Setup Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Job Queue,Interface';
            OptionMembers = " ","Job Queue",Interface;
            DataClassification = CustomerContent;
        }
        field(21; LastModified; DateTime)
        {
            Caption = 'Last Modified';
            DataClassification = CustomerContent;
        }
        field(22; LastModifiedBy; Code[50])
        {
            Caption = 'Modified By';
            TableRelation = User."User Name";
            DataClassification = CustomerContent;

        }
        field(23; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Disabled,Enabled';
            OptionMembers = Disabled,Enabled;
            DataClassification = CustomerContent;
        }
        field(24; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        with tIntfCtrlSetupLines do begin
            Reset();
            SetRange(InterfaceType, Type);
            SetFilter("HeaderNo.", "No.");
            if FindSet() then
                DeleteAll();
        end;
    end;

    trigger OnModify()
    begin
        SetModified("No.", Type);
    end;

    trigger OnRename()
    begin
        SetModified("No.", Type);
    end;

    var
        tIntfCtrlSetupLines: Record "Interface Ctrl Setup Line";
        Modified: Boolean;

    procedure SetEnabled()
    begin
        if Status = Status::Disabled then begin
            Status := Status::Enabled;
            Modify();
        end;
    end;

    procedure SetDisabled()
    begin
        if Status = Status::Enabled then begin
            Status := Status::Disabled;
            Modify();
        end;
    end;

    procedure SetModified(HeaderNo: Code[20]; InterfaceType: Option)
    begin
        //Save the datetime of latest modification and username of the modifier
        Reset();
        SetFilter("No.", HeaderNo);
        SetRange(Type, InterfaceType);
        if FindFirst() then begin
            LastModifiedBy := CopyStr(UserId(), 1, 50);
            LastModified := CurrentDateTime();
            Modify();
        end;
    end;
}