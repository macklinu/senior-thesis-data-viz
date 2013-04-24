/**
 * Asteroids
 *
 * original code: https://github.com/neufuture/SimpleTwitterStream/ 
 *
 */

import java.util.*;
// import java.util.concurrent.CopyOnWriteArrayList; 
import controlP5.*;

ControlP5 cp5;
Group tweetGroup;
Textlabel instructions;
ListBox tweets; // = new ListBox[3];

Twitter tw;
Gun gun;
ArrayList<Asteroid> asteroids;

final static int NORTH = 1;
final static int EAST = 2;
final static int SOUTH = 4;
final static int WEST = 8;
final static int L = 16;
final static int R = 32;
int result;

float g = 1;
String textValue = "";
boolean showSearchBox = false;

void setup() {
  size(1280, 720);
  smooth();
  imageMode(CENTER);
  cp5 = new ControlP5(this);

  cp5 = new ControlP5(this);
  // cp5.setControlFont(createFont("Roboto", 20, true), 12);

  cp5.addTextfield("search")
    .setPosition(10, 25)
      .setSize(100, 20)
        //.setFont(createFont("arial",20))
        .setAutoClear(true);

  instructions = cp5.addTextlabel("instructions")
    .setText("press \"t\" to search twitter")
      .setPosition(10, 10)
        ;

  tw = new Twitter();
  gun = new Gun(width/2, height/2);
  asteroids = new ArrayList<Asteroid>();
  result = 0;
}

public void search(String text) {
  // automatically receives results from controller input
  cp5.get(Textfield.class, "search").setFocus(false);
  tw.setKeywords(text);
  showSearchBox = !showSearchBox;
}

void draw() {
  background(0);
  if (showSearchBox) {
  }
  else {
    cp5.get(Textfield.class, "search").hide();
  }
  if (!cp5.get(Textfield.class, "search").isActive()) {
    // rotate gun
    switch(result) {
      /*
  case NORTH: 
       gun.moveY(-1); 
       break;
       case EAST: 
       gun.moveX(1); 
       break;
       case SOUTH: 
       gun.moveY(1); 
       break;
       case WEST: 
       gun.moveX(-1); 
       break;
       case NORTH|EAST: 
       gun.moveY(-1); 
       gun.moveX(1); 
       break;
       case NORTH|WEST: 
       gun.moveY(-1); 
       gun.moveX(-1); 
       break;
       case SOUTH|EAST: 
       gun.moveY(1); 
       gun.moveX(1); 
       break;
       case SOUTH|WEST: 
       gun.moveY(1); 
       gun.moveX(-1); 
       break;
       */
    case L: 
      gun.rot(-PI); 
      break;
    case R: 
      gun.rot(PI); 
      break;
    }
  }
  // move and draw the gun
  gun.update();
  gun.display();
  // iterate through on screen asteroids
  ListIterator<Asteroid> it = asteroids.listIterator();
  List<Bullet> activeBullets = gun.getBullets();
  List<Asteroid> deadAsteroids = new ArrayList<Asteroid>(); // temp dead asteroid pool
  List<Bullet> deadBullets = new ArrayList<Bullet>(); // temp dead bullet pool
  while (it.hasNext ()) { // while there are asteroids
    Asteroid a = it.next(); // a = the asteroid we're looking at
    // check each bullet for collisions
    for (Bullet b : activeBullets) {
      checkCollision(a, b);
      if (b.isOffScreen()) deadBullets.add(b); 
      if (a.isHit()) deadBullets.add(b);
    }
    if (a.isDead()) deadAsteroids.add(a);
    PVector aForce = a.repel(a);
    a.applyForce(aForce);
    PVector force = gun.attract(a);
    // a.applyForce(force);
    a.update();
    a.display(); // draw the asteroid
  } // end of while loop
  if (deadAsteroids.size() > 0) asteroids.removeAll(deadAsteroids);
  if (deadBullets.size() > 0) activeBullets.removeAll(deadBullets);
}

void mousePressed() {
}

void keyPressed() {
  if (!cp5.get(Textfield.class, "search").isActive()) {
    if (key == ' ') gun.fire(); // fire the gun }
    if (key == 't') { 
      showSearchBox = true;
      cp5.get(Textfield.class, "search").show();
      cp5.get(Textfield.class, "search").setFocus(true);
    }
  }
  // deal with keyboard controls (for now)
  switch(key) {
    case('w'):
    case('W'):
    result |=NORTH;
    break;
    case('d'):
    case('D'):
    result |=EAST;
    break;
    case('s'):
    case('S'):
    result |=SOUTH;
    break;
    case('a'):
    case('A'):
    result |=WEST;
    break;
    case('j'):
    case('J'):
    result |=L;
    break;
    case('k'):
    case('K'):
    result |=R;
    break;
  }
}

void keyReleased() {  
  switch(key) {
    case('w'):
    case('W'):
    result ^=NORTH;
    break;
    case('d'):
    case('D'):
    result ^=EAST;
    break;
    case('s'):
    case('S'):
    result ^=SOUTH;
    break;
    case('a'):
    case('A'):
    result ^=WEST;
    break;
    case('j'):
    case('J'):
    result ^=L;
    break;
    case('k'):
    case('K'):
    result ^=R;
    break;
  }
}

void checkCollision(Asteroid a, Bullet b) {
  if (dist(a.location.x, a.location.y, b.location.x, b.location.y) < a.w/2) { // works with an ellipse
    a.hit(true); // asteroid was hit
  }
}

void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with id " + theEvent.getController().getStringValue());
}

