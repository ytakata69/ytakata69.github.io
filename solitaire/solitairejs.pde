/**
 * A peg solitaire playground.
 * <p>
 * Credits:
 * <ul>
 * <li>Marble images from <a href="https://www.pixiv.net/artworks/64255303">https://www.pixiv.net/artworks/64255303</a></li>
 * <li>Sounds from <a href="https://zapsplat.com">https://zapsplat.com</a></li>
 * </ul>
 */
/* @pjs preload="64255303_p14.png,64255303_p7.png,64255303_p9.png,shadow.png"; */

Board board;
View view;

void setup() {
  size(500, 500);
  board = new Board();
  view = new View(board);
}

void draw() {
  // 舞台
  pushMatrix();
  translate(width/2, height/2);
  background(64);
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

  view.draw();
}

void mouseClicked() {
  PVector colrow = view.pixel2grid(mouseX, mouseY);
  board.select(int(colrow.x), int(colrow.y));
}

void sound() {
  playSound();
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

  Board() {
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if ((2 <= row && row < 5) ||
            (2 <= col && col < 5))
        {
          // 1以上: ビー玉の種類
          board[row][col] = (row + col) % 3 + 1;
        }
      }
    }
    board[3][3] = SPACE;
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
          board[row][col] = board[int(selected.y)][int(selected.x)];
          board[int(selected.y)][int(selected.x)] = SPACE;
          board[midY][midX] = SPACE;
          selected = null;
          sound();
        }
      }
    }
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

  PImage[] marble = new PImage[3];
  PImage shadow;

  View(Board board_) {
    board = board_;
    GRID = float(width)/(board.width() + 1);
    marble[0] = loadImage("64255303_p14.png");
    marble[1] = loadImage("64255303_p7.png");
    marble[2] = loadImage("64255303_p9.png");
    shadow = loadImage("shadow.png");
  }

  void draw() {
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
