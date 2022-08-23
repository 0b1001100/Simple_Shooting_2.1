import processing.awt.*;
import processing.awt.PSurfaceAWT.*;

import java.awt.*;
import java.awt.event.*;

import java.lang.reflect.*;

import java.nio.*;
import java.nio.file.*;

import java.util.*;
import java.util.concurrent.*;
import java.util.Map.Entry;

import com.jogamp.opengl.util.GLBuffers;
import com.jogamp.newt.opengl.*;
import com.jogamp.newt.event.*;
import com.jogamp.opengl.*;

Simple_shooting_2_1 CopyApplet=this;

Myself player;

ExecutorService exec;

ArrayList<Future<?>>CollisionFuture=new ArrayList<Future<?>>();
ArrayList<Future<?>>entityFuture=new ArrayList<Future<?>>();
ArrayList<Future<PGraphics>>drawFuture=new ArrayList<Future<PGraphics>>();

ArrayList<EntityCollision>CollisionProcess=new ArrayList<EntityCollision>();
byte collisionNumber=16;
int minDataNumber=4;

ArrayList<EntityProcess>UpdateProcess=new ArrayList<EntityProcess>();
byte updateNumber=16;

ArrayList<EntityDraw>DrawProcess=new ArrayList<EntityDraw>();
byte drawNumber=4;

float vectorMagnification=1;
float pMagnification=1;

PShader FXAAShader;
PShader colorInv;
PShader Lighting;
PShader GravityLens;
PShader menuShader;
java.util.List<GravityBullet>LensData=Collections.synchronizedList(new ArrayList<GravityBullet>());

GameProcess main;
Stage stage;

ComponentSetLayer stageLayer=new ComponentSetLayer();
ComponentSetLayer starts=new ComponentSetLayer();
ComponentSet resultSet;
ItemList stageList=new ItemList();

ItemTable MastarTable;

GL4 gl4;

JSONObject LanguageData;
JSONObject Language;
JSONObject conf;

PImage mouseImage;
PFont font_30;

HashSet<String>moveKeyCode=new HashSet<String>(Arrays.asList(createArray(str(UP),str(DOWN),str(RIGHT),str(LEFT),"87","119","65","97","83","115","68","100")));

ArrayList<String>StageFlag=new ArrayList<String>();
java.util.List<Entity>Entities=new ArrayList<Entity>(50);
java.util.List<Entity>NextEntities=new ArrayList<Entity>();
ArrayList<ArrayList<Entity>>HeapEntity=new ArrayList<ArrayList<Entity>>();
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
boolean pause=false;
boolean windowResized=false;
boolean resultAnimation=false;
boolean launched=false;
String nowPressedKey;
String nowMenu="Main";
String pMenu="Main";
String StageName="";
float keyPressTime=0;
float resultTime=0;
long pTime=0;
int compute_program;
int compute_shader;
int nowPressedKeyCode;
int ModifierKey=0;
int pEntityNum=0;
int pscene=0;
int scene=0;

boolean displayFPS=true;
boolean colorInverse=false;
boolean FXAA=false;

static final String ShaderPath=".\\data\\shader\\";
static final String StageConfPath=".\\data\\StageConfig\\";
static final String WeaponInitPath=".\\data\\WeaponData\\WeaponInit.json";
static final String ImagePath=".\\data\\images\\";

{PJOGL.profile=4;}

