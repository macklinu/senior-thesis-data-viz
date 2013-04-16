class Bullet {
  PVector location;
  PVector velocity;
  float d;
  float speed;
  float dx, dy;

  Bullet(float lx, float ly, float angle) {
    speed = 3;
    if (angle >= 0 && angle <= 90) {
      dx = map(angle, 0, 90, 0, 1);
      dy = map(angle, 0, 90, -1, 0);
    }
    else if (angle >= 90 && angle <= 180) {
      dx = map(angle, 90, 180, 1, 0);
      dy = map(angle, 90, 180, 0, 1);
    }
    else if (angle >= 180 && angle <= 270) {
      dx = map(angle, 180, 270, 0, -1);
      dy = map(angle, 180, 270, 1, 0);
    }
    else if (angle >= 270 && angle <= 360) {
      dx = map(angle, 270, 360, -1, 0);
      dy = map(angle, 270, 360, 0, -1);
    }
    location = new PVector(lx, ly);
    velocity = new PVector(dx * speed, dy * speed);
    // println("new bullet created" + "\t" + lx + ", " + ly);
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

