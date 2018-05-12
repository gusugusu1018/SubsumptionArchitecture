int xmax = 500;
int ymax = 500;
int[][] obstacles = {{100,200,50,200},
                       {300,400,200,50},
                       {200,80,80,50},
                       {150,250,100,50}};

class Egent {
  int x,y,direction;
  int next_x,next_y,next_direction;
  
  Egent (int _init_x, int _init_y, int _direction) {
    x = _init_x;
    y = _init_y;
    direction = _direction;
    next_x = _init_x;
    next_y = _init_y;
    next_direction = _direction;
  }

  int detectCollision(int _x,int _y){
    if ((_x<0)||(_x>xmax)||(_y<0)||(_y>ymax)) {
      return 1;
    }
    int i;
    for (i=0;i<4;i++){
      if ((_x > obstacles[i][0]) && (_x < obstacles[i][0] + obstacles[i][2])
        && (_y > obstacles[i][1]) && (_y < obstacles[i][1] + obstacles[i][3])) {
        return 1;
      }
    }
    return 0;
  }

  void turn(int _a) {
    next_direction = direction + _a;
    if (next_direction > 360) {
      next_direction -= 360;
    } else if (next_direction < -360) {
      next_direction += 360;
    }
  }
  
  void goForward(float _r) {
    next_x = x;
    next_y = y;
    next_x += _r*cos(radians(next_direction-90));
    next_y += _r*sin(radians(next_direction-90));
  }
  
  void locationUpdate() {
    x = next_x;
    y = next_y;
    direction = next_direction;
  }

  void move() {
    turn((int)random(-30,30));
    goForward(4);
    int ret;
    ret = detectCollision(next_x,next_y);
    if (ret==1) {
//      noLoop();
      print("detect collision\n");
      print("x="+next_x+",y="+next_y+",d="+next_direction+"\n");
      print("Turn\n");
      turn(60);
      next_x = x;
      next_y = y;
      locationUpdate();
    } else {
      locationUpdate();
      print("x="+x+",y="+y+",d="+direction+"\n");
    }
  }

  void update() {
    move();
    pushMatrix();
    translate(x, y);
    rotate(radians(-90));
    fill(125,125,255);
    beginShape();
    vertex(15*cos(radians(direction)), 15*sin(radians(direction)));
    vertex(10*cos(radians(120+direction)), 10*sin(radians(120+direction)));
    vertex(1*cos(radians(180+direction)), 1*sin(radians(180+direction)));
    vertex(10*cos(radians(240+direction)), 10*sin(radians(240+direction)));
    endShape(CLOSE);
    popMatrix();
  }
}
void obstacleDisplay() {
  int i;
  for (i=0;i<4;i++) {
    rect(obstacles[i][0],obstacles[i][1],obstacles[i][2],obstacles[i][3]);
  }
  fill(255,255,255);
}

Egent egent1;

void setup() {
  surface.setResizable(true);
  surface.setSize(xmax, ymax);
  //size(xmax,ymax);
  egent1 = new Egent(50,50,120);
  obstacleDisplay();
  egent1.update();
}

void mapdraw() {
  background(255,255,255);
  stroke(0);
  fill(0,0,0);
  obstacleDisplay();
  egent1.update();
}

void draw() {
  mapdraw();
  //noLoop();
}
