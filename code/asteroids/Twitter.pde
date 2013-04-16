/////////////////////////////////
// Twitter Streaming API class //
/////////////////////////////////

// This is where you enter your Oauth info
static String OAuthConsumerKey = "oF0km6WmpgYkED3rZ8n9aQ";
static String OAuthConsumerSecret = "iSJcMKfq3eTkTMOYV1uS96fTe1dFVHODasWUPNpszc";
// This is where you enter your Access Token info
static String AccessToken = "138650215-gPqoUNOKEaucxc4YOCVWpamhqDYLXx8dsoeFJbU3";
static String AccessTokenSecret = "kNPONdyWCPFDLEYP0jfBgsW8FwFPYZBgVrEg01XzwI";

class Twitter {

  // if you enter keywords here it will filter, otherwise it will sample
  String[] keywords = { 
    "Ann Arbor", "Detroit"
  };
  PImage img;
  boolean imageLoaded;

  TwitterStream twitter = new TwitterStreamFactory().getInstance();

  Twitter() {
    connectTwitter();
    twitter.addListener(listener);

    if (keywords.length==0) twitter.sample();
    else twitter.filter(new FilterQuery().track(keywords));
  }

  void display() {
    // if (imageLoaded) image(img, width/2, height/2);
  }

  // Initial connection
  void connectTwitter() {
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
      // println("NEW STATUS\n");
      // println("@" + status.getUser().getScreenName() + " - " + status.getText() + "\n");
      String tweet = "@" + status.getUser().getScreenName() + " - " + status.getText();
      if (tweet != null) asteroids.add(new Asteroid(random(100, width-100), random(100, height-100), status.getText().length(), tweet));

      String imgUrl = null;
      String imgPage = null;

      // Checks for images posted using twitter API

      if (status.getMediaEntities() != null) {
        imgUrl= status.getMediaEntities()[0].getMediaURL().toString();
      }
      // Checks for images posted using other APIs

      else {
        if (status.getURLEntities().length > 0) {
          if (status.getURLEntities()[0].getExpandedURL() != null) {
            imgPage = status.getURLEntities()[0].getExpandedURL().toString();
          }
          else {
            if (status.getURLEntities()[0].getDisplayURL() != null) {
              imgPage = status.getURLEntities()[0].getDisplayURL().toString();
            }
          }
        }

        if (imgPage != null) imgUrl  = parseTwitterImg(imgPage);
      }

      if (imgUrl != null) {

        println("found image: " + imgUrl);

        // hacks to make image load correctly

        if (imgUrl.startsWith("//")) {
          println("s3 weirdness");
          imgUrl = "http:" + imgUrl;
        }
        if (!imgUrl.endsWith(".jpg")) {
          byte[] imgBytes = loadBytes(imgUrl);
          saveBytes("tempImage.jpg", imgBytes);
          imgUrl = "tempImage.jpg";
        }

        println("loading " + imgUrl);
        img = loadImage(imgUrl);
        imageLoaded = true;
      }
    }

    public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
      //println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
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

  // Twitter doesn't recognize images from other sites as media, so must be parsed manually
  // You can add more services at the top if something is missing

  String parseTwitterImg(String pageUrl) {

    for (int i=0; i<imageService.length; i++) {
      if (pageUrl.startsWith(imageService[i][0])) {

        String fullPage = "";  // container for html
        String lines[] = loadStrings(pageUrl); // load html into an array, then move to container
        for (int j=0; j < lines.length; j++) { 
          fullPage += lines[j] + "\n";
        }

        String[] pieces = split(fullPage, imageService[i][1]);
        pieces = split(pieces[1], "\""); 

        return(pieces[0]);
      }
    }
    return(null);
  }
}

