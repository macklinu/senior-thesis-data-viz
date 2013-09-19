import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import controlP5.*; 
import processing.serial.*; 

import twitter4j.examples.block.*; 
import twitter4j.examples.trends.*; 
import twitter4j.conf.*; 
import twitter4j.json.*; 
import twitter4j.internal.async.*; 
import twitter4j.internal.logging.*; 
import twitter4j.api.*; 
import twitter4j.internal.json.*; 
import twitter4j.examples.friendsandfollowers.*; 
import twitter4j.*; 
import twitter4j.examples.directmessage.*; 
import twitter4j.media.*; 
import twitter4j.examples.list.*; 
import twitter4j.examples.stream.*; 
import twitter4j.examples.search.*; 
import twitter4j.examples.friendship.*; 
import twitter4j.examples.timeline.*; 
import twitter4j.util.*; 
import twitter4j.examples.tweets.*; 
import twitter4j.examples.user.*; 
import twitter4j.examples.async.*; 
import twitter4j.examples.help.*; 
import twitter4j.examples.media.*; 
import twitter4j.auth.*; 
import twitter4j.internal.util.*; 
import twitter4j.examples.account.*; 
import twitter4j.examples.geo.*; 
import twitter4j.internal.http.*; 
import twitter4j.examples.spamreporting.*; 
import twitter4j.examples.oauth.*; 
import twitter4j.examples.favorite.*; 
import twitter4j.examples.json.*; 
import twitter4j.examples.notification.*; 
import twitter4j.examples.listsubscribers.*; 
import twitter4j.management.*; 
import twitter4j.examples.listmembers.*; 
import twitter4j.examples.savedsearches.*; 
import twitter4j.examples.legal.*; 
import twitter4j.internal.org.json.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class asteroids extends PApplet {

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
int twitterBlue;

public void setup() {
  frame.setBackground(new java.awt.Color(20, 20, 20));
  size(960/2 + 300, 720/2);
  colorMode(HSB, 360);
  smooth();
  createUI();
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

public void createUI() {
  cp5 = new ControlP5(this); // ControlP5 init
  PFont font = loadFont("Roboto-Medium.vlw");
  PFont searchFont = loadFont("Roboto-9.vlw");
  cp5.setControlFont(font, 12); // main font will be Roboto
  // create text box that will contain tweets
  twitterBlue = color(207, 360*.80f, 360*.92f); // main blue color
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

public void draw() {
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
    text("Asteroids", width/2, height/2-50);
    text("A Twitter visualization", width/2, height/2 + 20 -50);
    if (SNESController) text("Press START to begin", width/2, height/2);
    else text("Click the mouse to begin", width/2, height/2);
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
        if (buttons[4].held()) gun.moveY(-1); 
        if (buttons[7].held()) gun.moveX(1); 
        if (buttons[5].held()) gun.moveY(1); 
        if (buttons[6].held()) gun.moveX(-1); 
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
    while (it.hasNext ()) { // while there are asteroids
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

public void mousePressed() {
  if (!SNESController) introScreen = false; // click the mouse to start
}

public void keyPressed() {
  if (key == '=') saveFrame("screenshots/"+timestamp()+".png");
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

public void keyReleased() {  
  // deal with keyboard controls (for now)
  if (!SNESController) keyboard.released();
}

public void checkCollision(Asteroid a, Bullet b) {
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
public void serialEvent(Serial arduino) {
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

public String timestamp() {
  String currentTime = str(year()) 
  + nf(month(), 2)
  + nf(day(), 2)
  + "_"
  + nf(hour(), 2)
  + nf(minute(), 2)
  + nf(second(), 2);
  return currentTime;
}
class Asteroid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  String tweet;
  float x, y, w, h;
  boolean hit;
  boolean dead;
  float hitTime, textTime;

  Asteroid(float x, float y, float w, String tweet) {
    this.x = x;
    this.y = y;
    this.w = map(w, 0, 140, 10, 140);
    mass = map(w, 0, 140, 280, 800);
    this.tweet = tweet;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    hit = dead = false;
    textTime = 6000;
  }

  Asteroid(Asteroid a) {
    this.x = a.x;
    this.y = a.y;
    this.w = map(a.w, 0, 140, 10, 140);
    mass = map(a.w, 0, 140, 280, 800);
    this.tweet = a.tweet;
    location = new PVector(a.x, a.y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    hit = dead = false;
    textTime = 6000;
  }

  public PVector repel(Asteroid a) {
    PVector force = PVector.sub(location, a.location); // Calculate direction of force
    float distance = force.mag(); // Distance between objects
    distance = constrain(distance, 1.0f, 10000.0f); // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize(); // Normalize vector (distance doesn't matter here, we just want this vector for direction
    float strength = (g * mass * a.mass) / (distance * distance); // Calculate gravitional force magnitude
    force.mult(-1*strength); // Get force vector --> magnitude * direction
    return force;
  }

  public void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  public void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(-0.01f);
  }

  public void display() {
    if (hit) {
      // want to implement a time system to display tweets in the asteroid field instead of a textbox
      dead = true;
    }
    else {
      stroke(255);
      noFill();
      ellipse(location.x, location.y, w, w);
    }
  }

  public void hit(boolean b) {
    hit = b;
    hitTime = millis();
  }

  public boolean isHit() {
    return hit;
  }

  public boolean isDead() {
    return dead;
  }
  
  public String getTweet() {
    return tweet;
  }
}

class Bullet {
  PVector location;
  PVector velocity;
  float r;
  float speed;
  float dx, dy;

  Bullet(float lx, float ly, float angle) {
    speed = 5;
    // calculating angle of firing
    if (angle >= 0 && angle <= 90) {
      dx = map(angle, 0, 90, 0, 1);
      dy = map(angle, 0, 90, -1, 0);
    }
    else if (angle >= 90 && angle <= 180) {
      dx = map(angle, 90, 180, 1, 0);
      dy = map(angle, 90, 180, 0, 1);
    }
    else if (angle >= 180 && angle <= 270) {
      dx = map(angle, 180, 270, 0, -1);
      dy = map(angle, 180, 270, 1, 0);
    }
    else if (angle >= 270 && angle <= 360) {
      dx = map(angle, 270, 360, -1, 0);
      dy = map(angle, 270, 360, 0, -1);
    }
    location = new PVector(lx, ly);
    velocity = new PVector(dx * speed, dy * speed);
    r = 3;
  }

  public void update() {
    location.add(velocity);
  }

  public void display() {
    // Display circle at x location
    stroke(255);
    noFill();
    ellipse(location.x, location.y, r*2, r*2);
  }

  public boolean isOffScreen() {
    if (location.x+r < 0 || location.x+r > width
      || location.y+r < 0 || location.y+r > height) return true;
    else return false;
  }
}

class Button {
  String id; // controller button name
  int reading, lastReading; // current and previous button press readings
  long time, timeBetween; // to determine

  Button(String id) {
    this.id = id;
    time = millis();
  }

  public boolean clicked() {
    boolean clicked;
    // if the previous button state has changed and is now 1, that means the button was clicked
    if ((reading != lastReading) && (reading == 1)) clicked = true;
    else clicked = false;
    lastReading = reading; // update the previous button state
    return clicked;
  }

  public boolean held() {
    if (reading == 1) return true;
    else return false;
  }
  
  public void set(int button) {
    reading = button;
  }
}

class Gun {
  ArrayList<Bullet> bullets = new ArrayList<Bullet>();
  PVector location; // current position on screen
  float x, y, w, h;
  float angle, a;
  float r;
  float mass;

  Gun(float x, float y) {
    this.x = x;
    this.y = y;
    location = new PVector(x, y);
    mass = 10;
    w = 10;
    h = 15;
    angle = 0;
    a = 0;
  }

  public void rot(float a) {
    this.a+=a;
    if (this.a > 360) this.a %= 360.f;
    if (this.a < 0) this.a += 360.f;
  }

  public void moveX(float mx) {
    location.x+=mx;
  }
  public void moveY(float my) {
    location.y+=my;
  }

  public PVector attract(Asteroid a) {
    PVector force = PVector.sub(location, a.location); // Calculate direction of force
    float d = force.mag(); // Distance between objects
    d = constrain(d, 5.0f, 25.0f); // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize(); // Normalize vector (distance doesn't matter here, we just want this vector for direction)
    float strength = (g * mass * a.mass) / (d * d); // Calculate gravitional force magnitude
    force.mult(strength); // Get force vector --> magnitude * direction
    return force;
  }

  public void update() {
    // update gun angle and all bullets
    r = radians(a)+radians(angle);
    for (Bullet b: bullets) {
      b.update();
    }
  }

  public void display() {
    noFill();
    stroke(255);
    pushMatrix();
    translate(location.x, location.y);
    rotate(r);
    triangle(0, -h/2, w/2, h/2, -w/2, h/2);
    popMatrix();
    for (Bullet b: bullets) {
      b.display();
    }
  }

  public void fire() {
    bullets.add(new Bullet((location.x + (sin(r)*h/2)), (location.y + (cos(r)*-h/2)), (abs(a) % 360.f)));
  }

  public ArrayList<Bullet> getBullets() {
    return bullets;
  }

  public PVector getLocation() {
    return location;
  }
}

class Keyboard {

  final static int NORTH = 1;
  final static int EAST = 2;
  final static int SOUTH = 4;
  final static int WEST = 8;
  final static int L = 16;
  final static int R = 32;
  int result;

  Keyboard() {
    result = 0;
  }

  public void check(Gun gun) {
    switch(result) {
      case NORTH: 
      gun.moveY(-2); 
      break;
      case EAST: 
      gun.moveX(2); 
      break;
      case SOUTH: 
      gun.moveY(2); 
      break;
      case WEST: 
      gun.moveX(-2); 
      break;
      case NORTH|EAST: 
      gun.moveY(-2); 
      gun.moveX(2); 
      break;
      case NORTH|WEST: 
      gun.moveY(-2); 
      gun.moveX(-2); 
      break;
      case SOUTH|EAST: 
      gun.moveY(2); 
      gun.moveX(2); 
      break;
      case SOUTH|WEST: 
      gun.moveY(2); 
      gun.moveX(-2); 
      break;
      case L: 
      gun.rot(-PI); 
      break;
      case R: 
      gun.rot(PI); 
      break;
    }
  }

  public void pressed() {
    switch(key) {
      case('w'):
      case('W'):
      result |=NORTH;
      break;
      case('d'):
      case('D'):
      result |=EAST;
      break;
      case('s'):
      case('S'):
      result |=SOUTH;
      break;
      case('a'):
      case('A'):
      result |=WEST;
      break;
      case('j'):
      case('J'):
      result |=L;
      break;
      case('k'):
      case('K'):
      result |=R;
      break;
    }
  }

  public void released() {
    switch(key) {
      case('w'):
      case('W'):
      result ^=NORTH;
      break;
      case('d'):
      case('D'):
      result ^=EAST;
      break;
      case('s'):
      case('S'):
      result ^=SOUTH;
      break;
      case('a'):
      case('A'):
      result ^=WEST;
      break;
      case('j'):
      case('J'):
      result ^=L;
      break;
      case('k'):
      case('K'):
      result ^=R;
      break;
    }
  }
  
}
/////////////////////////////////
// Twitter Streaming API class //
/////////////////////////////////

// OAuth info
static String OAuthConsumerKey = "oF0km6WmpgYkED3rZ8n9aQ";
static String OAuthConsumerSecret = "iSJcMKfq3eTkTMOYV1uS96fTe1dFVHODasWUPNpszc";
// access token info
static String AccessToken = "138650215-gPqoUNOKEaucxc4YOCVWpamhqDYLXx8dsoeFJbU3";
static String AccessTokenSecret = "kNPONdyWCPFDLEYP0jfBgsW8FwFPYZBgVrEg01XzwI";

class Twitter {
  // search keyword; empty to start
  String[] keywords = { 
    ""
  };
  TwitterStream twitter = new TwitterStreamFactory().getInstance();
 
  Twitter() {
    setup();
  }
  
  public void setup() {
    connectTwitter();
    twitter.addListener(listener);
    twitter.filter(new FilterQuery().track(keywords));
  }

  // Initial connection
  public void connectTwitter() {
    twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
    AccessToken accessToken = loadAccessToken();
    twitter.setOAuthAccessToken(accessToken);
  }

  // Loading up the access token
  private AccessToken loadAccessToken() {
    return new AccessToken(AccessToken, AccessTokenSecret);
  }

  // This listens for new tweet
  StatusListener listener = new StatusListener() {
    public void onStatus(Status status) {
      // the tweet to display
      String tweet = "@" + status.getUser().getScreenName() + ":\n" + status.getText();
      // create an asteroid
      tempAsteroids.add(new Asteroid(random(0, width-250), random(0, height), status.getText().length(), tweet));
    }
    // need the following methods for the StatusListener to work
    public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
      println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
    }
    public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
      println("Got track limitation notice:" + numberOfLimitedStatuses);
    }
    public void onScrubGeo(long userId, long upToStatusId) {
      println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
    }
    public void onException(Exception ex) {
      ex.printStackTrace();
    }
  };

  // set search keyword
  public void setKeywords(String s) {
    keywords[0] = s;
    twitter.filter(new FilterQuery().track(keywords));
  }
  
  // get search keyword for display in the visualization
  public String getKeyword() {
    return keywords[0];
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "asteroids" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
