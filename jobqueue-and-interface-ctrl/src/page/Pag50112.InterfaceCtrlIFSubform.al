page 50112 "Interface Ctrl IF Subform"
{
    Caption = 'Interface List';
    PageType = ListPart;
    SourceTable = "Interface Ctrl Setup Line";
    SourceTableView = WHERE (InterfaceType = FILTER (Interface));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TableID; TableID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Log table from which the interface status is monitored.';
                }
                field(TableDescription; TableDescription)
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the selected interface log table.';
                }
                field(TableField; TableField)
                {
                    ApplicationArea = All;
                    ToolTip = 'Log table field that contains the information about the respective interface status.';
                }
                field(TableFieldDescription; TableFieldDescription)
                {
                    ApplicationArea = All;
                }
                field(IsJobControlOn; IsJobControlOn)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetLineNo("HeaderNo.", InterfaceType);
    end;
}