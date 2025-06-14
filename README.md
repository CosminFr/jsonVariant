# jsonVariant
jsonVariant is custom variant implementation for making working with JSON in Delphi a very easy experience.

![JSON Variant image](/Images/jsonVariant_Code.png)

Homepage: https://github.com/CosminFr/jsonVariant

## 👩‍🏫 Usage Instructions
Simply add JsonVariant.pas in your project and start using it.
```
uses
  System.Variants, JsonVariant;
```

### Create JSON Variant
To create a JSON variant use one of the VarJSONCreate functions:
```
function VarJSONCreate(const aJsonText: String): Variant;     overload;
function VarJSONCreate: Variant;                              overload;
function VarJSONCreate(const Args: array of const): Variant;  overload;
function VarJSONCreate(const aVarArray: Variant): Variant;    overload;
```
***JSON from text/string***  
```
var
  jData : Variant;
begin
  jData := VarJSONCreate(jsonText);
```
> [!WARNING]
> If `jsonText` does not hold a valid JSON, an `EJSONParseException` is raised.

> [!TIP]
> Check the exception message for a hint (line, position) where it failed.
    
***Empty JSON Object***  
```
  jData := VarJSONCreate();
```

***Empty JSON Array***  
```
  jData := VarJSONCreate([]);
```
***JSON Array from another array***  
```
var
  jPhones : Variant;
begin
  jPhones := VarJSONCreate(['0400 123 456', '+614 0012 3333', '(03) 0012 5555']);
```
or from a variant array `vArrPhones: Variant`
```
  jPhones := VarJSONCreate(vArrPhones);
```

### JSON content
Access JSON properties like you would with a normal Delphi object.
```
  json := VarJSONCreate('{"Name": "John Smith",	"Phone": "(03) 1234 5555"}');
  json.Height := "1.79m";
  ShowMessage(Format('%s (%s): %s', [json.Name, json.Height, json.Phone]));
```
or for an array
```
  jArr := VarJSONCreate([1, 2, 4, 8]);
  jArr.Add(16);
```

### JSON output
To get the JSON text from a JSON Variant one can simply cast it to a string:
```
  memJSON.Text := json;
```
or use one of the custom functions `[As|To][String|JSON|Text]`:
```
  memJSON.Text := json.AsString;
```
> [!TIP] 
> The default output provides a "compact" version. To get a "pretty" version, use "*AsText*" function.


### Case sensitivity
Pay attention to the case of JSON Object properties as JSON is case sensitive! `Name` and `name` are different properties!

### Name conflict
If a property of the JSON object conflicts with a custom VarJSON property or function, the former "wins". However, since JSON object property is case sensitive while Delphi functions are not, a simple solution to avoid the conflict is to use a different case.

For example, a JSON object with property "Count":
```
  json:= VarJSONCreate('{"Count": 15}');
```

`json.Count` refers to that specified property `=15`. To access `Count` as the custom function representing the number of "Name/Value" pairs in the object `=1` simply use a different case (aka `json.count` or `json.COUNT`, ...).

### Date values
There is no specific type in JSON to handle dates. The usual behaviour is to format the date using *ISO 8601* rules.
```
  json.Date := Now;
  LocalDate := json.Date;           //might raise conversion error if it was not converted to a TDateTime!
  LocalDate := AsDate(json.Date);   //ensures the correct type, but returns 0 if conversion fails!
```
>[!NOTE]
>For a string property of length 24 (like the `Date` above) a conversion is attempted using ISO8601 format. If successful, `json.Date` returns a TDateTime variant, otherwise the string value is returned.

If a custom format is used/required, please use the "AsString/AsDate" functions with a specific format:
```
  json.Date := AsString(Now, 'YYYY/MM/DD');
  LocalDate := AsDate(json.Date, 'YYYY/MM/DD');
```

## 🧬 Custom properties and functions

### For both Object and Array

***ToString, AsString***  
Calls "ToString" on the associated TJSONValue.

***ToJson, AsJson***  
Calls "ToJSON" on the associated TJSONValue and returns a compact JSON text.

***ToText, AsText***  
Calls "Format" on the associated TJSONValue and returns the indented (aka pretty) formatted JSON text.

***Items(i), Values(i), Get(i)***  
Returns the Variant Value on position `i`. May raise "out of range" errors!
>[!NOTE]
> Also works as indexed property (aka Items[i], Values[i], Get[i])

***Items, Values***  
Returns a variant array with the Values. This creates a copy of all values as variants! 

***Clear, Empty***  
As one would expect removes all pairs/values from the Objecy or Array.

***IndexOf(str)***  
Returns the index of the value that matches the `str` param; -1 if no match found. 
> [!TIP] 
> For objects, the `str` is also compared with the key name.  
> Used to find the position of a specific property in the JSON Object.
    
