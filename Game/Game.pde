//Classes and enumeration definitions
class Mover {

  //Position field definition
  
  private final PVector location;
  private final PVector velocity;
  
  //Force field definition
  
  private final PVector gravity;
  private final PVector friction;
  
  //Constants
  
  private final float gravityConstant;
  private final float frictionMagnitude;
  private final int   ballRadius;
  private final int   plateDimensions;
  private final int   collisionDistance;
    
  //Constructor
  
  Mover(float gravityConstant, float frictionMagnitude, int ballRadius, int plateDimensions, int cylinderBaseSize) {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    
    gravity = new PVector(0, 0, 0);
    this.gravityConstant = gravityConstant;
    
    friction = new PVector(0, 0, 0);
    this.frictionMagnitude = frictionMagnitude;
    
    this.ballRadius = ballRadius;
    this.plateDimensions = plateDimensions;
    collisionDistance = cylinderBaseSize + ballRadius;
  }
  
  //Changes gravity force and friction then updates velocity and location
  
  void update(float rotationX, float rotationZ) {
    gravity.x = sin(rotationZ) * gravityConstant;
    gravity.z = sin(rotationX) * gravityConstant;   
    
    friction.x = velocity.x;
    friction.y = velocity.y;
    friction.z = velocity.z;
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
    
  }
  
  //Checks if there is a collision with the edges of the plate
  
  void checkEdges() {
     if (location.x > plateDimensions / 2) {
      velocity.x = -abs(velocity.x);
      location.x = plateDimensions / 2;
    } else if (location.x < -plateDimensions / 2) {
      velocity.x = abs(velocity.x);
      location.x = - plateDimensions / 2;
    }
    if (location.z > plateDimensions / 2) {
      velocity.z = -abs(velocity.z);
      location.z= plateDimensions / 2;
    } else if (location.z < -plateDimensions / 2) {
      velocity.z = abs(velocity.z);
      location.z= - plateDimensions / 2;
    }
  }
  
  //Checks if there is a collision with a cylinder  
  
  void checkCylinderCollision(ArrayList<PVector> cylinders) {
    for(PVector cylinder : cylinders) {
      float distance = sqrt(((location.x - cylinder.x) * (location.x - cylinder.x)) + ((location.z - cylinder.z) * (location.z - cylinder.z)));
      if(distance <= collisionDistance) {
        PVector normalVector = PVector.sub(location, cylinder);
        normalVector.normalize();
        normalVector.mult(PVector.dot(velocity, normalVector) * 2);
        velocity.sub(normalVector);
      }
    }
  }
  
  //Displays the ball
  
  void display() {
    fill(122, 187, 180);
    translate(location.x, location.y, location.z);
    sphere(ballRadius);
  }
}

class Cylinder {
  
  //Fields
  
  PShape shape            = new PShape();
  PShape openCylinder     = new PShape(); 
  PShape topOfCylinder    = new PShape();
  PShape bottomOfCylinder = new PShape();
  
  
  //Constructor
  
  Cylinder(float cylinderBaseSize, float cylinderHeight, int cylinderResolution) {
    shape = createShape(GROUP);
    
    float angle;
    float[] x = new float[cylinderResolution + 1]; 
    float[] y = new float[cylinderResolution + 1];

    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i; 
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    
    //Open cylinder
    
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    for (int i = 0; i < x.length; i++) { 
      openCylinder.vertex(x[i], 0, y[i]); 
      openCylinder.vertex(x[i], -cylinderHeight, y[i]);
    }
    openCylinder.endShape();
    
    shape.addChild(openCylinder);
  
    //Top of the cylinder
    
    topOfCylinder = createShape();
    topOfCylinder.beginShape(TRIANGLE_FAN);
    topOfCylinder.vertex(0, -cylinderHeight, 0);
    for (int i = 0; i< x.length; i++) {
      topOfCylinder.vertex(x[i], -cylinderHeight, y[i]);
    }
    topOfCylinder.endShape();
    
    shape.addChild(topOfCylinder);
    
    //Bottom of the cylinder
    
    bottomOfCylinder = createShape();
    bottomOfCylinder.beginShape(TRIANGLE_FAN);
    bottomOfCylinder.vertex(0, 0, 0);
    for (int i = 0; i< x.length; i++) {
      bottomOfCylinder.vertex(x[i], 0, y[i]);
    }
    bottomOfCylinder.endShape();
    
    shape.addChild(bottomOfCylinder);
  }
}

enum Mode {
  DRAWING, GAME
};

//Plate definition

final int   plateWidth      = 10;
final int   plateDimensions = 500;

//Plate movement speed