void setup(){
  size(1280,720,P2D);
  hint(DISABLE_OPENGL_ERRORS);
  //noSmooth();
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
      width=w.getWidth();
      height=w.getHeight();
      windowResized=true;
    }
  }
  );
  ((GLWindow)surface.getNative()).addKeyListener(new com.jogamp.newt.event.KeyListener() {
    void keyPressed(com.jogamp.newt.event.KeyEvent e){
    }
    void keyReleased(com.jogamp.newt.event.KeyEvent e){
    }
  }
  );
  gl4=((PJOGL)((PGraphicsOpenGL)g).pgl).gl.getGL4();
  compute_shader=gl4.glCreateShader(GL4.GL_COMPUTE_SHADER);
  String[] vlines = new String[]{join(loadStrings(ShaderPath+"Merge.glsl"), "\n")};
  int[] vlengths = new int[]{vlines[0].length()};
  gl4.glShaderSource(compute_shader,vlines.length,vlines,vlengths,0);
  gl4.glCompileShader(compute_shader);
  compute_program=gl4.glCreateProgram();
  gl4.glAttachShader(compute_program, compute_shader);
  gl4.glLinkProgram(compute_program);
  mouseImage=loadImage(ImagePath+"mouse.png");
  textFont(createFont("SansSerif.plain",15));
  font_30=createFont("SansSerif.plain",30);
  FXAAShader=loadShader(ShaderPath+"FXAA.glsl");
  colorInv=loadShader(ShaderPath+"ColorInv.glsl");
  Lighting=loadShader(ShaderPath+"Lighting.glsl");
  GravityLens=loadShader(ShaderPath+"GravityLens.glsl");
  menuShader=loadShader(ShaderPath+"Menu.glsl");
  blendMode(ADD);
  scroll=new PVector(0, 0);
  pTime=System.currentTimeMillis();
  localMouse=unProject(mouseX, mouseY);
  initGPGPU();
  if(doGPGPU)try{initMergeGPGPU();}catch(Exception e){e.printStackTrace();}
  LoadData();
  initThread();
}

void draw(){
  switch(scene) {
    case 0:Menu();
    break;
    case 1:Load();
    break;
    case 2:Field();
    break;
    case 3:Result();
  }
  eventProcess();
  if(scene==2){
    byte ThreadNumber=(byte)min(floor(EntityDataX.size()/(float)minDataNumber),(int)collisionNumber);
    if(pEntityNum!=EntityDataX.size()){
      float block=EntityDataX.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber;b++){
        CollisionProcess.get(b).setData(round(block*b),round(block*(b+1)),b);
      }
    }
    CollisionFuture.clear();
    for(int i=0;i<ThreadNumber;i++){
      CollisionFuture.add(exec.submit(CollisionProcess.get(i)));
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
    if(player!=null){
      player.camera.update();
    }
  }
  Shader();
  if(displayFPS)printFPS();
  updatePreValue();
  updateFPS();
}

void dispose(){
  saveJSONObject(conf,".\\data\\save\\config.json");
}

