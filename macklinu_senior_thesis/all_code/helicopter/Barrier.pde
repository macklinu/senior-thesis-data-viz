class Barrier {
  CSV csv;
  RShape barrier;
  float[] allPoints;
  RPoint[] barrierPoints;

  int numSegments;
  int totalSegments;
  int offset = 0;
  int speed;
  float rangeMin, rangeMax;
  int colNum = 4;
  float dataMin = MAX_FLOAT;
  float dataMax = MIN_FLOAT;
  boolean nearEnd = false;
  String id;
  String[] dates;

  Barrier(String filepath, float rangeMin, float rangeMax, String type) {
    if (type.equals("data")) {
      numSegments = 320 + 2;
      speed = 4;
    }
    else {
      numSegments = 80 + 2;
      speed = 6;
    }
    this.rangeMin = rangeMin;
    this.rangeMax = rangeMax;
    csv = new CSV(dataPath(filepath)); // create a csv object
    id = split(filepath, '.')[0];
    totalSegments = csv.getRowCount() - 1; //
    barrierPoints = new RPoint[numSegments];
    allPoints = new float[totalSegments];
    dates = new String[totalSegments];
    minMax(colNum); // find min and max of column 4 in the dataset
    for (int i = 0; i < totalSegments; i++) {
      allPoints[i] = map(csv.getFloat(i, colNum), dataMin, dataMax, rangeMax, rangeMin); // reverse logic for screen coordinates
      dates[i] = csv.getString(i, 0);
    }
    allPoints = reverse(allPoints);
    dates = reverse(dates);
    createBarrier();
  }

  void update() {
    if (numSegments + offset > totalSegments - speed - 1) { 
      nearEnd = true;
    }
    if (!nearEnd) {
      offset+=speed;
      createBarrier();
    }
  }

  void display() {
    // RG.shape(barrier);
  }

  void minMax(int col) {
    for (int i = csv.getRowCount() - 1; i > 0; i--) {
      float value = csv.getFloat(i, col);
      if (value > dataMax) dataMax = value;
      if (value < dataMin) dataMin = value;
    }
  }

  // to be overridden by child class
  void createBarrier() {
  }

  int getNumSegments() { 
    return numSegments;
  }

  RShape getShape() {
    return barrier;
  }
  
  boolean nearEnd() {
    return nearEnd;
  }
}

