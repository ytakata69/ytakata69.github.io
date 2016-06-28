/**
 * Slotmachine:
 * a funny application to select an item randomly.
 * <br>
 * @author y-takata, 2013/Oct/15
 */

String[] allItems = {
  "Apple",
  "Banana",
  "Cherry",
  "Date",
  "Elderberry",
  "Fig",
  "Grape",
};

final float LINE_HEIGHT = 68;
final int ROLLING  = 0;
final int STOPPING = 1;
final int STOPPED  = 2;

Items items;

void setup() {
  size(400, 160);
  items = new Items();
  items.shuffle();
  stroke(255);
  noFill();
  textSize(64);
  textAlign(CENTER, BOTTOM);
}

int y = 0; // height_of_one_item == 1000
int vy = 200;
int phase = ROLLING;

int index(int y, int i) {
  return (int(y/1000) + i) % items.size();
}

void draw() {
  float dy = (y % 1000) / 1000.0;
  background(0);
  for (int i = 0; i < 5; i++) {
    text(items.get(index(y, i)),
         width/2, height - (i - dy) * LINE_HEIGHT);
  }

  if (phase == STOPPING) {
    if (vy >= 1) {
      vy -= 1;  // slowing down
    } else {
      phase = STOPPED;
      vy = 200; // re-initialize
    }
  }
  if (phase != STOPPED) {
    y += vy;
  }
  if (phase == STOPPED) {
    rect(20, height - (2 - dy) * LINE_HEIGHT,
         width - 40, LINE_HEIGHT);
  }
}

void mousePressed() {
  // Reset the items by clicking the upper-left corner.
  if (mouseX < width/8 && mouseY < height/4) {
    y = y % (items.size() * 1000);
    items.reset();
    phase = ROLLING;
    vy = 200;
  }
  else if (phase == ROLLING) {
    phase = STOPPING;
  }
  else if (phase == STOPPED) {
    if (items.size() > 1) {
      y = y % (items.size() * 1000);
      items.remove(index(y, 1));
      phase = ROLLING;
    }
  }
}

/**
 * The set of rolling items
 */
class Items {
  String[] items;
  int numItem;

  Items() {
    reset();
  }

  public String get(int i) {
    return items[i];
  }
  public int size() {
    return numItem;
  }

  private void swap(int i, int j) {
    String tmp = items[i];
    items[i] = items[j];
    items[j] = tmp;
  }

  public void shuffle() {
    for (int i = 0; i < numItem; i++) {
      this.swap(i, int(random(numItem)));
    }
  }

  public void reset() {
    items = new String[allItems.length];
    numItem = allItems.length;
    for (int i = 0; i < numItem; i++) {
      items[i] = allItems[i];
    }
    this.shuffle();
  }

  public void remove(int j) {
    //  println(items[j]);
    numItem--;
    for (int i = j; i < numItem; i++) {
      items[i] = items[i + 1];
    }
  }
}