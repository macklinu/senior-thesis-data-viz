/*
 * Sunrise/Sunset class from 
 * https://github.com/mikereedell/sunrisesunsetlib-java
 */

import java.util.Calendar;

class Today {

  Location location = new Location("42.2708", "-83.7264");
  SunriseSunsetCalculator calculator = new SunriseSunsetCalculator(location, "America/New_York");
  int sunrise, sunset; // today's sunrise and sunset
  int DAY, HOUR;
  int tMax = 86400; // max number of seconds in one day
  int t; // current time

  Today() {
    setSunriseSunset();
    DAY = day();
    HOUR = hour();
    t = timeInSeconds(hour(), minute(), second());
  }

  void run(int h, int m, int s) {
    t = timeInSeconds(h, m, s);
  }

  /////////////
  // SETTERS //
  /////////////

  void setSunriseSunset() {
    String sunriseTemp = calculator.getOfficialSunriseForDate(Calendar.getInstance()); // today's sunrise
    String sunsetTemp = calculator.getOfficialSunsetForDate(Calendar.getInstance()); // todays' sunset
    println(sunriseTemp + "\t" + sunsetTemp);
    String[] sr = split(sunriseTemp, ":");
    String[] ss = split(sunsetTemp, ":");
    sunrise = timeInSeconds(int(sr[0]), int(sr[1]), 0);
    sunset = timeInSeconds(int(ss[0]), int(ss[1]), 0);
  }

  /////////////
  // GETTERS //
  /////////////

  int getSunrise() {
    return sunrise;
  }

  int getSunset() {
    return sunset;
  }
  
  int getCurrentTime() {
    return t;
  }

  // get the time of day as a fraction of a whole
  // returns 0.0 - 1.0
  float getPositionInDay() {
    return t/float(tMax);
  }

  ///////////////////
  // MISCELLANEOUS //
  ///////////////////

  int timeInSeconds(int h, int m, int s) {
    return ((h * 3600) + (m * 60) + s);
  }

  String timeToString() {
    float h = floor(t / 3600);
    float m = (t / 60) - h * 60; // (t / 60) % 60; 
    float s = (t - (m * 60 + h * 3600)); // ts % 60;
    return nf((int) h, 2) + ":" + nf((int) m, 2) + ":" + nf((int) s, 2);
  }

  //////////////////
  // TIMES OF DAY //
  //////////////////

  boolean isMorning() {
    if (t >= sunrise && t < timeInSeconds(12, 0, 0)) return true;
    else return false;
  }

  boolean isAfternoon() {
    if (t > timeInSeconds(12, 0, 0) && t < sunset) return true;
    else return false;
  }

  boolean isNight() {
    if (t < sunrise || t > sunset) return true;
    else return false;
  }

  boolean isSunInSky() {
    if (t >= sunrise && t <= sunset) return true;
    else return false;
  }
}

