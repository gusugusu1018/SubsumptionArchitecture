int meshSize = 10;
int blockNums = 100;
int fieldSize;
int[] Map;
int proceedCost = 3;
int agentPos;
int batteryStatus;
int scopeRange = 10;
int[] VisionScope;
void setup() {
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
void draw() {
   sensing(agentPos);
   checkBattery(batteryStatus);
   checkGoal(agentPos);
   drawEnv();
   drawAgent(agentPos);
   println(batteryStatus);
   //ruleBaseBehaiv();
   int actionAlive=2;
   int impAlive=0;
   if (batteryStatus<=20) {
      if (VisionScope[scopeRange]==1) {
         actionAlive=0;
      } else {
         for (int i=1;i<scopeRange;i++) {
            if (VisionScope[scopeRange+i]==1) {
               actionAlive=1;
               break;
            }
            if (VisionScope[scopeRange-i]==1) {
               actionAlive=-1;
               break;
            }
         }
      }
   }
   int actionProgress=2;
   if (batteryStatus<=60 && VisionScope[scopeRange]==1){
      for (int i=1;i<scopeRange;i++) {
         if (VisionScope[scopeRange+i]==1) {
            actionProgress=1;
            break;
         }
         actionProgress=0;
      }
   } else {
       actionProgress=1;
   }
   if (actionAlive==2) agentMove(actionProgress);
   else agentMove(actionAlive);
}
void agentMove(int src) {
   if (src!=0) {
      agentPos+=src;
      batteryStatus-=proceedCost;
   } else {
      batteryCharge();
   }
}
void drawEnv() {
   for (int i=0;i<blockNums;i++) {
      switch(Map[i]) {
         case 0 : fill(255);break; // normal
         case 1 : fill(0,255,0);break; // battery charger
         default : fill(255,0,0);break; // start gloal
      }
      rect(meshSize*i,0,meshSize,meshSize);
   }
}
void drawAgent(int mypos) {
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
void batteryCharge() {
   batteryStatus+=10;
   println("Battery Charge");
   if (batteryStatus>100)batteryStatus=100;
}
void checkGoal(int mypos) {
   if (Map[mypos]==3) {
      println("Goal");
      noLoop();
   }
}
void checkBattery(int battery) {
   if (battery < 0) {
      println("Battry Down");
      noLoop();
   }
}
void sensing(int mypos) {
   for (int i=0;i<scopeRange*2+1;i++) {
      // i=scopeRange == mypos
      if (mypos-scopeRange+i>=0) VisionScope[i] = Map[mypos-scopeRange+i];
   }
}
void ruleBaseBehaiv(){
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
