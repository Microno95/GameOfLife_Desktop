import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

/**
 * Created by ekin4 on 06/08/2016.
 */

public class CellMesh {

  private PVector meshDims = new PVector(1, 1), meshLoc = new PVector(0, 0);
  private PGraphics screen;
  private DisplayableCell first, curRow, curCol;
  private float zoomLevel = 1;
  private boolean newStateAvailable = true, periodic = false;

  public CellMesh(PApplet display_, boolean state, PVector position_, 
    PVector dims_, Color stroke_, PVector meshDims_, 
    PVector meshLoc_) {
    double scalingX = 1920, scalingY = 1080;
    scalingX /= display_.displayWidth;
    scalingY /= display_.displayHeight;
    meshLoc = new PVector(meshLoc_.x * (float) scalingX, meshLoc_.y * (float) scalingY);
    first = new DisplayableCell(state, null, 
      new PVector(position_.x * (float) scalingX, position_.y * (float) scalingY), 
      new PVector(dims_.x * (float) (scalingX * scalingY), 
      dims_.y * (float) (scalingY * scalingX)), stroke_);
    meshDims = meshDims_;
    if (meshDims.x * meshDims.y > 10000) {
      screen = display_.createGraphics((int) meshDims.x, (int) meshDims.y);
    } else {
      screen = null;
    }
  }

  public void createMesh(int sep, PApplet display_) {
    if (sep < 0) {
      sep = 2;
    }
    if (screen == null) {
      screen = display_.createGraphics((int) (meshDims.x * sep * first.getDims().x), (int) (meshDims.y * sep * first.getDims().y));
    }
    curCol = first;
    for (int i = 0; i < meshDims.x; i++) {
      curCol.setRight(
        new DisplayableCell((false), first, 
        new PVector(first.getDims().x * sep * i, 0), 
        new PVector(first.getDims().x, first.getDims().y), 
        first.getStrokeColour()));
      curCol.getRight().setLeft(curCol);
      curRow = curCol;
      for (int k = 0; k < meshDims.y; k++) {
        curRow.setBottom(new DisplayableCell((false), first, 
          new PVector(curCol.getRelPosition().x, first.getDims().y * sep * k), 
          new PVector(first.getDims().x, first.getDims().y), 
          first.getStrokeColour()));
        curRow.getBottom().setTop(curRow);
        curRow = curRow.getBottom();
        curRow.setLeft(curRow.getTop().getLeft().getBottom());
        curRow.getLeft().setRight(curRow);
        curRow.setUpperLeft(curRow.getTop().getLeft());
        curRow.getUpperLeft().setLowerRight(curRow);
      }
      curCol = curCol.getRight();
    }
    curRow = curCol;
    for (int k = 0; k < meshDims.y; k++) {
      curRow.setBottom(new DisplayableCell((false), first, 
        new PVector(curCol.getRelPosition().x, first.getDims().y * sep * k), 
        new PVector(first.getDims().x, first.getDims().y), 
        first.getStrokeColour()));
      curRow.getBottom().setTop(curRow);
      curRow = curRow.getBottom();
      curRow.setLeft(curRow.getTop().getLeft().getBottom());
      curRow.getLeft().setRight(curRow);
      curRow.setUpperLeft(curRow.getTop().getLeft());
      curRow.getUpperLeft().setLowerRight(curRow);
    }
    curCol = first;
    int timesCol = 0, timesRow = 0;
    while (timesCol < 2) {
      curRow = curCol;
      timesRow = 0;
      while (timesRow < 2) {
        curRow = curRow.getBottom();
        curRow.setUpperRight(curRow.getTop().getRight());
        curRow.getUpperRight().setLowerLeft(curRow);
        timesRow += (curRow == curRow.getBottom() ? 1 : 0);
      }
      curCol = curCol.getRight();
      timesCol += (curCol == curCol.getRight() ? 1 : 0);
    }
  }

