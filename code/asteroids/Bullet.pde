class Bullet {
  PVector location;
  PVector velocity;
  float d;

  Bullet(float x, float y) {
    location = new PVector(x, y);
    velocity = new PVector(0, -5.75);
    println("new bullet created" + "\t" + x + ", " + y);
    d = 10;
  }

  void update() {
    location.add(velocity);
  }

  void display() {
    // Display circle at x location
    //noStroke(0);
    fill(175, 150);
    ellipse(location.x, location.y, d, d);
  }

  boolean isOffScreen() {
    if (location.x+d/2 < 0 || location.x+d/2 > width
      || location.y+d/2 < 0 || location.y+d/2 > height) return true;
    else return false;
  }
}

