/**
 * Asteroids
 *
 * A real-time Twitter visualization paying homage to Atari's Asteroids
 *
 * Twitter Streaming API 
 * https://github.com/neufuture/SimpleTwitterStream/ 
 * +
 * http://twitter4j.org/en/index.html
 *
 */

// imports
import java.util.*;
import controlP5.*;
import processing.serial.*;

// create objects
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
// global variables
String[] buttonID = {
  "b", "y", "select", "start", "up", "down", "left", "right", "a", "x", "l", "r"
};
int[] serialInArray = new int[17]; // length: 17 = (255 start byte) + 16 byte controller message
int serialCount;
boolean introScreen = true;
boolean SNESController = false; // if using a SNES controller
float g = 1;
String textValue = "";
String allTweets = "";
boolean showSearchBox = false;
color twitterBlue;
PFont p;

void setup() {
  frame.setBackground(new java.awt.Color(20, 20, 20));
  size(960/2 + 300, 720/2);
  colorMode(HSB, 360);
  smooth();
  createUI();
  p = loadFont("Roboto-Medium.vlw");
  if (SNESController) {
    println(Serial.list());
    arduino = new Serial(this, Serial.list()[4], 57600);
  }
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
  cp5 = new ControlP5(this); // ControlP5 init
  PFont font = loadFont("Roboto-Medium.vlw");
  PFont searchFont = loadFont("Roboto-9.vlw");
  cp5.setControlFont(font, 12); // main font will be Roboto
  // create text box that will contain tweets
  twitterBlue = color(207, 360*.80, 360*.92); // main blue color
  tweetArea = cp5.addTextarea("tweetArea")
    .setPosition(width-250, 50)
      .setSize(240, height-60)
        .setLineHeight(14)
          .setColor(color(235))
            .setColorBackground(color(255, 175))
              .setColorForeground(color(255, 175));
  // when a search is conducted, this word will appear in blue to show the current search term
  keyword = cp5.addTextlabel("keyword")
    .setPosition(width-250 + 25, 20)
      .setColorValueLabel(twitterBlue);
  keyword.valueLabel().align(ControlP5.LEFT, ControlP5.CENTER);
  // create the Twitter icon button to open the search box
  PImage[] icons = {
    loadImage("twitter_16_off.jpg"), loadImage("twitter_16_rollover.jpg"), loadImage("twitter_16_on.jpg")
    };
    openTweetBox = cp5.addButton("openTweetBox")
      .setImages(icons)
        .setPosition(width-250+5, 20)
          .updateSize();
  cp5.addTextlabel("click to open search box")
    .setPosition(60, 100)
      .setColorValueLabel(twitterBlue);
  openTweetBox.captionLabel().hide();
  // create the search box
  search = cp5.addTextfield("search")
    .setPosition(width-250 + 25, 18)
      .setSize(125, 20)
        .setColorBackground(color(60)) 
          .setColorActive(twitterBlue) 
            .setColorForeground(color(60))
              .setAutoClear(true);
  search.captionLabel().hide();
  // the "SEARCH" button
  conductSearch = cp5.addBang("conductSearch")
    .setPosition(search.getPosition().x + search.getWidth() + 10, search.getPosition().y)
      .setSize(50, 20);
  conductSearch.captionLabel()
    .setText("search")
      .setFont(searchFont)
        .align(ControlP5.CENTER, ControlP5.CENTER);
}

