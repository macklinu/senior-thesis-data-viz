# 3D visualization

This visualization was an early attempt to visualize data in 3D and work on programming with user interface elements. This Processing sketch focused more so on understanding how to create and make technical elements work and less on presenting an interesting dataset, so the latter would be the logical next iteration of this visualization.

![](./screenshots/01_5.png)
![](./screenshots/01_6.png)
![](./screenshots/01_7.png)

### Working with custom UI elements  

One focus of this Processing sketch was to deal with user interface (UI) elements, how they are created with code, and the importance they provide when exploring and using a computer program.

I began by starting with a Scrollbar class that is found in the Processing examples folder as the base to learn about how to go about coding a custom UI element. Below are screenshots of two scrollbars from this example sketch.

![](./screenshots/sb1.png)
![](./screenshots/sb2.png)
![](./screenshots/sb3.png)

While this provided a great starting point, I noticed a handful of things when interacting with them that did not seem right. First, if I click and held down one of the scrollbars and moved my mouse accidentally over another scrollbar, I would adjust the position of the scrollbar I did not intend to interact with. It seemed necessary to have a locked position in order to ensure the user can only interact with the one scrollbar that was clicked. 

Within the constructor for the Scrollbar class, I included a way to pass in the other scrollbars that are on the page by including `Scrollbar[] others`.

```
Scrollbar (float xp, float yp, int sw, int sh, int l, Scrollbar[] others, String id, float lo, float hi) {
  // init code goes here
}
```

This allows for one individual scrollbar to check its neighbors to see if it is being interacted with in any way. If any of its neighbors are being clicked on or dragged, the scrollbar will ignore user input, allowing for an error-free, singular interaction.

```
// first test to see if the other scrollbars are being hovered over
for (int i = 0; i < others.length; i++) {
  if (others[i].locked) { // if another scrollbar is clicked on
    otherslocked = true; // then another scrollbar is in use
    break; // no need to check anything else
  } 
  else { 
    otherslocked = false; // otherwise, no scrollbars are being interacted with
  }
}
// if no other scrollbar is in use
// process mouse hover and click events
if (!otherslocked) {
  overEvent();
  pressEvent();
}
```

In the case of this Processing sketch, each scrollbar affected a singular parameter of the 3D camera's position in how it viewed the data. There were nine scrollbars that adjusted the camera's x and y position and the rotation angle of the camera. Therefore, each scrollbar needed an ID in order to display what parameter it was affecting on the scrollbar itself. The screenshot below shows how that specific scrollbar

![](./screenshots/sbID.png)

The example Scrollbar class also lacked which values would be returned from the scrollbar in a clear manner. Since I knew what minimum and maximum values I needed from each scrollbar, I added a way to add this to the scrollbar when it was created.

Instead of this:

```
// within the Scrollbar class
float getPos() {
  // Convert spos to be values between
  // 0 and the total width of the scrollbar
  return spos * ratio;
}

// in the main loop
// Get the position of the img1 scrollbar
// and convert to a value to display the img1 image 
float img1Pos = hs1.getPos()-width/2;
fill(255);
image(img1, width/2-img1.width/2 + img1Pos*1.5, 0);
```

The Scrollbar class now works like this:

```
// from the Scrollbar class
// convert the position of the scrollbar to a value within the range of the minimum and maximum possible values
value = map(spos, sposMin, sposMax, lo, hi);

// how to retrieve it from the class
float getValue() {
  return value;
}

// in use in the main loop
// update the camera position by passing in a scrollbar
for (int i = 0; i < scrollbars.length; i++) { 
  cam.update(i, scrollbars[i]);
}
// get the scrollbar value and use it to set a camera parameter
void update(int i, Scrollbar s) {
  values[i] = s.getValue();
}
```

This provided a simpler, more directed way of allowing the data from a scrollbar to be used by another object in the Processing sketch.

