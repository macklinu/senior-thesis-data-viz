class Weather extends Thread {

  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  int count;                 // counter
  boolean available;
  boolean sleeping;

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

  // Constructor, create the thread
  // It is not running by default

  Weather (int w) {
    wait = w;
    running = false;
    // id = s;
    count = 0;
    // Accessing the weather service
    BASE_URL = dataPath("raw.json");
  }

  Weather (int w, String zipCode) {
    wait = w;
    running = false;
    // id = s;
    count = 0;
    this.zipCode = zipCode;
    BASE_URL = "http://api.wunderground.com/api/0a80de5d54554b74/conditions/q/" + zipCode + ".json";
  }

  int getCount() {
    return count;
  }

  // Overriding "start()"
  void start () {
    // Set running equal to true
    running = true;
    sleeping = false;
    // Print messages
    println("Starting thread (will execute every " + wait + " milliseconds.)"); 
    // Do whatever start does in Thread, don't forget this!
    super.start();
  }


  // We must implement run, this gets triggered by start()
  void run () {
    while (running) {
      sleeping = false;
      loadData();
      available = true;
      println("data loaded");
      // Ok, let's wait for however long we should wait
      try {
        sleeping = true;
        sleep((long)(wait));
      } 
      catch (Exception e) {
      }
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
  }

  boolean available() {
    return available;
  }

  private void loadData() {
    // Get the JSON formatted response
    String response = PApplet.join(loadStrings(dataPath("raw.json")), "");
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
  
  String getCurrentCondition() {
    return weatherCondition;
  }

  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
}

