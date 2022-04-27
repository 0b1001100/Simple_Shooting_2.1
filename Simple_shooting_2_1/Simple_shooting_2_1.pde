import processing.awt.*;
import processing.awt.PSurfaceAWT.*;

import java.awt.*;
import java.awt.event.*;

import java.util.*;
import java.util.concurrent.*;

import com.jogamp.opengl.util.GLBuffers;
import com.jogamp.newt.opengl.*;
import com.jogamp.newt.event.*;
import com.jogamp.opengl.*;

Simple_shooting_2_1 CopyApplet=this;

Myself player;

ExecutorService exec=Executors.newCachedThreadPool();
Future<?> particleFuture;
Future<?> enemyFuture;
Future<?> bulletFuture;

ParticleProcess particleTask=new ParticleProcess();
EnemyProcess enemyTask=new EnemyProcess();
BulletProcess bulletTask=new BulletProcess();

float vectorMagnification=1;

GameProcess main;
Stage stage;

ComponentSetLayer starts=new ComponentSetLayer();

ItemTable MastarTable;

GL4 gl;

HashSet<String>moveKeyCode=new HashSet<String>(Arrays.asList(createArray(str(UP),str(DOWN),str(RIGHT),str(LEFT),"87","119","65","97","83","115","68","100")));

java.util.List<Particle>Particles=Collections.synchronizedList(new ArrayList<Particle>());
java.util.List<Bullet>eneBullets=Collections.synchronizedList(new ArrayList<Bullet>());
java.util.List<Bullet>Bullets=Collections.synchronizedList(new ArrayList<Bullet>());
java.util.List<Enemy>Enemies=Collections.synchronizedList(new ArrayList<Enemy>());
java.util.List<Exp>Exps=Collections.synchronizedList(new ArrayList<Exp>());
java.util.List<Particle>ParticleHeap=Collections.synchronizedList(new ArrayList<Particle>());
java.util.List<Bullet>eneBulletHeap=Collections.synchronizedList(new ArrayList<Bullet>());
java.util.List<Bullet>BulletHeap=Collections.synchronizedList(new ArrayList<Bullet>());
java.util.List<Enemy>EnemyHeap=Collections.synchronizedList(new ArrayList<Enemy>());
java.util.List<Exp>ExpHeap=Collections.synchronizedList(new ArrayList<Exp>());
HashSet<String>PressedKeyCode=new HashSet<String>();
HashSet<String>PressedKey=new HashSet<String>();
ArrayList<Long>Times=new ArrayList<Long>();
PVector scroll;
PVector pscreen=new PVector(1280, 720);
PVector localMouse;
PShader colorInv;
boolean pmousePress=false;
boolean mousePress=false;
boolean keyRelease=false;
boolean keyPress=false;
boolean changeScene=true;
boolean ColorInv=false;
String nowPressedKey;
String nowMenu="Main";
String pMenu="Main";
long pTime=0;
int nowPressedKeyCode;
int ModifierKey=0;
int pEnemyNum=0;
int pBulletNum=0;
int pscene=0;
int scene=0;

static final String ShaderPath=".\\data\\shader\\";

void setup() {
  size(1280, 720, P2D);
  ((GLWindow)surface.getNative()).addWindowListener(new com.jogamp.newt.event.WindowListener() {
    void windowDestroyed(com.jogamp.newt.event.WindowEvent e) {
    }

    void windowDestroyNotify(com.jogamp.newt.event.WindowEvent e) {
    }

    void windowGainedFocus(com.jogamp.newt.event.WindowEvent e) {
    }

    void windowLostFocus(com.jogamp.newt.event.WindowEvent e) {
    }

    void  windowMoved(com.jogamp.newt.event.WindowEvent e) {
    }

    void windowRepaint(WindowUpdateEvent e) {
    }

    @Override
      void windowResized(com.jogamp.newt.event.WindowEvent e) {
      GLWindow w=(GLWindow)surface.getNative();
      pscreen.sub(w.getWidth(), w.getHeight()).div(2);
      scroll.sub(pscreen);
      pscreen=new PVector(w.getWidth(), w.getHeight());
    }
  }
  );((GLWindow)surface.getNative()).addKeyListener(new com.jogamp.newt.event.KeyListener() {
    void keyPressed(com.jogamp.newt.event.KeyEvent e){
    }
    void keyReleased(com.jogamp.newt.event.KeyEvent e){
    }
  }
  );
  PFont font=createFont("SansSerif.plain", 15);
  textFont(font);
  colorInv=loadShader(ShaderPath+"ColorInv.glsl");
  blendMode(ADD);
  scroll=new PVector(0, 0);
  pTime=System.currentTimeMillis();
  localMouse=unProject(mouseX, mouseY);
}

