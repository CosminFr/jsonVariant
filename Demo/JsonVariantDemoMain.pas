unit JsonVariantDemoMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons;

type
  TfrmJVDemo = class(TForm)
    pnlButtons: TPanel;
    pnlJSON: TPanel;
    lblJSON: TLabel;
    memJson: TMemo;
    btnCreateJsonObject: TButton;
    btnCreateJsonList: TButton;
    btnUpdateJsonObject: TButton;
    btnUpdateJsonList: TButton;
    btnParseJsonObject: TButton;
    btnParseJsonList: TButton;
    btnValidateJsonObject: TButton;
    btnValidateJsonList: TButton;
    btnClose: TButton;
    pnlLog: TPanel;
    lblLog: TLabel;
    memLog: TMemo;
    splitLog: TSplitter;
    btnRealignLog: TSpeedButton;
    pnlClient: TPanel;
    btnOwnership: TButton;
    btnCase: TButton;
    btnConflicts: TButton;
    btnDateTime: TButton;
    gbPath: TGroupBox;
    cbPath: TComboBox;
    btnPath: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnCreateJsonObjectClick(Sender: TObject);
    procedure btnUpdateJsonObjectClick(Sender: TObject);
    procedure btnValidateJsonObjectClick(Sender: TObject);
    procedure btnParseJsonObjectClick(Sender: TObject);
    procedure btnCreateJsonListClick(Sender: TObject);
    procedure btnUpdateJsonListClick(Sender: TObject);
    procedure btnRealignLogClick(Sender: TObject);
    procedure btnValidateJsonListClick(Sender: TObject);
    procedure btnParseJsonListClick(Sender: TObject);
    procedure btnOwnershipClick(Sender: TObject);
    procedure btnCaseClick(Sender: TObject);
    procedure btnConflictsClick(Sender: TObject);
    procedure btnDateTimeClick(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure cbPathEnter(Sender: TObject);
  private
    procedure StartTest(const aName: String);
    procedure Log(const aText: String);
  end;

var
  frmJVDemo: TfrmJVDemo;

implementation

{$R *.dfm}

uses
  JSON,
  JsonVariant;

procedure TfrmJVDemo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmJVDemo.StartTest(const aName: String);
begin
  memLog.Lines.Add('--------------------------------------------');
  memLog.Lines.Add('   ' + aName);
  memLog.Lines.Add('--------------------------------------------');
end;

procedure TfrmJVDemo.Log(const aText: String);
begin
  memLog.Lines.Add(aText);
end;

procedure TfrmJVDemo.btnCreateJsonObjectClick(Sender: TObject);
var
  jData : Variant;
begin
  jData := VarJSONCreate();
  jData.Name    := 'John Smith';
  jData.DOB     := EncodeDate(1980, 7, 15);
  jData.Created := Now;
  jData.Address := VarJSONCreate();            //creates "Address" property as a JSON object - to be defined below
  jData.Phone   := '(03) 1234 5555';
  jData.Address.Street  := '10 Flinders St';
  jData.Address.City    := 'Melbourne';
  jData.Address.ZipCode := 3000;
  jData.Address.State   := 'VIC';

  memJson.Text := jData.AsJson;
end;

procedure TfrmJVDemo.btnUpdateJsonObjectClick(Sender: TObject);
var
  jData : Variant;
begin
  try
    jData := VarJSONCreate(memJson.Text);
    jData.Name    := 'Jane Doe';
    jData.DOB     := '1985/08/16';
    jData.Mobile  := '0400 123 456';
    jData.Updated := Now;
    jData.Remove('Phone');
    jData.Delete('Error');                  //Delete = Remove   (ignored if nothing to remove)
    jData.IsRegistered := True;
    jData.Address.Street  := '9 Elizabeth St';

    memJson.Text := jData.AsJson;
  except
    on E: Exception do
      Log(Format('Error %s in btnUpdateJsonObjectClick: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TfrmJVDemo.btnValidateJsonObjectClick(Sender: TObject);
var
  jData, jTmp : Variant;
begin
  try
    jData := VarJSONCreate(memJson.Text);

    StartTest('ValidateJsonObject');

    if not VarIsJsonObject(jData) then
      raise EParserError.Create('Input JSON is not an Object!');


    if jData.HasProperty('Name') then
      Log('Property "Name" found')
    else
      Log('Missing "Name" property');
    if jData.HasKey('IsRegistered') then                     //HasProperty = HasAttribute = HasName = HasKey
      Log('Key "IsRegistered" found')
    else
      Log('Missing "IsRegistered" key');

    if jData.HasName('Phone') then                           //HasProperty = HasAttribute = HasName = HasKey
      Log('Property "Phone" found')
    else
      Log('Missing "Phone" property');

    if jData.HasAttribute('Mobile') then                     //HasProperty = HasAttribute = HasName = HasKey
      Log('Attribute "Mobile" found')
    else
      Log('Missing "Mobile" attribute');

    jTmp := jData.Address;
    if VarIsEmpty(jTmp) then
      Log('"Address" property is Empty! ')
    else if VarIsStr(jTmp) then
      Log('"Address" property is String: ' + VarToStr(jTmp))
    else if VarIsJSON(jTmp) then begin
      Log('"Address" property is VarJSON - as expected ');

      jTmp := jData.Address.ZipCode;
      if VarType(jTmp) = varInteger then
        Log('"Address.ZipCode" is Integer ')
      else
        Log('"Address.ZipCode" is ' + VarTypeAsText(VarType(jTmp)));

    end;
  except
    on E: Exception do
      Log(Format('Error %s in btnValidateJsonObjectClick: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TfrmJVDemo.btnParseJsonObjectClick(Sender: TObject);
var
  jData, jVal : Variant;
  i : Integer;
  name : String;
  jPair : TJSONPair;

begin
  try
    jData := VarJSONCreate(memJson.Text);

    StartTest('ParseJsonObject (Version 1) for each name get value');
    for name in NamesOf(jData) do
      Log(name + '=' + VarToStr(jData.Get(name)));


    StartTest('ParseJsonObject (Version 2) old style for to Count-1 and get name & value by index');
    for i := 0 to jData.Count -1 do begin
      name := jData.Names[i];
      jVal := jData.Values[i];
      Log(name + '=' + VarToStr(jVal));
    end;

    StartTest('ParseJsonObject (Version 3) Peek into JSON Object and parse "Pairs" ');
    for jPair in PeekJsonObject(jData) do
      Log(jPair.JsonString.Value + '=' + jPair.JsonValue.ToJSON);


  except
    on E: Exception do
      Log(Format('Error %s in btnParseJsonObjectClick: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TfrmJVDemo.btnRealignLogClick(Sender: TObject);
begin
  if pnlLog.Align = alRight then begin
    pnlLog.Align   := alBottom;
    splitLog.Align := alBottom;
  end else begin  //alBottom => Right
    pnlLog.Align   := alRight;
    splitLog.Align := alRight;
  end;
  pnlLog.Realign;
end;

procedure TfrmJVDemo.btnCreateJsonListClick(Sender: TObject);
var
  jData : Variant;
begin
  jData := VarJSONCreate([]);     //Creates empty array
  jData.Add('John Smith');
  jData.Add('(03) 1234 5555');
  jData.Add(300);
  jData.Add(Now);

  memJson.Text := jData.AsJson;
end;

procedure TfrmJVDemo.btnUpdateJsonListClick(Sender: TObject);
var
  jData : Variant;
  jPhone  : Variant;
  jPhones : Variant;
begin
  try
    jData   := VarJSONCreate(memJson.Text);          //no type check! could be object or array!
    jPhones := VarJSONCreate(['0400 123 456', '0400 123 444', '0400 123 555']);

    if jData.Count = 4 then begin  //expected count after initialization
      jPhone := jData.Items[1];    //extract the phone value from 2nd position & move to phones list
      jData.Delete(1);
      jPhones.Add(jPhone);
    end;

    while jData.Count > 3 do      //remove extra values from a previous update
      jData.Delete(3);


    jData.Append(jPhones);    //Appends all elements to the list!
    jData.Add(jPhones);       //Adds the list as new element

    memJson.Text := jData.AsJson;
  except
    on E: Exception do
      Log(Format('Error %s in btnUpdateJsonListClick: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TfrmJVDemo.btnValidateJsonListClick(Sender: TObject);
var
  jData : Variant;
begin
  try
    StartTest('ValidateJsonObject');
    jData := VarJSONCreate(memJson.Text);   //no type check! could be object or array!

    if not VarIsJsonArray(jData) then
      raise EParserError.Create('Input JSON is not an Array!');

    if jData.Count = 4 then
      Log('There are 4 elements as expected after initialization')
    else
      Log(Format('List has %d elements', [Integer(jData.Count)]));

    jData.Clear;
    if jData.Count = 0 then
      Log('The list was cleared successfully')
    else
      Log(Format('List was NOT cleared and it still has %d elements', [Integer(jData.Count)]));
  except
    on E: Exception do
      Log(Format('Error %s in btnValidateJsonListClick: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TfrmJVDemo.btnParseJsonListClick(Sender: TObject);
var
  jData, jVal : Variant;
  i : Integer;
  jsVal : TJSONValue;
begin
  try
    jData := VarJSONCreate(memJson.Text);

    StartTest('ParseJsonObject (Version 1) for each name get value');
    for jVal in TArray<Variant>(jData.Items) do
      Log(VarToStr(jVal));


    StartTest('ParseJsonObject (Version 2) old style for to Count-1 and get name & value by index');
    for i := 0 to jData.Count -1 do begin
      jVal := jData.Values[i];
      Log(i.ToString + ': ' + VarToStr(jVal));
    end;

    StartTest('ParseJsonObject (Version 3) Peek into JSON Array');
    for jsVal in PeekJsonArray(jData) do
      Log(jsVal.ToJSON);


  except
    on E: Exception do
      Log(Format('Error %s in btnParseJsonObjectClick: %s', [E.ClassName, E.Message]));
  end;
end;

procedure TfrmJVDemo.btnOwnershipClick(Sender: TObject);
var
  jData : Variant;
  jAddress : Variant;

begin
  StartTest('Ownership considerations Demo');
  //See btnCreateJsonObjectClick. The second object "jData.Address" is created directly into the first JSON object
  //Let's see other options:
  // 1 - create independently and assign it later
  jData := VarJSONCreate();
  jAddress := VarJSONCreate();            //creates "Address" property as a JSON object - to be defined below
  jAddress.Street  := '10 Flinders St';
  jAddress.City    := 'Melbourne';
  jAddress.ZipCode := 3000;
  jAddress.State   := 'VIC';

  jData.Name    := 'John Smith';
  jData.Created := Now;
  jData.Address := jAddress;              //assigns the "Address" property as a COPY of the jAddress!
  jData.Phone   := '(03) 1234 5555';

  //Changing the "jAddress" will not affect "jData.Address"! Two independent copies!
  jAddress.State   := 'NSW';
  if jData.Address.State = 'VIC' then
    Log('Changing the "jAddress" does not affect "jData.Address"! Two independent copies!')
  else
    Log('Changing the "jAddress" affected "jData.Address"! References the same JSON object!');

  //Destroying jAddress is not an issue as the jData contains a copy (not reference)
  jAddress := Null;
  if jData.Address.State = 'VIC' then
    Log('Destroying "jAddress" does not affect "jData.Address"! Two independent copies!')
  else
    Log('Destroying "jAddress" affected "jData.Address"! References the same JSON object!');

  // 2 - reference the same object
  jAddress := jData.Address;
  //and re-try the above...
  jAddress.State   := 'NSW';
  if jData.Address.State = 'VIC' then
    Log('Changing the "jAddress" does not affect "jData.Address"! Two independent copies!')
  else
    Log('Changing the "jAddress" affected "jData.Address"! References the same JSON object!');

  //Destroying jAddress is not an issue as the jData is the owner.
  //However, destroying the jData, jAddress is still assigned, but no longer valid!
  jData := Null;
  try
    if VarIsEmpty(jAddress) then
      Log('Destroying "jData" emptied "jAddress"!')
    else if VarIsNull(jAddress) then
      Log('Destroying "jData" makes "jAddress" NULL!')
    else if jAddress.State = 'NSW' then
      Log('Destroying "jData" did not affect "jData.Address"! Although it references a freed object!!') ;
  except
    Log('After destroying "jData" the "jAddress" is invalid! Referenced JSON object was destroyed!');
  end;
end;

procedure TfrmJVDemo.btnCaseClick(Sender: TObject);
var
  j : Variant;
begin
  StartTest('Case Sensitivity Demo');
  // Since JSON is case sensitive ID, Id and id are all different properties!
  // Also being variants, a numerical string literal can be converted on the fly.
  j := VarJSONCreate;
  j.ID := 50;
  j.Id := '45';
  j.id := j.ID - j.Id;

  if j.id = 5 then
    Log('JSON is case sensitive: ' + j.ToString)
  else
    Log('Case sensitivity check failed!');
end;

procedure TfrmJVDemo.btnConflictsClick(Sender: TObject);
var
  j : Variant;
  k : String;
begin
  StartTest('Naming conflits demo');
  j := VarJSONCreate;
  j.ID     := 50;
  j.Count  := 123;             //Setting a property "Count"
  j.count  := 'second count';  //Setting a property "count"
  j.Remove := True;
  j.Delete := 'Yes';
  //What happens with the function "Count" (as in the number of properties)?
  //A: Luckily Delphi functions are case insensitive, so the function returns the same result for "count" or "COUNT" or "cOuNt",...
  // * A property value always supperceeds any function, but the function can be accessed through different case OR
  //   a synonim function (aka Items vs Values | Names vs Keys | Remove vs Delete | ...
  Log(Format('JSON has %s properties. (Count=%s; count=%s)', [j.COUNT, j.Count, j.count]));

  j.Names  := VarJSONCreate(['John', 'Smith']);
  Log(Format('JSON has a "Names" property: %s', [j.Names.ToString]));
  Log('So parse "Keys" (or "names") instead of "Names":');
  for k in TArray<String>(j.Keys) do
    Log(k);

  if j.Remove then
    j.Remove('Remove');        //somehow still works as Delphi knows this is a function not property!

  Log('JSON after deleting "Remove": ' + j.AsJson);
end;

procedure TfrmJVDemo.btnDateTimeClick(Sender: TObject);
var
  j : Variant;
  d : TDateTime;
begin
  StartTest('Date/Time Demo');
  //As you might have noticed above, date/time can be assigned to json and it's automatically converted to ISO8601 format
  //if you want other formats, please use AsDate/AsString functions
  j := VarJSONCreate;
  j.Default    := Now;
  j.SystemDate := AsString(Now-15, 'System');     //ShortDateFormat as configured in your local system (windows)
  j.MyDate     := AsString(Now, 'DD-MM-YYYY');    //manually specify desired format

  d := AsDate(j.MyDate, 'DD-MM-YYYY');           //j.MyDate is a string, try to convert it to a date using expected format...
  Log('MyDate from JSON: ' + DateToStr(d));

  d := j.Default;                                //if in ISO8601 format, it may convert to varDate
  if VarIsType(j.Default, varDate) then                          //otherwise it might be a string
    Log('Default Date from JSON: ' + DateToStr(d))
  else
    Log('Default Date from JSON (not a date?): ' + VarToStr(j.Default));
  d := AsDate(j.SystemDate);                         //Also tries "System" if the default ISO8601 fails!
  Log('System Date from JSON: ' + DateToStr(d));

  memJson.Text := j.AsText;
end;

const
  JSON_PATH_DEMO  = '''
                    { "store": {
                        "book": [
                          { "category": "reference",
                            "author": "Nigel Rees",
                            "title": "Sayings of the Century",
                            "price": 8.95
                          },
                          { "category": "fiction",
                            "author": "Evelyn Waugh",
                            "title": "Sword of Honour",
                            "price": 12.99
                          },
                          { "category": "fiction",
                            "author": "Herman Melville",
                            "title": "Moby Dick",
                            "isbn": "0-553-21311-3",
                            "price": 8.99
                          },
                          { "category": "fiction",
                            "author": "J. R. R. Tolkien",
                            "title": "The Lord of the Rings",
                            "isbn": "0-395-19395-8",
                            "price": 22.99
                          }
                        ],
                        "bicycle": {
                          "color": "red",
                          "price": 19.95
                        }
                      }
                    }
                    ''';
procedure TfrmJVDemo.cbPathEnter(Sender: TObject);
begin
  memJson.Text := JSON_PATH_DEMO;
end;


function  VarToText(aSource: Variant): String;
var
  i : Integer;
  v : Variant;
begin
  if VarIsArray(aSource) then begin
    Result := '[';
    for v in TArray<Variant>(aSource) do
      Result := Result + '"' + VarToText(v) + '", ';

    Result := Result + ']';
  end else
    Result := VarToStr(aSource);

end;

procedure TfrmJVDemo.btnPathClick(Sender: TObject);
var
  json : Variant;
  vRes : Variant;
begin
  //uses the examples from https://goessner.net/articles/JsonPath/
  memJson.Text := JSON_PATH_DEMO;
  json := VarJSONCreate(memJson.Text);

  StartTest('JSON Path');

  try
    vRes := json.FindValue(cbPath.Text);
  except
    on E: Exception do
      vRes := E.Message;
  end;
  Log(Format('FindValue("%s"): "%s"', [cbPath.Text, VarToText(vRes)]));

  try
    vRes := json.Path(cbPath.Text);
  except
    on E: Exception do
      vRes := E.Message;
  end;
  Log(Format('JSONPath("%s"): "%s"', [cbPath.Text, VarToText(vRes)]));
end;

end.