***FindValue(str)***  
Returns the variant containing the TJSNOValue as provided by `FindValue(str)`. It uses the `System.JSON.TJSONPathParser` to evaluate the `str` param.  
Does not handle `*` or `..` "wildcard" patterns.
    
***JSONPath(str), Path(str)***  
Inpired from [goessner.net/articles/JsonPath](https://goessner.net/articles/JsonPath/). 

The syntax to write paths is similar to XPath but in a Json way. The following XPath expression:
> /store/book[1]/title

would look like (dot notation)
> store.book[0].title

or (bracket notation)  
> ['store']['book'][0]['title']

The dot (.) token is used to access the object elements:
> ex: object.key

The bracket ([]) token is used to access array or object elements:
  * In array: cities[0]
  * In object: ["city"]["name"] or ['city']['name']
 
The quote (" or ') is used to introduce a literal when the element is being written in bracket notation:
>  ex:["first"]["second"] = ['first']['second'] = first.second

JSONPath allows the wildcard symbol `*` for member names and array indices and the recursive descent operator `..` 
> \*.book[0].title => returns first book's title from any element, not only `store`  
> ..title => returns all titles  
> store.book[\*].title => returns all titles  

Negative value in an array index token (the number between [] brackets) suggests position from end of the array:
> ..book[-1]  => last book

> [!WARNING]
> Values exceeding the array size will raise "out of range" errors!

> [!TODO]  
> the array slice syntax proposal [start:end:step] is not supported yet!



### Specific to Array

***Add(element)***  
Where "element" is a variant to be added to the list/array.

**Notes**: 
- If the element is VarJSON, the JSON value is cloned.
- If the element is an Array, it is added as one element of array type.

***Append(element)***  
Very similar with "Add". In most cases, it has the same behavior and appends that element to the list. 
However, if the element is an array, all its elements are added to the list (instead of one array element).

***Remove(i), Delete(i)***  
Removes the element on position "i".  
May raise "out of range" errors!

### Specific to Object

***Items(name), Values(name), Get(name)***  
Specific for objects, these functions accept a string value representing the key name and returns the Variant Value for that property.  
> [!WARNING]
> if the property with specified name is not found it raises an exception!

***Remove(name), Delete(name)***  
Removes the pair matching the key name.  
If there is no matching key name, nothing is removed/deleted!

***Names[i], Keys[i]***  
Returns the key name on position `i`.  
May raise "out of range" errors!

***HasProperty(name), HasAttribute(name), HasName(name), HasKey(name)***  
Checks if the object has a property with the specified name. True if property exists, False otherwise.

***Names, Keys***  
<a name="names-keys"></a>
Returns a variant array with the key names.  


### General functions

***VarIsJSON, VarIsJsonObject, VarIsJsonArray***  
Boolean functions to check if the provided variant is JSON (Object or Array).

***VarJSONCreate***  
See [Create JSON Variant](#create-json-variant)

***ExtractJsonValue(Variant): TJSONValue;***  
Creates a new TJSONValue (clone) from the variant! The ownership is passed to the caller => pay attention to memory leaks...

***PeekJsonValue (Variant) : TJSONValue;***  
Exposes the JSON Value used by a VarJSON. Returns `nil` for non JSON variants!  
Ownership is NOT transfered! DO NOT FREE!!!

***PeekJsonObject(Variant) : TJSONObject;***  
To avoid type casting, if you know the result is a JSON object.

***PeekJsonArray (Variant) : TJSONArray;***  
To avoid type casting, if you know the result is a JSON array.

***NamesOf(Variant): TStringDynArray;***  
Returns a dynamic string array with the key names. Similar with [Names](#names-keys) property but easier to use in a `for in` loop:
```
    for name in NamesOf(json) do
      Log(name + '=' + VarToStr(json.Values(name)));
```

***ValuesOf(Variant): TArray<Variant>;***  
Returns a dynamic Variant array with the values of the JSON Object/Array. This is a copy (clone) of the source JSON variant values! 


## 📜 License
Dual-licensed:
- **GPL v3 licence** - Use for free, under the restrictions of the **GPL v3 licence**, or 
- Purchase a **commercial licence**. Which grants you the right to use in your own applications, royalty free, without any requirement to disclose your source code nor any modifications to any other party. [Contact ZenDev4D](mailto:contact@zendev4d.com?subject=Licence%20for%20jsonVariant) for details.

Please consider supportting this project by donating ("Buy me a coffee", "Thanks.dev", "Paypal").

## 🙏 Contributions
Feel free to submit pull requests, report bugs or suggest improvements. This project is intended to stay small but powerful.
