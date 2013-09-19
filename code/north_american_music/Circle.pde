class Circle {
  color c;
  float x, y;
  float radius;
  int numWaves;
  float startX, startY, firstX, firstY, secondX, secondY;
  State start, first, second;
  Ani firstAni, secondAni, ghostAni;
  float firstTime, secondTime;
  float ghost;
  float strokeAlpha, fillAlpha;
  float firstDest, secondDest;
  boolean complete;

  Circle(float x, float y, float radius, color c, State start, State first, State second) {
    // initialize variables for each circle
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.c = c;
    this.start = start;
    this.first = first;
    this.second = second;
    this.firstTime = start.firstTime;
    this.secondTime = start.secondTime;
    strokeAlpha = 200;
    fillAlpha = 20;
    firstDest = dist(start.epiX, start.epiY, first.epiX, first.epiY);
    secondDest = dist(start.epiX, start.epiY, second.epiX, second.epiY);
    complete = false;

    // begin the animation upon creation
    animate();
  }

  void animate() {
    // the first animation increases the radius of the circle from the starting point to the  1st city reached
    firstAni = new Ani(this, toSeconds(firstTime), "radius", firstDest, Ani.LINEAR, "onEnd:nextAni");
  }

  private void nextAni() {
    // the second animation increases the radius of the circle from the 1st city reached to its final destination
    println(start.id + " made it to: " + first.id);
    // update the circle's radius to reflect making it to the first city
    radius = dist(start.epiX, start.epiY, first.epiX, first.epiY);
    // animate the circle radius to the next city
    secondAni = new Ani(this, toSeconds(secondTime - firstTime), "radius", secondDest, Ani.LINEAR, "onEnd:alphaAni");
  }

  private void alphaAni() {
    // once a sound has reached the furthest destination,
    // fade out the stroke and fill colors until it disappears
    Ani.to(this, 5, "strokeAlpha:0,fillAlpha:0", Ani.LINEAR, "onEnd:finishAni");
  }

  private void finishAni() {
    // once the circle disappears, stop drawing the circle
    println(start.id + " made it to: " + second.id);
    complete = true;
  }

  // to check whether or not to remove the circle from screen once it's reached its destination
  boolean isCompleted() {
    return complete;
  }

  // convert ms to sec for the Ani library
  private float toSeconds(float ms) {
    return ms / 1000.0;
  }

  void display() {
    ellipseMode(RADIUS);
    strokeWeight(1.25);
    stroke(c, strokeAlpha);
    fill(c, fillAlpha);
    ellipse(x, y, radius, radius);
    // draw some text
    // drawText();
  }

  private void drawText() {
    fill(0);
    textSize(7);
    text(nf((firstAni.getPosition() / dist(start.epiX, start.epiY, first.epiX, first.epiY)) * 100.0, 0, 2) + "% to " + first.id, x, y);
    if (secondAni != null) text(nf((secondAni.getPosition() / dist(start.epiX, start.epiY, second.epiX, second.epiY)) * 100.0, 0, 2) + "% to " + second.id, x, y + 12);
    else text(nf((firstAni.getPosition() / dist(start.epiX, start.epiY, second.epiX, second.epiY)) * 100.0, 0, 2) + "% to " + second.id, x, y + 12);
  }
}

