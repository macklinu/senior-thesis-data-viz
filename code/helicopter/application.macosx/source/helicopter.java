import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import geomerative.*; 
import org.apache.batik.svggen.font.table.*; 
import org.apache.batik.svggen.font.*; 
import processing.serial.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class helicopter extends PApplet {

// http://bit.ly/ZnsWF9

/*
AAPL - Apple
 BAC - Bank of America
 BP - BP
 DELL - Dell
 DOW - Dow Chemical
 GOOG - Google
 IBM - IBM
 MCD - McDonald's
 MSFT - Microsoft
 SBUX - Starbucks
 T - AT&T
 TDS - Telephone & Data Systems
 VZ - Verizon
 XOM - Exxon Mobil
 */







Serial arduino;
ControlP5 cp5;
ListBox l;
Textlabel title;
Toggle toggle;
Ground ground; 
Ceiling ceiling;
RShape helicopter;
Button[] buttons = new Button[12];
String[] buttonID = {
  "b", "y", "select", "start", "up", "down", "left", "right", "a", "x", "l", "r"
};
int[] serialInArray = new int[17]; // length: 17 = (255 start byte) + 16 byte controller message
int serialCount;
long masterTime, masterTimeBetween; // for time between button presses
boolean collision = false;
boolean dataFinishedLoading = false;
boolean gameSelect = true;
boolean gamePlay = false;
String ceilingData, groundData;
String gameType;

float x, y, mx;
float up, mult, down, downMult;

public void setup() {
  size(960/2, 720/2);
  smooth();
  colorMode(HSB);
  RG.init(this); // initialize Geomerative library
  helicopter = RG.loadShape("helicopter.svg");
  helicopter.scale(0.05f);
  cp5 = new ControlP5(this);
  //cp5.setControlFont((createFont("Roboto", 20)),14);
  PFont p = loadFont("BebasNeue.vlw"); 
  cp5.setControlFont(p);
  l = cp5.addListBox("myList")
    .setPosition(width/2 - 200/2, height/2 - 75)
      .disableCollapse() 
        .setSize(200, 200)
          .setItemHeight(20)
            .setBarHeight(24)
              .setColorBackground(color(0, 128))
                .setColorActive(color(0))
                  .setColorForeground(0xff28B5EA); //color(63, 174, 216, 100));
  l.captionLabel().toUpperCase(false);
  l.captionLabel().set("Select a game");
  l.captionLabel().setColor(0xff3FAED8);
  l.captionLabel().style().marginTop = 3;
  l.valueLabel().style().marginTop = 3;
  l.addItem("Apple vs. Microsoft", 0);
  l.addItem("Dell vs. IBM", 1);
  l.addItem("McDonald's vs. Starbucks", 2);
  l.addItem("Bank of America vs. McDonald's", 3);
  l.addItem("Verizon Wireless vs. AT&T", 4);
  l.addItem("Exxon Mobil vs. BP", 5);
  // create a toggle and change the default look to a (on/off) switch look
  toggle = cp5.addToggle("toggle")
    .setPosition(width/2 - 40, height/1.5f)
      .setSize(80, 20)
        .setColorBackground(color(0, 128))
          .setColorActive(0xff3FAED8)
            .setValue(true)
              .setMode(ControlP5.SWITCH);
  toggle.captionLabel().set("data viz mode");
  toggle.captionLabel().setColor(color(255));
  title = cp5.addTextlabel("title")
    .setText("Helistockter")
      .setColorValue(0xffffffff)
        .setWidth(5);
  // cp5.addFrameRate().setInterval(10).setPosition(width - 20, height - 20 );
  arduino = new Serial(this, Serial.list()[4], 57600);
  for (int i = 0; i < buttons.length; i++) {
    buttons[i] = new Button(buttonID[i]);
  }
  masterTime = millis();
}

public void initGame() {
  x = 50;
  mx = 0;
  y = height/2;
  mult = 0.1f;
  downMult = 0.15f;
  thread("loadData");
  collision = false;
  gamePlay = true;
}

public void draw() {
  if (gameSelect) {
    cursor();
    background(120);
    pushMatrix();
    popMatrix();
    showUI(true);
  }
  if (gamePlay) {
    background(120);
    noCursor();
    if (dataFinishedLoading) {
      background(230);
      showUI(false);
      readController();
      if (!collision) {
        // button press code
        //for (int i = 0; i < buttons.length; i++) {
        // buttons[i].update();
        if (buttons[8].held()) {
          downMult = 0.15f;
          up += 0.55f * mult;
          mult += 0.11f;
        }
        else { 
          up = 0;
          mult = 0.1f;
        }
        /*
        if (buttons[i].clicked()) {
         masterTimeBetween = millis() - masterTime;
         masterTime = millis();
         println("clicked: " + i + "\t" + buttons[i].id +  "\t" + masterTimeBetween + "\t" + masterTime);
         }
         */
        //}
        ceiling.update();
        ground.update();
        y-=up;
        down = 0.55f * downMult;
        downMult += 0.48f;
        y+=down;
        // println(y);
        // draw the ground and ceiling
        ground.display();
        ceiling.display();
        // create and draw the helicopter
        if (ground.nearEnd() && ceiling.nearEnd()) {
          RShape rect = RShape.createRectangle(x + (mx+=5), y, 20, 10);
          fill(200, 150, 255);
          RG.shape(rect);
          checkCollisions(rect);
          if (x + mx + 30 >= width) { 
            println("#win");
            gamePlay = false;
            gameSelect = true;
          }
        }
        else {
          RShape rect = RShape.createRectangle(x, y, 20, 10);
          fill(200, 150, 255);
          RG.shape(rect);
          checkCollisions(rect);
        }

        // when game ends
      }
      else {
        initGame();
      }
    }
  }
}

public void checkCollisions(RShape r) {
  // check for intersections between the helicopter, ground and ceiling
  RPoint[] gps = ground.getShape().getIntersections(r);
  RPoint[] cps = ceiling.getShape().getIntersections(r);
  // if an intersection has occurred
  if (gps != null || cps != null) { 
    collision = true; // collision!
    println("GAME OVER");
    gamePlay = false;
    gameSelect = true;
  }
}

public void readController() {
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].set(serialInArray[i+1]);
  }
}

