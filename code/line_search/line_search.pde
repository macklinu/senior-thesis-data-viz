import java.util.Map;
import java.util.List;
import java.util.Iterator;
import controlP5.*;

ControlP5 cp5;
ListBox list;

String[] lines;
String[][] csv;
int csvWidth = 0;
String filepath;
float current = 0;
// This will keep track of whether the thread is finished
boolean finished = false;
// And how far along
float percent = 0;

Map<String, DataChunk> multiMap = new HashMap<String, DataChunk>();
float[] data;
float[] x, y;
float min, max;
int[] curDays;

void setup() {
  size(640, 360);
  smooth();
  cp5 = new ControlP5(this);
  list = cp5.addListBox("companies")
    .setPosition(15, 15*2)
      .setSize(100, height-15)
        .setItemHeight(15)
          .setBarHeight(15)
            .setColorBackground(color(255, 128))
              .setColorActive(color(0))
                .setColorForeground(color(40, 100, 0));
  list.captionLabel().set("Companies");
  list.captionLabel().style().marginTop = 3;
  list.valueLabel().style().marginTop = 3;
  // Spawn the thread!
  thread("loadData");
}

void draw() {
  background(0);

  // If we're not finished draw a "loading bar"
  // This is so that we can see the progress of the thread
  // This would not be necessary in a sketch where you wanted to load data in the background
  // and hide this from the user, allowing the draw() loop to simply continue
  if (!finished) {
    list.hide();
    stroke(255);
    noFill();
    rect(width/2-150, height/2, 300, 10);
    fill(255);
    // The size of the rectangle is mapped to the percentage completed
    float w = map(percent, 0, 1, 0, 300);
    rect(width/2-150, height/2, w, 10);
    textSize(14);
    textAlign(CENTER);
    fill(255);
    text("Loading", width/2, height/2+30);
  } 
  else {
    list.show();
    for (int i = 0 ; i < x.length - 1; i++) {
      noStroke();
      fill(255, 100);
      ellipse(x[i], y[i], 5, 5);
    }
  }
}

// asynchronous data loading
void loadData() {
  finished = false;
  percent = 0;

  println("Loading...");
  float start = millis();

  lines = loadStrings(dataPath("sp500hst-small.csv")); // load CSV file
  // split by comma delimiter
  for (int i = 0; i < lines.length; i++) {
    String [] chars = split(lines[i], ",");
    if (chars.length > csvWidth) {
      csvWidth = chars.length;
    }
  }
  // create a 2D array based on the size of the csv row length and column length
  csv = new String [lines.length][csvWidth];
  String testCompany = "";
  int count = 0;
  ArrayList<String> dates = new ArrayList<String>(); // create values arraylist
  ArrayList<Float> values = new ArrayList<Float>(); // create values arraylist
  for (int i = 0; i < lines.length; i++) {
    percent = float(i)/lines.length;
    String [] temp = new String [lines.length];
    temp = split(lines[i], ",");
    String tempCompany = temp[1];
    if (!tempCompany.equals(testCompany)) {
      // buttons.add(new Button(tempCompany, 0, count++ * 10));
      dates = new ArrayList<String>(); // create values arraylist
      values = new ArrayList<Float>(); // create values arraylist
      ListBoxItem lbi = list.addItem(tempCompany, count++);
      // list.captionLabel().setFont(createFont("Roboto", 10));
      dates.add(temp[0]); // populate arraylist with first value
      values.add(float(temp[4])); // populate arraylist with first value
    }
    else {
      dates.add(temp[0]); // add the rest of the data for a given company
      values.add(float(temp[4])); // populate arraylist with first value
    }
    testCompany = temp[1];
    DataChunk d = new DataChunk(dates, values);
    multiMap.put(tempCompany, d); // add datachunk to multimap
  }

  float now = millis() - start;
  println("load time: " + nf(now/1000, 1, 2) + "s");
  setDataDisplay("A");
  // The thread is completed!
  finished = true;
}

void setDataDisplay(String company) {
  DataChunk d = multiMap.get(company);
  float[] starter = d.getValues();
  // curDays = new int[starter.length];
  x = y = new float[starter.length];
  float[] sorted = sort(starter);
  min = sorted[0];
  max = sorted[sorted.length - 1];
  curDays = d.getDIY();
  // data = starter;
  for (int i = 0; i < starter.length - 1; i++) {
    x[i] = map(curDays[i], 0, 365, 200, 600);
    y[i] = map(starter[i], min, max, 300, 50);
  }
}

void controlEvent(ControlEvent theEvent) {
  String company = list.getItem((int)theEvent.group().value()).getName();
  setDataDisplay(company);
}

