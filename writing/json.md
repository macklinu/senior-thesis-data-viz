# Processing + JSON
> First major attempt to find data and parse it Processing.

## First steps

### Working with the Data
#### Working with the Weather Underground API
Just because.

#### Why JSON?
After trying to battle with XML in Processing and not understanding how to use the XML library well with an XML data structure, I did some research on other data protocols for the web. And having done some basic web design and development for [my website](http://macklinu.com), I did some reading about JSON (JavaScript Object Notation). This [article](http://www.json.org/xml.html) gave me good arguments for using JSON as opposed to XML. Here is a main summary:

+ one
+ two
+ three

#### Processing JSON library
Processing does not come with JSON parsing built-in, so a Google search turned up a version of the JSON Java library that would made to be easily used in the Processing IDE. The JSON Processing library can be viewed [here](https://github.com/agoransson/JSON-processing).

The documentation for this library was not very complete at the time of this writing, so while I understood how to load a `JSONObject` into memory, I was unable to understand how to parse a `JSONArray`. Retreiving data from a `JSONObject` made sense through the library's documentation:

~~~
String response = loadStrings("example.json")[0];
  // Make sure we got a response.
  if ( response != null ) {
    // Initialize the JSONObject for the response
    JSONObject root = new JSONObject( response );
    // Get the "condition" JSONObject
    JSONObject condition = root.getJSONObject("condition");
    // Get the "temperature" value from the condition object
    int temperature = condition.getInt("temperature");
    // Print the temperature
    println( temperature );
  }

~~~

However, this same concept did not work with a `JSONArray`. With any array, you have to walk through each element of the array to access whatever is inside. Without a [documented code example](http://37signals.com/svn/posts/3018-api-design-for-humans) of this, I was unsure what steps to take.

More Google searching led to a blog post by [Jer Thorp](http://blprnt.com/), a data visualization expert who is an adjunct faculty member at NYU's [ITP](http://itp.nyu.edu/itp/) program. Thorp's [blog post](http://blog.blprnt.com/blog/blprnt/processing-json-the-new-york-times) presented a great deal of information in using JSON and Processing through an example with the New York Times API, which answered some questions that the JSON Processing library did not document.

#### Parsing JSON in Processing

Let's take a JSON excerpt from the Weather Underground API and parse it in Processing. Say we have this file titled `forecast.json`:  

~~~
{
    "forecast":{
        "txt_forecast": {
        "date":"4:00 PM EST",
        "forecastday": [
        {
        "period":0,
        "icon":"partlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        "title":"Wednesday",
        "fcttext":"Partly cloudy with a chance of snow in the afternoon. High of 34F with a windchill as low as 16F. Breezy. Winds from the SW at 10 to 20 mph. Chance of snow 20%.",
        "fcttext_metric":"Partly cloudy with a chance of snow in the afternoon. High of 1C with a windchill as low as -9C. Windy. Winds from the SW at 15 to 30 km/h.",
        "pop":"20"
        }
        ,
        {
        "period":1,
        "icon":"mostlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/mostlycloudy.gif",
        "title":"Wednesday Night",
        "fcttext":"Mostly cloudy with a chance of snow. Low of 25F with a windchill as low as 16F. Breezy. Winds from the West at 10 to 20 mph. Chance of snow 20%.",
        "fcttext_metric":"Mostly cloudy with a chance of snow. Low of -4C with a windchill as low as -9C. Windy. Winds from the West at 15 to 35 km/h.",
        "pop":"20"
        }
        ,
        {
        "period":2,
        "icon":"mostlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/mostlycloudy.gif",
        "title":"Thursday",
        "fcttext":"Mostly cloudy with a chance of snow. High of 28F with a windchill as low as 16F. Breezy. Winds from the WNW at 10 to 20 mph. Chance of snow 20%.",
        "fcttext_metric":"Mostly cloudy with a chance of snow. High of -2C with a windchill as low as -9C. Windy. Winds from the WNW at 15 to 30 km/h.",
        "pop":"20"
        }
        ,
        {
        "period":3,
        "icon":"partlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        "title":"Thursday Night",
        "fcttext":"Partly cloudy. Low of 16F with a windchill as low as 7F. Winds from the West at 5 to 15 mph.",
        "fcttext_metric":"Partly cloudy. Low of -9C with a windchill as low as -14C. Windy. Winds from the West at 10 to 25 km/h.",
        "pop":"10"
        }
        ,
        {
        "period":4,
        "icon":"partlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        "title":"Friday",
        "fcttext":"Partly cloudy. High of 37F with a windchill as low as 9F. Breezy. Winds from the SW at 10 to 20 mph.",
        "fcttext_metric":"Partly cloudy. High of 3C with a windchill as low as -13C. Windy. Winds from the SW at 15 to 30 km/h.",
        "pop":"10"
        }
        ,
        {
        "period":5,
        "icon":"partlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        "title":"Friday Night",
        "fcttext":"Partly cloudy. Low of 27F with a windchill as low as 16F. Breezy. Winds from the SW at 15 to 20 mph.",
        "fcttext_metric":"Partly cloudy. Low of -3C with a windchill as low as -9C. Windy. Winds from the SW at 25 to 35 km/h.",
        "pop":"0"
        }
        ,
        {
        "period":6,
        "icon":"mostlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/mostlycloudy.gif",
        "title":"Saturday",
        "fcttext":"Partly cloudy in the morning, then overcast with a chance of rain. Fog early. High of 39F with a windchill as low as 18F. Winds from the WSW at 10 to 15 mph. Chance of rain 20%.",
        "fcttext_metric":"Partly cloudy in the morning, then overcast with a chance of rain. Fog early. High of 4C with a windchill as low as -8C. Breezy. Winds from the WSW at 20 to 25 km/h.",
        "pop":"20"
        }
        ,
        {
        "period":7,
        "icon":"partlycloudy",
        "icon_url":"http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        "title":"Saturday Night",
        "fcttext":"Overcast. Low of 21F with a windchill as low as 14F. Breezy. Winds from the WSW at 20 to 25 mph.",
        "fcttext_metric":"Overcast. Low of -6C with a windchill as low as -10C. Windy. Winds from the WSW at 30 to 40 km/h.",
        "pop":"0"
        }
        ]
        },
    }
~~~

Everything is contained within the `"forecast"` `JSONObject`. Here is the structure of the file:

~~~
{
    JSONObject:{
        JSONObject:{
            String
            JSONArray[
                JSONObject {
                    Int
                    String
                    String
                    ...
                }
                ...
            ]
        }
    }
}
~~~

The main `JSONObject` `"forecast"` contains another JSONObject `"txt_forecast"` that contains the information we'd like to access and use in a visualization. The bulk of that information is contained within a `JSONArray`, so there are some extra steps that must be taken to access that array using the Processing JSON library.

~~~
import org.json.*;  

  // take the .json text file and join the parts of it into a string 
  String response = join(loadStrings("forecast.json"), "");
  // convert that string into a JSONObject for use by the JSON library
  JSONObject root = new JSONObject(response);
  // enter the "forecast" object 
  JSONObject forecast = root.getJSONObject("forecast");
  // enter the "txt_forecast" object 
  JSONObject txtForecast = forecast.getJSONObject("txt_forecast");
  // enter the "forecastday" array 
  JSONArray forecastDay = txtForecast.getJSONArray("forecastday");  

  // for each element in the array, access each JSONObject 
  // retrieve the data in the String "title" 
  // first object returns "Wednesday" 
  try {
    for (int i = 0; i < forecastDay.length(); i++) {
      JSONObject o = (JSONObject) forecastDay.get(i);
      String day = o.getString("title");
    };
  }
  catch (JSONException e) {  
    println (e.toString());
  }

~~~

#### try...catch
I had my first encounter with the `try` and `catch` keywords in Processing. I don't quite understand what they mean, but I have a feeling it might be useful to know moving forward with using JSON/XML in Processing. From the Processing [website](http://processing.org/reference/try.html):
> The `try` keyword is used with `catch` to handle exceptions. Sun's Java documentation defines an exception as "an event, which occurs during the execution of a program, that disrupts the normal flow of the program's instructions." This could be, for example, an error while a file is read.

And a code example from the same page:
~~~
try {  
  tryStatements  
} catch (exception) {  
  catchStatements  
}
~~~

* * * 
  
Created on 15 Jan 2013. Updated on 27 Mar 2013.