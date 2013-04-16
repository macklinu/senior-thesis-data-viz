import java.util.Map;
import java.util.List;
import java.util.Iterator;

int totalRows = 122574;
String[] lines;
String[][] csv;
int csvWidth = 0;
String filepath;
float current = 0;
// This will keep track of whether the thread is finished
boolean finished = false;
// And how far along
float percent = 0;

Map<String, ArrayList<Float>> multiMap = new HashMap<String, ArrayList<Float>>();
ArrayList<Float> values = new ArrayList<Float>();
ArrayList<Button> buttons = new ArrayList<Button>();

void setup() {
  size(640, 360);
  smooth();
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
    // The thread is complete!
    for (Button b: buttons) b.display();
    
    //    textAlign(CENTER);
    //    textSize(10);
    // fill(255);
    // text("Finished loading. Click the mouse to load again.", width/2, height/2);
  }
}

void mousePressed() {
  // if (finished) thread("loadData");
}

void keyPressed() {
  if (finished) {
    if (key == 'a') println(multiMap.get("ADSK") + "\n" + multiMap.get("ADSK").size());
    if (key == 'b') println(multiMap.get("AAPL") + "\n" + multiMap.get("AAPL").size());
  }
}

// asynchronous data loading
void loadData() {
  finished = false;
  percent = 0;

  println("Loading...");
  float start = millis();

  lines = loadStrings(dataPath("sp500hst.csv")); // load CSV file
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
  for (int i = 0; i < lines.length; i++) {
    percent = float(i)/lines.length;
    String [] temp = new String [lines.length];
    temp = split(lines[i], ",");
    String tempCompany = temp[1];
    if (!tempCompany.equals(testCompany)) {
      buttons.add(new Button(tempCompany, 0, count++ * 10));
      multiMap.put(tempCompany, values);
      /*
      Iterator iterator = (Iterator) multiMap.keySet().iterator();
       while (iterator.hasNext ()) {
       String key = iterator.next().toString();
       String value = multiMap.get(key).toString();
       println(key + " " + value);
       }
       println();
       */
      values = new ArrayList<Float>();
    }
    else values.add(float(temp[4]));
    testCompany = temp[1];
  }

  float now = millis() - start;
  println(nf(now, 1, 2));
  // The thread is completed!
  finished = true;
}

