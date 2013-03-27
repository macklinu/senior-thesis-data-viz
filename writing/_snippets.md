# Code snippets for use in data visualization  

This collection of code snippets is a good reference and learning tool for some important, reusable functions in data visualization.

Sources include:  
[_Visualizing Data_ - Ben Fry](http://google.com)

## Processing

### Create a timestamp for saving files with a unique name

~~~
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
~~~

### Create, populate, and write a .csv file

~~~
Table table;

void setup() {
  // create an empty table
  table = createTable();
  // add the appropriate columns for your data
  table.addColumn("id");
  table.addColumn("species");
  table.addColumn("name");
  // add a new row and populate the appropriate columns
  TableRow newRow = table.addRow();
  newRow.setInt("id", table.getRowCount() - 1);
  newRow.setString("species", "Panthera leo");
  newRow.setString("name", "Lion");
  // save the row to a new .csv file stored in the data folder
  saveTable(table, "data/new.csv");
}
~~~

### Find min and max values in an array

~~~
// after the first test, these values will be overwritten
// the minimum number currently equals the maximum possible value
// and vice versa
float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;

float[] x; // contains values of length n

for (int i = 0; i < x.length; i++) {
    float value = x[i]; // test each value in the array
    if (value > dataMax) {
        dataMax = value;
    }
    if (value < dataMin) {
        dataMin = value;
    }
}
~~~