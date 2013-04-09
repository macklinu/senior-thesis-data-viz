class Dataset {
  CSV csv;
  float[] data;

  float dataMin = MAX_FLOAT;
  float dataMax = MIN_FLOAT;

  Dataset(String filepath, int row) {
    csv = new CSV(filepath);
    data = new float[csv.getRowCount()];
    for (int i = 1; i < csv.getRowCount(); i++) {
      data[i] = csv.getFloat(i, row); // test each value in the array
      if (data[i] > dataMax) dataMax = data[i];
      if (data[i] < dataMin) dataMin = data[i];
    }
  }

  float getData(int i) {
    return data[i];
  }

  float getRowCount() {
    return csv.getRowCount();
  }

  float getMin() {
    return dataMin;
  }

  float getMax() {
    return dataMax;
  }
}