void draw() {
  switch(scene) {
    case 0:Menu();
    break;
    case 1:Load();
    break;
    case 2:Field();
    break;
  }
  eventProcess();
  if(scene==2){
    try {
      bulletFuture.get();
      particleFuture.get();
      enemyFuture.get();
    }
    catch(ConcurrentModificationException e) {
      e.printStackTrace();
    }
    catch(InterruptedException|ExecutionException f) {println(f);f.printStackTrace();
    }
    catch(NullPointerException g) {
    }
  }
  printFPS();
  Shader();
  updatePreValue();
  updateFPS();
}

void Menu() {
  background(0);
  if (changeScene) {
    starts=new ComponentSetLayer();
    NormalButton New=new NormalButton("New Game");
    New.setBounds(100, 100, 120, 30);
    New.addListener(()-> {
      scene=1;
    }
    );
    NormalButton Load=new NormalButton("Load Game");
    Load.setBounds(100, 140, 120, 30);
    NormalButton Config=new NormalButton("Confuguration");
    Config.setBounds(100, 180, 120, 30);
    starts.addLayer("root",toSet(New,Load,Config));
  }
  starts.display();
  starts.update();
}

void Load() {
  background(0);
  scene=2;
}

void Field() {
  if (changeScene) {
    main=new GameProcess();
  }
  main.process();
}

void eventProcess() {
  if (!pmousePress&&mousePressed) {
    mousePress=true;
  } else {
    mousePress=false;
  }
  if (scene!=pscene) {
    changeScene=true;
  } else if (!nowMenu.equals(pMenu)) {
    changeScene=true;
  } else {
    changeScene=false;
  }
}

/*void CollisionProcess() {
  BulletEnemyX=new TreeMap<Float,Object>(BulletX);
  BulletEnemyX.putAll(EnemyX);
  if (pEnemyNum!=EnemyX.size()) {
    p1=new EnemyCollision(0,(int)(EnemyX.size()*0.33));
    p2=new EnemyCollision((int)(EnemyX.size()*0.33), (int)(EnemyX.size()*0.66));
    p3=new EnemyCollision((int)(EnemyX.size()*0.66), EnemyX.size());
  }
  if (pBulletNum!=BulletX.size()) {
    b1=new BulletCollision(0,(int)(BulletEnemyX.size()*0.5));
    b2=new BulletCollision((int)(BulletEnemyX.size()*0.5), BulletEnemyX.size());
  }
  try {
    CollisionFuture1=exec.submit(p1);
    CollisionFuture2=exec.submit(p2);
    CollisionFuture3=exec.submit(p3);
    BulletCollision1=exec.submit(b1);
    BulletCollision2=exec.submit(b2);
  }
  catch(Exception e) {
  }
  pEnemyNum=EnemyX.size();
  pBulletNum=BulletX.size();
  EnemyX.clear();
  EnemyData.clear();
  BulletX.clear();
  BulletData.clear();
}*/

void updateFPS() {
  Times.add(System.currentTimeMillis()-pTime);
  while (Times.size()>60) {
    Times.remove(0);
  }
  pTime=System.currentTimeMillis();
  vectorMagnification=60f/(1000f/Times.get(Times.size()-1));
}

void updatePreValue() {
  keyRelease=false;
  keyPress=false;
  pmousePress=mousePressed;
  pscene=scene;
  pMenu=nowMenu;
  pEnemyNum=EnemyX.size();
  pBulletNum=BulletX.size();
  EnemyX.clear();
  EnemyData.clear();
  BulletX.clear();
  BulletData.clear();
}

void Shader() {
  if (ColorInv) {
    colorInv.set("tex", g);
    colorInv.set("resolution", width, height);
    filter(colorInv);
  }
  if (player!=null) {
    /*if(scene==2){
     View.set("Map",g);
     View.set("StartPos",player.pos);
     View.set("resolution",width,height);
     filter(View);
     }*/
  }
}

void printFPS() {
  pushMatrix();
  resetMatrix();
  textAlign(LEFT);
  textSize(10);
  fill(0, 220, 0);
  float MTime=0;
  for (long l : Times)MTime+=l;
  MTime/=(float)Times.size();
  text(1000f/MTime, 10, 10);
  popMatrix();
}

PMatrix3D getMatrixLocalToWindow() {
  PMatrix3D projection = ((PGraphics2D)g).projection;
  PMatrix3D modelview = ((PGraphics2D)g).modelview;

  PMatrix3D viewport = new PMatrix3D();
  viewport.m00 = viewport.m03 = width/2;
  viewport.m11 = -height/2;
  viewport.m13 =  height/2;

  viewport.apply(projection);
  viewport.apply(modelview);
  return viewport;
}

<T> T[] createArray(T... val){
  return val;
}

