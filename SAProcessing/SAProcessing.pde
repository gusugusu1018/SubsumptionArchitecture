int xmax = 500;
int ymax = 500;
int[][] obstacles = {{100,200,50,200},
                       {300,400,200,50},
                       {200,80,80,50},
                       {150,250,100,50}};
int[][] chargeStation = {{0,0,50,50}};

class Egent {
  // Perceptions
  int id,x,y,direction,size;
	float mileage = 0.0f;
	float battery = 100.0f;
	int collisionFlag = 0;

  int next_x,next_y,next_direction;
  
  Egent (int _id, int _init_x, int _init_y, int _direction, int _size) {
		id = _id;
    x = _init_x;
    y = _init_y;
    direction = _direction;
		size = _size;
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
				noLoop();
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
    //turn((int)random(-30,30));
    //goForward(4);
    (int)random(-30,30);
		4;
	}

  void move() {
	  wander();
    turn();
    goForward();
    int ret = detectCollision(next_x,next_y);
    if (ret==1) {
      print("detect collision\n");
      print("Turn\n");
      turn(60);
      next_x = x;
      next_y = y;
      locationUpdate();
		  print("x="+x+",y="+y+",d="+direction+",mile="+mileage+",bat="+battery+"\n");
    } else {
      locationUpdate();
		  print("x="+x+",y="+y+",d="+direction+",mile="+mileage+",bat="+battery+"\n");
    }
  }

	void display() {
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

void obstacleDisplay() {
  fill(0);
  int i;
  for (i=0;i<4;i++) {
    rect(obstacles[i][0],obstacles[i][1],obstacles[i][2],obstacles[i][3]);
  }
}

void chargeStationDisplay() {
  fill(0,255,0);
  int i;
  for (i=0;i<1;i++) {
    rect(chargeStation[i][0],chargeStation[i][1],chargeStation[i][2],chargeStation[i][3]);
  }
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
	chargeStationDisplay();
  egent1.update();
}

void draw() {
  mapdraw();
  //noLoop();
}
