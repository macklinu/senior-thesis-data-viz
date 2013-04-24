String sign = "libra";
String baseURL = "http://pipes.yahoo.com/pipes/pipe.run?_id=_omfgXdL3BGGadhGdrq02Q&_render=rss&sign="+sign+"&url=http%3A%2F%2Ffeeds.astrology.com%2Fdailyoverview";

XML xml = loadXML(baseURL);
String horoscope = split(split(xml.getChild("channel/item/description").getContent(), "</p>")[0].substring(3), "\n")[0];
println(horoscope);


