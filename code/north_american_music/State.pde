class State {
  State first, second;
  ArrayList<Circle> circles;
  PShape shape, star;
  String id;
  int x, y;
  float epiX, epiY;
  color c;
  float circleSize;
  float starScale;  
  float firstTime, secondTime;

  State(String id, int x, int y, float epiX, float epiY, float circleSize, color c) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.epiX = epiX;
    this.epiY = epiY;
    this.circleSize = circleSize;
    this.c = c;

    circles = new ArrayList<Circle>();

    // create a star shape
    star = createShape();
    star.beginShape();
    star.noStroke();
    star.fill(c);
    star.vertex(0, -50);
    star.vertex(14, -20);
    star.vertex(47, -15);
    star.vertex(23, 7);
    star.vertex(29, 40);
    star.vertex(0, 25);
    star.vertex(-29, 40);
    star.vertex(-23, 7);
    star.vertex(-47, -15);
    star.vertex(-14, -20);
    star.endShape(CLOSE);

    starScale = 0.1;
  }

  void display() {
    // if there are any created circles
    // check them all and display them accordingly
    Iterator<Circle> it = circles.iterator();
    while (it.hasNext ()) {
      Circle c = it.next();
      c.display();
      if (c.isCompleted()) it.remove();
    }
    // draw the university's location with a star
    pushMatrix();
    scale(starScale);
    translate(epiX/starScale, epiY/starScale);
    shape(star);
    popMatrix();
  }

  void addCircle(State first, State second, float firstTime, float secondTime) {
    this.first = first;
    this.second = second;
    this.firstTime = firstTime;
    this.secondTime = secondTime;

    circles.add(new Circle(epiX, epiY, circleSize, c, this, first, second));
  }
}

