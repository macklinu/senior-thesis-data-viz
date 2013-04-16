class Button {
  String id;
  float x, y;
  
  Button(String id, float x, float y) {
    this.id = id;
    this.x = x;
    this.y = y;
  }
  
  void display() {
    fill(100, 100);
    rect(x, y, 25, 15);
    fill(255);
    textAlign(CENTER);
    textSize(10);
    text(id, x + 5, y + 5);
  }
  
}
