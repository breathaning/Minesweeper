import de.bezier.guido.*;
private float buttonSize = 20;
private TileButton[][] buttons;
private int[][] adjacent = {
  {1, -1},
  {0, -1},
  {-1, -1},
  {-1, 0},
  {-1, 1},
  {0, 1},
  {1, 1},
  {1, 0},
};
private int mineCount = 75;
private RestartButton restartButton;

private boolean gameEnd = false;
private boolean win = false;
  
public void setup (){
    size(500, 500);
    textAlign(CENTER, CENTER);
    Interactive.make( this );
    buttons = new TileButton[(int)(height / buttonSize)][(int)(width / buttonSize)];
    for (int iy = 0; iy < buttons.length; iy++) {
      for (int ix = 0; ix < buttons[iy].length; ix++) {
        buttons[iy][ix] = new TileButton(ix, iy, buttonSize - 1, buttonSize - 1);
      }
    }
    newGame();
    restartButton = new RestartButton(width / 2, height * 0.75, 100, 50);
}
public void draw (){
    background( 0 );
    if (gameEnd) {
      String displayText = win ? "You Win! :)" : "You Lose :(";
      textSize(25);
      fill(100, 100, 100);
      text(displayText, width / 2, height / 2);
    }
}

public void newGame() {
  gameEnd = false;
  for (int iy = 0; iy < buttons.length; iy++) {
      for (int ix = 0; ix < buttons[iy].length; ix++) {
        buttons[iy][ix].reset();
      }
  }
  int mines = 0;
  while (mines < mineCount) {
    int iy = (int)(Math.random() * buttons.length);
    int ix = (int)(Math.random() * buttons[iy].length);
    if (buttons[iy][ix].getValue() == 9) { continue; }
    buttons[iy][ix].setValue(9);
    mines++;
  }
  for (int iy = 0; iy < buttons.length; iy++) {
    for (int ix = 0; ix < buttons[iy].length; ix++) {
      if (buttons[iy][ix].getValue() == 9) { continue; }
      int value = 0;
      for (int i = 0; i < adjacent.length; i++) {
        int oix = ix + adjacent[i][0];
        int oiy = iy + adjacent[i][1];
        if (!buttons[0][0].isValid(oix, oiy)) { continue; }
        if (buttons[oiy][oix].getValue() != 9) { continue; }
        value++;
      }
      buttons[iy][ix].setValue(value);
    }
  }
}

public class RestartButton {
  private float x, y, width, height;
  public RestartButton(float x, float y, float width, float height) {
    this.x = x - width / 2;
    this.y = y - height / 2;
    this.width = width;
    this.height = height;
    Interactive.add( this );
  }
  
  public void draw() {
    if (!gameEnd) { return; }
    fill(255, 255, 200);
    noStroke();
    rect(x, y, width, height);
    fill(0, 0, 0);
    text("Restart", x + width / 2, y + height / 2);
  }
  
  public void mouseReleased() {
    newGame();
  }
}
public class TileButton
{
    private float x, y, width, height;
    private int ix, iy;
    private boolean open;
    private int value;
    private boolean flagged;
    public TileButton (int ix, int iy, float width, float height)
    {
        this.x = ix * buttonSize;
        this.y = iy * buttonSize;
        this.width = width;
        this.height = height;
        this.ix = ix;
        this.iy = iy;
        reset();
        Interactive.add( this );
    }
    public void reset() {
      value = 0;
      open = false;
      flagged = false;
    }
    public void mouseReleased () {
      if (gameEnd) { return; }
      if (mouseButton == LEFT && !isFlagged()) {
        if (isOpen()) {
          chordTile();
        } else {
          openTile();
        }
        checkGameEnd();
      } else if (mouseButton == RIGHT) {
        flagTile();
      }
    }
    public void draw () 
    {
      if (gameEnd) { return; }
      if (open) {
        if (value == 9) {
          fill(255, 0, 0);
        } else {
          fill( 200 );
        }
      } else {
        if (flagged) {
          fill(50);
        } else {
          fill( 100 );
        }
      }
      stroke(0, 0, 0);
      strokeWeight(1);
      rect(x, y, width, height);
      if (open && value != 9) {
        if (value != 0) {
          if (value == 1) {
            fill(0, 0, 255);
          } else if (value == 2) {
            fill(0, 128, 0);
          } else if (value == 3) {
            fill(255, 0, 0);
          } else if (value == 4) {
            fill(0, 0, 128);
          } else if (value == 5) {
            fill(128, 0, 0);
          } else if (value == 6) {
            fill(0, 128, 128);
          } else if (value == 7) {
            fill(0, 0, 0);
          } else {
            fill(128, 128, 128);
          }
          textSize(14);
          text(value, x + width * 0.5, y + height * 0.5);
        }
      }
    }
    public void openTile() {
      open = true;
      if (value != 0) { return; }
      for (int i = 0; i < adjacent.length; i++) {
        int oix = ix + adjacent[i][0];
        int oiy = iy + adjacent[i][1];
        if (!isValid(oix, oiy)) { continue; }
        if (buttons[oiy][oix].isOpen()) { continue; }
        buttons[oiy][oix].openTile();
      }
    }
    public void chordTile() {
      if (value == 0) { return; }
      int flagCount = 0;
      for (int i = 0; i < adjacent.length; i++) {
        int oix = ix + adjacent[i][0];
        int oiy = iy + adjacent[i][1];
        if (!isValid(oix, oiy)) { continue; }
        if (!buttons[oiy][oix].isFlagged() || buttons[oiy][oix].isOpen()) { continue; }
        flagCount++;
      }
      if (flagCount != value) { return; }
      for (int i = 0; i < adjacent.length; i++) {
        int oix = ix + adjacent[i][0];
        int oiy = iy + adjacent[i][1];
        if (!isValid(oix, oiy)) { continue; }
        if (buttons[oiy][oix].isFlagged()) { continue; }
        buttons[oiy][oix].openTile();
      }
    }
    public void flagTile() {
      flagged = !flagged;
    }
    public boolean isOpen(){ return open; }
    public boolean isFlagged() {return flagged; }
    public void setValue(int newValue) {
      value = newValue;
    }
    public int getValue() { return value; }
    private boolean isValid(int x, int y) {
      return y >= 0 && y < buttons.length && x >= 0 && x < buttons[y].length;
    }
    private void checkGameEnd() {
      if (gameEnd) { return; }
      
      int openCount = 0;
      boolean lose = false;
      for (int y = 0; y < buttons.length; y++) {
        if (lose) { break; }
        for (int x = 0; x < buttons[y].length; x++) {
          if (!buttons[y][x].isOpen()) { continue; }
          if (buttons[y][x].getValue() == 9) {
            lose = true;
            break;
          } else {
            openCount++; 
          }
        }
      }
      
      if (lose) {
        gameEnd = true;
        win = false;
      } else if (openCount == buttons.length * buttons[0].length - mineCount) {
        gameEnd = true;
        win = true;
      }
    }
}
  

  
