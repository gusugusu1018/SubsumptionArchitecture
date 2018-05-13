int fieldSize = 500;
int mesh = 100;
int obstacleNums = 4;
int[][] obstacles = {{100,200,50,200},
                       {300,400,200,50},
                       {200,80,80,50},
                       {150,250,100,50}};
int chargeStationNums = 1;
int[][] chargeStation = {{0,0,50,50}};

int[][] obMap = new int[mesh][mesh];

class Egent {
  // Perceptions
  int id,x,y,direction,egentSize;
  float mileage = 0.0f;
  float battery = 100.0f;
  int collisionFlag = 0;
  int next_x,next_y,next_direction;
  int exploreSize = 12;
  
  Egent (int _id, int _init_x, int _init_y, int _direction, int _size) {
    id = _id;
    x = _init_x;
    y = _init_y;
    direction = _direction;
    egentSize = _size;
    next_x = _init_x;
    next_y = _init_y;
    next_direction = _direction;
  }

  int detectCollision(int _x,int _y){
    int i,j;
    int d = fieldSize/mesh;
    int l = floor(_x/d)-egentSize/2;
    int m = floor(_y/d)-egentSize/2;
    for (i = l;i<l+egentSize;i++) {
      for (j = m;j<m+egentSize;j++) {
        if (!((i>=0)&&(i<mesh)&&(j>=0)&&(j<mesh)) || (obMap[i][j]==1)) {
          return 1;
        } else {
          obMap[i][j]=3;
        }
      }
    }
    /*
    if ((_x<0)||(_x>fieldSize)||(_y<0)||(_y>fieldSize)) {
      return 1;
    }s
    int i;
    for (i=0;i<obstacleNums;i++){
      if ((_x > obstacles[i][0]) && (_x < obstacles[i][0] + obstacles[i][2])
        && (_y > obstacles[i][1]) && (_y < obstacles[i][1] + obstacles[i][3])) {
        return 1;
      }
    }*/
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

  void batteryMonitor(float _d) {
    int i;
    for (i=0;i<1;i++){
      if ((x > chargeStation[i][0]) && (x < chargeStation[i][0] + chargeStation[i][2])
        && (y > chargeStation[i][1]) && (y < chargeStation[i][1] + chargeStation[i][3])) {
          if (battery<100.0f) {
	    battery += 10.0f;
            if (battery >100.0f) {
              battery = 100.0f;
              print("battery full!\n");
            }
          } else {
            print("battery full!\n");
          }
      } else {
        battery -= _d*0.1f;
      }
    }
    if (battery<0.0f) {
      print("battery down!\n");
      //noLoop();
    }
  }
  
  void locationUpdate() {
    float d = sqrt(pow((x - next_x),2) + pow((y - next_y),2));
    mileage += d;
    x = next_x;
    y = next_y;
    direction = next_direction;
    batteryMonitor(d);
  }
  
  void wander() {
    turn((int)random(-30,30));
    goForward((int)random(3,5));
    //(int)random(-30,30);
    //4;
  }
  
  void avoidCollision() {
      //turn(60);
      //turn((int)random(120,240));
      turn((int)random(-90,90));
      next_x = x;
      next_y = y;
      locationUpdate();
  }
  
  void explore(){
    int i,j;
    int d = fieldSize/mesh;
    int l = floor(x/d)-exploreSize/2;
    int m = floor(y/d)-exploreSize/2;
    int counter = 0;
    int buf_x=x;
    int buf_y=y;
    
    for (i = l;i<l+exploreSize;i++) {
      for (j = m;j<m+exploreSize;j++) {
        
        if (((i>=0)&&(i<mesh)&&(j>=0)&&(j<mesh)) && (obMap[i][j]==0)) {
          counter++;
          buf_x = i*fieldSize/mesh;
          buf_y = j*fieldSize/mesh;
          /*
          float a = atan(float(y-j*fieldSize/mesh)/float(x-i*fieldSize/mesh))/PI;
          next_direction = int(a);
          //next_x = i*fieldSize/mesh;
          //next_y = j*fieldSize/mesh;
          turn((int)random(-30,30));
          int r = (int)random(3,5);
          //int r = 2;
          next_x += r*cos(radians(next_direction-90));
          next_y += r*sin(radians(next_direction-90));
        } else {
          turn((int)random(-30,30));
          int r = (int)random(3,5);
          //int r = 2;
          next_x += r*cos(radians(next_direction-90));
          next_y += r*sin(radians(next_direction-90));
          */
        }
      }
    }
    if (counter>0) {
      float a = atan(float(y-buf_y)/float(x-buf_x))/PI;
      next_direction = int(a);
      turn((int)random(-10,10));
      int r = (int)random(3,5);
      //int r = 2;
      next_x += r*cos(radians(next_direction-90));
      next_y += r*sin(radians(next_direction-90));
    } else {
      wander();
    }
  }

  void move() {
    //wander();
    //turn();
    //goForward();
    explore();
    int ret = detectCollision(next_x,next_y);
    if (ret==1) {
      print("detect collision\n");
      avoidCollision();
      print("x="+x+",y="+y+",d="+direction+",mile="+mileage+",bat="+battery+"\n");
    } else {
      locationUpdate();
      print("x="+x+",y="+y+",d="+direction+",mile="+mileage+",bat="+battery+"\n");
    }
  }
  
  void display() {
    // egent
    fill(180);
    int d = fieldSize/mesh;
    rect(floor(x/d)*d-egentSize/2*d,floor(y/d)*d-egentSize/2*d,egentSize*d,egentSize*d);
    /*
    // path
    int i,j;
    int l = floor(x/d)-egentSize/2;
    int m = floor(y/d)-egentSize/2;
    for (i = l;i<l+egentSize;i++) {
      for (j = m;j<m+egentSize;j++) {
        if ((i>=0)&&(i<mesh)&&(j>=0)&&(j<mesh)) obMap[i][j]=3;
      }
    }
    */
    // direction
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

  void update() {
    move();
    display();
  }
}

void MapDisplay() {
  int i,j;
  for (i=0;i<mesh;i++) {
    for (j=0;j<mesh;j++) {
      if (obMap[i][j] == 1) {
        stroke(0);
        fill(125);
      } else if (obMap[i][j] == 2) {
        stroke(0,255,0);
        fill(0,255,0);//green
      } else if (obMap[i][j] == 3) {
        stroke(0);
        fill(0,0,255);//blue
      } else {
        stroke(0);
        fill(255);
      }
      rect(i*fieldSize/mesh,j*fieldSize/mesh,fieldSize/mesh,fieldSize/mesh);
    }
  }
}

void makeMap() {
  background(255);
  int i,j,k;
  int d = fieldSize/mesh;
  for (i=0;i<mesh;i++) {
    for (j=0;j<mesh;j++) {
      // initilize
      obMap[i][j]=0;
      // obstacles
      for (k=0;k<obstacleNums;k++){
        if ((i*d >= obstacles[k][0]) && (i*d <= obstacles[k][0] + obstacles[k][2])
          && (j*d >= obstacles[k][1]) && (j*d <= obstacles[k][1] + obstacles[k][3])) {
          obMap[i][j]=1;
        }
      }
      // charge Stations
      for (k=0;k<chargeStationNums;k++){
        if ((i*d >= chargeStation[k][0]) && (i*d < chargeStation[k][0] + chargeStation[k][2])
          && (j*d >= chargeStation[k][1]) && (j*d < chargeStation[k][1] + chargeStation[k][3])) {
          obMap[i][j]=2;
        }
      }
    }
  }
}

Egent egent1;

void setup() {
  // For Processing 3.0
  //surface.setResizable(true);
  //surface.setSize(fieldSize, fieldSize);
  // For Processing 2.0
  size(fieldSize,fieldSize);

  // make egent and map
  egent1 = new Egent(1,50,50,120,6);
  makeMap();
}

void draw() {
  MapDisplay();
  egent1.update();
}