void LoadData(){
  conf=loadJSONObject(".\\data\\save\\config.json");
  useGPGPU=conf.getBoolean("GPGPU");
  if(useGPGPU)initGPGPU();
  LoadLanguage();
  LanguageData=loadJSONObject(".\\data\\lang\\Languages.json");
  UpgradeArray=loadJSONObject(".\\data\\WeaponData\\WeaponUpgrade.json");
  JSONArray a=loadJSONArray(WeaponInitPath);
  for(int i=0;i<a.size();i++){
    try{
      JSONObject o=a.getJSONObject(i);
      String name=o.getString("name");
      if(o.getString("type").equals("weapon")){
        WeaponConstructor.put(name,Class.forName("Simple_shooting_2_1$"+name+"Weapon").getDeclaredConstructor(Simple_shooting_2_1.class,JSONObject.class));
        masterTable.addTable(new Item(o,"weapon"),o.getFloat("weight"));
      }else if(o.getString("type").equals("item")){
        masterTable.addTable(new Item(o,"item"),o.getFloat("weight"));
      }
    }catch(ClassNotFoundException|NoSuchMethodException g){g.printStackTrace();}
  }
  Arrays.asList(conf.getJSONArray("Weapons").getStringArray()).forEach(s->{playerTable.addTable(masterTable.get(s),masterTable.get(s).getWeight());});
  stageList.addContent(conf.getJSONArray("Stage").getStringArray());
  displayFPS=conf.getBoolean("FPS");
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
  stageList.setBounds(250,100,300,500);
  stageList.showSub=false;
  stageList.addSelectListener((s)->{
    scene=1;
    StageName=s;
  });
  MenuButton Config=new MenuButton(Language.getString("config"));
  Config.setBounds(100,180,120,25);
  Config.addListener(()->{
    starts.toChild("confMenu");
  });
  MenuTextBox confBox=new MenuTextBox(Language.getString("ex"));
  confBox.setBounds(width-320,100,300,500);
  confBox.addWindowResizeEvent(()->{
    confBox.setBounds(width-320,100,300,500);
  });
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
    MenuCheckBox dispFPS=new MenuCheckBox(Language.getString("disp_FPS"),displayFPS);
    dispFPS.setBounds(250,220,120,25);
    dispFPS.addListener(()->{
      displayFPS=dispFPS.value;
      conf.setBoolean("FPS",displayFPS);
    });
    dispFPS.addFocusListener(new FocusEvent(){
      void getFocus(){
        confBox.setText(Language.getString("ex_disp_FPS"));
      }
      
      void lostFocus(){}
    });
    MenuButton Lang=new MenuButton(Language.getString("language"));
    Lang.setBounds(250,260,120,25);
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
        LoadLanguage();
        initMenu();
        starts.toParent();
      });
    //--
  //---
  MenuButton operationEx=new MenuButton(Language.getString("operation_ex"));
  operationEx.setBounds(100,220,120,25);
  operationEx.addListener(()->{
    starts.toChild("operation");
  });
  //--
    MenuButton back_op=new MenuButton(Language.getString("back"));
    back_op.setBounds(width*0.5-60,height*0.9,120,25);
    back_op.addListener(()->{
      starts.toParent();
    });
    back_op.addWindowResizeEvent(()->{
      back_op.setBounds(width*0.5-60,height*0.9,120,25);
    });
    Canvas op_canvas=new Canvas(g);
    op_canvas.setContent((pg)->{
      pg.beginDraw();
      pg.blendMode(BLEND);
      pg.rectMode(CENTER);
      pg.fill(20);
      pg.noStroke();
      for(int i=0;i<4;i++)pg.rect(87.5+45*i,70,35,35,3);
      pg.textSize(30);
      pg.textFont(font_30);
      pg.textAlign(CENTER);
      pg.fill(255);
      for(int i=0;i<4;i++)pg.text(i==0?"W":i==1?"A":i==2?"S":i==3?"D":"",87.5+45*i,82.5);
      pg.fill(0);
      pg.textAlign(LEFT);
      text(": "+Language.getString("move"),245,82.5);
      image(mouseImage,70,85);
      text(": "+Language.getString("shot"),150,130);
      pg.endDraw();
    });
  //--
  starts.setSubChildDisplayType(1);
  starts.addLayer("root",toSet(New));
  starts.addChild("root","main",toSet(Select,Config,operationEx));
  starts.addSubChild("main","stage",toSet(stageList));
  starts.addSubChild("main","confMenu",toSet(Colorinv,dispFPS,Lang),toSet(confBox));
  starts.addSubChild("confMenu","Language",toSet(LangList));
  starts.addChild("main","operation",toSet(back_op,op_canvas));
  if(launched){
    starts.toChild("main");
  }else{
    launched=true;
  }
}

void Load(){
  background(0);
  scene=2;
}