float       speedValue           = 1;
final float speedValueLowerLimit = 0.2;
final float speedValueUpperLimit = 1.6;

//Plate tilting angle

float       angleValueX = 0;
float       angleValueY = 0;
final float limitAngle  = PI/3;
final float drawingX    = 0;
final float drawingY    = -PI/2;

//Mover

Mover       mover;
final int   ballRadius        = 24;
final float gravityConstant   = 0.1;
final float frictionMagnitude = 0.01;

//Cylinders

Cylinder           cylinder;
int                cylinderBaseSize   = 20; 
int                cylinderHeight     = 50; 
int                cylinderResolution = 40;
ArrayList<PVector> cylinders          = new ArrayList<PVector>();

//Mode definition
Mode mode = Mode.GAME;

//Settings

void settings() {
  size(1920, 1000, P3D);
}

//Sketch setup

void setup() {
  noStroke();
  mover    = new Mover(gravityConstant, frictionMagnitude, ballRadius, plateDimensions, cylinderBaseSize);
  cylinder = new Cylinder(cylinderBaseSize, cylinderHeight, cylinderResolution);
}

//Mode Setup Functions

void gameMode() {
  mode = Mode.GAME;
}

void drawingMode() {
  mode = Mode.DRAWING;
}

boolean isInDrawingMode() {
  return mode == Mode.DRAWING;
}

//Drawing function
void draw() {

  //SETTINGS :

  camera();
  ambientLight(102, 102, 102);
  if (isInDrawingMode()) {
    directionalLight(50, 100, 125, 0, 0, -1);
  } else {
    directionalLight(50, 100, 125, 1, 1, 0);
  }
  background(255);

  //DRAWING :

  //Speed value limit definition
  
  if (speedValue <= speedValueLowerLimit) {
    speedValue = speedValueLowerLimit;
  } else if (speedValue >= speedValueUpperLimit) {
    speedValue = speedValueUpperLimit;
  } 

  //Angle limit definition

  if (angleValueX < -limitAngle) {
    angleValueX = -limitAngle;
  } else if (angleValueX > limitAngle) {
    angleValueX = limitAngle;
  } 
  if (angleValueY < -limitAngle) {
    angleValueY = -limitAngle;
  } else if (angleValueY > limitAngle) {
    angleValueY = limitAngle;
  } 

  //Translation, rotation and drawing of the plate
  
  pushMatrix();
  translate(width/2, height/2, 0);
  if (isInDrawingMode()) { //Places the plate with a view from above
    rotateX(drawingY);
    rotateZ(drawingX);
  } else { //rotates the plate normally
    rotateX(-angleValueY);
    rotateZ(angleValueX);
  }
  box(plateDimensions, plateWidth, plateDimensions);

  //Cylinders drawing 
  
  for (int i = 0; i < cylinders.size(); i++) {
    PVector vec = cylinders.get(i);
    pushMatrix();
    translate(vec.x, -(plateWidth / 2), vec.z);
    shape(cylinder.shape);
    popMatrix();
  } 

  //Ball drawing
  
  pushMatrix();
  if (!isInDrawingMode()) { //Only draws the ball when in gaming mode
    translate(0, -(plateWidth / 2) - ballRadius, 0);
    mover.update(angleValueY, angleValueX);
    mover.checkEdges();
    mover.checkCylinderCollision(cylinders);
    mover.display();
  }
  popMatrix();
  popMatrix();
}

//Method that checks if the mouse is inside the box while in drawing mode

boolean checkIfMouseIsInThePlate() {
  if ((mouseX - (width / 2) >= ((plateDimensions / 2) - cylinderBaseSize)) || mouseX - (width / 2) <= -((plateDimensions / 2) - cylinderBaseSize)) {
    return false;
  } else {
    return ((mouseY - (height / 2) <= ((plateDimensions / 2) - cylinderBaseSize)) && mouseY - (height / 2) >= -((plateDimensions / 2) - cylinderBaseSize));
  }
}

//Method that adds a cylinder to the array

void addCylinder() {  
  cylinders.add(new PVector( -(width / 2 - mouseX), 0, -(height / 2 - mouseY)));
}

//User interaction methods

void mouseDragged() {
  if (!isInDrawingMode()) {
    angleValueX += map(mouseX - pmouseX, -width / 2, width / 2, -PI, PI) * speedValue;
    angleValueY += map(mouseY - pmouseY, -height / 2, height / 2, -PI, PI) * speedValue;
  }
}

void mousePressed() {
  if (isInDrawingMode() && checkIfMouseIsInThePlate()) {
    addCylinder();
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  speedValue = speedValue + (0.1 * e);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      drawingMode();
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      gameMode();
    }
  }
}