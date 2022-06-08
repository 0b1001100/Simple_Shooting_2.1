import processing.awt.*;
import processing.awt.PSurfaceAWT.*;

import java.awt.*;
import java.awt.event.*;

import java.lang.reflect.*;

import java.nio.*;
import java.nio.file.*;

import java.util.*;
import java.util.concurrent.*;

import com.jogamp.opengl.util.GLBuffers;
import com.jogamp.newt.opengl.*;
import com.jogamp.newt.event.*;
import com.jogamp.opengl.*;

Simple_shooting_2_1 CopyApplet=this;

Myself player;

ExecutorService exec;

ArrayList<Future<?>>CollisionFuture=new ArrayList<Future<?>>();
ArrayList<Future<?>>entityFuture=new ArrayList<Future<?>>();

ArrayList<EntityCollision>CollisionProcess=new ArrayList<EntityCollision>();
byte collisionNumber=16;
int minDataNumber=4;

ArrayList<EntityProcess>UpdateProcess=new ArrayList<EntityProcess>();
byte updateNumber=16;

float vectorMagnification=1;

PShader colorInv;
PShader Lighting;
PShader GravityLens;
java.util.List<GravityBullet>LensData=Collections.synchronizedList(new ArrayList<GravityBullet>());

GameProcess main;
Stage stage;

ComponentSetLayer starts=new ComponentSetLayer();

ItemTable MastarTable;

GL4 gl;

JSONObject LanguageData;
JSONObject Language;
JSONObject conf;

HashSet<String>moveKeyCode=new HashSet<String>(Arrays.asList(createArray(str(UP),str(DOWN),str(RIGHT),str(LEFT),"87","119","65","97","83","115","68","100")));

java.util.List<Entity>Entities=new ArrayList<Entity>();
java.util.List<Entity>NextEntities=Collections.synchronizedList(new ArrayList<Entity>());
HashSet<String>PressedKeyCode=new HashSet<String>();
HashSet<String>PressedKey=new HashSet<String>();
ArrayList<Long>Times=new ArrayList<Long>();
PVector scroll;
PVector pscreen=new PVector(1280, 720);
PVector localMouse;
boolean pmousePress=false;
boolean mousePress=false;
boolean keyRelease=false;
boolean keyPress=false;
boolean changeScene=true;
String nowPressedKey;
String nowMenu="Main";
String pMenu="Main";
String StageName="";
long pTime=0;
int nowPressedKeyCode;
int ModifierKey=0;
int pEntityNum=0;
int pscene=0;
int scene=0;

boolean colorInverse=false;

static final String ShaderPath=".\\data\\shader\\";
static final String StageConfPath=".\\data\\StageConfig\\";
static final String WeaponInitPath=".\\data\\WeaponData\\WeaponInit.json";

{PJOGL.profile=4;}

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
  Lighting=loadShader(ShaderPath+"Lighting.glsl");
  GravityLens=loadShader(ShaderPath+"GravityLens.glsl");
  blendMode(ADD);
  scroll=new PVector(0, 0);
  pTime=System.currentTimeMillis();
  localMouse=unProject(mouseX, mouseY);
  //initGPGPU();
  LoadData();
  initThread();
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
    if(pEntityNum!=EntityX.size()){
      CollisionProcess.clear();
      byte ThreadNumber=(byte)min(floor(EntityX.size()/(float)minDataNumber),(int)collisionNumber);
      float block=EntityX.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber;b++){
        CollisionProcess.add(new EntityCollision(round(block*b),round(block*(b+1)),b));
      }
    }
    CollisionFuture.clear();
    for(EntityCollision e:CollisionProcess){
      CollisionFuture.add(exec.submit(e));
    }
    for(Future<?> f:CollisionFuture){
      try {
        f.get();
      }
      catch(ConcurrentModificationException e) {
        e.printStackTrace();
      }
      catch(InterruptedException|ExecutionException F) {println(F);F.printStackTrace();
      }
      catch(NullPointerException g) {
      }
    }
  }
  printFPS();
  Shader();
  updatePreValue();
  updateFPS();
}

void LoadData(){
  conf=loadJSONObject(".\\data\\save\\config.json");
  useGPGPU=conf.getBoolean("GPGPU");
  LoadLanguage();
  LanguageData=loadJSONObject(".\\data\\lang\\Languages.json");
  UpgradeArray=loadJSONObject(".\\data\\WeaponData\\WeaponUpgrade.json");
  JSONArray a=loadJSONArray(WeaponInitPath);
  for(int i=0;i<a.size();i++){
    try{
      JSONObject o=a.getJSONObject(i);
      String name=o.getString("name");
      WeaponConstructor.put(name,Class.forName("Simple_shooting_2_1$"+name+"Weapon").getDeclaredConstructor(Simple_shooting_2_1.class,JSONObject.class));
      masterTable.addTable(new Item(o,"weapon"),o.getFloat("weight"));
    }catch(ClassNotFoundException|NoSuchMethodException g){g.printStackTrace();}
  }
  Arrays.asList(conf.getJSONArray("Weapons").getStringArray()).forEach(s->{playerTable.addTable(masterTable.get(s),masterTable.get(s).getWeight());});
}

void LoadLanguage(){
  Language=loadJSONObject(".\\data\\lang\\"+conf.getString("Language")+".json");
}

void Menu() {
  if (changeScene){
    initMenu();
  }
  switch(starts.nowLayer){
    case "root":background(0);break;
    default:background(230);break;
  }
  starts.display();
  starts.update();
  if(colorInverse&&!starts.nowLayer.equals("root")){
    colorInv.set("tex",g);
    colorInv.set("resolution",width,height);
    filter(colorInv);
  }
}

