class Asteroid {
  Textarea tweetArea;

  String tweet;
  float x, y, w, h;
  boolean hit;
  boolean dead;
  float hitTime, textTime;

  Asteroid(float x, float y, float w, String tweet) {
    this.x = x;
    this.y = y;
    this.w = map(w, 0, 140, 10, 140);
    this.tweet = tweet;

    tweetArea = cp5.addTextarea(tweet)
      .setPosition(x - 300/2, y)
        .setSize(300, 200)
          .setFont(createFont("Monaco", 10))
            .setLineHeight(14)
                .setText(tweet);

    hit = dead = false;
    textTime = 6000;
  }

  void display() {
    if (hit) {
      tweetArea.setColor(color(225));
      if (millis() - hitTime > textTime) { 
        tweetArea.setColor(color(0, 0));
        dead = true;
      }
    }
    else {
      // tweetArea.hide();
      tweetArea.setColor(color(0, 0));
      fill(255, 200);
      noStroke();
      ellipse(x, y, w, w);
    }
  }

  void hit(boolean b) {
    hit = b;
    hitTime = millis();
  }

  boolean isHit() {
    return hit;
  }

  boolean isDead() {
    return dead;
  }
}

