/*
 * 
 * 
 * Sunrise/Sunset class from 
 * https://github.com/mikereedell/sunrisesunsetlib-java
 *
 */

import java.util.Calendar;

Location location = new Location("42.2708", "-83.7264");
SunriseSunsetCalculator calculator = new SunriseSunsetCalculator(location, "America/New_York");
int sunrise, sunset;

// times of day
boolean morning, afternoon, night;
boolean sun, moon;

int DAY, HOUR;
int tMax = 86400; // max number of seconds in one day

void setup() {
  size(displayWidth, 100);
  colorMode(HSB, 360);
  getSunriseSunset();
  DAY = day();
  HOUR = hour();
  println(DAY);
}

void getSunriseSunset() {
  String sunriseTemp = calculator.getOfficialSunriseForDate(Calendar.getInstance()); // today's sunrise
  String sunsetTemp = calculator.getOfficialSunsetForDate(Calendar.getInstance()); // todays' sunset
  println(sunriseTemp + "\t" + sunsetTemp);
  String[] sr = split(sunriseTemp, ":");
  String[] ss = split(sunsetTemp, ":");
  sunrise = timeInSeconds(int(sr[0]), int(sr[1]), 0);
  sunset = timeInSeconds(int(ss[0]), int(ss[1]), 0);
}

void draw() {
  // t = current moment in time
  //  int t = timeInSeconds(hour(), minute(), second());
  /*
  int h = 0;
  int m = 15;
  int s = 23;
  */
  int h = hour();
  int m = minute();
  int s = second();
  int t = timeInSeconds(h, m, s);
  
  
  
  // determine if it's morning, afternoon, or night
  if (t >= sunrise && t < timeInSeconds(12, 0, 0)) {
    morning = true;
    afternoon = false;
    night = false;
  }
  else if (t > timeInSeconds(12, 0, 0) && t < sunset) {
    morning = false;
    afternoon = true;
    night = false;
  }
  else if (t < sunrise || t > sunset) {
    morning = false;
    afternoon = false;
    night = true;
  }
  // println(morning + "\t" + afternoon + "\t" + night);
  // determining whether the sun is in the sky
  if (t >= sunrise && t <= sunset) { 
    sun = true;
    moon = false;
  }
  else { 
    sun = false;
    moon = true;
  }
  // println(sun + "\t" + moon);
  // println(sunrise + "\t" + t + "\t" + sunset);
  float w = map(t, 0, tMax, 0, width);

  background(map(mouseX, 0, width, 210, 254), map(mouseX, 0, width, 360, 360 * 0.90), map(mouseX, 0, width, 360, 360 * 0.16));
  fill(0);
  noStroke();
  rectMode(CORNER);
  rect(0, height/2, w, 50);
  for (int i = 0; i < 24; i++) {
    for (int j = 0; j < 4; j++) {
      // draw subdivisions of time
    }
    stroke(220);
    line(map(i, 0, 24, 0, width), height/2, map(i, 0, 24, 0, width), height);
    fill(300);
    if (i < 13) text(nf(i, 2), map(i, 0, 24, 0, width), height/3);
    else text(nf(i - 12, 2), map(i, 0, 24, 0, width), height/3);
  }
  stroke(330);
  line(map(t, 0, tMax, 0, width), height/2, map(t, 0, tMax, 0, width), height);
  fill(330);
  text(":" + nf(m, 2) + ":" + nf(s, 2), map(t, 0, tMax, 0, width) + 5, height/1.3);
  stroke(0, 360, 360);
  line(map(sunrise, 0, tMax, 0, width), height/2, map(sunrise, 0, tMax, 0, width), height);
  // line(map(timeInSeconds(srHr, srMin, 0), 0, 86400, 0, width), height/2, map(timeInSeconds(ssHr, ssMin, 0), 0, 86400, 0, width), height/2);
  fill(0, 300, 300, 100);
  rectMode(CORNERS);
  rect(map(sunrise, 0, tMax, 0, width), height, map(sunset, 0, tMax, 0, width), height/2);
  line(map(sunset, 0, tMax, 0, width), height/2, map(sunset, 0, tMax, 0, width), height);

  // checking to see if there's a new day while the program is running
  // if so, update the sunrise and sunset times
  if (HOUR != hour()) {
    HOUR = hour();
    println("hour changed: " + HOUR);
    if (DAY != day()) {
      println("day changed: " + DAY);
      println("new sunrise/sunset");
      getSunriseSunset();
      DAY = day();
    }
    else println("same day tho");
  }
}

int timeInSeconds(int h, int m, int s) {
  return ((h * 3600) + (m * 60) + s);
}

String time (int ts) {
  float h = floor(ts / 3600);
  float m = (ts / 60) - h * 60; // (ts / 60) % 60; 
  float s = (ts - (m * 60 + h * 3600)); // ts % 60;
  return nf((int) h, 2) + ":" + nf((int) m, 2) + ":" + nf((int) s, 2);
}

void mousePressed() {
  save(timestamp() + ".png");
  int ts = (int) map(mouseX, 0, width, 0, tMax);
  print(time(ts) + "\t");
  if (ts < (86400/2)) println("morning");
  else println("evening");
}

String timestamp() {
  String currentTime = str(year()) 
    + nf(month(), 2)
      + nf(day(), 2)
        + "_"
          + nf(hour(), 2)
          + nf(minute(), 2)
            + nf(second(), 2);
  return currentTime;
}