<P extends Collection,C extends Collection> boolean containsList(P p,C c){
  boolean ret=false;
  for(Object o:c){
    if(p.contains(o)){
      ret=true;
      break;
    }
  }
  return ret;
}

boolean onMouse(float x, float y, float dx, float dy) {
  return x<=mouseX&mouseX<=x+dx&y<=mouseY&mouseY<=y+dy;
}

PVector unProject(float winX, float winY) {
  PMatrix3D mat = getMatrixLocalToWindow();
  mat.invert();

  float[] in = {winX, winY, 1.0f, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);

  if (out[3] == 0 ) {
    return null;
  }

  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);
  return result;
}

float Sigmoid(float t) {
  return 1f/(1+pow(2.7182818, -t));
}

float ESigmoid(float t) {
  return pow(2.718281828, 5-t)/pow(pow(2.718281828, 5-t)+1, 2);
}

int sign(float f) {
  return f==0?0:f>0?1:-1;
}

float dist(PVector a, PVector b) {
  return dist(a.x, a.y, b.x, b.y);
}

float sqDist(PVector s, PVector e){
  return (s.x-e.x)*(s.x-e.x)+(s.y-e.y)*(s.y-e.y);
}

boolean qDist(PVector s, PVector e, float d) {
  return ((s.x-e.x)*(s.x-e.x)+(s.y-e.y)*(s.y-e.y))<=d*d;
}

boolean qDist(PVector s1, PVector e1, PVector s2, PVector e2) {
  return ((s1.x-e1.x)*(s1.x-e1.x)+(s1.y-e1.y)*(s1.y-e1.y))<=((s2.x-e2.x)*(s2.x-e2.x)+(s2.y-e2.y)*(s2.y-e2.y));
}

float cross(PVector v1, PVector v2) {
  return v1.x*v2.y-v2.x*v1.y;
}

float dot(PVector v1, PVector v2) {
  return v1.x*v2.x+v1.y*v2.y;
}

PVector normalize(PVector s, PVector e) {
  float f=s.dist(e);
  return new PVector((e.x-s.x)/f, (e.y-s.y)/f);
}

PVector normalize(PVector v) {
  float f=sqrt(sq(v.x)+sq(v.y));
  return new PVector(v.x/f, v.y/f);
}

PVector createVector(PVector s, PVector e) {
  return e.copy().sub(s);
}

boolean CircleCollision(PVector c,float size,PVector s,PVector v){
    PVector bulletVel=v.copy().mult(vectorMagnification);
    PVector vecAP=createVector(s,c);
    PVector normalAB=normalize(bulletVel);//vecAB->b.vel
    float lenAX=dot(normalAB,vecAP);
    float dist;
    if(lenAX<0){
      dist=dist(s.x,s.y,c.x,c.y);
    }else if(lenAX>dist(0,0,bulletVel.x,bulletVel.y)){
      dist=dist(s.x+bulletVel.x,s.y+bulletVel.y,c.x,c.y);
    }else{
      dist=abs(cross(normalAB,vecAP));
    }
    return dist<size/2;
}

boolean SegmentCollision(PVector s1, PVector v1, PVector s2, PVector v2) {
  PVector v=new PVector(s2.x-s1.x, s2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return false;
  }
  float crs_v_v1=cross(v, v1);
  float crs_v_v2=cross(v, v2);
  float t1 = crs_v_v2/crs_v1_v2;
  float t2 = crs_v_v1/crs_v1_v2;
  if (t1+0.000000000001<0||t1-0.000000000001>1||t2+0.000000000001<0||t2-0.000000000001>1) {
    return false;
  }
  return true;
}

boolean LineCollision(PVector s1, PVector v1, PVector l2, PVector v2) {
  PVector v=new PVector(l2.x-s1.x, l2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return false;
  }
  float t=cross(v, v1);
  if (t+0.00001<0|1<t-0.00001) {
    return false;
  }
  return true;
}

PVector SegmentCrossPoint(PVector s1, PVector v1, PVector s2, PVector v2) {
  PVector v=new PVector(s2.x-s1.x, s2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return null;
  }
  float crs_v_v1=cross(v, v1);
  float crs_v_v2=cross(v, v2);
  float t1 = crs_v_v2/crs_v1_v2;
  float t2 = crs_v_v1/crs_v1_v2;
  if (t1+0.000000000001<0||t1-0.000000000001>1||t2+0.000000000001<0||t2-0.000000000001>1) {
    return null;
  }
  return s1.add(v1.copy().mult(t1));
}

PVector LineCrossPoint(PVector s1, PVector v1, PVector l2, PVector v2) {
  PVector v=new PVector(l2.x-s1.x, l2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return null;
  }
  float t=cross(v, v1);
  if (t+0.000000000001<0||t-0.000000000001>1) {
    return null;
  }
  return s1.add(v1.copy().mult(t));
}