void draw() {
  if (SNESController) {
    // read the SNES controller if using it
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].set(serialInArray[i+1]);
    }
  }
  background(0);
  // draw the intro screen
  if (introScreen) {
    openTweetBox.hide();
    search.hide();
    tweetArea.hide();
    conductSearch.hide();
    textAlign(CENTER);
    textFont(p);
    textSize(14);
    text("Asteroids", width/2, height/2-50);
    text("A Twitter visualization", width/2, height/2 + 20 -50);
    if (SNESController) { 
      text("Press START to begin", width/2, height/2);
    }
    else { 
      text("Click the mouse to begin", width/2, height/2);
      text("wasd - up / left / down / right", width/2, height/2 +40);
      text("jk - rotate gun", width/2, height/2+60);
      text("spacebar - fire gun", width/2, height/2+80);
    }
    if (SNESController) { 
      if (buttons[3].clicked()) introScreen = false;
    }
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
      if (SNESController) { 
        if (buttons[8].clicked()) gun.fire();
        if (buttons[4].held()) gun.moveY(-gun.amt); 
        if (buttons[7].held()) gun.moveX(gun.amt); 
        if (buttons[5].held()) gun.moveY(gun.amt); 
        if (buttons[6].held()) gun.moveX(-gun.amt); 
        if (buttons[10].held()) gun.rot(-PI);
        if (buttons[11].held()) gun.rot(PI);
      }
      else {
        keyboard.check(gun);
      }
      // move the gun
      gun.update();
    }
    // draw the gun
    gun.display();
    // iterate through on screen asteroids
    ListIterator<Asteroid> it = asteroids.listIterator(); // all on-screen asteroids
    List<Bullet> activeBullets = gun.getBullets(); // current on-screen bullets
    List<Asteroid> deadAsteroids = new ArrayList<Asteroid>(); // temp dead asteroid pool
    List<Bullet> deadBullets = new ArrayList<Bullet>(); // temp dead bullet pool
    while (it.hasNext()) { // while there are asteroids
      Asteroid a = it.next(); // a = the asteroid we're looking at
      // check each bullet for collisions
      for (Bullet b : activeBullets) {
        checkCollision(a, b);
        if (b.isOffScreen()) deadBullets.add(b); // if the bullet leaves the screen
        if (a.isHit()) { // if the asteroid is hit
          deadBullets.add(b);
          allTweets += a.getTweet() + "\n\n"; // add tweet to tweet text box on the right side of the screen
          tweetArea.setText(allTweets).scroll(1); // scroll down the list as new tweets are populated
        }
      }
      if (a.isDead()) deadAsteroids.add(a);
      // apply gravitational force to the asteroids and gun
      PVector aForce = a.repel(a);
      a.applyForce(aForce);
      PVector force = gun.attract(a);
      a.applyForce(force);
      a.update(); // update the asteroid
      a.display(); // draw the asteroid
    } // end of while loop
    if (deadAsteroids.size() > 0) asteroids.removeAll(deadAsteroids);
    if (deadBullets.size() > 0) activeBullets.removeAll(deadBullets);
    // this is actually where the on-screen asteroids are created
    // this method prevents concurrent modification/iteration
    if (tempAsteroids.size() > 0) { 
      for (int i = 0; i < tempAsteroids.size(); i++) {
        Asteroid temp = tempAsteroids.get(i); // get the temp asteroid
        asteroids.add(new Asteroid(temp)); // create a new asteroid with the temporary asteroid's exact same properties
        tempAsteroids = new ArrayList<Asteroid>(); // clear the tempAsteroids pool since we've added them to the main asteroid pool
      }
    }
  }
}

///////////////////////////////
// mouse and keyboard events //
///////////////////////////////

void mousePressed() {
  if (!SNESController) introScreen = false; // click the mouse to start
}

void keyPressed() {
  // if (key == '=') saveFrame("screenshots/"+timestamp()+".png");
  if (!search.isActive()) {
    if (!SNESController) { 
      if (key == ' ') { 
        gun.fire(); // fire the gun
      }
    }
  }
  // deal with keyboard controls (for now)
  if (!SNESController) keyboard.pressed();
}

void keyReleased() {  
  // deal with keyboard controls (for now)
  if (!SNESController) keyboard.released();
}

void checkCollision(Asteroid a, Bullet b) {
  if (dist(a.location.x, a.location.y, b.location.x, b.location.y) < a.w/2) { // works with an ellipse
    a.hit(true); // asteroid was hit
  }
}

/////////////////////////////
// controlp5 event methods //
/////////////////////////////

public void conductSearch() {
  search.setFocus(false);
  showSearchBox = false;
  search.hide();
  conductSearch.hide();
  tw.setKeywords(search.getText());
  keyword.setText(tw.getKeyword());
}

public void openTweetBox() {
  showSearchBox = true;
  search.show();
  search.setFocus(true);
  conductSearch.show();
}

public void search(String text) {
  search.setFocus(false);
  showSearchBox = false;
  search.hide();
  conductSearch.hide();
  tw.setKeywords(text);
  keyword.setText(tw.getKeyword());
}

////////////
// serial //
////////////

// each incoming serial message
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

//////////
// misc //
//////////

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

