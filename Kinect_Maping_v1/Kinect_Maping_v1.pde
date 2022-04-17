import edu.ufl.digitalworlds.j4k.*;

PKinect kinect;
short[] depthMap;
float[] depthLookUp;
PImage depthImage;
PImage depthd;
DepthMap d;

int depthW = 0;
int depthH = 0;
int i = 0;
int mini, maxi;
float r = 0;
void setup(){
  size(640, 480, P3D);
  colorMode(RGB, 255, 255, 255);
  
  kinect = new PKinect(this);
  if(kinect.start(PKinect.DEPTH) == false){
    println("No Kinect avalaible");
    exit(); return;
  }else if(kinect.isInitialized()){
    println("Type : " + kinect.getDeviceType());
    depthW = kinect.getDepthWidth();
    depthH = kinect.getDepthHeight();
  }else{
    println("Problem with Kinect.");
    exit(); return;
  }
  
  depthMap = new short[depthW*depthH];
  depthImage = createImage(depthW, depthH, RGB);
  d = new DepthMap(depthW, depthH);
}

void draw() { 
  int i;
  depthMap = kinect.getDepthFrame();

  if (depthMap!=null) {
    maxi = 0; 
    mini = 100000;
    for (i=0; (i < depthH*depthW); i++) {
      if (mini>depthMap[i]) { 
        mini = depthMap[i];
      } else if (maxi < depthMap[i]) {
        maxi = depthMap[i];
      }
    }

    background(0);
 
    pushMatrix();
    translate(depthImage.width, depthImage.height, -300);
    rotateY(r);
    
    beginShape(POINTS);
  
    for(int x = 0; x < depthW; x+=4){
      for(int y = 0; y < depthH; y+=4){
        int index = x + y * depthImage.width;
        int depth = depthMap[index];
        stroke(255, 0, 0);
        PVector v = new PVector(x, y, mapping_depth(depth));
        stroke(255);
        point(v.x, v.y, v.z);
        
      }
    }
    endShape();
    
    popMatrix();
    r += 0.015;
  }
}

float mapping_depth(int depthValue) {
  return map(depthValue, 0, maxi, 0, -450);
}
