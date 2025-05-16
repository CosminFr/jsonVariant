unit TestVarJson;

interface

uses
  DUnitX.TestFramework,
  Variants, jsonVariant;

type
  [TestFixture]
  TTestVarJson = class
  public
    [Test]
    procedure TestFromScratch;
    [Test]
    procedure TestCaseSensitivity;
    [Test]
    procedure TestFromText;
    [Test]
    procedure TestArray;
  end;

implementation

procedure TTestVarJson.TestFromScratch;
var
  j : Variant;
begin
  // Create a new empty JSON object.
  j := VarJSONCreate;

  // Start assigning properties.  Properties that don't already exist are
  // automatically added when assigned.
  j.x := 50;
  j.y := '45';
  j.text := 'This is my message';

  Assert.AreEqual(50, Integer(j.x));
  Assert.AreEqual(45, Integer(j.y));
  Assert.AreEqual('This is my message', String(j.text));


//  j.backgroundColor := 'white';
//  j.color := '#123301';

  // Arrays must be assigned using Variant Arrays
  j.buttons := VarArrayOf(['Ok','Cancel']);
  Assert.AreEqual(2, Integer(j.buttons.Count));
  Assert.AreEqual('Ok', String(j.buttons.Items[0]));
  Assert.AreEqual('Cancel', String(j.buttons.Items[1]));

  j.buttons.Add('Abort');
  Assert.AreEqual(3, Integer(j.buttons.Count));

  // Object properties can be automatically created by simply accessing it
  // and assigning required properties
  j.User := VarJSONCreate;
  j.User.FirstName := 'Fred';
  j.User.LastName  := 'Willard';
  Assert.AreEqual('Fred', String(j.User.FirstName));

  j.User.FirstName := 'Frederick';
  Assert.AreEqual('Frederick', String(j.User.FirstName));

  // The JSON object can be converted to a JSON string with the AsJSON method.
//  WriteLn(j.AsJSON);
end;

procedure TTestVarJson.TestFromText;
var
  j : Variant;
begin
  // Create a new JSON object from a JSON string
  j := VarJSONCreate( '''
                      {
                        "firstName": "John",
                        "lastName": "Smith",
                        "address": {
                          "streetAddress": "21 2nd Street",
                          "city": "New York",
                          "state": "NY",
                          "postalCode": 10021
                        },
                        "phoneNumbers": [
                          "212 732-1234",
                          "646 123-4567"
                        ]
                      }
                      ''');

  // Access JSON properties as actual object properties
  Assert.AreEqual('John', String(j.firstName));
  Assert.AreEqual(10021, Integer(j.address.postalCode));

  // Array type properties get a fake count property to indicate array size.
  Assert.AreEqual(2, Integer(j.phoneNumbers.Count));

  // Array items can be accessed by standard delphi indexed property notation.
  Assert.AreEqual('212 732-1234', String(j.phoneNumbers.Items[0]));
  Assert.AreEqual('646 123-4567', String(j.phoneNumbers.Values[1]));  //Values=Items

  // Overwrite a few properties
  j.firstName := 'Ted';
  j.phoneNumbers.Delete(1);
  j.phoneNumbers.Add('555-555-5555');

  Assert.AreEqual('Ted', String(j.firstName));
  Assert.AreEqual('555-555-5555', String(j.phoneNumbers.Items(1)));

  // Generate JSON string for altered JSON object;
  Assert.AreNotEqual('', String(j.AsJSON));
end;

procedure TTestVarJson.TestCaseSensitivity;
var
  j : Variant;
begin
  // Create a new empty JSON object.
  j := VarJSONCreate;
  // Since JSON is case sensitive ID, Id and id are all different properties!
  // Also being variants, a numerical string literal can be converted on the fly.
  j.ID := 50;
  j.Id := '45';
  j.id := j.ID - j.Id;

  Assert.AreEqual(50, Integer(j.ID));
  Assert.AreEqual(45, Integer(j.Id));
  Assert.AreEqual(5,  Integer(j.id));
end;

procedure TTestVarJson.TestArray;
var
  j : Variant;
  i : Integer;
begin
  // Create from Array
  j := VarJSONCreate(['Ok','Cancel', 5]);

//  Assert.AreEqual('Ok', String(j.Items[0]));

  Assert.AreEqual(3, Integer(j.Count));
  Assert.AreEqual('Ok', String(j.Values[0]));       //List elements can be accessed with Items|Values|Get
  Assert.AreEqual('Cancel', String(j.Items(1)));
  Assert.AreEqual(5, Integer(j.Get(2)));

  //Note Delphi's TJSONArray only allows Add & Remove! It cannot easily update or insert values!
  j.Add('Abort');
  Assert.AreEqual(4, Integer(j.Count));
  Assert.AreEqual('Abort', String(j.Items[3]));

  j.Remove(3); //Abort
  j.Delete(0); //Ok                                //Delete = same as Remove
  Assert.AreEqual(2, Integer(j.Count));
  Assert.AreEqual('Cancel', String(j.Items[0]));
  Assert.AreEqual(5, Integer(j.Values[1]));

  j.Add('new test value');
  j.Add(7.3);
  i := j.IndexOf('new test value');
  Assert.AreEqual(2, i);
  i := j.FindValue(7.3);
  Assert.AreEqual(3, i);

end;

initialization
  TDUnitX.RegisterTestFixture(TTestVarJson);

end.
