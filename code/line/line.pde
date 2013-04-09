Dataset population;

void setup() {
  size(640, 600);
  colorMode(HSB);
  population = new Dataset(dataPath("canada.csv"), 5);
}

void draw() {
  background(150);
  for (int i = 1; i < population.getRowCount(); i++) {
    if (i < population.getRowCount() - 1) {
      float x1 = map(i, 1, population.getRowCount(), 50, 550);
      float y1 = map(population.getData(i), population.getMin(), population.getMax(), 450, 50);
      float x2 = map(i+1, 1, population.getRowCount(), 50, 550);
      float y2 = map(population.getData(i+1), population.getMin(), population.getMax(), 450, 50);
      stroke(230); 
      line(x1, y1, x2, y2);
      fill(230, 50);
      ellipse(x1, y1, 10, 10);
      if (dist(mouseX, mouseY, x1, y1) < 5) {
        fill(230);
        text(int(population.getData(i)), mouseX, mouseY - 10);
      }
    }
    else {
      float x1 = map(i-1, 1, population.getRowCount(), 50, 550);
      float y1 = map(population.getData(i-1), population.getMin(), population.getMax(), 450, 50);
      float x2 = map(i, 1, population.getRowCount(), 50, 550);
      float y2 = map(population.getData(i), population.getMin(), population.getMax(), 450, 50);
      stroke(230); 
      line(x1, y1, x2, y2);
      fill(230, 50);
      ellipse(x2, y2, 10, 10);
      if (dist(mouseX, mouseY, x2, y2) < 5) {
        fill(230);
        text(int(population.getData(i)), mouseX, mouseY - 10);
      }
    }
  }
}

  /*
for (int i = 0; i < x.length; i++) {
   float value = x[i]; // test each value in the array
   if (value > dataMax) {
   dataMax = value;
   }
   if (value < dataMin) {
   dataMin = value;
   }
   }
   */

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