color toColor(Color c) {
  return color(c.getRed(), c.getGreen(), c.getBlue(), c.getAlpha());
}

color toRGB(Color c) {
  return color(c.getRed(), c.getGreen(), c.getBlue(), 255);
}

Color toAWTColor(color c) {
  return new Color((c>>16)&0xFF, (c>>8)&0xFF, c&0xFF, (c>>24)&0xFF);
}

Color mult(Color C, float c) {
  return new Color(round(C.getRed()*c), round(C.getGreen()*c), round(C.getBlue()*c), C.getAlpha());
}

Color cloneColor(Color c) {
  return new Color(c.getRed(), c.getGreen(), c.getBlue(), c.getAlpha());
}

void keyPressed(processing.event.KeyEvent e) {
  keyPress=true;
  ModifierKey=e.getKeyCode();
  PressedKey.add(str(key));
  PressedKeyCode.add(str(keyCode));
  nowPressedKey=str(key);
  nowPressedKeyCode=keyCode;
}

void keyReleased(processing.event.KeyEvent e) {
  keyRelease=false;
  ModifierKey=-1;
  PressedKeyCode.remove(str(keyCode));
  PressedKey.remove(str(key));
}

class Entity implements Egent, Cloneable {
  DeadEvent dead=(e)->{};
  float size=20;
  PVector prePos;
  PVector pos;
  PVector vel=new PVector(0, 0);
  PVector LeftUP;
  PVector LeftDown;
  PVector RightUP;
  PVector RightDown;
  Color c=new Color(0, 255, 0);
  float rotate=0;
  float accelSpeed=0.25;
  float maxSpeed=7.5;
  float Speed=0;
  float Mass=10;
  float e=0.5;
  boolean isDead=false;
  boolean pDead=false;

  Entity() {
  }

  void display() {
  }

  void update() {
    if(isDead&&!pDead){
      dead.deadEvent(this);
      pDead=isDead;
    }
  }

  void setColor(Color c) {
    this.c=c;
  }

  void setMaxSpeed(float s) {
    maxSpeed=s;
  }

  void setSpeed(float s) {
    Speed=s;
  }

  void setMass(float m) {
    Mass=m;
  }

  Entity clone()throws CloneNotSupportedException {
    Entity clone=(Entity)super.clone();
    clone.pos=pos==null?null:pos.copy();
    clone.vel=vel==null?null:vel.copy();
    clone.c=cloneColor(c);
    return clone;
  }
  
  void addDeadListener(DeadEvent e){
    dead=e;
  }
}

class Camera {
  Entity target;
  boolean moveEvent=false;
  boolean resetMove=false;
  boolean moveTo=false;
  PVector movePos;
  PVector pos;
  PVector vel;
  float maxVel=18;
  float moveDist;
  int stopTime=60;
  int moveTime=0;

  Camera() {
  }

  void update() {
    if (moveEvent) {
      if (!moveTo&&!resetMove) {
        move();
      } else if (!resetMove) {
        if (stopTime>0) {
          stopTime--;
        } else {
          resetMove=true;
          moveTo=false;
        }
      } else if (resetMove) {
        returnMove();
      }
    } else {
      vel=target.vel;
      pos.sub(vel);
      scroll=pos;
      translate(scroll.x, scroll.y);
    }
  }

  void setTarget(Entity e) {
    target=e;
    pos=new PVector(width/2, height/2).sub(e.pos);
  }

  void reset() {
    pos=new PVector(width/2, height/2).sub(target.pos);
  }

  void moveTo(float wx, float wy) {
    movePos=new PVector(-wx, -wy).add(width, height).sub(pos.x*2, pos.y*2);
    moveDist=movePos.dist(pos);
    moveEvent=true;
    moveTo=false;
  }

  void resetMove() {
    moveEvent=false;
    resetMove=false;
    moveTo=false;
    pos=new PVector(width/2, height/2).sub(target.pos);
    moveTime=0;
    stopTime=60;
  }

  void move() {
    if (moveTime<60) {
      float scala=ESigmoid((float)moveTime/6f/5.91950);
      vel=new PVector((movePos.x-target.pos.x)*scala, (movePos.y-target.pos.y)*scala);
      pos.add(vel);
      moveTime++;
    } else {
      pos=new PVector(movePos.x, movePos.y);
      moveTo=true;
    }
  }

  void returnMove() {
    if (moveTime>0) {
      float scala=ESigmoid((float)moveTime/6f/5.91950);
      vel=new PVector((movePos.x-target.pos.x)*scala, (movePos.y-target.pos.y)*scala);
      pos.sub(vel);
      moveTime--;
    } else {
      moveEvent=false;
      resetMove();
    }
  }
}

interface Egent {
  void display();

  void update();
}

interface DeadEvent{
  void deadEvent(Entity e);
}
