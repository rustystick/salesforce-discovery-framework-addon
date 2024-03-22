%dw 2.5
output application/json
input payload application/json
import every from dw::core::Arrays

type DataType = "Date" | "Time" | "Boolean" | "Radio" | "EditBlock" | "Block" | "TextBlock" | "Select" | "MultiSelect" | String

type Field = {
    questionName: String, 
    label: String,
    value: String | Date | Time | Boolean, 
    dataType: DataType,
    isNa: Boolean
}

fun addDataType(field: Object) = 
    if(!(field.dataType?) and field.value is Object) {"dataType" : "Block"} ++ field
    else field

fun toField(field, locale='en'): Field =  
    field pluck((value, key) -> {"questionName" : key} ++ value)
    map addDataType($)
    map ((item) ->  
        parseValue(item, locale) ++ {
        "isTextBlock" : item.dataType is "TextBlock",
        "isEditBlock" : item.dataType is "EditBlock",
        "isBlock" : item.dataType is "Block", 
        "isPlainField" : item.dataType != "TextBlock" and item.dataType != "EditBlock" and item.dataType != "Block"
    })

fun toFieldValue(field, locale) = 
    (toField(field, locale)
    map {"rowValues": $})
    orderBy -$$

fun extractEditBlockColumns(editBlock) = 
    {
        "columns" : toField(editBlock.value[0]) map {"column" :$.label} orderBy -$$
    }

fun wrapEditBlock(editBlock) = editBlock mapObject 
        ($$) : if($$ as String != "value") $ else 
               if(typeOf($) ~= Array) $ else [$]
               filter ((item) -> pluck(item, (val, key)->val.value) every($ != ""))

fun parseValue(field, locale): String = 
    field
    mapObject((value, key, index) -> {
        (key): if(key as String != "value") value else
                if(value == '') '' else 
                    field.dataType match {
                        case literalmatch: "Date" -> upper(value as DateTime {format: "E MMM dd HH:mm:ss O u"} as String {format: "YYY-MMM-dd", locale: locale}) replace "." with("")
                        case literalmatch: "Time" -> value as LocalTime as String {format: "KK:mm a"}
                        case literalmatch: "Telephone" -> phoneNumberFormat(value)
                        case literalmatch: "TextBlock" -> value
                        else -> value
                    }
    })

fun phoneNumberFormat(number: String) = if(sizeOf(number) != 10) number else "(" ++ number[0 to 2] ++ ")-" ++ number[3 to 5] ++ "-" ++ number[6 to 9]
---
{"generatedDateTime": upper((payload.generatedDateTime as DateTime >> "Canada/Atlantic" as TimeZone) as String {format: "YYYY-MMM-dd hh:mm:ss a", locale: payload.locale})  replace "." with(""),
"steps": payload.payload
// make step as array
pluck ((value, key) -> {"stepName" : key} ++ value)
map ((item, index) -> item mapObject ((value, key, index) -> 
    (key): if(key as String != "value") value else
    value toField(payload.locale)
    // skip lookup fields
    filter !($.questionName contains("Lookup"))
    // TODO: once we can filter out hidden formulas then this is not needed
    map ((item) -> item.dataType match  {
        case literalmatch: "TextBlock" -> item
                mapObject(value, key) -> 
                    (key) : if(key as String == "label") null else value
        case literalmatch: "EditBlock" -> do {
                var wrappedItem = wrapEditBlock(item)  
                ---
                extractEditBlockColumns(wrappedItem) ++ 
                                wrappedItem mapObject(value, key) -> 
                                    (key) : if(key as String != "value") value 
                                            else
                                            value 
                                            map toFieldValue($, payload.locale)
                                            // same here
                                            filter !($.questionName contains("Lookup"))
                                            map {"rows": $}
        } 
        case literalmatch: "Block" -> 
            item mapObject(value, key) ->  {
                ((key): value) if (key as String != 'value'), 
                ("blockValue" : 
                    value 
                    toField(payload.locale)
                    filter !($.questionName contains("Lookup"))
                    map((item) -> item.dataType match  {
                        case literalmatch: "TextBlock" -> item
                                mapObject (value, key) -> 
                                        (key) : if(key as String == "label") null else value
                        else -> item
                    })
                    orderBy -$$) if (key as String == 'value')
            }
        else -> item
    })
    orderBy -$$
))
orderBy -$$}
// to test and develop, take a payload and go to https://dataweave.mulesoft.com/learn/dataweave