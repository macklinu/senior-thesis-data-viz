import java.util.*; // map, list, iterator, date
import java.text.*;
import controlP5.*;

ControlP5 cp5;
ListBox list;
Group group;

String dataFile = "sp500hst-small.csv";
String[] lines;
String[][] csv;
int csvWidth = 0;
String filepath;
float current = 0;
boolean finished = false; // keep track of whether the thread is finished
float percent = 0; // how far along

Map<String, DataChunk> multiMap = new HashMap<String, DataChunk>();
float[] data;
float[] x, y;
float min, max;
int[] curDays;

int currentItem = -1; // both -1
int activeItem = -1;

int visibleItems; // lines.length - 1
color listBgColor = color(255, 128);
color listActiveColor = color(120, 50, 100);
color listCurrentColor = color(0, 50, 100);

void setup() {
  size(640, 360);
  colorMode(HSB);
  smooth();
  cp5 = new ControlP5(this);
  // create list box and set attributes
  list = cp5.addListBox("companies")
    .setPosition(15, 15*2)
      .setSize(100, height-15)
        .setItemHeight(15)
          .setBarHeight(15)
            .setColorBackground(listBgColor)
              .setColorActive(color(0))
                .setColorForeground(color(40, 100, 100));
  list.captionLabel().set("Companies");
  list.captionLabel().style().marginTop = 3;
  list.valueLabel().style().marginTop = 3;
  // create the thread
  thread("loadData");
  list.hide();
}

void draw() {
  background(0);
  // if the data loading thread is not finished
  // draw a loading bar
  if (!finished) {
    stroke(255);
    noFill();
    rect(width/2-150, height/2, 300, 10);
    fill(255);
    // size of the rectangle is mapped to the percentage completed
    float w = map(percent, 0, 1, 0, 300);
    rect(width/2-150, height/2, w, 10);
    textSize(14);
    textAlign(CENTER);
    fill(255);
    text("Loading", width/2, height/2+30);
  } 
  // when the data has finished loading
  else {
    list.show();
    if (activeItem != -1) list.getItem(activeItem).setColorBackground(listActiveColor);
    for (int i = 0 ; i < x.length - 1; i++) {
      noStroke();
      fill(255, 100);
      ellipse(x[i], y[i], 5, 5);
    }
  }
}

// asynchronous data loading
// load all of the data
void loadData() {
  finished = false;
  percent = 0;
  println("Loading...");
  float start = millis();
  lines = loadStrings(dataPath(dataFile)); // load CSV file
  // split by comma delimiter
  for (int i = 0; i < lines.length; i++) {
    String [] chars = split(lines[i], ",");
    if (chars.length > csvWidth) {
      csvWidth = chars.length;
    }
  }
  // create a 2D array based on the size of the csv row length and column length
  csv = new String[lines.length][csvWidth];
  String testCompany = ""; // check for a new company
  char testLetter = ' '; // check for a new letter
  int count = 0;
  ArrayList<String> dates = new ArrayList<String>(); // create values arraylist
  ArrayList<Float> values = new ArrayList<Float>(); // create values arraylist
  for (int i = 0; i < lines.length; i++) {
    percent = float(i)/lines.length;
    String[] temp = new String[lines.length];
    temp = split(lines[i], ",");
    String tempCompany = temp[1];
    char tempLetter = tempCompany.charAt(0);
    if (!tempCompany.equals(testCompany)) {
      dates = new ArrayList<String>(); // create values arraylist
      values = new ArrayList<Float>(); // create values arraylist
      ListBoxItem lbi = list.addItem(tempCompany, count++);
      dates.add(temp[0]); // populate arraylist with first value
      values.add(float(temp[4])); // populate arraylist with first value
    }
    else {
      dates.add(temp[0]); // add the rest of the data for a given company
      values.add(float(temp[4])); // populate arraylist with first value
    }
    testCompany = temp[1];
    testLetter = tempCompany.charAt(0);
    DataChunk d = new DataChunk(dates, values);
    multiMap.put(tempCompany, d); // add datachunk to multimap
  }
  visibleItems = list.getListBoxItems().length-1;
  float now = millis() - start;
  println("load time: " + nf(now/1000, 1, 2) + "s");
  setDataDisplay("A");
  // The thread is completed!
  finished = true;
}

void setDataDisplay(String company) {
  DataChunk d = multiMap.get(company); // create a temporary datachunk of selected company
  float[] starter = d.getValues();
  x = y = new float[starter.length];
  float[] sorted = sort(starter);
  min = sorted[0];
  max = sorted[sorted.length - 1];
  curDays = d.getDIY();
  for (int i = 0; i < starter.length - 1; i++) {
    x[i] = map(curDays[i], 0, 365, 500, 600); // number of days moved
    y[i] = map(starter[i], min, max, 300, 50);
  }
}

void keyPressed() {
  if (finished) {
    switch(keyCode) {
      // move up the list
      case(UP):
      list.getItem(currentItem).setColorBackground(listBgColor);
      list.scroll((float)currentItem/(list.getListBoxItems().length - visibleItems));
      currentItem--;
      currentItem = constrain(currentItem, 0, list.getListBoxItems().length-1 );
      list.getItem(currentItem).setColorBackground(listCurrentColor);
      break;
      // move down the list
      case(DOWN):
      list.getItem(max(0, currentItem)).setColorBackground(listBgColor);
      currentItem++;
      currentItem = constrain(currentItem, 0, list.getListBoxItems().length-1);
      list.scroll( (float)currentItem / ( list.getListBoxItems().length- visibleItems )  );
      list.getItem(currentItem).setColorBackground(listCurrentColor);
      break;
      // press ENTER to select new company
      case(ENTER):
      String company = list.getItem(currentItem).getName();
      // set the background color of all items to the 
      for (int i = 0; i < visibleItems; i++) {
        list.getItem(i).setColorBackground(listBgColor);
      }
      activeItem = currentItem; // set the active item as the one selected
      setDataDisplay(company); // display the selected company's data
      break;
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  String company = list.getItem((int)theEvent.group().value()).getName();
  setDataDisplay(company);
}

