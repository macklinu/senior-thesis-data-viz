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
  int tweetCount = 0;

  // if you enter keywords here it will filter, otherwise it will sample
  String[] keywords = { 
    ""
  };

  TwitterStream twitter = new TwitterStreamFactory().getInstance();
 
  Twitter() {
    setup();
  }
  
  void setup() {
    connectTwitter();
    twitter.addListener(listener);
    twitter.filter(new FilterQuery().track(keywords));
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
      /*
      println("--------");
      println("@" + status.getUser().getScreenName() + "\t" + status.getUser().getFollowersCount());
      println(status.getText() + "\n");
      println(status.isRetweet() + "\t" + status.getRetweetCount());
      println("--------");
      */
      String tweet = "@" + status.getUser().getScreenName() + ":\n" + status.getText();
      tempAsteroids.add(new Asteroid(random(0, width-250), random(0, height), status.getText().length(), tweet));
    }

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

  void setKeywords(String s) {
    keywords[0] = s;
    twitter.filter(new FilterQuery().track(keywords));
  }
  
  String getKeyword() {
    return keywords[0];
  }
}

