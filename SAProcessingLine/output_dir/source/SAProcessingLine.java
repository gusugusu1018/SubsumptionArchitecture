import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SAProcessingLine extends PApplet {

int meshSize = 10;
int blockNums = 100;
int fieldSize;
int[] Map;
int proceedCost = 3;
int agentPos;
int batteryStatus;
int scopeRange = 10;
int[] VisionScope;
public void setup() {
   frameRate(20);
   fieldSize = meshSize * blockNums;
   size(fieldSize,meshSize*10);
   agentPos = 0;
   batteryStatus = 100;
   Map = new int[blockNums+scopeRange+1];
   Map[0] = 2; // start
   for (int i=1;i<blockNums-1;i++) {
      if (random(100)<90) Map[i] = 0; // normal block
      else Map[i] = 1; // random battery charger
      if (i%20==0) Map[i]=1; // static battery charger
   }
   Map[blockNums-1] = 3; // goal
   VisionScope = new int[scopeRange*2+1];
   for (int i=0;i<scopeRange*2+1;i++) VisionScope[i] = 0;
}
public void draw() {
   sensing(agentPos);
   checkBattery(batteryStatus);
   batteryCharge(agentPos);
   checkGoal(agentPos);
   drawEnv();
   drawAgent(agentPos);
   println(batteryStatus);
   agentPos++;
   batteryStatus-=3;
}
public void drawEnv() {
   for (int i=0;i<blockNums;i++) {
      switch(Map[i]) {
         case 0 : fill(255);break; // normal
         case 1 : fill(0,255,0);break; // battery charger
         default : fill(255,0,0);break; // start gloal
      }
      rect(meshSize*i,0,meshSize,meshSize);
   }
}
public void drawAgent(int mypos) {
   fill(0);
   rect(0,meshSize,fieldSize,meshSize);
   for (int i=0;i<scopeRange*2+1;i++) {
      switch(VisionScope[i]) {
         case 0 : fill(255);break; // normal
         case 1 : fill(0,255,0);break; // battery charger
         default : fill(255,0,0);break; // start gloal
      }
      if (mypos-scopeRange+i>=0)
         rect(meshSize*(mypos-scopeRange+i),meshSize,meshSize,meshSize);
   }
   fill(0,0,255);
   rect(mypos*meshSize,meshSize,meshSize,meshSize);
}
public void batteryCharge(int mypos) {
   if (Map[mypos]==1) {
      batteryStatus++;
      println("Battery Charge");
   }
}
public void checkGoal(int mypos) {
   if (Map[mypos]==3) {
      println("Goal");
      noLoop();
   }
}
public void checkBattery(int battery) {
   if (battery < 0) {
      println("Battry Down");
      noLoop();
   }
}
public void sensing(int mypos) {
   for (int i=0;i<scopeRange*2+1;i++) {
      // i=scopeRange == mypos
      if (mypos-scopeRange+i>=0) VisionScope[i] = Map[mypos-scopeRange+i];
   }
}
public void aliveBehav() {
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SAProcessingLine" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
