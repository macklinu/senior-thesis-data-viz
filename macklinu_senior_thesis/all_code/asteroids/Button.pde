class Button {
  String id; // controller button name
  int reading, lastReading; // current and previous button press readings
  long time, timeBetween; // to determine

  Button(String id) {
    this.id = id;
    time = millis();
  }

  boolean clicked() {
    boolean clicked;
    // if the previous button state has changed and is now 1, that means the button was clicked
    if ((reading != lastReading) && (reading == 1)) clicked = true;
    else clicked = false;
    lastReading = reading; // update the previous button state
    return clicked;
  }

  boolean held() {
    if (reading == 1) return true;
    else return false;
  }
  
  void set(int button) {
    reading = button;
  }
}

