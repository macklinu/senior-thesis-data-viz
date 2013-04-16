/**
 * Asteroids
 *
 * original code: https://github.com/neufuture/SimpleTwitterStream/ 
 *
 */

import java.util.Iterator;
import java.util.concurrent.CopyOnWriteArrayList; 

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
  noStroke();
  imageMode(CENTER);

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
  gun.update();
  gun.display();
  Iterator<Asteroid> it = asteroids.iterator();
  CopyOnWriteArrayList<Asteroid> tempA = new CopyOnWriteArrayList<Asteroid>();
  CopyOnWriteArrayList<Bullet> tempB = new CopyOnWriteArrayList<Bullet>();
  while (it.hasNext ()) {
    Asteroid a = it.next();
    a.display();
    for (Bullet b : gun.getBullets()) {
      checkCollision(a, b);
      if (b.isOffScreen()) {
        tempB.add(b);
      }
      if (a.isHit()) {
        tempA.add(a);
        tempB.add(b);
      }
    }
  }
  if (tempA.size() > 0) {
    asteroids.removeAll(tempA);
    tempA = new CopyOnWriteArrayList<Asteroid>();
    
  }
  if (tempB.size() > 0) {
    println("removed " + tempB.size() + " bullet(s) from screen: " + tempB);
    gun.getBullets().removeAll(tempB);
    tempB = new CopyOnWriteArrayList<Bullet>();
  }
}

void keyPressed() {
  if (key == ' ') gun.fire();
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
  if (dist(a.x, a.y, b.location.x, b.location.y) < a.w/2) { 
    a.hit(true);
  }
}

