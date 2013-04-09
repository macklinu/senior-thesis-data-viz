// Real-time weather data
// Should be checked every 10 minutes

import org.json.*;

int temp;

void setup() {
  // Accessing the weather service
  String BASE_URL = dataPath("raw.json"); // "http://api.wunderground.com/api/0a80de5d54554b74/conditions/q/MI/Ann_Arbor.json";

  // Get the JSON formatted response
  String response = join(loadStrings(BASE_URL), "");
  // println(response);
 
  // Make sure we got a response.
  if (response != null) {
    // Initialize the JSONObject for the response
    org.json.JSONObject root = new org.json.JSONObject(response);
    org.json.JSONObject current = root.getJSONObject("current_observation");
    temp = current.getInt("temp_f");
  }
}

void draw() {
}
