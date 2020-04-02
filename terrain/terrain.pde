// Daniel Shiffman
// http://codingtra.in

import oscP5.*;

//OSC receive
OscP5 oscP5;
OscP5 oscP5Send;

int cols, rows;
int scl = 20;
int w = 3000;
int h = 1600;

float stretchMin = -10;
float stretchMax = 10;

float flying = 0;
float flyFactor = 0;

float stretchFactor = 0;

float[][] terrain;

void setup() {
  fullScreen(P3D); 
  cols = w / scl;
  rows = h/ scl;
  terrain = new float[cols][rows];
  
  oscP5 = new OscP5(this, 12010);
  oscP5Send = new OscP5(this, 12011);
}

void calculateStretch(){
  //stretchMin = -stretchFactor;
  stretchMax = map(stretchFactor, 35, 400, 10, 300);
  stretchMin = -stretchMax;
}

void sendPerlinNoise(float x, float y, float z) {
  OscMessage myMessage = new OscMessage("/perlin");
  
  // sends the the coordinates of the perlin nosie
  myMessage.add(x);
  myMessage.add(y);
  myMessage.add(z);
  
  /* send the message */
  oscP5Send.send(myMessage, "127.0.0.1", 12011);
}


void draw() {
  
  calculateStretch();

  //flying -= 0.001;
  flying -= flyFactor;

  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff), 0, 1, stretchMin, stretchMax);
      
      //sendPerlinNoise(x, y, terrain[x][y]);
      
      xoff += 0.2;
    }
    yoff += 0.2;
  }



  background(0);
  noFill();

  translate(width/2, height/2+50);
  rotateX(PI/3);
  translate(-w/2, -h/2);
  for (int y = 0; y < rows-1; y++) {
    
    //strokeWeight(map(y, 0, rows-1, .0001, 1.5));
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      
      stroke(map(terrain[x][y], stretchMin, stretchMax, 100, 200) , map(x,0,cols,0,250),map(y,0,rows-1,0,250));
      
      vertex(x*scl, y*scl, terrain[x][y]);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
      //rect(x*scl, y*scl, scl, scl);
    }
    endShape();
  }
}

void oscEvent(OscMessage theOscMessage) {
  
  // recieves a value for the speed from MAX based
  // on the note being played (slow = low)
  
  if (theOscMessage.checkAddrPattern("/leftX")) {
    
    float value = theOscMessage.get(0).floatValue();
    flyFactor = map(value, -300, 300, 0.001, 0.12);
    
    print(flyFactor, "\n");
  }
  else if (theOscMessage.checkAddrPattern("/leftY")) {
    
    stretchFactor = theOscMessage.get(0).floatValue();
    
    print(stretchFactor, "\n");
  }
}


//stroke(7,153,242,alpha);
//stroke(255,255,255,alpha);
