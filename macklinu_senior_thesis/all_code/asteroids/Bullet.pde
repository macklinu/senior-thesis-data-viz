class Bullet {
  PVector location;
  PVector velocity;
  float r;
  float speed;
  float dx, dy;

  Bullet(float lx, float ly, float angle) {
    speed = 5;
    // calculating angle of firing
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
    r = 3;
  }

  void update() {
    location.add(velocity);
  }

  void display() {
    // Display circle at x location
    stroke(255);
    noFill();
    ellipse(location.x, location.y, r*2, r*2);
  }

  boolean isOffScreen() {
    if (location.x+r < 0 || location.x+r > width
      || location.y+r < 0 || location.y+r > height) return true;
    else return false;
  }
}

