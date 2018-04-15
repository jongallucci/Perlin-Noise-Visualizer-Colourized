float scl = 10;
int rows, cols;
PVector[] flow;
int numberOfParticles = 10000; 
Particle[] pars;

void setup() {
  size(3800, 2100);
  background(0);
  hint(DISABLE_DEPTH_MASK);

  colorMode(HSB, 255);
  rows = floor(width / scl);
  cols = floor(height / scl);
  flow = new PVector[(cols * rows)];

  pars = new Particle[numberOfParticles];
  for (int numPar = 0; numPar < pars.length; numPar++) {
    pars[numPar] = new Particle();
  }
}

float inc = 0.2;
float speed = 5;
float xoff;
float yoff;
float zoff;

void draw() {
  strokeWeight(5);
  yoff = 0;
  for (int y = 0; y < rows; y++) {
    xoff = 0;
    for (int x = 0; x < cols; x++) {
      float angle = noise(xoff, yoff, zoff) * TWO_PI * 4;
      PVector v = PVector.fromAngle(angle);
      v.setMag(0.5);
      int index = (x + y * cols);
      flow[index] = v;
      xoff += inc;

      //stroke(255);
      //pushMatrix();
      //translate(y * scl, x * scl);
      //rotate(v.heading());
      //line(0, 0, scl, 0);
      //popMatrix();
    }
    yoff += inc;
  }
  //zoff += 0.0005;

  for (int numPar = 0; numPar < pars.length; numPar++) {
    pars[numPar].Follow(flow);
    pars[numPar].Update();
    pars[numPar].Edges();
    pars[numPar].Show();
  }
}

////////////////////////
class Particle {
  PVector pos, vel, acc, prevPos;
  int maxSpeed = 8;
  int c = 0;

  Particle() {
    pos = new PVector (random(width), random(height));
    vel = new PVector (0, 0);
    acc = new PVector (0, 0);
    prevPos = pos.copy();
  }

  void UpdatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
  }

  void Update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void ApplyForce(PVector force) {
    acc.add(force);
  }

  void Show() {
    stroke(c, 255, 255, 12);
    c += 1;
    if (c > 255) c = 0;
    strokeWeight(4); //4
    //point(pos.x, pos.y);
    line(pos.x, pos.y, prevPos.x, prevPos.y);
    UpdatePrev();
  }

  void Edges() {
    if (pos.x > width) {
      pos.x = 0;
      UpdatePrev();
    }
    if (pos.x < 0) {
      pos.x = width;
      UpdatePrev();
    }
    if (pos.y > height) {
      pos.y = 0;
      UpdatePrev();
    }
    if (pos.y < 0) {
      pos.y = height;
      UpdatePrev();
    }
  }
  void Follow(PVector[] flow) {
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);

    int index = (x-1) + ((y-1) * cols);
    index = index - 1;
    if (index > flow.length || index < 0) {
      index = flow.length - 1;
    }
    PVector force = flow[index];
    ApplyForce(force);
  }
}
