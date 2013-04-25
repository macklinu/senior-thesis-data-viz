/**
 * Asteroids
 *
 * original code: https://github.com/neufuture/SimpleTwitterStream/ 
 *
 */

import java.util.*;
import controlP5.*;
import processing.serial.*;

ControlP5 cp5;
Group tweetGroup;
Textlabel instructions, keyword;
ListBox tweets;
Bang conductSearch;
Textarea tweetArea;
controlP5.Button openTweetBox;
Textfield search;
Button[] buttons = new Button[12];
Serial arduino;
Twitter tw;
Gun gun;
ArrayList<Asteroid> asteroids;
ArrayList<Asteroid> tempAsteroids;
Keyboard keyboard;
String[] buttonID = {
  "b", "y", "select", "start", "up", "down", "left", "right", "a", "x", "l", "r"
};
int[] serialInArray = new int[17]; // length: 17 = (255 start byte) + 16 byte controller message
int serialCount;
long masterTime, masterTimeBetween; // for time between button presses
int shift = 0;
int toggle = 0;
boolean introScreen = true;

float g = 1;
String textValue = "";
String allTweets = "";
boolean showSearchBox = false;
color twitterBlue; // = color(191, 360*.76, 360*.92);

void setup() {
  frame.setBackground(new java.awt.Color(20, 20, 20));
  size(960/2 + 300, 720/2);
  colorMode(HSB, 360);
  smooth();

  twitterBlue = color(207, 360*.80, 360*.92);

  createUI();
  println(Serial.list());
  arduino = new Serial(this, Serial.list()[4], 57600);
  for (int i = 0; i < buttons.length; i++) {
    buttons[i] = new Button(buttonID[i]);
  }
  tw = new Twitter();
  gun = new Gun(width/2, height/2);
  asteroids = new ArrayList<Asteroid>();
  tempAsteroids = new ArrayList<Asteroid>();
  keyboard = new Keyboard();
}

void createUI() {
  cp5 = new ControlP5(this);
  cp5.setControlFont(createFont("Roboto", 20, true), 12);

  tweetArea = cp5.addTextarea("tweetArea")
    .setPosition(width-250, 50)
      .setSize(240, height-60)
        .setLineHeight(14)
          .setColor(color(235))
            .setColorBackground(color(255, 175))
              .setColorForeground(color(255, 175))
                ;

  keyword = cp5.addTextlabel("keyword")
    .setPosition(width-250 + 25, 20)
      .setColorValueLabel(twitterBlue)
        ;

  keyword.valueLabel().align(ControlP5.LEFT, ControlP5.CENTER);

  PImage[] icons = {
    loadImage("twitter_16_off.jpg"), loadImage("twitter_16_rollover.jpg"), loadImage("twitter_16_on.jpg")
    }
    ;

  openTweetBox = cp5.addButton("openTweetBox")
    .setImages(icons)
      .setPosition(width-250+5, 20)
        .updateSize()
          ;
  cp5.addTextlabel("click to open search box")
    .setPosition(60, 100)
      .setColorValueLabel(twitterBlue)
        ;

  openTweetBox.captionLabel().hide();

  search = cp5.addTextfield("search")
    .setPosition(width-250 + 25, 18)
      .setSize(125, 20)
        .setColorBackground(color(60)) 
          .setColorActive(twitterBlue) 
            .setColorForeground(color(60))
              //.setFont(createFont("arial",20))
              .setAutoClear(true);

  search.captionLabel().hide();

  conductSearch = cp5.addBang("conductSearch")
    .setPosition(search.getPosition().x + search.getWidth() + 10, search.getPosition().y)
      .setSize(50, 20)
        ;
  conductSearch.captionLabel()
    .setText("search")
      .setFont(createFont("Roboto", 9))
        .align(ControlP5.CENTER, ControlP5.CENTER)
          ;  

  /*
  instructions = cp5.addTextlabel("instructions")
   .setText("press \"t\" to search twitter")
   .setPosition(10, 10)
   ;
   */
}

public void search(String text) {
  // automatically receives results from controller input
  search.setFocus(false);
  showSearchBox = false;
  search.hide();
  conductSearch.hide();
  tw.setKeywords(text);
  keyword.setText(tw.getKeyword());
}

