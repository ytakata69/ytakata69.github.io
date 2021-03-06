/**
 * A peg solitaire playground.
 * <p>
 * Credits:
 * <ul>
 * <li>Marble images from <a href="https://www.pixiv.net/artworks/64255303">https://www.pixiv.net/artworks/64255303</a></li>
 * <li>Sounds from <a href="https://zapsplat.com">https://zapsplat.com</a></li>
 * </ul>
 */

/* @pjs preload="64255303_p14.png,64255303_p7.png,64255303_p9.png";
        preload="64255303_p1.png,64255303_p2.png,64255303_p5.png";
        preload="shadow.png"; */

final String[] MARBLE_FILES = {
  "64255303_p14.png", "64255303_p7.png", "64255303_p9.png",
  "64255303_p1.png", "64255303_p2.png", "64255303_p5.png"
};
final String SHADOW_FILE = "shadow.png";
final int N_MARBLE = MARBLE_FILES.length;

final String AUDIO_FILE = "./zapsplat_cartoon_wood_knock_single_17786.mp3";
Object audioObj = new Audio(AUDIO_FILE);

Board board;
View view;

boolean waitingDoubleClick;
int waitingDoubleClickStart;

void setup() {
  size(500, 500);
  frameRate(30);
  board = new Board();
  view = new View(board);
}

void draw() {
  view.draw();
  if (waitingDoubleClick && millis() - waitingDoubleClickStart > 900) {
    waitingDoubleClick = false;
  }
}

void mousePressed() {
  PVector colrow = view.pixel2grid(mouseX, mouseY);
  if (colrow.x < 0 && colrow.y < 0) {
    board.undo();
  } else if (colrow.x >= board.width() && colrow.y < 0) {
    board.redo();
  } else if (colrow.x < 0 && colrow.y >= board.width()) {
    if (waitingDoubleClick) {
      board.reset();
      waitingDoubleClick = false;
    } else {
      waitingDoubleClick = true;
      waitingDoubleClickStart = millis();
    }
  } else {
    board.select(int(colrow.x), int(colrow.y));
  }
}

void sound() {
  audioObj.play();
  audioObj = new Audio(AUDIO_FILE);
}
/**
 * Model-View-ControllerのModel.
 */
class Board {
  int[][] board = new int[7][7];
  final int OUT_OF_BOUNDS = 0;
  final int SPACE = -1;

  // 選択中のビー玉の列と行
  PVector selected = null;

  // undo history
  History history;

  Board() {
    this.reset();
  }

  void reset() {
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if ((2 <= row && row < 5) ||
            (2 <= col && col < 5))
        {
          // 1以上: ビー玉の種類
          int b = (row % 2) * 2 + (col % 2);
          //int b = (row + col) % N_MARBLE;
          board[row][col] = b + 1;
        }
        else {
          board[row][col] = OUT_OF_BOUNDS;
        }
      }
    }
    board[3][3] = SPACE;
    selected = null;
    history = new History(board.length * board.length);
  }

  void select(int col, int row) {
    if (row < 0 || row >= board.length ||
        col < 0 || col >= board[row].length)
    {
      return;
    }

    // 選択済みのビー玉を再度選択したらキャンセル
    if (selected != null && selected.x == col && selected.y == row) {
      selected = null;
    }
    // 新たに選択
    else if (isMarble(col, row)) {
      selected = new PVector(col, row);
    }
    // ビー玉を選択している状態で空き場所を選択
    else if (selected != null && isSpace(col, row)) {
      if ((col == selected.x && abs(row - selected.y) == 2) ||
          (row == selected.y && abs(col - selected.x) == 2))
      {
        int midX = int((col + selected.x) / 2);
        int midY = int((row + selected.y) / 2);
        if (isMarble(midX, midY)) {
          history.push(int(selected.x), int(selected.y), col, row,
                       board[midY][midX]);
          move(int(selected.x), int(selected.y), col, row, SPACE);
          sound();
        }
      }
    }
  }

  private void move(int fromX, int fromY, int toX, int toY, int midMarble) {
    int midX = int((fromX + toX) / 2);
    int midY = int((fromY + toY) / 2);
    board[toY][toX] = board[fromY][fromX];
    board[fromY][fromX] = SPACE;
    board[midY][midX] = midMarble;
    selected = null;
  }

  int width() {
    return board.length;
  }
  
  boolean isMarble(int x, int y) {
    return board[y][x] > 0;
  }
  boolean isSpace(int x, int y) {
    return board[y][x] == SPACE;
  }
  boolean isSelected(int x, int y) {
    return selected != null && int(selected.x) == x && int(selected.y) == y;
  }
  int getMarble(int x, int y) {
    return board[y][x];
  }

  void undo() {
    HistoryEntry he = history.back();
    if (he == null) { return; }
    move(int(he.to.x), int(he.to.y), int(he.from.x), int(he.from.y), he.marble);
  }

  void redo() {
    HistoryEntry he = history.forward();
    if (he == null) { return; }
    move(int(he.from.x), int(he.from.y), int(he.to.x), int(he.to.y), SPACE);
  }

}
class History {
  HistoryEntry[] history;
  int used = 0;
  int pos  = 0;

