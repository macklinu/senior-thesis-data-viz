/**
 * North American Music
 *
 * 2 Apr 2013
 * Digital Music Ensemble: University of Michigan, Ann Arbor
 * audio programming: Colin Fulton
 * visual programming: Macklin Underdown 
 *
 * Visualization for MICHIGAN
 *
 */

import java.util.Iterator; // for the circles ArrayList
import de.looksgood.ani.*; // animation library
import de.looksgood.ani.easing.*;
import oscP5.*; // OSC library to communicate between visual sketches
import netP5.*;

Country nam;
OscP5 fromIL, fromNY;
NetAddress toIL, toNY;

int x = -587; // adjust x position of svg
int y = -121; // adjust x position of svg
float sc = 2.025; // global scale of map

// times it takes to travel from one state to another (in ms)
float speed = 50.0; // 1 = realtime
float MI_to_IL = 1287378.0 / speed;
float MI_to_NY = 2408736.0 / speed;
float IL_to_NY = 3623298.0 / speed;

PFont font;

String corner = "north american music";

void setup() {
  // P3D is crucial; otherwise, the framerate drops significantly over time
  size(1280, 720, P3D);
  smooth();
  colorMode(HSB, 360);

  fromIL = new OscP5(this, 7800);
  fromNY = new OscP5(this, 7801);
  toIL = new NetAddress("127.0.0.1", 7802);
  toNY = new NetAddress("127.0.0.1", 7804);
  fromIL.plug(this, "ilStart", "/ilStart");
  fromNY.plug(this, "nyStart", "/nyStart");

  Ani.init(this); // initialize the animation library
  nam = new Country(x, y); // create the United States of America
  // load a font
  font = loadFont("Inconsolata.vlw");
  textFont(font);
}

void draw() {
  background(200);
  nam.display(); // do everything
}

void keyPressed() {
  if (key == '1') {
    nam.create(0, 1, 2, MI_to_IL, IL_to_NY); // create IL
  }
  if (key == '2') {
    nam.create(1, 0, 2, MI_to_IL, MI_to_NY); // create MI
  }
  if (key == '3') {
    nam.create(2, 1, 0, MI_to_IL, IL_to_NY); // create NY
  }
}

/////////////////
// osc methods //
/////////////////

public void ilStart(int i) {
  println("IL has started playing, but you can't hear it yet.");
  nam.create(0, 1, 2, MI_to_IL, IL_to_NY);
}

public void nyStart(int i) {
  println("NY has started playing, but you can't hear it yet.");
  nam.create(2, 1, 0, MI_to_IL, IL_to_NY);
}

//////////
// misc //
//////////

// custom timestamp string makes saving files chronologically organized 
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

