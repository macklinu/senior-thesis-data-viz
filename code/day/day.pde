Today today;

void setup() {
  size(displayWidth, 100);
  colorMode(HSB, 360);
  today = new Today();
}

void draw() {
  today.run(hour(), minute(), second());
  /*
  int h = 0;
   int m = 15;
   int s = 23;
   */

  /*
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
   */
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