void Result(){
  if(changeScene){
    resetMatrix();
    resultAnimation=true;
    resultTime=0;
    MenuButton resultButton=new MenuButton("OK");
    resultButton.setBounds(width*0.5-60,height*0.7,120,25);
    resultButton.addWindowResizeEvent(()->{
      resultButton.setBounds(width*0.5-60,height*0.7,120,25);
    });
    resultButton.addListener(()->{
      scene=0;
    });
    resultButton.requestFocus();
    resultSet=toSet(resultButton);
    saveConfig save=new saveConfig();
    exec.submit(save);
  }
  background(230);
  if(resultAnimation){
    float normUItime=resultTime/30;
    background(320*normUItime);
    blendMode(BLEND);
    float Width=width/main.x;
    float Height=height/main.y;
    for(int i=0;i<main.y;i++){
      for(int j=0;j<main.x;j++){
        fill(230);
        noStroke();
        rectMode(CENTER);
        float scale=min(max(resultTime*(main.y/9)-(j+i),0),1);
        rect(Width*j+Width/2,Height*i+Height/2,Width*scale,Height*scale);
      }
    }
    resultTime+=vectorMagnification;
    if(resultTime>30)resultAnimation=false;
  }
  textAlign(CENTER);
  fill(0);
  textSize(50);
  textFont(font_30);
  text(StageFlag.contains("Game_Over")?"Game over":"Stage clear",width*0.5,height*0.2);
  resultSet.display();
  resultSet.update();
  if(resultAnimation){
    menuShader.set("time",resultTime);
    menuShader.set("xy",(float)main.x,(float)main.y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",230f/255f,230f/255f,230f/255f,1.0);
    menuShader.set("tex",g);
    filter(menuShader);
  }
}

void initThread(){
  collisionNumber=updateNumber=(byte)min(16,Runtime.getRuntime().availableProcessors());
  exec=Executors.newFixedThreadPool(collisionNumber);
  for(int i=0;i<updateNumber;i++){
    HeapEntity.add(new ArrayList<Entity>());
    HeapEntityDataX.add(new ArrayList<AABBData>());
    CollisionProcess.add(new EntityCollision(0,0,(byte)0));
    UpdateProcess.add(new EntityProcess(0,0,(byte)0));
  }
  for(int i=0;i<drawNumber-1;i++){
    DrawProcess.add(new EntityDraw(0,0));
  }
}

void Field() {
  if (changeScene){
    main=new GameProcess();
    main.FieldSize=null;
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
      }else if(config.getString("type").equals("setting")){
        main.FieldSize=new PVector(config.getJSONArray("size").getIntArray()[0],config.getJSONArray("size").getIntArray()[1]);
        main.setWall();
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
  if((PressedKeyCode.size()>1||(PressedKeyCode.size()==1&&!PressedKeyCode.contains("16")))&&(nowPressedKeyCode==147||nowPressedKeyCode==37||nowPressedKeyCode==39||!nowPressedKey.equals(str((char)-1)))){
    keyPressTime+=vectorMagnification/60;
  }else{
    keyPressTime=0;
  }
  if(!keyPressed)PressedKey.clear();
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
  pMagnification=vectorMagnification;
  windowResized=false;
  keyRelease=false;
  keyPress=false;
  pmousePress=mousePressed;
  pscene=scene;
  pMenu=nowMenu;
  pEntityNum=EntityDataX.size();
  EntityDataX.clear();
}

void Shader(){
  if (player!=null) {
  }
  if(FXAA){
    FXAAShader.set("resolution",width,height);
    FXAAShader.set("input_texture",g);
    if(scene==2){
      applyShader(FXAAShader);
    }else{
      filter(FXAAShader);
    }
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

PMatrix3D getMatrixLocalToWindow(PGraphics g) {
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

PVector unProject(float winX, float winY) {
  PMatrix3D mat = getMatrixLocalToWindow(g);
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

PVector unProject(float winX, float winY,PGraphics g) {
  PMatrix3D mat = getMatrixLocalToWindow(g);
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

PVector Project(float winX, float winY) {
  PMatrix3D mat = getMatrixLocalToWindow(g);

  float[] in = {winX, winY, 1.0f, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);

  if (out[3] == 0 ) {
    return null;
  }

  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);
  return result;
}

PVector Project(float winX, float winY,PGraphics g) {
  PMatrix3D mat = getMatrixLocalToWindow(g);

  float[] in = {winX, winY, 1.0f, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);

  if (out[3] == 0 ) {
    return null;
  }

  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);
  return result;
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

void updateUniform2f(String uniformName,float uniformValue1,float uniformValue2){
  int loc=gl4.glGetUniformLocation(compute_program,uniformName);
  gl4.glUniform2f(loc,uniformValue1,uniformValue2);
  if (loc!=-1){
    gl4.glUniform2f(loc,uniformValue1,uniformValue2);
  }
}

boolean onMouse(float x, float y, float dx, float dy) {
  return x<=mouseX&mouseX<=x+dx&y<=mouseY&mouseY<=y+dy;
}

boolean onBox(PVector p1,PVector p2,PVector v){
  return p2.x<=p1.x&&p1.x<=p2.x+v.x&&p2.y<=p1.y&&p1.y<=p2.y+v.y;
}

PVector unProject(PVector v){
  return unProject(v.x,v.y);
}

PVector Project(PVector v){
  return Project(v.x,v.y);
}

PVector unProject(PVector v,PGraphics g){
  return unProject(v.x,v.y,g);
}

PVector Project(PVector v,PGraphics g){
  return Project(v.x,v.y,g);
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

void line(PVector s,PVector v){
  line(s.x,s.y,s.x+v.x,s.y+v.y);
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
    PVector vecAP=createVector(s,c);
    PVector normalAB=normalize(v);//vecAB->b.vel
    float lenAX=dot(normalAB,vecAP);
    float dist;
    if(lenAX<0){
      dist=dist(s.x,s.y,c.x,c.y);
    }else if(lenAX>dist(0,0,v.x,v.y)){
      dist=dist(s.x+v.x,s.y+v.y,c.x,c.y);
    }else{
      dist=abs(cross(normalAB,vecAP));
    }
    return dist<size*0.5;
}

PVector CircleMovePosition(PVector c,float size,PVector s,PVector v){
    PVector vecAP=createVector(s,c);
    PVector normalAB=normalize(v);
    float lenAX=dot(normalAB,vecAP);
    float dist;
    if(lenAX<0){
      if(dist(s.x,s.y,c.x,c.y)>=size*0.5)return c;
      float rad=-atan2(c,s)-PI;
      return s.copy().add(new PVector(0,1).rotate(rad).mult(size*0.5));
    }else if(lenAX>dist(0,0,v.x,v.y)){
      if(dist(s.x+v.x,s.y+v.y,c.x,c.y)>=size*0.5)return c;
      float rad=-atan2(c,new PVector(s.x+v.x,s.y+v.y))-PI;
      return new PVector(s.x+v.x,s.y+v.y).add(new PVector(0,1).rotate(rad).mult(size*0.5));
    }else{
      dist=cross(normalAB,vecAP);
      if(abs(dist)>=size*0.5)return c;
      return c.copy().add(new PVector(-v.y,v.x).normalize().mult((size*0.5-abs(dist))*sign(dist)));
    }
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

PVector getCrossPoint(PVector pos,PVector vel,PVector C,float r) {
  
  float a=vel.y;
  float b=-vel.x;
  float c=-a*pos.x-b*pos.y;
  
  float d=abs((a*C.x+b*C.y+c)/mag(a,b));
  
  float theta = atan2(b, a);
  
  if(d>r){
    return null;
  }else if(d==r){
    PVector point;
    
    if(a*C.x+b*C.y+c>0)theta+=PI;

    float crossX=r*cos(theta)+C.x;
    float crossY=r*sin(theta)+C.y;

    point=new PVector(crossX, crossY);
    return point;
  }else{
    float alpha,beta,phi;
    phi=acos(d/r);
    alpha=theta-phi;
    beta=theta+phi;
    
    if(a*C.x+b*C.y+c>0){
      alpha+=PI;
      beta+=PI;
    }
    
    PVector c1=new PVector(r*cos(alpha)+C.x,r*sin(alpha)+C.y);
    PVector c2=new PVector(r*cos(beta)+C.x,r*sin(beta)+C.y);
    
    if(dist(c1,pos)<dist(c2,pos)){
      if(sign(c1.x-pos.x)==sign(vel.x)){
        return c1;
      }else{
        return c2;
      }
    }else{
      return c2;
    }
  }
}

color toColor(Color c) {
  return color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
}

color toRGB(Color c) {
  return color(c.getRed(),c.getGreen(),c.getBlue(),255);
}

Color toAWTColor(color c) {
  return new Color((c>>16)&0xFF,(c>>8)&0xFF,c&0xFF,(c>>24)&0xFF);
}

Color mult(Color C, float c) {
  return new Color(round(C.getRed()*c),round(C.getGreen()*c),round(C.getBlue()*c),C.getAlpha());
}

Color cloneColor(Color c) {
  return new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
}

void keyPressed(){
  keyPressTime=0;
  keyPress=true;
  ModifierKey=keyCode;
  PressedKey.add(str(key));
  PressedKeyCode.add(str(keyCode));
  nowPressedKey=str(key);
  nowPressedKeyCode=keyCode;
}

void keyReleased(){
  keyPressTime=0;
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
  int threadNum=0;
  boolean isDead=false;
  boolean pDead=false;

  Entity() {
  }

  void display(PGraphics g){
  }

  void update(){
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
    HeapEntityDataX.get(threadNum).add(new AABBData(min,"s",this));
    HeapEntityDataX.get(threadNum).add(new AABBData(max,"e",this));
  }
  
  void Collision(Entity e){
  }
  
  void displayAABB(PGraphics g){
    g.rectMode(CENTER);
    g.noFill();
    g.strokeWeight(1);
    g.stroke(255);
    g.rect(Center.x,Center.y,AxisSize.x,AxisSize.y);
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
      pos=new PVector(width/2, height/2).sub(target.pos);
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

interface ExcludeGPGPU{
}

interface Egent {
  void display(PGraphics g);

  void update();
}

interface DeadEvent{
  void deadEvent(Entity e);
}
