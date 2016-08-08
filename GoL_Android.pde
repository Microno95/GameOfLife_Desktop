/*
 * COLOUR CODES
 * 
 * new Color(48, 120, 245, 128) : Faded Navy Blue
 * 
 * new Color(128, 128, 128, 80) : Light Grey
 * 
 * 
 * MESH LIMITATIONS 
 * 
 * No more than 100,000 cells, otherwise too sluggish (FPS drops to 2).
 * 
 */

import processing.core.PVector;

int displayWidth = width, displayHeight = height;

public void settings() {
  size(1000, 1000, P2D);
}

static int genStepFPS = 1;
static float inc = (float) 0.025;
static boolean runGen = true, plusHeld = false, negHeld = false;
CellMesh GoL_Mesh;

public void setup() {
  hint(DISABLE_TEXTURE_MIPMAPS);
  ((PGraphicsOpenGL)g).textureSampling(2);
  frameRate(60);
  background(0);
  GoL_Mesh = new CellMesh(this, false, new PVector(5, 5), new PVector(10, 10), 
    new Color(128, 128, 128, 80), new PVector(100, 100), new PVector(40, 40));
  GoL_Mesh.createMesh(1, this);
  GoL_Mesh.togglePeriodicBoundaryConditions();
  //GoL_Mesh.checkPeriodicBoundaryConditions();

  DisplayableCell baseCell = GoL_Mesh.getCell(10, 50);

  // BEACON
  baseCell.getLowerRight().setState(true);
  baseCell.getLowerRight().getRight().setState(true);
  baseCell.getLowerRight().getBottom().setState(true);
  baseCell.getLowerRight().getLowerRight().getLowerRight().getLowerRight().setState(true);
  baseCell.getLowerRight().getLowerRight().getLowerRight().getLowerRight().getTop().setState(true);
  baseCell.getLowerRight().getLowerRight().getLowerRight().getLowerRight().getLeft().setState(true);

  // BLINKER
  GoL_Mesh.getCell(20, 90).getBottom().setState(true);
  GoL_Mesh.getCell(20, 90).getBottom().getRight().setState(true);
  GoL_Mesh.getCell(20, 90).getBottom().getRight().getRight().setState(true);

  //GLIDER - x_ controls the leftmost x, and y_ controls the topmost y_;
  int x_ = 0, y_ = 0;
  GoL_Mesh.getCell(x_ + 1, y_).setState(true);
  GoL_Mesh.getCell(x_ + 2, y_ + 1).setState(true);
  GoL_Mesh.getCell(x_ + 2, y_ + 2).setState(true);
  GoL_Mesh.getCell(x_ + 1, y_ + 2).setState(true);
  GoL_Mesh.getCell(x_, y_ + 2).setState(true);
  
  x_ = 5;
  y_ = 0;
  GoL_Mesh.getCell(x_ + 2, y_ + 1).setState(true);
  GoL_Mesh.getCell(x_ + 3, y_ + 2).setState(true);
  GoL_Mesh.getCell(x_ + 3, y_ + 3).setState(true);
  GoL_Mesh.getCell(x_ + 2, y_ + 3).setState(true);
  GoL_Mesh.getCell(x_ + 1, y_ + 3).setState(true);
  
  
}

public void draw() {
  background(0);
  if (frameCount % genStepFPS == 0 && runGen) {
    GoL_Mesh.updateMesh();
  }
  GoL_Mesh.displayMesh(this);
  if (mousePressed) {
    GoL_Mesh.getMeshLoc().add(new PVector(mouseX - pmouseX, mouseY - pmouseY));
  }
  if (plusHeld && !negHeld) {
    GoL_Mesh.setZoomLevel(GoL_Mesh.getZoomLevel() * (1 + inc));
  } else if (negHeld && !plusHeld) {
    GoL_Mesh.setZoomLevel(GoL_Mesh.getZoomLevel() * (1 - inc));
  }
  textSize(28 * (float) (1000 * 1000) / (width * height));
  fill(255);
  text("FPS: " + frameRate, 0, 28 * (float) 1000 / height);
  text("GenStep: " + genStepFPS, (width - 200) * (float) 1000 / width, 
    28 * (float) 1000 / height);
}

public void keyPressed() {
  if (key == ' ') {
    runGen = !runGen;
  }
  if (key == 's' || key == 'S') {
    GoL_Mesh.screenShot(this);
  }
  if (keyCode == UP) {
    genStepFPS++;
  } else if (genStepFPS > 1 && keyCode == DOWN) {
    genStepFPS--;
  }
  if (key == '+') {
    plusHeld = true;
    negHeld = false;
  } else if (key == '-') {
    plusHeld = false;
    negHeld = true;
  }
  if (key == 'r' || key == 'R') {
    setup(); 
  }
}

public void keyReleased() {
  if (key == '-') {
    negHeld = false;
  } else if (key == '+') {
    plusHeld = false;
  }
}