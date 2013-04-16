import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;

RPoint[] groundPoints, ceilingPoints;
RShape ground, ceiling;

boolean touch;
int totalWidth;
int tx;

void setup() {
  size(500, 500);
  smooth();
  RG.init(this);
  groundPoints = ceilingPoints = new RPoint[500];
  totalWidth = groundPoints.length * 40; 
  println(totalWidth);
  createGround();
  createCeiling();
  noCursor();
}

void draw() {
  background(150);
  pushMatrix();
  translate(tx, 0);
  if (!touch) {
    // Draw the shape
    if (touch) fill(255, 0, 0, 200);
    else fill(0, 200);
    noStroke();
    RG.shape(ground);
    RG.shape(ceiling);

    if (mouseX != 0 && mouseY !=0 ) {
      // Create and draw a cutting line
      fill(220);
      stroke(255);
      // RShape rect;
      RShape rect = RShape.createRectangle((float)mouseX - tx, (float)mouseY, (float)20, (float)10);
      RG.shape(rect);

      fill(100, 200);
      noStroke();
      // Get the intersection points
      RPoint[] groundPs = ground.getIntersections(rect);
      RPoint[] ceilingPs = ceiling.getIntersections(rect);
      if (groundPs != null || ceilingPs != null) {
        touch = true;
      }
    }
  }
  popMatrix();
  println(frameRate);
}

void keyPressed() {
  if (key == ' ') {
    createGround();
    createCeiling();
    touch = false;
  }
  if (keyCode == RIGHT) tx -= 40;
}

void createGround() {
  groundPoints[0] = new RPoint(0, height);
  for (int i = 1; i < groundPoints.length - 1; i++) {
    groundPoints[i] = new RPoint(width/40*i, random(350, 450));
  }
  groundPoints[groundPoints.length - 1] = new RPoint(width, height);
  ground = new RShape(new RPath(groundPoints));
}

void createCeiling() {
  ceilingPoints[0] = new RPoint(0, 0);
  for (int i = 1; i < ceilingPoints.length - 1; i++) {
    ceilingPoints[i] = new RPoint(width/40*i, random(50, 150));
  }
  ceilingPoints[ceilingPoints.length - 1] = new RPoint(width, 0);
  ceiling = new RShape(new RPath(ceilingPoints));
}

