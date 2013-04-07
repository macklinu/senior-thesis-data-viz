// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// PBox2D example

// An uneven surface boundary

class Surface {
  // We'll keep track of all of the surface points
  ArrayList<Vec2> surface;

  CSV google;

  float dataMin = MAX_FLOAT;
  float dataMax = MIN_FLOAT;

  Surface() {
    surface = new ArrayList<Vec2>();

    // This is what box2d uses to put the surface in its world
    ChainShape chain = new ChainShape();

    // Perlin noise argument
    float xoff = 0.0;

    google = new CSV(dataPath("GOOG.csv")); // load the stock file
    // find the min and max data values
    for (int i = google.getRowCount() - 1; i > 0; i--) {
      float value = google.getFloat(i, 4);
      if (value > dataMax) {
        dataMax = value;
      }
      if (value < dataMin) {
        dataMin = value;
      }
    }

    // step through the stock data and create a surface from it
    for (int i = google.getRowCount() - 1; i > 0; i--) {
      if (i < google.getRowCount() - 1) {
        float x = map(i, 0, google.getRowCount(), -40, width+40);
        float y = map(google.getFloat(i, 4), dataMin, dataMax, 400, 100);
        // Store the vertex in screen coordinates
        surface.add(new Vec2(x, y));
      }
    }

    // Build an array of vertices in Box2D coordinates
    // from the ArrayList we made
    Vec2[] vertices = new Vec2[surface.size()];
    for (int i = 0; i < vertices.length; i++) {
      Vec2 edge = box2d.coordPixelsToWorld(surface.get(i));
      vertices[i] = edge;
    }

    // Create the chain!
    chain.createChain(vertices, vertices.length);

    // The edge chain is now attached to a body via a fixture
    BodyDef bd = new BodyDef();
    bd.position.set(0.0f, 0.0f);
    Body body = box2d.createBody(bd);
    // Shortcut, we could define a fixture if we
    // want to specify frictions, restitution, etc.
    body.createFixture(chain, 1);
  }
  
  boolean getCollision(float mx, float my, float range) {
    for (Vec2 v: surface) {
      if (dist(mx, my, v.x, v.y) < range) return true;
    }
    return false;
  }

  // A simple function to just draw the edge chain as a series of vertex points
  void display() {
    strokeWeight(2);
    stroke(0);
    noFill();
    beginShape();
    for (Vec2 v: surface) {
      vertex(v.x, v.y);
    }
    endShape();
  }
}