void initMenu(){
  starts=new ComponentSetLayer();
  NormalButton New=new NormalButton(Language.getString("start_game"));
  New.setBounds(100,100,120,30);
  New.addListener(()-> {
    starts.toChild("main");
  }
  );
  MenuButton Select=new MenuButton(Language.getString("stage_select"));
  Select.setBounds(100,140,120,25);
  Select.addListener(()->{
    starts.toChild("stage");
  });
  ItemList stage=new ItemList();
  stage.setBounds(250,100,300,500);
  stage.showSub=false;
  stage.addContent("Stage1");
  stage.addSelectListener((s)->{
    switch(s){
      case "Stage1":scene=1;break;
    }
    StageName=s;
  });
  MenuButton Config=new MenuButton(Language.getString("config"));
  Config.setBounds(100,180,120,25);
  Config.addListener(()->{
    starts.toChild("confMenu");
  });
  MenuTextBox confBox=new MenuTextBox(Language.getString("ex"));
  confBox.setBounds(width-320,100,300,500);
  //---
    MenuCheckBox Colorinv=new MenuCheckBox(Language.getString("color_inverse"),colorInverse);
    Colorinv.setBounds(250,180,120,25);
    Colorinv.addListener(()->{
      colorInverse=Colorinv.value;
    });
    Colorinv.addFocusListener(new FocusEvent(){
      void getFocus(){
        confBox.setText(Language.getString("ex_color_inverse"));
      }
      
      void lostFocus(){}
    });
    MenuButton Lang=new MenuButton(Language.getString("language"));
    Lang.setBounds(250,220,120,25);
    Lang.addListener(()->{
      starts.toChild("Language");
    });
    Lang.addFocusListener(new FocusEvent(){
      void getFocus(){
        confBox.setText(Language.getString("ex_language"));
      }
      
      void lostFocus(){}
    });
    //--
      ItemList LangList=new ItemList();
      LangList.setBounds(400,100,300,500);
      LangList.showSub=false;
      for(int i=0;i<LanguageData.getJSONArray("Language").size();i++){
        LangList.addContent(LanguageData.getJSONArray("Language").getJSONObject(i).getString("name"));
      }
      LangList.addSelectListener((s)->{
        if(conf.getString("Language").equals(LanguageData.getString(s))){
          starts.toParent();
          return;
        }
        conf.setString("Language",LanguageData.getString(s));
        saveJSONObject(conf,".\\data\\save\\config.json");
        LoadLanguage();
        initMenu();
        starts.toParent();
      });
    //--
  //---
  starts.setSubChildDisplayType(1);
  starts.addLayer("root",toSet(New));
  starts.addChild("root","main",toSet(Select,Config));
  starts.addSubChild("main","stage",toSet(stage));
  starts.addSubChild("main","confMenu",toSet(Colorinv,Lang),toSet(confBox));
  starts.addSubChild("confMenu","Language",toSet(LangList));
}

void Load() {
  background(0);
  scene=2;
}

void initThread(){
  exec=Executors.newFixedThreadPool(collisionNumber);
}

void Field() {
  if (changeScene){
    main=new GameProcess();
    stage.name=StageName;
    JSONArray data=loadJSONArray(StageConfPath+StageName+".json");
    for(int i=0;i<data.size();i++){
      JSONObject config=data.getJSONObject(i);
      JSONObject param=config.getJSONObject("param");
      if(config.getString("type").equals("auto")){
        Enemy[] e=new Enemy[param.getJSONArray("name").size()];
        for(int j=0;j<e.length;j++){
          try{
            e[j]=(Enemy)Class.forName("Simple_shooting_2_1$"+param.getJSONArray("name").get(j)).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet);
          }catch(ClassNotFoundException|NoSuchMethodException|InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
        }
        stage.addProcess(StageName,new TimeSchedule(config.getFloat("time"),s->{s.autoSpown(param.getBoolean("disp"),param.getFloat("freq"),e);}));
      }else if(config.getString("type").equals("add")){
        stage.addProcess(StageName,new TimeSchedule(config.getFloat("time"),s->{
          try{
            s.addSpown(param.getInt("number"),param.getFloat("dist"),param.getFloat("offset"),
            (Enemy)Class.forName("Simple_shooting_2_1$"+param.getString("name")).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet));
          }catch(ClassNotFoundException|NoSuchMethodException|InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
        }));
      }
    }
    stage.addProcess(StageName,new TimeSchedule(2000,s->{s.endSchedule=true;}));
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
  pEntityNum=EntityX.size();
  EntityX.clear();
  EntityDataX.clear();
}

void Shader(){
  if (player!=null) {
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

void applyShader(PShader s){
  pushMatrix();
  resetMatrix();
  shader(s);
  g.loadPixels();
  image(g,0,0);
  resetShader();
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

float atan2(PVector s,PVector e){
  return atan2(e.x-s.x,e.y-s.y);
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
  PVector pos;
  PVector vel=new PVector(0,0);
  PVector Center=new PVector();
  PVector AxisSize=new PVector();
  Color c=new Color(0,255,0);
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
  
  protected void putAABB(){
    float x=AxisSize.x*0.5;
    float min=Center.x-x;
    float max=Center.x+x;
    synchronized(EntityX){
      EntityX.put(min,this);
      EntityX.put(max,this);
    }
    synchronized(EntityDataX){
      EntityDataX.put(min,"s");
      EntityDataX.put(max,"e");
    }
  }
  
  void Collision(Entity e){
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
