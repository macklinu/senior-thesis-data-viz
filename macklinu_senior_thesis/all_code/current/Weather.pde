class Weather extends Thread {

  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  int count;                 // counter
  boolean available;

  String baseURL;
  String zipCode;
  float tempF; // temperature (F)
  String windDir;
  String weatherCondition;
  int relativeHumidity;
  float precipHr, precipToday;

  //////////////////
  // Constructors //
  //////////////////

  // The thread does not run by default
  Weather (int w) {
    wait = w;
    running = available = false;
    count = 0;
    // Accessing the weather service
    baseURL = dataPath("raw.json");
  }

  // If zipcode added, look up zipcode weather
  Weather (int w, String zipCode) {
    wait = w;
    running = available = false;
    count = 0;
    this.zipCode = zipCode;
    baseURL = "http://api.wunderground.com/api/0a80de5d54554b74/conditions/q/" + zipCode + ".json";
  }

  int getCount() {
    return count;
  }

  // Overriding "start()"
  void start () {
    // Set running equal to true
    running = true;
    // Print messages
    println("Starting thread (will execute every " + wait + " milliseconds.)"); 
    // Do whatever start does in Thread, don't forget this!
    super.start();
  }


  // We must implement run, this gets triggered by start()
  void run () {
    while (running) {
      loadData();
      available = true;
      println("data loaded");
      // Ok, let's wait for however long we should wait
      try {
        sleep((long)(wait));
      } 
      catch (Exception e) {
      }
    }
  }

  boolean available() {
    return available;
  }

  void loadData() {
    // Get the JSON formatted response
    String response = PApplet.join(loadStrings(baseURL), "");
    // Make sure we got a response
    if (response != null) {
      // Initialize the JSONObject for the response
      JSONObject root = JSONObject.parse(response);
      JSONObject current = root.getJSONObject("current_observation");
      // assign variables
      tempF = current.getFloat("temp_f");
      windDir = current.getString("wind_dir");
      weatherCondition = current.getString("weather");
      precipHr = float(current.getString("precip_1hr_in"));
      precipToday = float(current.getString("precip_today_in"));
      relativeHumidity = int(split(current.getString("relative_humidity"), "%")[0]);
      println(tempF);
      println(windDir);
      println(weatherCondition);
      println(precipHr);
      println(precipToday);
      println(relativeHumidity);
    }
    else {
      println("ERROR: didn't retrieve weather");
    }
  }

  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
}

