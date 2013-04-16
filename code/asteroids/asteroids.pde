/**
 * Asteroids
 *
 * original code: https://github.com/neufuture/SimpleTwitterStream/ 
 *
 */

import java.util.Iterator;
import java.util.concurrent.CopyOnWriteArrayList; 
import controlP5.*;

ControlP5 cp5;

Twitter tw;
Gun gun;
CopyOnWriteArrayList<Asteroid> asteroids;

final static int NORTH = 1;
final static int EAST = 2;
final static int SOUTH = 4;
final static int WEST = 8;
final static int L = 16;
final static int R = 32;
int result;

void setup() {
  size(800, 600);
  smooth();
  imageMode(CENTER);
  cp5 = new ControlP5(this);

  tw = new Twitter();
  gun = new Gun(width/2, height/2);
  asteroids = new CopyOnWriteArrayList<Asteroid>();
  result = 0;
}

void draw() {
  background(0);
  // rotate gun
  switch(result) {
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
  case L: 
    gun.rot(-PI); 
    break;
  case R: 
    gun.rot(PI); 
    break;
  }
  // move and draw the gun
  gun.update();
  gun.display();
  // iterate through on screen asteroids
  Iterator<Asteroid> it = asteroids.iterator();
  CopyOnWriteArrayList<Asteroid> deadAsteroids = new CopyOnWriteArrayList<Asteroid>(); // temp dead asteroid pool
  CopyOnWriteArrayList<Bullet> deadBullets = new CopyOnWriteArrayList<Bullet>(); // temp dead bullet pool
  while (it.hasNext ()) { // while there are asteroids
    Asteroid a = it.next();
    a.display(); // draw it
    // check each bullet for collisions
    for (Bullet b : gun.getBullets()) {
      checkCollision(a, b);
      if (b.isOffScreen()) deadBullets.add(b); 
      if (a.isHit()) deadBullets.add(b);
    }
    if (a.isDead()) deadAsteroids.add(a);
  } // end of while loop
  if (deadAsteroids.size() > 0) {
    asteroids.removeAll(deadAsteroids);
    deadAsteroids = new CopyOnWriteArrayList<Asteroid>();
  }
  if (deadBullets.size() > 0) {
    // println("removed " + deadBullets.size() + " bullet(s) from screen: " + deadBullets);
    gun.getBullets().removeAll(deadBullets);
    //deadBullets = new CopyOnWriteArrayList<Bullet>();
  }
}

void keyPressed() {
  if (key == ' ') gun.fire(); // fire the gun
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
  if (dist(a.x, a.y, b.location.x, b.location.y) < a.w/2) { // works with an ellipse
    a.hit(true); // asteroid was hit
  }
}

void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with id "+theEvent.getController().getId());
}
