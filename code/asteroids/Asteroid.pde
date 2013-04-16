class Asteroid {
  float x, y, w, h;
  boolean hit;

  Asteroid(float x, float y, float w) {
    this.x = x;
    this.y = y;
    this.w = w;
    
    hit = false;
  }

  void display() {
    fill(255, 50);
    ellipse(x, y, w, w);
  }
  
  void hit(boolean b) {
    hit = b;
  }
  
  boolean isHit() {
    return hit;
  }
}

