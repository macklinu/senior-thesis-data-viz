class Asteroid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;    // Mass, tied to size
  String tweet;
  float x, y, w, h;
  boolean hit;
  boolean dead;
  float hitTime, textTime;

  Asteroid(float x, float y, float w, String tweet) {
    this.x = x;
    this.y = y;
    this.w = map(w, 0, 140, 10, 140);
    mass = map(w, 0, 140, 280, 800);
    this.tweet = tweet;
    location = new PVector(x, y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    hit = dead = false;
    textTime = 6000;
  }
  
  PVector repel(Asteroid a) {
    PVector force = PVector.sub(location, a.location);             // Calculate direction of force
    float distance = force.mag();                                 // Distance between objects
    distance = constrain(distance,1.0,10000.0);                             // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize();                                            // Normalize vector (distance doesn't matter here, we just want this vector for direction
    float strength = (g * mass * a.mass) / (distance * distance); // Calculate gravitional force magnitude
    force.mult(-1*strength);                                      // Get force vector --> magnitude * direction
    return force;
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(-0.01);
  }

  void display() {
    if (hit) {
      //tweetArea.setColor(color(225));
      //  if (millis() - hitTime > textTime) { 
      // tweetArea.setColor(color(0, 0));
      dead = true;
      // }
    }
    else {
      fill(255, 200);
      noStroke();
      ellipse(location.x, location.y, w, w);
    }
  }

  void hit(boolean b) {
    hit = b;
    hitTime = millis();
  }

  boolean isHit() {
    return hit;
  }

  boolean isDead() {
    return dead;
  }
}