public void createBarriers(String groundData, String ceilingData) {
  ground = new Ground(groundData, 150, 20, gameType);
  ceiling = new Ceiling(ceilingData, height-150, height-20, gameType);
}

public void keyPressed() {
  if (key == ' ') {
    createBarriers(groundData, ceilingData);
    collision = false;
  }
  if (keyCode == RIGHT) { 
    ground.update();
    ceiling.update();
  }
}

public String timestamp() {
  String currentTime = str(year()) 
    + nf(month(), 2)
      + nf(day(), 2)
        + "_"
          + nf(hour(), 2)
          + nf(minute(), 2)
            + nf(second(), 2);
  return currentTime;
}

public void loadData() {
  dataFinishedLoading = false;
  createBarriers(groundData, ceilingData);
  dataFinishedLoading = true;
}

// each incoming serial message...
public void serialEvent(Serial arduino) {
  int inByte = arduino.read();
  if (inByte == 255) serialCount = 0; // 255 inByte signifies the beginning of the serial string
  // set incoming byte into a temporary array and move through it
  // these values will be reassigned
  serialInArray[serialCount] = inByte;
  serialCount++;

  if (serialCount > serialInArray.length - 1) {
    // reset the serial count to receive the next message
    serialCount = 0;
  }
}

public void controlEvent(ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event
  // originates from a ControlGroup. therefore
  // you need to check the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.

  if (theEvent.isFrom(l)) {
    int game = (int)theEvent.group().value();
    switch(game) {
    case 0:
      groundData = "AAPL.csv";
      ceilingData = "MSFT.csv";
      break;
    case 1:
      groundData = "DELL.csv";
      ceilingData = "IBM.csv";
      break;
    case 2:
      groundData = "MCD.csv";
      ceilingData = "SBUX.csv";
      break;
    case 3:
      groundData = "BAC.csv";
      ceilingData = "MCD.csv";
      break;
    case 4:
      groundData = "VZ.csv";
      ceilingData = "T.csv";
      break;
    case 5:
      groundData = "XOM.csv";
      ceilingData = "BP.csv";
      break;
    }
    // set game mode type
    int gameMode = (int) toggle.getValue();
    if (gameMode == 0) {
      gameType = "game";
    }
    else {
      gameType = "data";
    }
    println(gameType);
    gameSelect = false;
    initGame();
  }
  if (theEvent.isFrom(toggle)) {
    //println(theEvent.group().getInfo());
    switch((int) theEvent.value()) {
    case 0:
      toggle.captionLabel().set("speed mode");
      break;
    case 1:
      toggle.captionLabel().set("data viz mode");
      break;
    }
  }
}

