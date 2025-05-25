# jsonVariant
jsonVariant is custom variant implementation for making working with JSON in Delphi a very easy experience.

![JSON Variant image](/Images/jsonVariant_Code.png)

Homepage: https://github.com/CosminFr/jsonVariant

### Licence
jsonVariant is dual-licensed. You may choose to use it under the restrictions of the **GPL v3 licence** at no cost to you, or you may purchase a **commercial licence**.  

A commercial licence grants you the right to use jsonVariant in your own applications, royalty free, without any requirement to disclose your source code nor any modifications to any other party. 
A commercial licence is sold per developer but it must take into account the level of support required. Please connect through [LinkedIn](https://www.linkedin.com/in/cosminfrentiu/) to show interest and request a quote or an invoice.  Payment may be made via PayPal, or via bank transfer.  Details will be provided on the invoice.

Please consider supportting this project by donating ("Buy me a coffee", "Thanks.dev", "Paypal").

## Usage Instructions
Simply add JsonVariant.pas in your project and start using it.

### Create JSON Variant
To create a JSON variant use one of the VarJSONCreate functions
| Sample            | Description        |
| ----------------- | ------------------ |
| VarJSONCreate()   | empty JSON Object  |
| VarJSONCreate([]) | empty JSON Array   |
| VarJSONCreate([1, "item B", Now]) | sample JSON Array with 3 values |
| VarJSONCreate(data) | JSON Object or Array as specified in data string/text |
    
### JSON content
Access JSON properties like you would with a normal delphi object
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
> memJSON.Text := json;

or 

> memJSON.Text := json.*AsString*;

**Note**: The default output provides a "compact" version. To get a "pretty" version, use "*AsText*" function.


### Case sensitivity
Pay attention to the case of JSON Object properties as JSON is case sensitive! "Name" and "name" are different properties!

### Name conflict
If a property of the JSON object conflicts with a custom VarJSON property or function, the former "wins". However, since JSON object property is case sensitive while Delphi functions are not, a simple solution to avoid the conflict is to use a different case.

For example, a JSON object with property "Count":
> json:= VarJSONCreate('{"Count": 15}');

"*json.Count*" refers to that specified property (=15). To access "Count" as the custom function representing the number of "Name/Value" pairs in the object (=1) simply use a different case (aka json.count or json.COUNT, ...)

### Date values
There is no specific type in JSON to handle dates. The usual behaviour is to format the date using *ISO 8601* rules.
```
  json.Date := Now;
  LocalDate := json.Date;           //might raise conversion error if it was not converted to a TDateTime!
  LocalDate := AsDate(json.Date);   //ensures the correct type, but returns 0 if conversion fails!
```
If a custom format is used/required, please use the "AsString/AsDate" functions with a specific format:
```
  json.Date := AsString(Now, 'YYYY/MM/DD');
  LocalDate := AsDate(json.Date, 'YYYY/MM/DD');
```

### Custom properties and functions

#### For both Object and Array

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

***IndexOf(str), FindValue(str)***  
Returns the index of the value that matches the `str` param; -1 if no match found. 
> [!TIP] 
> For objects, the `str` is also compared with the key name.  
> Used to find the position of a specific property in the JSON Object.
    
***Clear, Empty***  
As one would expect removes all pairs/values from the Objecy or Array.


#### Specific to Array

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

#### Specific to Object

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


#### General functions

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



