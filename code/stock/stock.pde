import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.*;

PBox2D box2d;
Surface surface;
// An ArrayList of particles that will fall on the surface
ArrayList<Particle> particles;

float x, y; 
int w, h; 
color c;

boolean gameSelect = true;
boolean gamePlay = false;

void setup() {
  size(500, 500);
  smooth();
  w = 40;
  h = 20;
  colorMode(HSB, 360);

  // Initialize box2d physics and create the world
  box2d = new PBox2D(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -20);

  // Create the empty list
  particles = new ArrayList<Particle>();

  // Create the surface
  surface = new Surface();
  
  c = color(0, 0, 0);
}

void draw() {
  if (mousePressed) {
    float sz = random(2, 6);
    particles.add(new Particle(mouseX, mouseY, sz));
  }
  // We must always step through time!
  box2d.step();

  background(300);
  if (gameSelect) {
  }
  if (gamePlay) {
  }

  // Draw the surface
  if (surface.getCollision(x, y, 3.2)) c = color(0, 255, 255);
  else c = color(0);
  surface.display();
  
  fill(c);
  rect(x, y, w, h);

  // Draw all particles
  for (Particle p: particles) {
    p.display();
  }

  // Particles that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    if (p.done()) {
      particles.remove(i);
    }
  }
}

void keyPressed() {
  if (keyCode == LEFT) { 
    x-= 3.2;
    x = constrain(x, 0, width); // keep x in range
  }
  if (keyCode == RIGHT) { 
    x+= 3.2;
    x = constrain(x, 0, width); // keep x in range
  }
  if (keyCode == UP) { 
    y-= 3.2;
    y = constrain(y, 0, width); // keep x in range
  }
  if (keyCode == DOWN) { 
    y+= 3.2;
    y = constrain(y, 0, width); // keep x in range
  }
}

