codeunit 50100 "YTJOpenDataMgmt"
// YTJ's API definition can be found from http://avoindata.prh.fi/ytj.html#!/bis47v1/get

// Yhteisötietojärjestelmä, or YTJ, (in English, "The Business Information System") is a Finnish national authority responsible for
// maintaining up-to-date records of Finnish companies and their contact information
{
    procedure GetData(var Vendor: Record Vendor)
    begin
        OnBeforeGetYTJData(Vendor); // Event publisher for other extension to subscribe to
        GetYTJData(Vendor);
        OnAfterGetYTJData(Vendor); // Event publisher for other extension to subscribe to
    end;

    local procedure GetYTJData(var Vendor: Record Vendor)
    begin
        // Business Identity Code is used as a primary key to get the company information
        if not CheckBIC(Vendor."Business Identity Code") then
            exit;
        // User must confirm the action
        if not ConfirmRun() then
            exit;
        HandleDataFromWebService(Vendor);
    end;

    local procedure CheckBIC(VendorBIC: Text[20]): Boolean
    // If BIC is not found, an error will occur
    var
        EmptyBICMsg: Label 'Business Identity Code cannot be empty. Please, provide a value.';
    begin
        if VendorBIC = '' then begin
            Message(EmptyBICMsg);
            exit(false);
        end
        else
            exit(true);
    end;

    local procedure ConfirmRun(): Boolean
    var
        ConfirmLabelMsg: Label 'Do you want to fetch Vendor Information from YTJ?';
    begin
        if Confirm(ConfirmLabelMsg, true) then
            exit(true);
    end;

    local procedure InitVendorRecord(var Vendor: Record Vendor)
    // Let us init the fields we'll populate from YTJ
    // Not all the available fields from API response are used
    begin
        with Vendor do begin
            Name := '';
            Address := '';
            City := '';
            "Post Code" := '';
            "Phone No." := '';
        end;
    end;

    local procedure SaveVendorRecord(var Vendor: Record Vendor)
    begin
        Vendor.Modify(true);
    end;

    local procedure HandleDataFromWebService(var Vendor: Record Vendor)
    begin
        InitVendorRecord(Vendor);
        PopulateVendorFields(Vendor, FetchData(Vendor."Business Identity Code"));
        SaveVendorRecord(Vendor);
    end;

    local procedure PopulateVendorFields(var Vendor: Record Vendor; ContentJSON: JsonObject)
    var
        JSONArray: JsonArray;
        FullJSONObject: JsonObject;
        JSONObject: JsonObject;
        JSONToken: JsonToken;
    begin
        if ContentJSON.SelectToken('results', JSONToken) then begin
            JSONArray := JSONToken.AsArray();
            if JSONArray.Get(0, JSONToken) then begin
                FullJSONObject := JSONToken.AsObject();
                if FullJSONObject.Get('name', JSONToken) then
                    Vendor.Name := CopyStr(JSONToken.AsValue().AsText(), 1, 50);
                if FullJSONObject.Get('addresses', JSONToken) then begin
                    JSONArray := JSONToken.AsArray();
                    if JSONArray.Get(0, JSONToken) then begin
                        JSONObject := JSONToken.AsObject();
                        if JSONObject.Get('street', JSONToken) then
                            Vendor.Address := CopyStr(JSONToken.AsValue().AsText(), 1, 50);
                        if JSONObject.Get('postCode', JSONToken) then
                            Vendor."Post Code" := CopyStr(JSONToken.AsValue().AsText(), 1, 20);
                        if JSONObject.Get('city', JSONToken) then
                            Vendor.City := CopyStr(JSONToken.AsValue().AsText(), 1, 30);
                    end;
                    if FullJSONObject.Get('contactDetails', JSONToken) then begin
                        JSONArray := JSONToken.AsArray();
                        if JSONArray.Get(0, JSONToken) then begin
                            JSONObject := JSONToken.AsObject();
                            if JSONObject.Get('value', JSONToken) then
                                Vendor."Phone No." := CopyStr(JSONToken.AsValue().AsText(), 1, 30);
                        end;
                    end;
                    if FullJSONObject.Get('registeredEntries', JSONToken) then begin
                        JSONArray := JSONToken.AsArray();
                        if JSONArray.Get(5, JSONToken) then begin
                            JSONObject := JSONToken.AsObject();
                            if JSONObject.Get('status', JSONToken) then begin
                                if JSONToken.AsValue().AsText() = '1' then
                                    Vendor.RegisterValid := true
                                else
                                    Vendor.RegisterValid := false;
                                Vendor.LastChecked := Today();
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure FetchData(VendorBIC: Text[20]) ResponseJSON: JSONObject
    var
        ContentText: Text;
        HTTPContent: HttpContent;
        HTTPClient: HttpClient;
        HTTPResponseMsg: HttpResponseMessage;
        URLTxt: Label 'http://avoindata.prh.fi/bis/v1/';
        ConnectionErrorMsg: Label 'Connection could not be established.';
        ErrorResponseMsg: Label 'Connection to the remote API was unsuccessful. Please, try again later.';
    begin
        HTTPContent.WriteFrom(ContentText);

        if not HTTPClient.Get(URLTxt + VendorBIC, HTTPResponseMsg) then
            Error(ConnectionErrorMsg);
        if not HTTPResponseMsg.IsSuccessStatusCode() then
            Error(ErrorResponseMsg);

        HTTPResponseMsg.Content().ReadAs(ContentText);
        ResponseJSON.ReadFrom(ContentText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetYTJData(var Vendor: Record Vendor) // Event publisher for other extension to subscribe to
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetYTJData(var Vendor: Record Vendor) // Event publisher for other extension to subscribe to
    begin
    end;
}