void draw() {
  readController();
  background(0);
  if (introScreen) {
    openTweetBox.hide();
    search.hide();
    tweetArea.hide();
    conductSearch.hide();
    textAlign(CENTER);
    text("Asteroids", width/2, height/2-50);
    text("A Twitter visualization", width/2, height/2 + 20 -50);
    text("Press START to enter", width/2, height/2);
    if (buttons[3].clicked()) introScreen = false;
  }
  if (!introScreen) {
    openTweetBox.show();
    tweetArea.show();
    if (showSearchBox) {
    }
    else {
      search.hide();
      conductSearch.hide();
    }
    if (!search.isActive()) {
      // rotate gun
      // keyboard.check(gun);
      if (buttons[8].clicked()) gun.fire();
      if (buttons[4].held()) gun.moveY(-1); 
      if (buttons[7].held()) gun.moveX(1); 
      if (buttons[5].held()) gun.moveY(1); 
      if (buttons[6].held()) gun.moveX(-1); 
      if (buttons[10].held()) gun.rot(-PI);
      if (buttons[11].held()) gun.rot(PI);
      gun.update();
    }
    // move and draw the gun

    gun.display();
    // iterate through on screen asteroids
    ListIterator<Asteroid> it = asteroids.listIterator();
    List<Bullet> activeBullets = gun.getBullets();
    List<Asteroid> deadAsteroids = new ArrayList<Asteroid>(); // temp dead asteroid pool
    List<Bullet> deadBullets = new ArrayList<Bullet>(); // temp dead bullet pool
    while (it.hasNext ()) { // while there are asteroids
      Asteroid a = it.next(); // a = the asteroid we're looking at
      // check each bullet for collisions
      for (Bullet b : activeBullets) {
        checkCollision(a, b);
        if (b.isOffScreen()) deadBullets.add(b); 
        if (a.isHit()) { 
          deadBullets.add(b);
          allTweets += a.getTweet() + "\n\n";
          tweetArea.setText(allTweets).scroll(1); // scroll down the list as new tweets are populated
        }
      }
      if (a.isDead()) deadAsteroids.add(a);
      PVector aForce = a.repel(a);
      a.applyForce(aForce);
      PVector force = gun.attract(a);
      // a.applyForce(force);
      a.update();
      a.display(); // draw the asteroid
    } // end of while loop
    if (deadAsteroids.size() > 0) asteroids.removeAll(deadAsteroids);
    if (deadBullets.size() > 0) activeBullets.removeAll(deadBullets);
    if (tempAsteroids.size() > 0) { 
      for (int i = 0; i < tempAsteroids.size(); i++) {
        Asteroid temp = tempAsteroids.get(i);
        asteroids.add(new Asteroid(temp));
        println(tempAsteroids.size());
        tempAsteroids = new ArrayList<Asteroid>();
        println(tempAsteroids.size());
      }
    }
  }
}

void mousePressed() {
  // introScreen = false;
}

void keyPressed() {
  if (key == '=') saveFrame("screenshots/"+timestamp()+".png");
  if (keyCode == TAB) shift++;
  if (!search.isActive()) {
    if (key == ' ') gun.fire(); // fire the gun }
    if (shift % 2 == 0 && shift !=0) { 
      showSearchBox = true;
      search.show();
      search.setFocus(true);
    }
    if (shift % 4 == 0 && shift !=0) {
      showSearchBox = false;
      search.hide();
      shift = 0;
    }
  }
  // deal with keyboard controls (for now)
  // keyboard.pressed();
}

void keyReleased() {  
  // keyboard.released();
}

void checkCollision(Asteroid a, Bullet b) {
  if (dist(a.location.x, a.location.y, b.location.x, b.location.y) < a.w/2) { // works with an ellipse
    a.hit(true); // asteroid was hit
  }
}

void controlEvent(ControlEvent theEvent) {
  // some toggle code when the twitter icon is clicked
  if (theEvent.isFrom(openTweetBox)) {
  }
}

public void conductSearch() {
  // automatically receives results from controller input
  search.setFocus(false);
  showSearchBox = false;
  search.hide();
  conductSearch.hide();
  tw.setKeywords(search.getText());
  println(search.getText());
  keyword.setText(tw.getKeyword());
  // toggle = 0;
  // shift = 0;
}

public void openTweetBox() {
  println(openTweetBox.value());
  showSearchBox = true;
  search.show();
  search.setFocus(true);
  conductSearch.show();
}

String timestamp() {
  String currentTime = str(year()) 
    + nf(month(), 2)
      + nf(day(), 2)
        + "_"
          + nf(hour(), 2)
          + nf(minute(), 2)
            + nf(second(), 2);
  return currentTime;
}

// each incoming serial message...
void serialEvent(Serial arduino) {
  int inByte = arduino.read();
  if (inByte == 255) serialCount = 0; // 255 inByte signifies the beginning of the serial string
  // set incoming byte into a temporary array and move through it
  // these values will be reassigned
  serialInArray[serialCount] = inByte;
  serialCount++;

  if (serialCount > serialInArray.length - 1) {
    // reset the serial count to receive the next message
    serialCount = 0;
  }
}

void readController() {
  for (int i = 0; i < buttons.length; i++) {
    buttons[i].set(serialInArray[i+1]);
  }
}

