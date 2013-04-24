// Real-time weather data
// Should be checked every 10 minutes

Weather weather;
Today today;

void setup() {
  size(640, 480);
  smooth();
  weather = new Weather((5 * (60*1000)), "48104");
  // weather.start();

  today = new Today();
}

void draw() {
  background(
  if (weather.available()) { 
    
  }
}

