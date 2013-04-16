Orb orb;
PVector velocity;
float gravity = .2, damping = 0.8;
int segments;
Ground[] ground;
float[] peakHeights;

float x, y; 
int w, h; 
color c;

boolean gameSelect = true;
boolean gamePlay = false;

CSV google;
float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;

boolean touch = false;

int start = 0;
int current = 40;

void setup() {
  size(1280, 720);
  smooth();
  w = 40;
  h = 20;
  colorMode(HSB, 360);

  orb = new Orb(200, 0, 10);
  velocity = new PVector(.5, 0);

  google = new CSV(dataPath("GOOG.csv")); // load the stock file
  segments = (google.getRowCount()-1);
  println(segments);
  ground = new Ground[segments];
  peakHeights = new float[segments+1];
  // find the min and max data values
  for (int i = google.getRowCount() - 1; i > 0; i--) {
    float value = google.getFloat(i, 4);
    if (value > dataMax) dataMax = value;
    if (value < dataMin) dataMin = value;
  }

  for (int i = 1; i < google.getRowCount(); i++) {
    peakHeights[i] = google.getFloat(i, 4); // map(google.getFloat(i, 4), dataMin, dataMax, 400, 100);
  }
  /* Float value required for segment width (segs)
   calculations so the ground spans the entire 
   display window, regardless of segment number. */
  float segs = segments/32;
  for (int i=0; i<segments; i++) {
    ground[i]  = new Ground(width/segs*i, peakHeights[i], 
    width/segs*(i+1), peakHeights[i+1]);
  }

  c = color(0, 0, 0);
  // noCursor();
}

void draw() {

  background(300);
  translate(0, -300);
  // Move orb
  orb.x += velocity.x;
  velocity.y += gravity;
  orb.y += velocity.y;

  // the airplane
  fill(c);
  rect(x, y, w, h);

  fill(127);
  beginShape();
  for (int i=start; i<current; i++) {
    vertex(ground[i].x1, ground[i].y1);
    vertex(ground[i].x2, ground[i].y2);
  }
  vertex(ground[current-start].x2, height + dataMin);
  vertex(ground[start].x1, height + dataMin);
  endShape(CLOSE);

  // Draw orb
  noStroke();
  if (touch) fill(0, 360, 360);
  else fill(250);
  ellipse(orb.x, orb.y, orb.r*2, orb.r*2);

  // Collision detection
  checkWallCollision();
  for (int i=start; i<current; i++) {
    checkGroundCollision(ground[i]);
  }
}

void checkWallCollision() {
  if (orb.x > width-orb.r) {
    orb.x = width-orb.r;
    velocity.x *= -1;
    velocity.x *= damping;
  } 
  else if (orb.x < orb.r) {
    orb.x = orb.r;
    velocity.x *= -1;
    velocity.x *= damping;
  }
}


void checkGroundCollision(Ground groundSegment) {

  // Get difference between orb and ground
  float deltaX = orb.x - groundSegment.x;
  float deltaY = orb.y - groundSegment.y;

  // Precalculate trig values
  float cosine = cos(groundSegment.rot);
  float sine = sin(groundSegment.rot);

  /* Rotate ground and velocity to allow 
   orthogonal collision calculations */
  float groundXTemp = cosine * deltaX + sine * deltaY;
  float groundYTemp = cosine * deltaY - sine * deltaX;
  float velocityXTemp = cosine * velocity.x + sine * velocity.y;
  float velocityYTemp = cosine * velocity.y - sine * velocity.x;

  /* Ground collision - check for surface 
   collision and also that orb is within 
   left/rights bounds of ground segment */
  if (groundYTemp > -orb.r &&
    orb.x > groundSegment.x1 &&
    orb.x < groundSegment.x2 ) {
    // keep orb from going into ground
    groundYTemp = -orb.r;
    // bounce and slow down orb
    velocityYTemp *= -1.0;
    velocityYTemp *= damping;
    touch = true;
    // println("TOUCH");
  }

  // Reset ground, velocity and orb
  deltaX = cosine * groundXTemp - sine * groundYTemp;
  deltaY = cosine * groundYTemp + sine * groundXTemp;
  velocity.x = cosine * velocityXTemp - sine * velocityYTemp;
  velocity.y = cosine * velocityYTemp + sine * velocityXTemp;
  orb.x = groundSegment.x + deltaX;
  orb.y = groundSegment.y + deltaY;
  // touch = false;
}

void keyPressed() {
  if (keyCode == LEFT) { 
    x-= 3.2;
    x = constrain(x, 0, width); // keep x in range
  }
  if (keyCode == RIGHT) { 
    start++;
    current++;
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

