unit JsonVariant;
(***********************************************************************************************************************

  Introducing "VarJSON" custom variant.

  Create a JSON variant with VarJSONCreate functions:
    * no param => empty JSON Object
    * const array => JSON Array
       - use [] for an empty JSON Array
    * JSON text => JSON variant for whatever Object/Array

  Access JSON properties like you would with a normal delphi object:
    json := VarJSONCreate('{"Name": "John Smith",	"Phone": "(03) 1234 5555"}');
    ShowMessage(json.Name + ': ' + json.Phone);

    jArr := VarJSONCreate([1, 2, 4, 8]);
    jArr.Add(16);

  To get the JSON text from a JSON Variant one can simply cast it to a string:
    memJSON.Text := json;          //(defaut=~.AsJson) returns a compact JSON
    memJSON.Text := json.AsText;   //returns a formatted JSON (aka "pretty" version).

***********************************************************************************************************************)
interface

uses
  System.Classes, System.Types, System.SysUtils, System.Variants, System.Generics.Collections, System.JSON,
  System.StrUtils, System.DateUtils;


function VarJSON: TVarType;
function VarIsJSON(const aValue: Variant): Boolean;
function VarAsJSON(const aValue: Variant): Variant;

function VarIsJsonObject(const aValue: Variant): Boolean;
function VarIsJsonArray (const aValue: Variant): Boolean;

function VarJSONCreate(const aJsonText: String): Variant;     overload;
function VarJSONCreate: Variant;                              overload;
function VarJSONCreate(const Args: array of const): Variant;  overload;
function VarJSONCreate(const aVarArray: Variant): Variant;    overload;

/// Creates a new TJSONValue (clone) from the variant! The ownership is passed to the caller = pay attention to memory leaks...
function ExtractJsonValue(const aValue: Variant): TJSONValue;

/// Exposes the JSON Value used by a VarJSON (returns nil for non JSON variants)! DO NOT FREE!!!
///  Ownership is NOT transfered! aka DO NOT FREE!!! (unless you want AV errors)
function PeekJsonValue (const aValue : Variant) : TJSONValue;
function PeekJsonObject(const aValue : Variant) : TJSONObject;
function PeekJsonArray (const aValue : Variant) : TJSONArray;

function NamesOf(const aValue: Variant): TStringDynArray;
function ValuesOf(const aValue: Variant): TArray<Variant>;

/// Conversion functions for setting values
function AsDate(aValue: String; aFormat: String = 'ISO8601') : TDateTime;
function AsBoolean(aValue: String) : Boolean;
function AsNumber(aValue: String) : Variant;
function AsString(aDate : TDateTime; aFormat: String = 'ISO8601') : String; overload;
function AsString(aBool : Boolean)   : String; overload;


implementation

{$IFDEF USE_LOGGER}
uses
  EasyLogger;
{$ENDIF}


{=======================================================================================================================

  TJsonVarData = the record for VarJSON custom variant.
               * similar with TVarData record of normal Variant
      contains: VType (= VarJSON - initialized at run-time)
                Owned (Boolean)
                Value (TJSONValue)

  TVarJsonVariant = the custom variant class handling VarJSON variants
                  * there is only ONE instance of this class = _VarDataJSON
                  * it handles conversions to other TVarData records & any operations on the new TJsonVarData

=======================================================================================================================}

