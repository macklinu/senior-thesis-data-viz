// http://bit.ly/ZnsWF9

import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;
import processing.serial.*;

Button[] buttons = new Button[12];
String[] buttonID = {
  "b", "y", "select", "start", "up", "down", "left", "right", "a", "x", "l", "r"
};
Serial arduino;
int[] serialInArray = new int[17]; // length: 17 = (255 start byte) + 16 byte controller message
int serialCount;

long masterTime, masterTimeBetween; // for time between button presses
/*
RShape ground, ceiling;
 RPoint[] groundPoints, ceilingPoints;
 
 boolean touch;
 int totalWidth;
 int tx;
 */

Ground ground; 
Ceiling ceiling;

boolean touch = false;

float x, y;
float a, mult, down, downMult;

void setup() {
  size(960, 720);
  smooth();
  colorMode(HSB);
  RG.init(this); // initialize Geomerative library
  createBarriers("GOOG.csv", "GOOG.csv");
  arduino = new Serial(this, Serial.list()[4], 57600);
  for (int i = 0; i < buttons.length; i++) {
    buttons[i] = new Button(buttonID[i]);
  }
  masterTime = millis();
  y = height/2;
  mult = 0.05;
  downMult = 0.05;
}

void draw() {
  background(255);
  readController();
  // button press code
  for (int i = 0; i < buttons.length; i++) {
    // buttons[i].update();
    if (buttons[8].held()) {
      downMult = 0.05;
      a += 0.05 * mult;
      mult += 0.0003;
    }
    else { 
      a = 0;
      mult = 0.1;
    }
    if (buttons[i].clicked()) {
      masterTimeBetween = millis() - masterTime;
      masterTime = millis();
      println("clicked: " + i + "\t" + buttons[i].id +  "\t" + masterTimeBetween + "\t" + masterTime);
    }
  }
  if (frameCount % 2 == 0) { 
    ceiling.update();
    ground.update();
  }
  y-=a;
  down = 0.05 * downMult;
  downMult += 0.55;
  y+=down;
  println(y);
  if (!touch) {
    ground.display();
    ceiling.display();

    RShape rect = RShape.createRectangle(50, y, 20, 10);
    RG.shape(rect);

    RPoint[] gps = ground.getShape().getIntersections(rect);
    RPoint[] cps = ceiling.getShape().getIntersections(rect);

    if (gps != null || cps != null) {
      touch = true;
      /*
    for (int i=0; i<cps.length; i++) {
       fill(0, 255, 255);
       ellipse(cps[i].x, cps[i].y, 10, 10);
       }
       */
    }

    fill(255);
    text(frameRate, 10, 10);
  }
}

void readController() {
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].set(serialInArray[i+1]);
  }
}

void createBarriers(String groundData, String ceilingData) {
  ground = new Ground(dataPath(groundData), 350, 50);
  ceiling = new Ceiling(dataPath(ceilingData), height-350, height-50);
}

void keyPressed() {
  if (key == ' ') {
    createBarriers("GOOG.csv", "GOOG.csv");
    touch = false;
  }
  if (keyCode == RIGHT) { 
    ground.update();
    ceiling.update();
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