  History(int maxlen) {
    history = new HistoryEntry[maxlen];
  }

  HistoryEntry back() {
    return pos > 0 ? history[--pos] : null;
  }
  HistoryEntry forward() {
    return pos < used ? history[pos++] : null;
  }

  void push(int fromX, int fromY, int toX, int toY, int marble) {
    push(new HistoryEntry(new PVector(fromX, fromY),
                          new PVector(toX, toY), marble));
  }
  void push(HistoryEntry he) {
    if (pos < history.length) {
      history[pos++] = he;
      used = pos;
    }
  }
}

class HistoryEntry {
  PVector from, to;
  int marble;
  HistoryEntry(PVector from_, PVector to_, int marble_) {
    from = from_;
    to = to_;
    marble = marble_;
  }
}
/**
 * Model-View-ControllerのView.
 */
class View {
  Board board;
  float GRID;
  final float MARBLE_WD = 50;
  final float MARKER_WD = 65;
  final float PIT_WD = 10;

  PImage[] marble = new PImage[N_MARBLE];
  PImage shadow;

  View(Board board_) {
    board = board_;
    GRID = float(width)/(board.width() + 1);
    for (int i = 0; i < marble.length; i++) {
      marble[i] = loadImage(MARBLE_FILES[i]);
    }
    shadow = loadImage(SHADOW_FILE);
  }

  void draw() {
    // 舞台
    drawStage();

    // ビー玉・くぼみ・選択マーク
    for (int row = 0; row < board.width(); row++) {
      for (int col = 0; col < board.width(); col++) {
        PVector v = grid2pixel(col, row);
        if (board.isMarble(col, row)) {
          // ビー玉の影
          image(shadow,
                v.x - (MARBLE_WD * 1.1)/2, v.y - MARBLE_WD/2 + 20,
                MARBLE_WD * 1.1, MARBLE_WD * 0.9);
          // 選択マーク
          if (board.isSelected(col, row)) {
            noStroke();
            fill(255, 0, 0);
            ellipse(v.x, v.y, MARKER_WD, MARKER_WD);
          }
          // ビー玉
          image(marble[board.getMarble(col, row) - 1],
                v.x - MARBLE_WD/2, v.y - MARBLE_WD/2,
                MARBLE_WD, MARBLE_WD);
        } else if (board.isSpace(col, row)) {
          // くぼみ
          noStroke();
          fill(128);
          ellipse(v.x, v.y, PIT_WD, PIT_WD);
        }
      }
    }
  }
  
  void drawStage() {
    background(waitingDoubleClick ? 80 : 64);

    pushMatrix();
    translate(width/2, height/2);
    stroke(96);
    strokeWeight(15);
    noFill();
    ellipse(0, 0, width * 1.2, width * 1.2);
    noStroke();
    fill(255);
    ellipse(0, 0, width * 1.1, width * 1.1);
    stroke(229);
    strokeWeight(5);
    noFill();
    ellipse(0, 0, width * 1.05, width * 1.05);
    popMatrix();
  }

  PVector grid2pixel(PVector g) {
    return grid2pixel(g.x, g.y);
  }
  PVector grid2pixel(float x, float y) {
    return new PVector(GRID * (x + 1), GRID * (y + 1));
  }

  PVector pixel2grid(float x, float y) {
    return new PVector(round(x / GRID) - 1,
                       round(y / GRID) - 1);
  }
}
