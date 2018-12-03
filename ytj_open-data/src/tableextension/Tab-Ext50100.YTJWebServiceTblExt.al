tableextension 50100 "YTJWebServiceTblExt" extends Vendor
{
    fields
    {
        // Extending the Vendor table with two new fields
        // Please, check the respective comments on Vendor Card related page extension
        field(50100; RegisterValid; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate();
            begin

            end;
        }
        field(50101; LastChecked; Date)
        {
            DataClassification = CustomerContent;
            trigger OnValidate();
            begin

            end;
        }
    }
}