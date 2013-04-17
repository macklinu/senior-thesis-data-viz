class Forecast {
  String BASE_URL;
  String zipCode;
  float tempF; // temperature (F)
  String windDir;
  String weatherCondition;
  String relativeHumidity;
  float relHumidity;
  float precip;
  
  //////////////////
  // Constructors //
  //////////////////

  Forecast() {
    // Accessing the weather service
    BASE_URL = dataPath("raw.json");
    loadData();
  }
  
  Forecast(String zipCode) {
    this.zipCode = zipCode;
    BASE_URL = "http://api.wunderground.com/api/0a80de5d54554b74/conditions/q/" + zipCode + ".json";
    loadData();
  }
  
  void loadData() {
    // Get the JSON formatted response
    String response = join(loadStrings(BASE_URL), "");
    // Make sure we got a response.
    if (response != null) {
      // Initialize the JSONObject for the response
      JSONObject root = JSONObject.parse(response);
      JSONObject current = root.getJSONObject("current_observation");
      // assign variables
      tempF = current.getFloat("temp_f");
      relativeHumidity = current.getString("relative_humidity");
      windDir = current.getString("wind_dir");
      weatherCondition = current.getString("weather");
      precip = float(current.getString("precip_1hr_in"));
      
      relHumidity = int(split(relativeHumidity, "%")[0]);
      
    }
    else {
      println("ERROR: didn't get the JSON");
    }
  }
}

