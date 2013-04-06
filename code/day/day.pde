void setup() {
  size(displayWidth, 100);
  colorMode(HSB, 360);
}

void draw() {
  int t = time_in_seconds(hour(), minute(), second());
  float w = map(t, 0, 86400, 0, width);
  println(t);
  background(180);
  fill(0);
  noStroke();
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
  line(map(time_in_seconds(7, 9, 0), 0, 86400, 0, width), height/2, map(time_in_seconds(7, 9, 0), 0, 86400, 0, width), height);
  line(map(time_in_seconds(20, 6, 0), 0, 86400, 0, width), height/2, map(time_in_seconds(7, 9, 0), 0, 86400, 0, width), height);
  line(map(time_in_seconds(20, 6, 0), 0, 86400, 0, width), height/2, map(time_in_seconds(20, 6, 0), 0, 86400, 0, width), height);
}

int time_in_seconds(int h, int m, int s) {
  return ((h * 3600) + (m * 60) + s);
}

void mousePressed() {
  save(timestamp() + ".png");
}
}