type
  TJsonVarData = packed record
    VType: TVarType;
    Reserved1, Reserved2: Word;
    Owned: WordBool;
    Value: TJSONValue;
    Reserved4: LongInt;
  end;

  TVarJsonVariant = class(TInvokeableVariantType)
  protected
    //Added to access "Property By Index"
    procedure DispInvoke(Dest: PVarData; [Ref] const Source: TVarData; CallDesc: PCallDesc; Params: Pointer); override;

    //Avoid base class behaviour (UPPERCASE) property names. JSON is Case Sensitive!!!
    function FixupIdent(const aText: string): string; override;

    // Create the proper Variant from provided JSON Value. That means standard variant for ordinal values! (Numeric/String)
    function VariantFromJsonValue(const aJsonValue: TJSONValue): Variant; overload;

    /// Note: The following functions CREATE the TJSONValue!
    /// The ownership is passed to the caller = pay attention to memory leaks...
    function JsonValueFromVariant(const aValue : Variant) : TJSONValue;

    /// Note: This exposes the JSONValue used! The ownership remains unchanged. DO NOT FREE!!!
    function PeekJsonValue(const aValue : Variant) : TJSONValue;

    /// If aValue is TJSONArray - empty it
    /// If aValue is TJSONObject - remove all pairs
    procedure ClearJson(const aValue : TJSONValue);

    /// Try to find the index of specified value. (-1 if not found)
    ///  The value matching is case sensitive!
    ///  For objects, try matching against both key & value
    function IndexOf(const aSource: TJSONValue; const aValue : Variant) : Integer;

    /// Create a variant array with key names from the JSON Object
    function GetNames(const aJsonObject: TJSONObject): Variant;
    /// Create a variant array with values from the JSON Value
    function GetValues(const aSource: TJSONValue): Variant;
  public
    procedure Clear(var V: TVarData); override;
    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;
    procedure CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType); override;

    function GetProperty(var Dest: TVarData; const V: TVarData; const Name: string): Boolean; override;
    function SetProperty(const V: TVarData; const Name: string; const Value: TVarData): Boolean; override;
    function GetPropertyByIndex(var Dest: TVarData; const V: TVarData; const Name: string; const Index : integer): Boolean;
    function SetPropertyByIndex(const V: TVarData; const Name: string; const Index : integer; const Value: TVarData): Boolean;

    function DoFunction(var Dest: TVarData; const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean; override;
    function DoProcedure(const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean; override;
  end;



function PrintJsonVarData(const aData: TJsonVarData) : String;
begin
  try
    if Assigned(aData.Value) then
      Result := Format('TJsonVarData(Owned=%s, Value=%s, JSON=%s)', [AsString(aData.Owned), aData.Value.Value, aData.Value.ToJSON])
    else
      Result := Format('TJsonVarData(Owned=%s, Value=NOT ASSIGNED!)', [AsString(aData.Owned)]);
  except
    try
      Result := Format('TJsonVarData(Owned=%s, Value=%s, JSON=RAISED EXCEPTION!)', [AsString(aData.Owned), aData.Value.Value]);
    except
      on E: Exception do
        Result := 'TJsonVarData(RAISED EXCEPTION!): ' + E.Message;
    end;
  end;
end;

function PrintVarData(const aData: TVarData) : String;
begin
  if aData.VType = VarJSON then
    Result := PrintJsonVarData(TJsonVarData(aData))
  else
    Result := Format('VType=%d; AsStr=%s', [aData.VType, VarToStr(Variant(aData))]);
end;

function AsDate(aValue: String; aFormat: String = 'ISO8601') : TDateTime;
var
  FS : TFormatSettings;
begin
  if aValue = '' then
    Result := 0
  else begin
    if SameText(aFormat, 'ISO8601') then begin
      //Try ISO8601
      if (Length(aValue) > 9) and TryISO8601ToDate(aValue, Result) then
        Exit
      //Try with system settings
      else if TryStrToDateTime(aValue, Result) then
        Exit
      else //Try from Float value
        Result := StrToFloatDef(aValue, 0);
    end else if SameText(aFormat, 'Numeric') then begin
      Result := StrToFloatDef(aValue, 0)
    end else begin
      FS := TFormatSettings.Create;
      if not SameText(aFormat, 'System') then
        FS.ShortDateFormat := aFormat;
      //Try given format
      if not TryStrToDateTime(aValue, Result, FS) then
        //Try ISO8601
        if not TryISO8601ToDate(aValue, Result) then
          //Try from Float value
          Result := StrToFloatDef(aValue, 0)
    end;
  end;
end;

function AsBoolean(aValue: String) : Boolean;
const FALSE_CHARS = ['0', 'F', 'f', 'N', 'n'];
begin
  Result := (aValue <> '') and (not CharInSet(aValue[1], FALSE_CHARS));
end;

function AsNumber(aValue: String) : Variant;
var
  iRes : Integer;
  i64  : Int64;
  cRes : Currency;
  dRes : Double;
begin
  if TryStrToInt(aValue, iRes) then
    Result := iRes
  else if TryStrToInt64(aValue, i64) then
    Result := i64
  else if TryStrToCurr(aValue, cRes) then
    Result := cRes
  else if TryStrToFloat(aValue, dRes) then
    Result := dRes
  else
    Result := aValue;  //Failed to set as number, leave as is (str)
end;

function AsString(aDate : TDateTime; aFormat: String = 'ISO8601') : String;
var
  FS : TFormatSettings;
begin
  if SameText(aFormat, 'ISO8601') then
    Result := DateToISO8601(aDate)
  else if SameText(aFormat, 'Numeric') then
    Result := FloatToStr(aDate)
  else begin
    FS := TFormatSettings.Create;
    if SameText(aFormat, 'System') then
      aFormat := FS.ShortDateFormat;
    Result := FormatDateTime(aFormat, aDate);
  end;
end;

function AsString(aBool : Boolean)   : String;
const
  STR_BOOL: array[Boolean] of string  = ('False', 'True');
begin
  Result := STR_BOOL[aBool];
end;



{ TVarJsonVariant }

procedure TVarJsonVariant.Clear(var V: TVarData);
var J: TJsonVarData absolute V;
begin
//  Logger.Debug('TVarJsonVariant.Clear: ' + PrintVarData(V));
  if (V.VType and varTypeMask) = VarJSON then begin
    if J.Owned then
      J.Value.Free();
    J.Value := nil;
    J.Owned := False;
    V.VType := varEmpty;
  end else
    inherited;
end;

procedure TVarJsonVariant.ClearJson(const aValue: TJSONValue);
var
  jObj : TJsonObject absolute aValue;
  jArr : TJSONArray  absolute aValue;
begin
  if (aValue is TJSONArray) then begin
//    jArr := TJSONArray(aValue);
    while jArr.Count > 0 do
      jArr.Remove(0);
  end else if (aValue is TJSONObject) then begin
//    jObj := TJSONObject(aValue);
    while jObj.Count > 0 do
      jObj.RemovePair(jObj.Pairs[0].JsonString.Value);
  end;
end;

procedure TVarJsonVariant.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if ((Source.VType and varTypeMask) = VarJSON) then begin
    TJsonVarData(Dest).Value := TJsonVarData(Source).Value;
    TJsonVarData(Dest).Owned := False;
    Dest.VType               := VarJSON;
//    Logger.DebugFmt('TVarJsonVariant.Copy: New Value=%s', [PrintVarData(Dest)]);
  end else
    inherited;
end;

procedure TVarJsonVariant.CastTo(var Dest: TVarData; const Source: TVarData; const AVarType: TVarType);
var
  jSource : TJSONValue;
begin
  //Safety check - Source should be VarJSON otherwise it should not try to cast it to something...
  if ((Source.VType and varTypeMask) = VarJSON) then begin
    Dest.VType := AVarType;
    jSource    := TJsonVarData(Source).Value;

    case AVarType and varTypeMask of
      //"VarIsOrdinal"
      varBoolean    : if jSource is TJSONBool then
                        Variant(Dest) := TJSONBool(jSource).AsBoolean
                      else if jSource is TJSONString then
                        Variant(Dest) := AsBoolean(TJSONString(jSource).Value)
                      else
                        Variant(Dest) := False;
      varSmallInt,
      varShortInt,
      varByte,
      varWord,
      varInteger   : if jSource is TJSONNumber then
                        Variant(Dest) := TJSONNumber(jSource).AsInt
                      else if jSource is TJSONString then
                        Variant(Dest) := StrToIntDef(TJSONString(jSource).Value, 0)
                      else
                        Variant(Dest) := 0;
      varUInt32     : if jSource is TJSONNumber then
                        Dest.VUInt64 := TJSONNumber(jSource).AsUInt
                      else if jSource is TJSONString then
                        Dest.VUInt64 := StrToUIntDef(TJSONString(jSource).Value, 0)
                      else
                        Dest.VUInt32 := 0;
      varInt64      : if jSource is TJSONNumber then
                        Dest.VUInt64 := TJSONNumber(jSource).AsInt64
                      else if jSource is TJSONString then
                        Dest.VUInt64 := StrToInt64Def(TJSONString(jSource).Value, 0)
                      else
                        Dest.VInt64 := 0;
      varUInt64     : if jSource is TJSONNumber then
                        Dest.VUInt64 := TJSONNumber(jSource).AsUInt64
                      else if jSource is TJSONString then
                        Dest.VUInt64 := StrToUInt64Def(TJSONString(jSource).Value, 0)
                      else
                        Dest.VUInt64 := 0;
      //"VarIsFloat"
      varCurrency   : if jSource is TJSONNumber then
                        Dest.VCurrency := TJSONNumber(jSource).AsCurrency
                      else if jSource is TJSONString then
                        Dest.VCurrency := StrToCurrDef(TJSONString(jSource).Value, 0)
                      else
                        Dest.VCurrency := 0;
      varSingle,
      varDouble     : if jSource is TJSONNumber then
                        Dest.VDouble := TJSONNumber(jSource).AsDouble
                      else if jSource is TJSONString then
                        Dest.VDouble := StrToFloatDef(TJSONString(jSource).Value, 0)
                      else
                        Dest.VDouble := 0;
      varDate       : if jSource is TJSONNumber then
                        Dest.VDate := TJSONNumber(jSource).AsDouble
                      else if jSource is TJSONString then
                        Dest.VDate := AsDate(TJSONString(jSource).Value)    //Try to get date from ISO8601 text
                      else
                        Dest.VDate := 0;
      //"VarIsStr"
      varOleStr,                                                         //TODO: find a better way to handle each string...
      varString,
      varUString    : if jSource is TJSONString then
                        Variant(Dest) := TJSONString(jSource).Value
                      else
                        Variant(Dest) := jSource.ToJSON;
    else //"non-constant" types
      if (AVarType and varTypeMask) = VarJSON then
        Copy(Dest, Source, False)
      else begin
        Variant(Dest) := jSource.ToJSON;
{$IFDEF USE_LOGGER}
        Logger.ErrorFmt('Unexpected Variant (input=%s)! Result might be unexpected. (output=%s)', [PrintVarData(Source), PrintVarData(Dest)]);
{$ENDIF}
      end;
    end; //case AVarType (else)
  end else
    inherited;
end;

function TVarJsonVariant.FixupIdent(const aText: string): string;
begin
  //Overriding base class behaviour (=UPPERCASE) due to JSON being case sensitive!!!
  Result := aText;
end;

procedure TVarJsonVariant.DispInvoke(Dest: PVarData; [Ref] const Source: TVarData; CallDesc: PCallDesc; Params: Pointer);
const
  CDoMethod    = $01;
  CPropertyGet = $02;
  CPropertySet = $04;
var
  LArgCount: Integer;
  PIdent: PByte;
  LIdent: string;
  VarParams: TVarDataArray;
  Strings: TStringRefList;
  bHandled : Boolean;
begin
  LArgCount := CallDesc^.ArgCount;
  if (LArgCount = 0) or (CallDesc^.CallType = CDoMethod) then
    inherited     //only interested in indexed properties
  else begin
    // Grab the identifier
    PIdent := @CallDesc^.ArgTypes[LArgCount];
    LIdent := FixupIdent( UTF8ToString(MarshaledAString(PIdent)) );
    SetLength(Strings, LArgCount);
    bHandled  := False;
    VarParams := GetDispatchInvokeArgs(CallDesc, Params, Strings, true);
    try
      // Override behaviour for "indexed" properties
      case CallDesc^.CallType of
        CPropertyGet:
          if (Dest <> nil) and                                           // there must be a dest
             (LArgCount = 1) and (VarParams[0].VType = varInteger) then   // we have 1 integer param
            bHandled := GetPropertyByIndex(Dest^, Source, LIdent, VarParams[0].VInteger);

        CPropertySet:
          if (Dest = nil) and                          // there can't be a dest
             (LArgCount = 2) and                       // we have 2 params
             (VarParams[0].VType = varInteger) then     // first one is integer (index)
            bHandled := SetPropertyByIndex(Source, LIdent, VarParams[0].VInteger, VarParams[1]);
      end;

    finally
      FinalizeDispatchInvokeArgs(CallDesc, VarParams, true);
      for var I := 0 to Length(Strings) - 1 do
      begin
        if Pointer(Strings[I].Wide) = nil then
          Break;
        {$IFNDEF NEXTGEN}
        if Strings[I].Ansi <> nil then
          Strings[I].Ansi^ := AnsiString(Strings[I].Wide)
        else
        {$ENDIF !NEXTGEN}
          if Strings[I].Unicode <> nil then
            Strings[I].Unicode^ := UnicodeString(Strings[I].Wide)
      end;
    end;

    if not bHandled then
      inherited;
  end;
end;

function TVarJsonVariant.DoFunction(var Dest: TVarData; const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean;
var
  jSource : TJSONValue;
begin
  jSource := TJsonVarData(V).Value;
  Result  := True;
  if MatchText(Name, ['ToString', 'AsString']) then
    Variant(Dest) := jSource.ToString
  else if MatchText(Name, ['ToJson', 'AsJson']) then
    Variant(Dest) := jSource.ToJSON
  else if MatchText(Name, ['ToText', 'AsText']) then
    Variant(Dest) := jSource.Format()
  else if MatchText(Name, ['Items', 'Values', 'Get']) then begin
    //There must be only one argument of type Integer!
    Result := (Length(Arguments) = 1) and (Arguments[0].VType = varInteger);
    if Result and (jSource is TJSONArray) then
      Variant(Dest) := VariantFromJsonValue(TJSONArray(jSource).Items[Arguments[0].VInteger])
    else if Result and (jSource is TJSONObject) then
      Variant(Dest) := VariantFromJsonValue(TJSONObject(jSource).Pairs[Arguments[0].VInteger].JsonValue);
    //For Objects, allow a finding the value by key/name string
    if (not Result) and (jSource is TJSONObject) and (Length(Arguments) = 1) and VarDataIsStr(Arguments[0]) then begin
      jSource := TJSONObject(jSource).FindValue(VarDataToStr(Arguments[0]));
      Result  := Assigned(jSource);
      if Result then
        Variant(Dest) := VariantFromJsonValue(jSource)
    end;
  end else if MatchText(Name, ['IndexOf', 'FindValue']) then begin
    //There must an argument AND the source must be assigned (accept both array & object)
    Result := (Length(Arguments) = 1) and Assigned(jSource);
    if Result then
      Variant(Dest) := IndexOf(jSource, Variant(Arguments[0]));
  end else if MatchText(Name, ['HasProperty', 'HasAttribute', 'HasName', 'HasKey']) then begin
    //There must an argument AND the source must be an object
    Result := (Length(Arguments) = 1) and (jSource is TJSONObject);
    if Result then
      Variant(Dest) := Assigned(TJSONObject(jSource).GetValue(Variant(Arguments[0])));
  end else
    Result := inherited DoFunction(Dest, V, Name, Arguments);
end;

function TVarJsonVariant.DoProcedure(const V: TVarData; const Name: string; const Arguments: TVarDataArray): Boolean;
var
  jSource : TJSONValue;
  jValue  : TJSONValue;
begin
  jSource := TJsonVarData(V).Value;
  if SameText(Name, 'Add') then begin
    //There must be only one argument AND the source must be an array!
    Result := (Length(Arguments) = 1) and (jSource is TJSONArray);
    if Result then
      TJSONArray(jSource).AddElement(JsonValueFromVariant(Variant(Arguments[0])));
      //Important note: the ownership is moved to the array. (either create or clone)
  end else if SameText(Name, 'Append') then begin
    //There must be only one argument AND the source must be an array!
    Result := (Length(Arguments) = 1) and (jSource is TJSONArray);
    if Result then begin
      jValue := JsonValueFromVariant(Variant(Arguments[0]));
      if jValue is TJSONArray then begin
        //if the value is an Array, append all those values instead of adding the list as one element (as Add would do)
        for var elem in TJSONArray(jValue) do
          TJSONArray(jSource).AddElement(elem);
      end else //if not array, behaves same as Add
        TJSONArray(jSource).AddElement(jValue);
    end;
      //Important note: the ownership is moved to the array. (either create or clone)
  end else if MatchText(Name, ['Remove', 'Delete']) then begin
    if (jSource is TJSONArray) then begin
      //There must be only one argument of type Integer!
      Result := (Length(Arguments) = 1) and (Arguments[0].VType = varInteger);
      if Result then
        TJSONArray(jSource).Remove(Arguments[0].VInteger);
    end else if (jSource is TJSONObject) then begin
      //There must be only one argument of type String!
      Result := (Length(Arguments) = 1) and (VarDataIsStr(Arguments[0]));
      if Result then
        TJSONObject(jSource).RemovePair(VarDataToStr(Arguments[0]));
    end else
      Result := False;
  end else if MatchText(Name, ['Clear', 'Empty']) then begin
    //There must be no arguments AND the source is either array or object!
    Result := (Length(Arguments) = 0) and
              ( (jSource is TJSONArray) or (jSource is TJSONObject) );
    if Result then
      ClearJson(jSource);
  end else
    Result := inherited;
end;

function TVarJsonVariant.GetProperty(var Dest: TVarData; const V: TVarData; const Name: string): Boolean;
var
  jSource, jDest : TJSONValue;
begin
  jSource := TJsonVarData(V).Value;
  Result  := False;
  if (jSource is TJSONObject) then begin
    jDest  := TJSONObject(jSource).FindValue(Name);
    Result := Assigned(jDest);
    if Result then
      Variant(Dest) := VariantFromJsonValue(jDest)
  end;
  //handle special properties (if not already found)
  if (not Result) and SameText(Name, 'Count') then begin
    Result := True;
    if (jSource is TJSONObject) then
      Variant(Dest) := TJSONObject(jSource).Count
    else if (jSource is TJSONArray) then begin
      Variant(Dest) := TJSONArray(jSource).Count;
    end else begin
      Variant(Dest) := 0;
    end;
  end else if (not Result) and MatchText(Name, ['Items', 'Values']) then begin
    Result        := True;
    Variant(Dest) := GetValues(jSource);
  end else if (not Result) and (jSource is TJSONObject) and MatchText(Name, ['Names', 'Keys']) then begin
    Result        := True;
    Variant(Dest) := GetNames(TJSONObject(jSource));
  end;
end;

function TVarJsonVariant.GetPropertyByIndex(var Dest: TVarData; const V: TVarData; const Name: string; const Index: integer): Boolean;
var
  jSource : TJSONValue;
  jPair   : TJSONPair;
begin
  jSource := TJsonVarData(V).Value;
  if (jSource is TJSONArray) and MatchText(Name, ['Items', 'Values', 'Get']) then begin
    Result        := True;
    Variant(Dest) := VariantFromJsonValue(TJSONArray(jSource).Items[Index]);
  end else if (jSource is TJSONObject) then begin
    jPair  := TJSONObject(jSource).Pairs[Index];
    Result := Assigned(jPair);
    if Result and MatchText(Name, ['Values', 'Items', 'Get']) then begin
      Variant(Dest) := VariantFromJsonValue(jPair.JsonValue);
    end else if Result and MatchText(Name, ['Names', 'Keys']) then begin
      Variant(Dest) := jPair.JsonString.Value;
    end;
  end else begin
    Result := False;
  end;
end;

function TVarJsonVariant.SetProperty(const V: TVarData; const Name: string; const Value: TVarData): Boolean;
var
  jSource, jDest : TJSONValue;
  jPair : TJSONPair;
begin
//  Logger.DebugFmt('TVarJsonVariant.SetProperty(VType=%d, Name=%s, ValueType=%d)', [V.VType, Name, Value.VType]);
  jSource := TJsonVarData(V).Value;
  Result  := (jSource is TJSONObject);
  if Result then begin
    jPair  := TJSONObject(jSource).Get(Name);
    jDest  := JsonValueFromVariant(Variant(Value));
    if Assigned(jPair) then begin
      jPair.JsonValue := jDest;
//      Logger.DebugFmt('Property "%s" updated. New Value=%s', [Name, jDest.ToJSON]);
    end else begin
      TJSONObject(jSource).AddPair(Name, jDest);
//      Logger.DebugFmt('Property "%s" added. Value=%s', [Name, jDest.ToJSON]);
    end;
  end;
end;

function TVarJsonVariant.SetPropertyByIndex(const V: TVarData; const Name: string;
  const Index: integer; const Value: TVarData): Boolean;
begin
  Result := False; //Delphi's TJSONArray is too dumb to handle such basic request
end;

function TVarJsonVariant.GetNames(const aJsonObject: TJSONObject): Variant;
var
  i : Integer;
begin
  Result := VarArrayCreate([0, aJsonObject.Count-1], varOleStr);
  for i := 0 to aJsonObject.Count-1 do begin
    Result[i] := aJsonObject.Pairs[i].JsonString.Value;
  end;
end;

function TVarJsonVariant.GetValues(const aSource: TJSONValue): Variant;
var
  i : Integer;
begin
  if aSource is TJSONArray then begin
    Result := VarArrayCreate([0, TJSONArray(aSource).Count-1], varVariant);
    for i := 0 to TJSONArray(aSource).Count-1 do
      Result[i] := VariantFromJsonValue(TJSONArray(aSource).Items[i]);
  end else if aSource is TJSONObject then begin
    Result := VarArrayCreate([0, TJSONObject(aSource).Count-1], varVariant);
    for i := 0 to TJSONObject(aSource).Count-1 do
      Result[i] := VariantFromJsonValue(TJSONObject(aSource).Pairs[i].JsonValue);
  end;
end;

function TVarJsonVariant.IndexOf(const aSource: TJSONValue; const aValue: Variant): Integer;
var
  jVal  : TJSONValue;
  jPair : TJSONPair;
  idx   : Integer;
  sVal  : String;
begin
  Result := -1;
  idx    := -1;
  sVal   := VarToStr(aValue);
  if aSource is TJSONArray then begin
    for jVal in TJSONArray(aSource) do begin
      Inc(idx);
      if SameStr(sVal, jVal.Value) then
        Exit(idx);
    end;
  end else if aSource is TJSONObject then begin
    for jPair in TJSONObject(aSource) do begin
      Inc(idx);
      if MatchStr(sVal, [jPair.JsonString.Value, jPair.JsonValue.Value]) then
        Exit(idx);
    end;
  end;
end;

function TVarJsonVariant.JsonValueFromVariant(const aValue: Variant): TJSONValue;
var
  vData : TVarData;
begin
  vData := FindVarData(aValue)^;
  case vData.VType and varTypeMask of
    //"VarIsOrdinal"
    varBoolean    : Result := TJSONBool.Create(vData.VBoolean);
    varSmallInt   : Result := TJSONNumber.Create(vData.VSmallInt);
    varInteger    : Result := TJSONNumber.Create(vData.VInteger);
    varShortInt   : Result := TJSONNumber.Create(vData.VShortInt);
    varByte       : Result := TJSONNumber.Create(vData.VByte);
    varWord       : Result := TJSONNumber.Create(vData.VWord);
    varUInt32     : Result := TJSONNumber.Create(vData.VUInt32);
    varInt64      : Result := TJSONNumber.Create(vData.VInt64);
    varUInt64     : Result := TJSONNumber.Create(vData.VUInt64);
    //"VarIsFloat"
    varCurrency   : Result := TJSONNumber.Create(vData.VCurrency);     //Must handle currency separately otherwise 7.3 as Double leads to 7.2999999999999998
    varSingle     : Result := TJSONNumber.Create(vData.VSingle);
    varDouble     : Result := TJSONNumber.Create(vData.VDouble);
    varDate       : Result := TJSONString.Create(DateToISO8601(vData.VDate));   //Keep dates as ISO8601 text
    //"VarIsStr"
    varOleStr,                                                         //TODO: find a better way to handle each string...
    varString,
    varUString    : try
                      //Check if the string is a valid JSON and use accordingly
                      Result := TJSONValue.ParseJSONValue(VarToStr(aValue));
                      if not Assigned(Result) then
                        Result := TJSONString.Create(VarToStr(aValue));
                    except
                      //Use as normal string value
                      Result := TJSONString.Create(VarToStr(aValue));
                    end;
  else //"non-constant" types
    if VarIsArray(aValue) then begin
      VarArrayLock(aValue);
      try
        Result := TJSONArray.Create;
        for var i := VarArrayLowBound(aValue, 1) to VarArrayHighBound(aValue, 1) do
          TJSONArray(Result).AddElement(JsonValueFromVariant(aValue[i]));
      finally
        VarArrayUnlock(aValue);
      end;
    end else if {VarIsJSON(aValue)} (vData.VType and varTypeMask) = VarJSON then begin
        Result := TJsonVarData(vData).Value.Clone as TJSONValue;  //Create a copy;
    end else begin
      Result := TJSONString.Create(VarToStr(aValue));
{$IFDEF USE_LOGGER}
      Logger.ErrorFmt('Unexpected Variant (input=%s)! Result might be empty or unexpected. (JSONString=%s)', [PrintVarData(TVarData(aValue)), Result.Value]);
{$ENDIF}
    end;
//  TBC - Known unhandled variant types:
//      varDispatch: (VDispatch: Pointer);
//      varError:    (VError: HRESULT);
//      varUnknown:  (VUnknown: Pointer);
//      varAny:      (VAny: Pointer);
//      varByRef:    (VPointer: Pointer);
//      varRecord:   (VRecord: TVarRecord);
  end; //case vType (else)
end;

function TVarJsonVariant.PeekJsonValue(const aValue: Variant): TJSONValue;
begin
  //This "exposes" the internal TJSONValue! make sure you are NOT destroying it!
  if VarIsJSON(aValue) then
    Result := TJsonVarData(aValue).Value
  else begin
    Result := nil;
{$IFDEF USE_LOGGER}
    Logger.ErrorFmt('Unexpected Variant in PeekJsonValue: %s', [PrintVarData(TVarData(aValue))]);
{$ENDIF}
  end;
end;

function TVarJsonVariant.VariantFromJsonValue(const aJsonValue: TJSONValue): Variant;
var
  dt : TDateTime;
begin
  VarClear(Result);
  if aJsonValue is TJSONNumber then begin
    Result := AsNumber(aJsonValue.Value);
  end else if aJsonValue is TJSONBool then begin
    Result := TJSONBool(aJsonValue).AsBoolean;
  end else if aJsonValue is TJSONString then begin
    //For strings of exactly 24 chars check if they are dates in ISO8601 format.
    if (Length(aJsonValue.Value) = 24) and TryISO8601ToDate(aJsonValue.Value, dt) then
      Exit(dt);
    Result := aJsonValue.Value;
  end else if (aJsonValue is TJSONObject) or (aJsonValue is TJSONArray) then begin
    TJsonVarData(Result).VType := VarJSON;
    TJsonVarData(Result).Value := aJsonValue;
    TJsonVarData(Result).Owned := False;
//    Logger.Debug('new VarJSON (linked): ' + PrintJsonVarData(TJsonVarData(Result)));
  end else if Assigned(aJsonValue) then begin
    Result := aJsonValue.Value;   //Unexpected value!
{$IFDEF USE_LOGGER}
    Logger.ErrorFmt('Unsupported JsonValue! (Class=%s, Value=%s, JSON=%s)', [aJsonValue.ClassName, aJsonValue.Value, aJsonValue.ToJSON]);
{$ENDIF}
  end;
//  Logger.DebugFmt('VariantFromJsonValue Result: %s', [PrintVarData(TVarData(Result))]);
end;



var
  _VarDataJSON: TVarJsonVariant = nil;

function VarJSON: TVarType;
begin
  Result := _VarDataJSON.VarType;
end;

function VarIsJSON(const aValue: Variant): Boolean;
begin
  Result := (TVarData(aValue).VType and varTypeMask) = VarJSON;
end;

function VarAsJSON(const aValue: Variant): Variant;
begin
  if VarIsJSON(aValue) then
    Result := aValue
  else
    VarCast(Result, aValue, VarJSON);
end;

function VarIsJsonObject(const aValue: Variant): Boolean;
begin
  if VarIsJSON(aValue) then
    Result := (TJsonVarData(aValue).Value is TJSONObject)
  else
    Result := False;
end;

function VarIsJsonArray(const aValue: Variant): Boolean;
begin
  if VarIsJSON(aValue) then
    Result := (TJsonVarData(aValue).Value is TJSONArray)
  else
    Result := False;
end;



function VarJSONCreate(const aJsonText: String): Variant;
begin
  VarClear(Result);
  TJsonVarData(Result).VType := VarJSON;
  TJsonVarData(Result).Value := TJSONValue.ParseJSONValue(aJsonText, True, True);
  TJsonVarData(Result).Owned := True;
end;

function VarJSONCreate: Variant;
begin
  VarClear(Result);
  TJsonVarData(Result).VType := VarJSON;
  TJsonVarData(Result).Value := TJSONObject.Create;
  TJsonVarData(Result).Owned := True;
end;


function VarJSONCreate(const Args: array of const): Variant;
var
  rec  : TVarRec;
  jArr : TJSONArray;
begin
  jArr := TJSONArray.Create;
  TJsonVarData(Result).VType := VarJSON;
  TJsonVarData(Result).Value := jArr;
  TJsonVarData(Result).Owned := True;
  for rec in Args do begin
    case rec.VType of
      vtBoolean       : jArr.Add(rec.VBoolean);
      vtInteger       : jArr.Add(rec.VInteger);
      vtChar          : jArr.Add(WideString(rec.VChar));
      vtWideChar      : jArr.Add(WideString(rec.VWideChar));
      vtExtended      : jArr.Add(rec.VExtended^);
      vtCurrency      : jArr.Add(rec.VCurrency^);
      vtWideString    : jArr.Add(WideString(rec.VWideString));
      vtAnsiString    : jArr.Add(String(rec.VAnsiString));
      vtString,
      vtUnicodeString : jArr.Add(String(rec.VUnicodeString));
      vtVariant       : jArr.AddElement(_VarDataJSON.JsonValueFromVariant(rec.VVariant^));
    else
      raise Exception.CreateFmt('Unsupported argument type %d ', [rec.VType]);
    end;
  end;
end;

function VarJSONCreate(const aVarArray: Variant): Variant;
var
  jArr : TJSONArray;
begin
  if VarIsArray(aVarArray) then begin
    VarArrayLock(aVarArray);
    try
      jArr := TJSONArray.Create;
      for var i := VarArrayLowBound(aVarArray, 1) to VarArrayHighBound(aVarArray, 1) do
        TJSONArray(jArr).AddElement(_VarDataJSON.JsonValueFromVariant(aVarArray[i]));
    finally
      VarArrayUnlock(aVarArray);
    end;
    TJsonVarData(Result).VType := VarJSON;
    TJsonVarData(Result).Value := jArr;
    TJsonVarData(Result).Owned := True;
  end else
    Result := aVarArray;
end;

function ExtractJsonValue(const aValue: Variant): TJSONValue;
begin
  Result := _VarDataJSON.JsonValueFromVariant(aValue);
end;

function PeekJsonValue(const aValue : Variant) : TJSONValue;
begin
  if VarIsJSON(aValue) then
    Result := _VarDataJSON.PeekJsonValue(aValue)
  else
    Result := nil;
end;

function PeekJsonObject(const aValue : Variant) : TJSONObject;
begin
  Result := PeekJsonValue(aValue) as TJSONObject;
end;

function PeekJsonArray(const aValue : Variant) : TJSONArray;
begin
  Result := PeekJsonValue(aValue) as TJSONArray;
end;

function NamesOf(const aValue: Variant): TStringDynArray;
begin
  if VarIsJsonObject(aValue) then
    Result := TStringDynArray(aValue.Names)
  else
    Result := nil;
end;

function ValuesOf(const aValue: Variant): TArray<Variant>;
begin
  if VarIsJSON(aValue) then
    Result := TArray<Variant>(aValue.Values)
  else
    Result := nil;
end;


initialization
  _VarDataJSON := TVarJsonVariant.Create;

finalization
  FreeAndNil(_VarDataJSON);

end.
