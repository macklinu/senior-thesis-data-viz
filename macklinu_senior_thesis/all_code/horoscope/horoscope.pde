String sign = "libra";
String baseURL = "http://pipes.yahoo.com/pipes/pipe.run?_id=_omfgXdL3BGGadhGdrq02Q&_render=rss&sign="+sign+"&url=http%3A%2F%2Ffeeds.astrology.com%2Fdailyoverview";

String horoscope; // = split(split(xml.getChild("channel/item/description").getContent(), "</p>")[0].substring(3), "\n")[0];

void setup() {
  size(300, 175);
  smooth();
  XML xml = loadXML(baseURL);
  horoscope = split(split(xml.getChild("channel/item/description").getContent(), "</p>")[0].substring(3), "\n")[0];

}

void draw() {
  background(0);
  fill(255);
  text(sign, 25, 25);
  text(horoscope, 25, 50, width - 75, height - 50);
}


