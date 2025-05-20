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
| Syntax | Description |
| ------ | ----------- |
| VarJSONCreate()   | empty JSON Object |
| VarJSONCreate([]) | empty JSON Array |
| VarJSONCreate([1, "item B", Now]) | dummy JSON Array with 3 values of different types|
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
> memJSON.Text := json.AsString;
Note: The default output provides a "compact" version of the JSON. To get a "pretty" version, use "~.AsText" function.



