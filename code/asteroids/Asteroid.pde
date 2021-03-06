class Asteroid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
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
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    hit = dead = false;
    textTime = 6000;
  }

  Asteroid(Asteroid a) {
    this.x = a.x;
    this.y = a.y;
    this.w = map(a.w, 0, 140, 10, 140);
    mass = map(a.w, 0, 140, 280, 800);
    this.tweet = a.tweet;
    location = new PVector(a.x, a.y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    hit = dead = false;
    textTime = 6000;
  }

  PVector repel(Asteroid a) {
    PVector force = PVector.sub(location, a.location); // Calculate direction of force
    float distance = force.mag(); // Distance between objects
    distance = constrain(distance, 1.0, 10000.0); // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize(); // Normalize vector (distance doesn't matter here, we just want this vector for direction
    float strength = (g * mass * a.mass) / (distance * distance); // Calculate gravitional force magnitude
    force.mult(-1*strength); // Get force vector --> magnitude * direction
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
      // want to implement a time system to display tweets in the asteroid field instead of a textbox
      dead = true;
    }
    else {
      stroke(255);
      noFill();
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
  
  String getTweet() {
    return tweet;
  }
}

