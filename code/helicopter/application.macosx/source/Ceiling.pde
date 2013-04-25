class Ceiling extends Barrier {
  
  Ceiling(String filepath, float rangeMin, float rangeMax, String type) {
    super(filepath, rangeMin, rangeMax, type);
  }
  
  void createBarrier() {
    barrierPoints[0] = new RPoint(0, 0); // first barrier point needs to connect to left corner of the screen
    barrierPoints[1] = new RPoint(0, allPoints[offset]); // first data point
    for (int i = 2; i < numSegments - 1; i++) {
      barrierPoints[i] = new RPoint(width/numSegments*i, allPoints[i+offset]);
    }
    barrierPoints[numSegments - 2] = new RPoint(width, allPoints[offset+numSegments]); // last data point
    barrierPoints[numSegments - 1] = new RPoint(width, 0); // last barrier point needs to connect to right corner of screen
    barrier = new RShape(new RPath(barrierPoints));
  }
  
  void display() {
    // stroke(0);
    noStroke();
    fill(160, 200, 100, 150);
    RG.shape(barrier);
    // textSize(20);
    text(id, 10, 20);
  }
  
}