public void showUI(boolean b) {
  int test;
  if (b) test = 1;
  else test = 0;
  switch(test) {
  case 1:
    l.show();
    toggle.show();
    title.show();
    break;
  case 0:
    l.hide();
    toggle.hide();
    title.hide();
    break;
  }
}

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

  public void update() {
    if (numSegments + offset > totalSegments - speed - 1) { 
      nearEnd = true;
    }
    if (!nearEnd) {
      offset+=speed;
      createBarrier();
    }
  }

  public void display() {
    // RG.shape(barrier);
  }

  public void minMax(int col) {
    for (int i = csv.getRowCount() - 1; i > 0; i--) {
      float value = csv.getFloat(i, col);
      if (value > dataMax) dataMax = value;
      if (value < dataMin) dataMin = value;
    }
  }

  // to be overridden by child class
  public void createBarrier() {
  }

  public int getNumSegments() { 
    return numSegments;
  }

  public RShape getShape() {
    return barrier;
  }
  
  public boolean nearEnd() {
    return nearEnd;
  }
}

class Button {
  String id; // controller button name
  int reading, lastReading; // current and previous button press readings
  long time, timeBetween; // to determine

  Button(String id) {
    this.id = id;
    time = millis();
  }

  public boolean clicked() {
    boolean clicked;
    // if the previous button state has changed and is now 1, that means the button was clicked
    if ((reading != lastReading) && (reading == 1)) clicked = true;
    else clicked = false;
    lastReading = reading; // update the previous button state
    return clicked;
  }

  public boolean held() {
    if (reading == 1) return true;
    else return false;
  }

  public void update() {
    /*
    if (this.clicked()) {
      timeBetween = millis() - time;
      time = millis();
      println("clicked: " + id +  "\t" + timeBetween + "\t" + time);
    }
    */
  }
  
  public void set(int button) {
    reading = button;
  }
}

class CSV {

  String[] lines;
  String[][] csv;
  int csvWidth = 0;
  String filepath;

  CSV(String filepath) {
    this.filepath = filepath;
    parseCSV();
  }

  public void parseCSV() {
    lines = loadStrings(filepath); // load CSV file
    // split by comma delimiter
    for (int i = 0; i < lines.length; i++) {
      String [] chars = split(lines[i], ",");
      if (chars.length > csvWidth) {
        csvWidth = chars.length;
      }
    }
    // create a 2D array based on the size of the csv row length and column length
    csv = new String [lines.length][csvWidth];
    for (int i = 0; i < lines.length; i++) {
      String [] temp = new String [lines.length];
      temp = split(lines[i], ",");
      for (int j = 0; j < temp.length; j++) {
        csv[i][j] = temp[j];
      }
    }
  }
  
  public int getRowCount() {
    return lines.length;
  }
  
  public int getColumnCount() {
    return csvWidth;
  }
  
  public float getFloat(int col, int row) {
    return parseFloat(csv[col][row]);
  }
  
  public int getInt(int col, int row) {
    return parseInt(csv[col][row]);
  }
  
  public String getString(int col, int row) {
    return csv[col][row];
  }
  
}
class Ceiling extends Barrier {
  
  Ceiling(String filepath, float rangeMin, float rangeMax, String type) {
    super(filepath, rangeMin, rangeMax, type);
  }
  
  public void createBarrier() {
    barrierPoints[0] = new RPoint(0, 0); // first barrier point needs to connect to left corner of the screen
    barrierPoints[1] = new RPoint(0, allPoints[offset]); // first data point
    for (int i = 2; i < numSegments - 1; i++) {
      barrierPoints[i] = new RPoint(width/numSegments*i, allPoints[i+offset]);
    }
    barrierPoints[numSegments - 2] = new RPoint(width, allPoints[offset+numSegments]); // last data point
    barrierPoints[numSegments - 1] = new RPoint(width, 0); // last barrier point needs to connect to right corner of screen
    barrier = new RShape(new RPath(barrierPoints));
  }
  
  public void display() {
    // stroke(0);
    noStroke();
    fill(160, 200, 100, 150);
    RG.shape(barrier);
    // textSize(20);
    text(id, 10, 20);
  }
  
}

class Ground extends Barrier {

  Ground(String filepath, float rangeMin, float rangeMax, String type) {
    super(filepath, rangeMin, rangeMax, type);
  }

  public void createBarrier() {
    barrierPoints[0] = new RPoint(0, height); // first barrier point needs to connect to left corner of the screen
    barrierPoints[1] = new RPoint(0, allPoints[offset]); // first data point
    for (int i = 2; i < numSegments - 1; i++) {
      barrierPoints[i] = new RPoint(width/numSegments*i, allPoints[i+offset]);
    }
    barrierPoints[numSegments - 2] = new RPoint(width, allPoints[offset+numSegments]); // last data point
    barrierPoints[numSegments - 1] = new RPoint(width, height); // last barrier point needs to connect to right corner of screen
    barrier = new RShape(new RPath(barrierPoints));
  }

  public void display() {
    // stroke(0);
    noStroke();
    fill(160, 200, 100, 150);
    RG.shape(barrier);
    // textSize(20);
    text(dates[offset], 10, height-30);
    text(id, 10, height-10);
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "helicopter" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