  public void displayMesh(PApplet display) {
    if (newStateAvailable) {
      screen.beginDraw();
      screen.background(0);
      curRow = first;
      if (meshDims.x * meshDims.y <= 10000) {
        for (int i = 0; i < meshDims.x; i++) {
          curCol = curRow;
          for (int k = 0; k < meshDims.y; k++) {
            curCol.updateState();
            curCol.display(screen);
            curCol = curCol.getRight();
          }
          curRow = curRow.getBottom();
        }
      } else {
        screen.loadPixels();
        for (int i = 0; i < screen.width; i++) {
          curCol = curRow;
          for (int k = 0; k < screen.height; k++) {
            curCol.updateState();
            int val = (curCol.getState() ? 255 : 0);
            screen.pixels[i + k * (int) screen.width] = new Color(val, val, val).getRGB();
            curCol = curCol.getRight();
          }
          curRow = curRow.getBottom();
        }
        screen.updatePixels();
        display.stroke(255);
        display.strokeWeight(4);
        display.rect(meshLoc.x - 1, meshLoc.y - 1, 
          meshDims.x * (float) 1.01 * zoomLevel, meshDims.y * (float) 1.01 * zoomLevel);
      }
      screen.endDraw();
      newStateAvailable = false;
    }
    display.image(screen, meshLoc.x, meshLoc.y, 
      meshDims.x * zoomLevel, meshDims.y * zoomLevel);
  }

  public void updateMesh() {
    curRow = first;
    curCol = curRow;
    for (int i = 0; i < meshDims.y; i++) {
      curCol = curRow;
      for (int k = 0; k < meshDims.x; k++) {
        switch (curCol.neighbourCount()) {
        case 0:
          curCol.setNewLifeState(false);
          break;
        case 1:
          curCol.setNewLifeState(false);
          break;
        case 2:
          curCol.setNewLifeState(curCol.getState());
          break;
        case 3:
          curCol.setNewLifeState(true);
          break;
        default:
          curCol.setNewLifeState(false);
          break;
        }
        curCol = curCol.getRight();
      }
      curRow = curRow.getBottom();
    }
    newStateAvailable = true;
  }

  public void screenShot(PApplet display) {
    screen.save(display.day() + "d_" + display.month() + "m_" + display.year()
      + "yr_" + display.hour() + "h_" + display.minute() + "min.bmp");
  }

  public DisplayableCell getCell(int i, int k) {
    /*
        * i is the Column and k is the row;
     * */
    DisplayableCell current = first;
    for (int m = 1; m <= i && m < meshDims.x; m++) {
      current = current.getRight();
    }
    for (int n = 1; n <= k && n < meshDims.y; n++) {
      current = current.getBottom();
    }
    return current;
  }

  public void togglePeriodicBoundaryConditions() {
    curCol = getCell(0, 0);
    curRow = getCell(0, (int) meshDims.y);
    for (int i = 0; i < meshDims.x; i++) {
      if (!periodic) {
        curCol.setTop(curRow);
        curRow.setBottom(curCol);
      } else {
        curCol.setTop(curCol);
        curRow.setBottom(curRow);
      }
      curCol = curCol.getRight();
      curRow = curRow.getRight();
    }
    curCol = getCell(0, 0);
    curRow = getCell((int) meshDims.x, 0);
    for (int i = 0; i < meshDims.y; i++) {
      if (!periodic) {
        curCol.setLeft(curRow);
        curRow.setRight(curCol);
      } else {
        curCol.setLeft(curCol);
        curRow.setRight(curRow);
      }
      curCol = curCol.getBottom();
      curRow = curRow.getBottom();
    }
    curCol = getCell(0, 0);
    curRow = getCell(0, (int) meshDims.y);
    for (int i = 0; i < meshDims.x; i++) {
      if (!periodic) {
        curCol.setUpperLeft(curRow.getLeft());
        curCol.setUpperRight(curRow.getRight());
        curRow.setLowerLeft(curCol.getLeft());
        curRow.setLowerRight(curCol.getRight());
      } else {
        curCol.setUpperLeft(curCol);
        curCol.setUpperRight(curCol);
        curRow.setLowerLeft(curRow);
        curRow.setLowerRight(curRow);
      }
      curCol = curCol.getRight();
      curRow = curRow.getRight();
    }
    curCol = getCell(0, 0);
    curRow = getCell((int) meshDims.x, 0);
    for (int i = 0; i < meshDims.y; i++) {
      if (!periodic) {
        curCol.setUpperLeft(curRow.getTop());
        curCol.setLowerLeft(curRow.getBottom());
        curRow.setUpperRight(curCol.getTop());
        curRow.setLowerRight(curCol.getBottom());
      } else {
        curCol.setUpperLeft(curCol);
        curCol.setLowerLeft(curCol);
        curRow.setUpperRight(curRow);
        curRow.setLowerRight(curRow);
      }
      curCol = curCol.getBottom();
      curRow = curRow.getBottom();
    }
    periodic = !periodic;
  }

