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

import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;
import processing.serial.*;
import controlP5.*;

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
boolean SNESController = false; // if using a SNES controller

float x, y, mx;
float up, mult, down, downMult;

PFont p;

void setup() {
  size(960/2, 720/2);
  smooth();
  colorMode(HSB);
  RG.init(this); // initialize Geomerative library
  helicopter = RG.loadShape("helicopter.svg");
  helicopter.scale(0.05);
  cp5 = new ControlP5(this);
  //cp5.setControlFont((createFont("Roboto", 20)),14);
  p = loadFont("BebasNeue.vlw"); 
  cp5.setControlFont(p);
  l = cp5.addListBox("myList")
    .setPosition(width/2 - 200/2, height/2 - 75)
      .disableCollapse() 
        .setSize(200, 200)
          .setItemHeight(20)
            .setBarHeight(24)
              .setColorBackground(color(0, 128))
                .setColorActive(color(0))
                  .setColorForeground(#28B5EA); //color(63, 174, 216, 100));
  l.captionLabel().toUpperCase(false);
  l.captionLabel().set("Select a game");
  l.captionLabel().setColor(#3FAED8);
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
    .setPosition(width/2 - 40, height/1.5)
      .setSize(80, 20)
        .setColorBackground(color(0, 128))
          .setColorActive(#3FAED8)
            .setValue(true)
              .setMode(ControlP5.SWITCH);
  toggle.captionLabel().set("data viz mode");
  toggle.captionLabel().setColor(color(255));
  title = cp5.addTextlabel("title")
    .setText("Helistockter")
      .setColorValue(#ffffff)
        .setWidth(5);
  // cp5.addFrameRate().setInterval(10).setPosition(width - 20, height - 20 );
  if (SNESController) arduino = new Serial(this, Serial.list()[4], 57600);
  for (int i = 0; i < buttons.length; i++) {
    buttons[i] = new Button(buttonID[i]);
  }
  masterTime = millis();
}

void initGame() {
  x = 50;
  mx = 0;
  y = height/2;
  mult = 0.1;
  downMult = 0.15;
  thread("loadData");
  collision = false;
  gamePlay = true;
}

void draw() {
  if (gameSelect) {
    cursor();
    background(120);
    pushMatrix();
    popMatrix();
    showUI(true);
    textFont(p);
    fill(255);
    text("Click the mouse and keep the helicopter from touching the ground and ceiling.", 4, 30);
  }
  if (gamePlay) {
    background(120);
    noCursor();
    if (dataFinishedLoading) {
      background(230);
      showUI(false);
      if (SNESController) readController();
      if (!collision) {
        // button press code
        //for (int i = 0; i < buttons.length; i++) {
        // buttons[i].update();
        if (SNESController) {
          if (buttons[8].held()) {
            downMult = 0.15;
            up += 0.55 * mult;
            mult += 0.11;
          }
          else { 
            up = 0;
            mult = 0.1;
          }
        }
        else {
          if (mousePressed) {
            downMult = 0.15;
            up += 0.55 * mult;
            mult += 0.11;
          }
          else { 
            up = 0;
            mult = 0.1;
          }
        }
        ceiling.update();
        ground.update();
        y-=up;
        down = 0.55 * downMult;
        downMult += 0.48;
        y+=down;
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

void checkCollisions(RShape r) {
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

void readController() {
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].set(serialInArray[i+1]);
  }
}

void createBarriers(String groundData, String ceilingData) {
  ground = new Ground(groundData, 150, 20, gameType);
  ceiling = new Ceiling(ceilingData, height-150, height-20, gameType);
}

void keyPressed() {
  if (key == ' ') {
    createBarriers(groundData, ceilingData);
    collision = false;
  }
  if (keyCode == RIGHT) { 
    ground.update();
    ceiling.update();
  }
  if (key == 's') {
    // save("screenshots/" + timestamp() + ".png");
  }
}

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

public void loadData() {
  dataFinishedLoading = false;
  createBarriers(groundData, ceilingData);
  dataFinishedLoading = true;
}

// each incoming serial message...
void serialEvent(Serial arduino) {
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

void controlEvent(ControlEvent theEvent) {
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
    // println(gameType);
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

void showUI(boolean b) {
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