In addition to altering how this Scrollbar class worked under the hood, I also wanted to change its visual presentation, both in color and how it transitioned from inactive to active states. The original scrollbar would change color the instant the mouse hovered over it, which seemed abrupt and choppy looking. To create a smoother visual effect, I used the [Ani](http://www.looksgood.de/libraries/Ani/) class, which is a Processing animation library. This created a smooth fade between active and inactive modes when hovering the mouse over a scrollbar, which gave the scrollbar a more natural, yet subtle visual effect. The code examples and screenshots are below.

![](./screenshots/sbID.png)

```
// from the Scrollbar class
// if the mouse is hovering over a scrollbar
// or the scrollbar is clicked on (locked)
if (over || locked) {
  // take 0.3 seconds to fade its color to the active state color
  fill(148, 360*.49, 360*scrollbarMult);
  Ani.to(this, 0.3, "scrollbarMult", scrollbarActiveMult);
} 
else {
  // take 0.3 seconds to fade its color to the inactive state color
  fill(148, 360*.49, 360*scrollbarMult);
  Ani.to(this, 0.3, "scrollbarMult", scrollbarInactiveMult);
}
```

![](./screenshots/01_1.png)
![](./screenshots/01_2.png)
![](./screenshots/01_3.png)

### Mousing over a 3D screen element

It is a comparatively easy task to determine the distance between the mouse x and y coordinates and a 2D object's coordinates than to find the distance to a 3D object's coordinates. Certain calculations must occur to bring a 3D object's coordinates into a 2D form that can be compared to the coordinates of the mouse. This term is often described as _picking_, and it was a challenge I had to tackle in order to interact with the 3D data spheres in the screenshots below. 

![](./screenshots/01_4.png)
![](./screenshots/01_8.png)

In the function `drawData()`, where the the circles that represent the 3D data set are drawn to the screen, there is an important line of code that makes this possible.

```
void drawData() {
  for (int i = 0; i < x.length; i++) {
    float tx = map(x[i], xMin, xMax, 0, width);
    float ty = map(y[i], yMin, yMax, 0, height);
    float tz = map(z[i], zMin, zMax, -height/2, height/2);
    int hue = int(map(x[i], xMin, xMax, 200, 50));
    float sz = map(x[i], xMin, xMax, 5, 15);
    pushMatrix();
    noStroke();
    if (dist(mouseX, mouseY, screenX(tx, ty, tz), screenY(tx, ty, tz)) < sz) { // 3D picking
      fill(hue, 360, 360, 220);
      hoverOver[i] = true;
    }
    else { 
      fill(hue, 360, 360);
      hoverOver[i] = false;
    }
    ambient(255, 26, 160);
    translate(tx, ty, tz);
    sphere(sz);
    popMatrix();
  }
}
```

This `if` statement checks to see if the mouse is hovering over a data element. Since the scene is rendered in 3D, using `screenX` and `screenY` are necessary to find where the sphere's 2D x and y screen coordinates are; otherwise, it would not be possible to check if the 2D mouse if hovering over a 3D screen element.

```
if (dist(mouseX, mouseY, screenX(tx, ty, tz), screenY(tx, ty, tz)) < sz) { // 3D picking
  fill(hue, 360, 360, 220); // make the circle more transparent to show we are hovering over
  hoverOver[i] = true; // the circle is being hovered over
}
```

Ultimately, this 3D visualization system would be more beneficial for viewing a 3D data set in a form like this, from the book [_Generative Gestaltung_](http://generative-gestaltung.de/):

![](./screenshots/M_1_4_01.png)

Being able to navigate into a more complex, interesting 3D display of data would provide for a much more enjoyable user experience. However, a lot of the basic tools that would be used in a more complex 3D data visualization are present in this Processing example, so the transition shouldn't be too difficult. This would allow for the next iteration of this project to focus more on the dataset and how to display it rather than learning how to make things technically happen. Ultimately, experiencing a data visualization should be about the data and less about how the visualization works, so it seems like a natural progression to create a visual like the one above in the next iteration of this Processing sketch.