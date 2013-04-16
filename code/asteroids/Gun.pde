class Gun {
  // ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  CopyOnWriteArrayList<Bullet> bullets = new CopyOnWriteArrayList<Bullet>();
  float x, y, w, h;
  float angle, a;
  float r;

  Gun(float x, float y) {
    this.x = x;
    this.y = y;
    w = 10;
    h = 15;
    angle = 0;
    a = 0;
  }

  void rot(float a) {
    this.a+=a;
  }
  
  void moveX(float mx) {
    x+=mx;
  }
  void moveY(float my) {
    y+=my;
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
    translate(x, y);
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
    bullets.add(new Bullet((x + (sin(r)*h/2)), (y + (cos(r)*-h/2))));
  }
  
  CopyOnWriteArrayList<Bullet> getBullets() { // = new CopyOnWriteArrayList<Bullet>();
  //ArrayList<Bullet> getBullets() {
    return bullets;
  }
}