  public void checkPeriodicBoundaryConditions() {
    curCol = getCell(0, 0);
    curRow = getCell(0, (int) meshDims.y);
    for (int i = 0; i < meshDims.x; i++) {
      PApplet.println("Top Check", curCol.getTop() == curRow, 
        "Bottom Check", curCol == curRow.getBottom());
      curCol = curCol.getRight();
      curRow = curRow.getRight();
    }
    curCol = getCell(0, 0);
    curRow = getCell((int) meshDims.x, 0);
    for (int i = 0; i < meshDims.y; i++) {
      PApplet.println("Left Check", curCol.getLeft() == curRow, 
        "Right Check", curCol == curRow.getRight());
      curCol = curCol.getBottom();
      curRow = curRow.getBottom();
    }
    curCol = getCell(0, 0);
    curRow = getCell(0, (int) meshDims.y);
    for (int i = 0; i < meshDims.x; i++) {
      PApplet.println("UpperLeft Check", curCol.getUpperLeft() == curRow.getLeft(), 
        "UpperRight Check", curCol.getUpperRight() == curRow.getRight(), 
        "LowerLeft Check", curCol.getLeft() == curRow.getLowerLeft(), 
        "LowerRight Check", curCol.getRight() == curRow.getLowerRight());
      curCol = curCol.getRight();
      curRow = curRow.getRight();
    }
    curCol = getCell(0, 0);
    curRow = getCell((int) meshDims.x, 0);
    for (int i = 0; i < meshDims.y; i++) {
      PApplet.println("UpperLeft Check", curCol.getUpperLeft() == curRow.getTop(), 
        "UpperRight Check", curCol.getLowerLeft() == curRow.getBottom(), 
        "LowerLeft Check", curCol.getTop() == curRow.getUpperRight(), 
        "LowerRight Check", curCol.getBottom() == curRow.getLowerRight());
      curCol = curCol.getBottom();
      curRow = curRow.getBottom();
    }
  }


  public DisplayableCell getFirst() {
    return first;
  }

  public void setFirst(DisplayableCell first) {
    this.first = first;
  }

  public PVector getMeshDims() {
    return meshDims;
  }

  public void setMeshDims(PVector meshDims) {
    this.meshDims = meshDims;
  }

  public PGraphics getScreen() {
    return screen;
  }

  public void setScreen(PGraphics screen) {
    this.screen = screen;
  }

  public DisplayableCell getCurRow() {
    return curRow;
  }

  public void setCurRow(DisplayableCell curRow) {
    this.curRow = curRow;
  }

  public DisplayableCell getCurCol() {
    return curCol;
  }

  public void setCurCol(DisplayableCell curCol) {
    this.curCol = curCol;
  }

  public float getZoomLevel() {
    return zoomLevel;
  }

  public void setZoomLevel(float zoomLevel) {
    this.zoomLevel = zoomLevel;
  }

  public PVector getMeshLoc() {
    return meshLoc;
  }

  public void setMeshLoc(PVector meshLoc) {
    this.meshLoc = meshLoc;
  }

  public boolean isNewStateAvailable() {
    return newStateAvailable;
  }

  public void setNewStateAvailable(boolean newStateAvailable) {
    this.newStateAvailable = newStateAvailable;
  }

  public boolean isPeriodic() {
    return periodic;
  }

  public void setPeriodic(boolean periodic) {
    this.periodic = periodic;
  }
}