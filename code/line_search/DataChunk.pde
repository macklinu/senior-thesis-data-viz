import java.util.*;
import java.text.*;

class DataChunk {
  String[] dates;
  float[] values;
  int[] dayInYear;

  DataChunk(ArrayList<String> d, ArrayList<Float> v) {
    dates = new String[d.size()];
    values = new float[v.size()];
    dayInYear = new int[d.size()];
    int i = 0;
    for (String s : d) {
      dates[i] = s;
      try { 
        dayInYear[i] = getDayOfYear(s);
      }
      catch (ParseException p) {
        println(p);
      }
      i++;
    }
    i = 0;
    for (float f : v) {
      values[i] = f;
      i++;
    }
  }

  String[] getDates() {
    return dates;
  } 

  float[] getValues() {
    return values;
  }
  
  int[] getDIY() {
    return dayInYear;
  }

  private int getDayOfYear(String dateString) throws ParseException {  
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");  
    Date date = sdf.parse(dateString);  
    GregorianCalendar greg = new GregorianCalendar();  
    greg.setTime(date);  
    if (dateString.substring(0, 4).equals("2010")) return (greg.get(greg.DAY_OF_YEAR) + 133);
    else return greg.get(greg.DAY_OF_YEAR) - 233; // "20090821" = 233
  }
}

