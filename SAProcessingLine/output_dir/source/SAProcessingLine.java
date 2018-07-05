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
int agentStatus = 0;//0 defined as running //1 defined as charging
int finCharge = 0;//0 defined as not fin //1 defined as fin
int step=1;
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
   checkGoal(agentPos);
   drawEnv();
   drawAgent(agentPos);
   //println(step+" step, battery : "+batteryStatus);
   //ruleBaseBehaiv();
   // ALIVE
   int actionAlive=2;//2 defined as no signal
   int impAlive=0;// 0~100
   if (agentStatus==1) {
      if (finCharge==1) {
         actionAlive = 2;
         impAlive = 0;
         agentStatus = 0;
      } else {
         actionAlive = 0;
         impAlive = 100;
      }
   } else {
      if (batteryStatus<=30) {
         if (VisionScope[scopeRange]==1) {
            actionAlive=0;
            agentStatus=1;
            impAlive=100*(int)(1.0f-sin((float)batteryStatus*2.0f*PI/400.0f));
         } else {
            int tempdist = 100;//100 defined as not found
            for (int i=1;i<scopeRange;i++) {
               if (VisionScope[scopeRange+i]==1) {
                  tempdist=i;
                  break;
               }
               if (VisionScope[scopeRange-i]==1) {
                  tempdist=-i;
                  break;
               }
            }
            if (tempdist==100) {
               actionAlive=2;//no signal
               impAlive=0;//no signal
            } else {
               if (tempdist<0) actionAlive=-1;
               else actionAlive=1;
               impAlive = 100*(int)(1.0f-sin((float)abs(tempdist)*2.0f*PI/40.0f));
            }
         }
      } else {
         actionAlive=2; //no signal
         impAlive=0;//no signal
      }
   }
   // PROGRESS
   int actionProgress=2;
   int impProgress=0;
   float progressRate = 1.0f-(float)agentPos/((float)step);
   actionProgress=1;
   impProgress=(int)(100.0f*progressRate);
   println(impProgress+" "+progressRate);
   int tempgoal = 100;//100 defined as not found
   for (int i=1;i<scopeRange;i++) {
      if (VisionScope[scopeRange+i]==1) {
         tempgoal=i;
         break;
      }
   }
   if (tempgoal<=10) {
      impProgress = 80;
   }

   // Arbiter
   if (actionAlive==2) agentMove(actionProgress);
   else agentMove(actionAlive);
   step++;
}
public void agentMove(int src) {
   if (src!=0) {
      agentPos+=src;
      batteryStatus-=proceedCost;
      finCharge=0;
   } else {
      batteryCharge();
   }
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
public void batteryCharge() {
   batteryStatus+=10;
   println("Battery Charge");
   if (batteryStatus>100) {
      batteryStatus=100;
      finCharge=1;
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
public void ruleBaseBehaiv(){
     if (batteryStatus<30) {
      if (VisionScope[scopeRange]==1) {
         //null
      } else {
         for (int i=1;i<scopeRange;i++) {
            if (VisionScope[scopeRange+i]==1) {
               agentPos++;
               batteryStatus-=proceedCost;
               break;
            }
            if (VisionScope[scopeRange-i]==1) {
               agentPos--;
               batteryStatus-=proceedCost;
               break;
            }
            //null
         }
      }
   } else {
      agentPos++;
      batteryStatus-=proceedCost;
   }
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
