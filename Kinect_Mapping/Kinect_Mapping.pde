import edu.ufl.digitalworlds.j4k.*;

PKinect kinect;
Skeleton[] s;

int max_skeleton;
int colorW;
int colorH;

PImage colorImage;
byte[] colorMap;

PVector head;
PVector rh;
PVector lh;
PVector previous_position_head;
PVector previous_handRight;
PVector previous_handLeft;
PVector spine;

ArrayList<Float> cub_save = new ArrayList();
float pos_x_cub;
float pos_y_cub;

float pos_x_hl;
float pos_y_hl;

float t;

float rot = 0;

void setup(){
  size(1280, 960, P3D);
  colorMode(RGB);
  kinect = new PKinect(this);
  
  if(kinect.start(PKinect.COLOR | PKinect.SKELETON) == false){
    println("No kinect connected.");
    exit(); return;
  }else if(kinect.isInitialized()){
    colorW       = kinect.getColorWidth();
    colorH       = kinect.getColorHeight();
    max_skeleton = kinect.getSkeletonCountLimit();
  }else{
    println("Error with kinect."); 
    exit(); return;
  }
  
  colorMap = new byte[colorW*colorH*4];
  colorImage = createImage(colorW, colorH, RGB);
  
}

void draw(){
  background(0);
  
  int i, j;
  colorMap = kinect.getColorFrame();
  s = kinect.getSkeletons();
  
  if(colorMap != null){
    colorImage.loadPixels();
    j = 0;
    for(i = 0; i < colorMap.length; i+=4){
      colorImage.pixels[j] = (colorMap[i+2]&0x0000FF) << 16 |
      (colorMap[i+1]&0x0000FF << 8) |
      (colorMap[i]&0x0000FF);
      j++;
    }
    colorImage.updatePixels();
  }
  image(colorImage, 0, 0, width, height);
  for(i = 0; i < max_skeleton; i++){
    if(s[i] != null){
      if(s[i].isTracked() == true){
        rh = position(i, Skeleton.HAND_RIGHT);
        lh = position(i, Skeleton.HAND_LEFT);
        boxHand(rh, lh);
      }
      image(colorImage, 0, 0, width, height);
      if(!cub_save.isEmpty()){
        for(int x = 0; x < cub_save.size(); x+=4){
            pushMatrix();
            translate(cub_save.get(x), cub_save.get(x + 1));
            translate(cub_save.get(x + 2), cub_save.get(x + 2));
            box(cub_save.get(x + 3));
            popMatrix();
        }
      }
    }
  }
}

PVector position(int userId, int type){
  PVector vector = new PVector();
  int[] pos;
  
  if(s[userId].isJointTracked(type)){
    pos = s[userId].get2DJoint(type, width, height);
    vector.x = pos[0];
    vector.y = pos[1];
  } return vector;
}

void boxHand(PVector handRight, PVector handLeft){
  pushMatrix(); 
  float dist = sqrt(pow((handLeft.x - handRight.x),2) + pow((handLeft.y - handLeft.y),2));
  translate(handLeft.x, handLeft.y);
  translate(dist/2 , dist/2);
  float d = sqrt(pow(sqrt(pow((handLeft.x - handRight.x),2) + pow((handLeft.y - handLeft.y),2)),2)/2);
  box(d);
  if(handRight.y <= 2){
    cub_save.add(handLeft.x);
    cub_save.add(handLeft.y);
    cub_save.add(dist/2);
    cub_save.add(d);
  }

  popMatrix();
}

float dist(PVector p1, PVector p2){
  float dx = pow((p1.x - p2.x), 2);
  float dy = pow((p1.y - p2.y), 2);
  
  return sqrt(dx + dy);
}
