table 50112 "Interface Ctrl Status"
{
    // Contents of this table are populated when page "Interface Ctrl Status" is run. Update is performed with a codeunit called "Interface Ctrl Status Update".
    Caption = 'Interface Control Status';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Numeric = true;
            DataClassification = CustomerContent;
        }
        field(21; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,OK,Error';
            OptionMembers = " ",OK,Error;
            DataClassification = CustomerContent;
        }
        field(22; Time; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(23; Description; Text[250])
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
}