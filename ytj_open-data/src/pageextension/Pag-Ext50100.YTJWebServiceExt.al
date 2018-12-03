pageextension 50100 "YTJWebServiceExt" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            // Adding two new fields to Vendor Card
            field(RegisterValid; RegisterValid)
            {
                // This field shows whether a selected company register entry is valid or not
                // By default we are checking "ennakkoperintärekisteri"
                ApplicationArea = All;
                Caption = 'Register Valid';
                Editable = false;
            }
            field(LastChecked; LastChecked)
            {
                // Date and time of the latest check
                ApplicationArea = All;
                Caption = 'Last Checked';
                Editable = false;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(GetYTJData)
            {
                // An action button for performing the API call
                ApplicationArea = All;
                Caption = 'Get Company Information';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Add;

                trigger OnAction();
                var
                    YTJOpenDataMgmt: Codeunit YTJOpenDataMgmt;
                begin
                    YTJOpenDataMgmt.GetData(Rec);
                end;
            }
        }
    }
}