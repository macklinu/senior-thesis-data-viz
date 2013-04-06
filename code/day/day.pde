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
String sunrise = calculator.getOfficialSunriseForDate(Calendar.getInstance()); // today's sunrise
String sunset = calculator.getOfficialSunsetForDate(Calendar.getInstance());
int srHr, srMin, ssHr, ssMin;

void setup() {
  size(displayWidth, 100);
  colorMode(HSB, 360);
  convertSunriseSunset();
}

void convertSunriseSunset() {
  String[] sr = split(sunrise, ":");
  String[] ss = split(sunset, ":");
  srHr = int(sr[0]);
  srMin = int(sr[1]);
  ssHr = int(ss[0]);
  ssMin = int(ss[1]);
}

void draw() {
  int t = time_in_seconds(hour(), minute(), second());
  float w = map(t, 0, 86400, 0, width);
  background(180);
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
    fill(50);
    text(nf(i, 2), map(i, 0, 24, 0, width), height/3);
  }
  stroke(330);
  line(map(t, 0, 86400, 0, width), height/2, map(t, 0, 86400, 0, width), height);
  fill(330);
  text(":" + nf(minute(), 2) + ":" + nf(second(), 2), map(t, 0, 86400, 0, width) + 5, height/1.3);
  stroke(0, 360, 360);
  line(map(time_in_seconds(srHr, srMin, 0), 0, 86400, 0, width), height/2, map(time_in_seconds(srHr, srMin, 0), 0, 86400, 0, width), height);
  // line(map(time_in_seconds(srHr, srMin, 0), 0, 86400, 0, width), height/2, map(time_in_seconds(ssHr, ssMin, 0), 0, 86400, 0, width), height/2);
  fill(0, 300, 300, 100);
  rectMode(CORNERS);
  rect(map(time_in_seconds(srHr, srMin, 0), 0, 86400, 0, width), height, map(time_in_seconds(ssHr, ssMin, 0), 0, 86400, 0, width), height/2);
  line(map(time_in_seconds(ssHr, ssMin, 0), 0, 86400, 0, width), height/2, map(time_in_seconds(ssHr, ssMin, 0), 0, 86400, 0, width), height);
  
}

int time_in_seconds(int h, int m, int s) {
  return ((h * 3600) + (m * 60) + s);
}

String time (int ts) {
  float h = floor(ts / 3600);
  float m = (ts / 60) - h * 60; // (ts / 60) % 60; 
  float s = (ts - (m * 60 + h * 3600)); // ts % 60;
  return nf((int) h, 2) + ":" + nf((int) m, 2) + ":" + nf((int) s, 2);
}

void mousePressed() {
  // save(timestamp() + ".png");
  int ts = (int) map(mouseX, 0, width, 0, 86400);
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

