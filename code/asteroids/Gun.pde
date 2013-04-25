class Gun {
  ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  // CopyOnWriteArrayList<Bullet> bullets = new CopyOnWriteArrayList<Bullet>();
  PVector location; // current position on screen
  float x, y, w, h;
  float angle, a;
  float r;
  float mass;

  Gun(float x, float y) {
    this.x = x;
    this.y = y;
    location = new PVector(x, y);
    mass = 10;
    w = 10;
    h = 15;
    angle = 0;
    a = 0;
  }

  void rot(float a) {
    this.a+=a;
    if (this.a > 360) this.a %= 360.;
    if (this.a < 0) this.a += 360.;
  }

  void moveX(float mx) {
    location.x+=mx;
  }
  void moveY(float my) {
    location.y+=my;
  }

  PVector attract(Asteroid a) {
    PVector force = PVector.sub(location, a.location);   // Calculate direction of force
    float d = force.mag();                              // Distance between objects
    d = constrain(d, 5.0, 25.0);                        // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize();              // Normalize vector (distance doesn't matter here, we just want this vector for direction)
    float strength = (g * mass * a.mass) / (d * d);      // Calculate gravitional force magnitude
    force.mult(strength);                                 // Get force vector --> magnitude * direction
    return force;
  }

  void update() {
    r = radians(a)+radians(angle);
    for (Bullet b: bullets) {
      b.update();
    }
  }

  void display() {
    noFill();
    stroke(255);
    pushMatrix();
    translate(location.x, location.y);
    rotate(r);
    // ellipse(0, -h/2, 10, 10);
    triangle(0, -h/2, w/2, h/2, -w/2, h/2);
    popMatrix();
    for (Bullet b: bullets) {
      b.display();
    }
    // ellipse((x + (sin(r)*h/2)), (y + (cos(r)*-h/2)), h, h);
    // line((x + (sin(r)*h/2)), (y + (cos(r)*-h/2)), degrees(r), degrees(r));
  }

  void fire() {
    println((abs(a) % 360.));
    bullets.add(new Bullet((location.x + (sin(r)*h/2)), (location.y + (cos(r)*-h/2)), (abs(a) % 360.)));
  }

  ArrayList<Bullet> getBullets() {
    return bullets;
  }

  PVector getLocation() {
    return location;
  }
}

