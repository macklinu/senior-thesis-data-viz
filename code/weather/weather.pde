// Real-time weather data
// Should be checked every 10 minutes

Weather weather;

void setup() {
  weather = new Weather(min_ms(5));
  weather.start();
}

void draw() {
  if (weather.available()) {
  }
}

int min_ms(int min) {
  return min * 60 * 1000;
}
