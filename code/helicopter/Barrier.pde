class Barrier {
  CSV csv;
  RShape barrier;
  float[] allPoints;
  RPoint[] barrierPoints;

  int numSegments = 42;
  int totalSegments;
  int offset = 0;
  float rangeMin, rangeMax;
  int colNum = 4;
  float dataMin = MAX_FLOAT;
  float dataMax = MIN_FLOAT;

  Barrier(String filepath, float rangeMin, float rangeMax) {
    this.rangeMin = rangeMin;
    this.rangeMax = rangeMax;
    csv = new CSV(filepath); // create a csv object
    totalSegments = csv.getRowCount() - 1; //
    barrierPoints = new RPoint[numSegments];
    allPoints = new float[totalSegments];
    minMax(colNum); // find min and max of column 4 in the dataset
    for (int i = 0; i < totalSegments; i++) {
      allPoints[i] = map(csv.getFloat(i, colNum), dataMin, dataMax, rangeMin, rangeMax); // reverse logic for screen coordinates
    }
    createBarrier();
    // println(allPoints);
  }

  void update() {
    offset+=1;
    createBarrier();
  }

  void display() {
    fill(150, 150);
    noStroke();
    RG.shape(barrier);
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
}

