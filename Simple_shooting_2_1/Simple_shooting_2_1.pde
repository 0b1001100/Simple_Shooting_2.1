import processing.awt.*;

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

float absoluteMagnification=1;
float vectorMagnification=1;
float pMagnification=1;

PGraphics preg;

float[] titleLight;
float[] titleLightSpeed;

PShader FXAAShader;
PShader colorInv;
PShader Lighting;
PShader GravityLens;
PShader menuShader;
PShader backgroundShader;
PShader titleShader;
PShader Title_HighShader;
java.util.List<GravityBullet>LensData=Collections.synchronizedList(new ArrayList<GravityBullet>());

GameProcess main;
Stage stage;

ComponentSetLayer stageLayer=new ComponentSetLayer();
ComponentSetLayer starts=new ComponentSetLayer();
ComponentSet resultSet;
ItemList stageList=new ItemList();

int resizedNumber=0;

ItemTable MastarTable;

GL4 gl4;

JSONObject LanguageData;
JSONObject Language;
JSONObject conf;

PImage mouseImage;
PFont font_70;
PFont font_30;
PFont font_20;
PFont font_15;

HashSet<String>moveKeyCode=new HashSet<String>(Arrays.asList(createArray(str(UP),str(DOWN),str(RIGHT),str(LEFT),"87","119","65","97","83","115","68","100")));

ArrayList<String>StageFlag=new ArrayList<String>();
ArrayList<Entity>Entities=new ArrayList<Entity>(50);
ArrayList<Entity>NextEntities=new ArrayList<Entity>();
HashSet<Entity>EntitySet=new HashSet<Entity>();
ArrayList<ArrayList<Entity>>HeapEntity=new ArrayList<ArrayList<Entity>>();
HashSet<String>PressedKeyCode=new HashSet<String>();
HashSet<String>PressedKey=new HashSet<String>();
ArrayList<Long>Times=new ArrayList<Long>();
PVector scroll;
PVector pscreen=new PVector(1280, 720);
PVector localMouse;
boolean mouseWheel=false;
boolean pmousePress=false;
boolean mousePress=false;
boolean keyRelease=false;
boolean keyPress=false;
boolean changeScene=true;
boolean pause=false;
boolean windowResized=false;
boolean resultAnimation=false;
boolean launched=false;
boolean ESCDown=false;
String nowPressedKey;
String nowMenu="Main";
String pMenu="Main";
String StageName="";
float keyPressTime=0;
float resultTime=0;
long pTime=0;
int mouseWheelCount=0;
int compute_program;
int compute_shader;
int nowPressedKeyCode;
int ModifierKey=0;
int pEntityNum=0;
int pscene=0;
int scene=0;

boolean HighQuality=false;
boolean displayFPS=true;
boolean colorInverse=false;
boolean FXAA=false;

static final String VERSION="1.1.0";

static final boolean Windows="\\".equals(System.getProperty("file.separator"));

static final String ShaderPath;
static final String LanguagePath;
static final String StageConfPath;
static final String WeaponDataPath;
static final String SavePath;
static final String ImagePath;

static{
  ShaderPath=Windows?".\\data\\shader\\":"../data/shader/";
  LanguagePath=Windows?".\\data\\lang\\":"../data/lang/";
  StageConfPath=Windows?".\\data\\StageConfig\\":"../data/StageConfig/";
  WeaponDataPath=Windows?".\\data\\WeaponData\\":"../data/WeaponData/";
  SavePath=Windows?".\\data\\save\\":"../data/save/";
  ImagePath=Windows?".\\data\\images\\":"../data/images/";
}

boolean vsync=false;
int RefleshRate=0;
int FrameRateConfig=60;

{
  PJOGL.profile=4;
}

void setup(){
  size(1280,720,P2D);
  hint(DISABLE_OPENGL_ERRORS);
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice device = ge.getDefaultScreenDevice();
  DisplayMode[] modes = device.getDisplayModes();
  for(DisplayMode s:modes){
    RefleshRate=max(RefleshRate,s.getRefreshRate());
  }
  ((GLWindow)surface.getNative()).addWindowListener(new com.jogamp.newt.event.WindowListener() {
    void windowDestroyed(com.jogamp.newt.event.WindowEvent e) {
    }

    void windowDestroyNotify(com.jogamp.newt.event.WindowEvent e) {
    }

    void windowGainedFocus(com.jogamp.newt.event.WindowEvent e){
    }

    void windowLostFocus(com.jogamp.newt.event.WindowEvent e){
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
      g.width=width=w.getWidth();
      g.height=height=w.getHeight();
      ++resizedNumber;
      windowResized=true;
    }
  });
  ((GLWindow)surface.getNative()).addKeyListener(new com.jogamp.newt.event.KeyListener() {
    void keyPressed(com.jogamp.newt.event.KeyEvent e){
    }
    void keyReleased(com.jogamp.newt.event.KeyEvent e){
    }
  });
  mouseImage=loadImage(ImagePath+"mouse.png");
  font_15=createFont("SansSerif.plain",15);
  font_20=createFont("SansSerif.plain",20);
  font_30=createFont("SansSerif.plain",30);
  font_70=createFont("SansSerif.plain",70);
  textFont(font_15);
  FXAAShader=loadShader(ShaderPath+"FXAA.glsl");
  colorInv=loadShader(ShaderPath+"ColorInv.glsl");
  Lighting=loadShader(ShaderPath+"Lighting.glsl");
  GravityLens=loadShader(ShaderPath+"GravityLens.glsl");
  menuShader=loadShader(ShaderPath+"Menu.glsl");
  backgroundShader=loadShader(ShaderPath+"2Dnoise.glsl");
  titleShader=loadShader(ShaderPath+"Title.glsl");
  Title_HighShader=loadShader(ShaderPath+"Title_high.glsl");
  preg=createGraphics(width,height,P2D);
  titleLight=new float[40];
  for(int i=0;i<20;i++){
    titleLight[i*2]=width*0.05*i+random(-5,5);
    titleLight[i*2+1]=random(0,height);
  }
  titleLightSpeed=new float[20];
  for(int i=0;i<20;i++){
    titleLightSpeed[i]=random(2.5,3.5);
  }
  blendMode(ADD);
  scroll=new PVector(0, 0);
  pTime=System.currentTimeMillis();
  localMouse=unProject(mouseX, mouseY);
  initGPGPU();
  if(doGPGPU)try{initMergeGPGPU();}catch(Exception e){e.printStackTrace();}
  LoadData();
  initThread();
}

 public void draw(){
   vectorMagnification*=absoluteMagnification;
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

 public void LoadData(){
  conf=loadJSONObject(SavePath+"config.json");
  useGPGPU=conf.getBoolean("GPGPU");
  if(useGPGPU)initGPGPU();
  LoadLanguage();
  LanguageData=loadJSONObject(LanguagePath+"Languages.json");
  UpgradeArray=loadJSONObject(WeaponDataPath+"WeaponUpgrade.json");
  initStatus();
  JSONArray a=loadJSONArray(WeaponDataPath+"WeaponInit.json");
  for(int i=0;i<a.size();i++){
    try{
      JSONObject o=a.getJSONObject(i);
      String name=o.getString("name");
      WeaponConstructor.put(name,Class.forName("Simple_shooting_2_1$"+name+"Weapon").getDeclaredConstructor(Simple_shooting_2_1.class,JSONObject.class));
      masterTable.addTable(new Item(o,o.getString("type")),o.getFloat("weight"));
    }catch(ClassNotFoundException|NoSuchMethodException g){g.printStackTrace();}
  }
  Arrays.asList(conf.getJSONArray("Weapons").getStringArray()).forEach(s->{playerTable.addTable(masterTable.get(s),masterTable.get(s).getWeight());});
  stageList.addContent(conf.getJSONArray("Stage").getStringArray());
  displayFPS=conf.getBoolean("FPS");
  HighQuality=conf.getBoolean("HighQuality");
  vsync=conf.getBoolean("vsync");
  if(vsync){
    FrameRateConfig=RefleshRate;
    frameRate(FrameRateConfig);
  }
}
  
 public void initStatus(){
  StatusList=new HashMap<String,HashMap<String,Float>>();
  StatusList.put("projectile",new HashMap<String,Float>());
  StatusList.put("scale",new HashMap<String,Float>());
  StatusList.put("power",new HashMap<String,Float>());
  StatusList.put("velocity",new HashMap<String,Float>());
  StatusList.put("duration",new HashMap<String,Float>());
  StatusList.put("cooltime",new HashMap<String,Float>());
  AddtionalStatus=new HashMap<String,Float>();
  AddtionalStatus.put("projectile",0f);
  AddtionalStatus.put("scale",1f);
  AddtionalStatus.put("power",1f);
  AddtionalStatus.put("velocity",1f);
  AddtionalStatus.put("duration",1f);
  AddtionalStatus.put("cooltime",1f);
}

void applyStaus(){
  StatusList.forEach((k1,v1)->{
    AddtionalStatus.put(k1,k1.equals("projectile")?0f:1f);
    v1.forEach((k2,v2)->{
      AddtionalStatus.replace(k1,AddtionalStatus.get(k1)+v2);
    });
  });
  player.subWeapons.forEach(w->{
    w.reInit();
  });
}

 public void LoadLanguage(){
  Language=loadJSONObject(LanguagePath+conf.getString("Language")+".json");
}

String getLanguageText(String s){
  return Language.getString(s);
}

 public void Menu() {
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

 public void initMenu(){
  starts=new ComponentSetLayer();
  NormalButton New=new NormalButton(Language.getString("start_game"));
  New.setBounds(width*0.5-60,height-80,120,30);
  New.addListener(()-> {
    starts.toChild("main");
  });
  New.addWindowResizeEvent(()->{
    New.setBounds(width*0.5-60,height-80,120,30);
  });
  Canvas TitleCanvas=new Canvas(g);
  TitleCanvas.setContent((g)->{
    if(HighQuality){
      Title_HighShader.set("time",System.nanoTime()/10000000000f);
      Title_HighShader.set("mouse",0,0);
      Title_HighShader.set("resolution",width,height);
      filter(Title_HighShader);
    }else{
      for(int i=0;i<20;i++){
        titleLight[i*2+1]-=titleLightSpeed[i];
        if(titleLight[i*2+1]<0)titleLight[i*2+1]=height;
      }
      if(frameCount==1){
        preg.beginDraw();
        preg.background(0);
        preg.endDraw();
        preg.loadPixels();
        g.loadPixels();
        titleShader.set("tex",g);
        titleShader.set("position",titleLight,2);
        titleShader.set("resolution",width,height);
        preg.filter(titleShader);
        g.filter(titleShader);
      }else{
        preg.loadPixels();
        g.loadPixels();
        titleShader.set("tex",preg);
        titleShader.set("position",titleLight,2);
        titleShader.set("resolution",width,height);
        preg.filter(titleShader);
        g.filter(titleShader);
      }
    }
    g.fill(255);
    g.textFont(font_70);
    g.textAlign(CENTER);
    g.textSize(70);
    g.text("Simple_shooting_2.1",width*0.5,130);
    g.fill(200);
    g.textFont(font_15);
    g.textAlign(LEFT);
    g.textSize(15);
    g.text("["+VERSION+"]  Developed by 0x4C",10,height-10);
  });
  TitleCanvas.addWindowResizeEvent(()->{
    preg=createGraphics(width,height,P2D);
    for(int i=0;i<20;i++){
      titleLight[i*2]=width*0.05*i+random(-5,5);
      titleLight[i*2+1]=random(0,height);
    }
  });
  ComponentSet titleSet=toSet(TitleCanvas,New);
  titleSet.addSelect();
  Y_AxisLayout mainLayout=new Y_AxisLayout(100,120,120,25,15);
  MenuButton Select=new MenuButton(Language.getString("stage_select"));
  Select.addListener(()->{
    starts.toChild("stage");
  });
  //--
    stageList.setBounds(250,100,300,500);
    stageList.showSub=false;
    stageList.addSelectListener((s)->{
      scene=1;
      StageName=s;
    });
  //--
  MenuButton Config=new MenuButton(Language.getString("config"));
  Config.addListener(()->{
    starts.toChild("confMenu");
  });
  MenuTextBox confBox=new MenuTextBox(Language.getString("ex"));
  confBox.setBounds(width-320,100,300,500);
  confBox.addWindowResizeEvent(()->{
    confBox.setBounds(width-320,100,300,500);
  });
  //---
    Y_AxisLayout confLayout=new Y_AxisLayout(250,160,120,25,15);
    MenuCheckBox AbsMag=new MenuCheckBox(Language.getString("mag_set"),absoluteMagnification==1.5);
    AbsMag.addListener(()->{
      absoluteMagnification=AbsMag.value?1.5:1;
    });
    AbsMag.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_mag_set"));
      }
      
       public void lostFocus(){}
    });
    MenuCheckBox Colorinv=new MenuCheckBox(Language.getString("color_inverse"),colorInverse);
    Colorinv.addListener(()->{
      colorInverse=Colorinv.value;
    });
    Colorinv.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_color_inverse"));
      }
      
       public void lostFocus(){}
    });
    MenuCheckBox dispFPS=new MenuCheckBox(Language.getString("disp_FPS"),displayFPS);
    dispFPS.addListener(()->{
      displayFPS=dispFPS.value;
      conf.setBoolean("FPS",displayFPS);
      exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
    });
    dispFPS.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_disp_FPS"));
      }
      
       public void lostFocus(){}
    });
    MenuCheckBox Quality=new MenuCheckBox(Language.getString("Quality"),HighQuality);
    Quality.setCustomizeText(getLanguageText("ex_qu_high"),getLanguageText("ex_qu_low"));
    Quality.addListener(()->{
      HighQuality=Quality.value;
      conf.setBoolean("HighQuality",HighQuality);
      exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
    });
    Quality.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_Quality"));
      }
      
       public void lostFocus(){}
    });
    MenuCheckBox vsy=new MenuCheckBox(Language.getString("VSync"),vsync);
    vsy.addListener(()->{
      vsync=vsy.value;
      FrameRateConfig=vsync?RefleshRate:60;
      frameRate(FrameRateConfig);
      conf.setBoolean("vsync",vsync);
      exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
    });
    vsy.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_VSync"));
      }
      
       public void lostFocus(){}
    });
    MenuButton Lang=new MenuButton(Language.getString("language"));
    Lang.addListener(()->{
      starts.toChild("Language");
    });
    Lang.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_language"));
      }
      
       public void lostFocus(){}
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
        exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
        LoadLanguage();
        initMenu();
        starts.toParent();
      });
    //--
    MenuButton exit=new MenuButton(Language.getString("exit"));
    exit.addListener(()->{
      exit();
    });
    exit.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_exit"));
      }
      
       public void lostFocus(){}
    });
  //---
  MenuButton operationEx=new MenuButton(Language.getString("operation_ex"));
  operationEx.addListener(()->{
    starts.toChild("operation");
  });
  //--
    MenuButton back_op=new MenuButton(Language.getString("back"));
    back_op.setBounds(width*0.5f-60,height*0.9f,120,25);
    back_op.addListener(()->{
      starts.toParent();
    });
    back_op.addWindowResizeEvent(()->{
      back_op.setBounds(width*0.5f-60,height*0.9f,120,25);
    });
    Canvas op_canvas=new Canvas(g);
    op_canvas.setContent((pg)->{
      pg.beginDraw();
      pg.blendMode(BLEND);
      pg.rectMode(CENTER);
      pg.fill(20);
      pg.noStroke();
      for(int i=0;i<4;i++)pg.rect(87.5f+45*i,70,35,35,3);
      pg.textSize(30);
      pg.textFont(font_30);
      pg.textAlign(CENTER);
      pg.fill(255);
      for(int i=0;i<4;i++)pg.text(i==0?"W":i==1?"A":i==2?"S":i==3?"D":"",87.5f+45*i,82.5f);
      pg.fill(0);
      pg.textAlign(LEFT);
      text(": "+Language.getString("move"),245,82.5f);
      image(mouseImage,70,85);
      text(": "+Language.getString("shot"),150,130);
      pg.endDraw();
    });
  //--
  MenuButton credit=new MenuButton(Language.getString("credit"));
  credit.addListener(()->{
    starts.toChild("credit");
  });
  //--
    MenuButton back_cr=new MenuButton(Language.getString("back"));
    back_cr.setBounds(width*0.5f-60,height*0.9f,120,25);
    back_cr.addListener(()->{
      starts.toParent();
    });
    back_cr.addWindowResizeEvent(()->{
      back_cr.setBounds(width*0.5f-60,height*0.9f,120,25);
    });
    PFont[] f={createFont("SansSerif.plain",height*0.03)};
    boolean[] cr_res={true};
    Canvas cr_canvas=new Canvas(g);
    cr_canvas.addWindowResizeEvent(()->{
      cr_res[0]=true;
    });
    cr_canvas.setContent((pg)->{
      pg.beginDraw();
      if(cr_res[0]){
        f[0]=createFont("SansSerif.plain",height*0.03);
        cr_res[0]=false;
      }
      pg.fill(0);
      pg.rectMode(CORNER);
      pg.textAlign(CENTER,TOP);
      pg.textLeading(30);
      pg.textSize(height*0.03);
      pg.textFont(f[0]);
      pg.text(getLanguageText("credit_co"),0,30,width,height*0.9-30);
      pg.textAlign(CENTER,BOTTOM);
      pg.textLeading(30);
      if(conf.getBoolean("clear"))pg.text(getLanguageText("credit_co_2"),0,0,width,height*0.9-30);
      pg.endDraw();
    });
  //--
  starts.setSubChildDisplayType(1);
  starts.addLayer("root",titleSet);
  starts.addChild("root","main",toSet(mainLayout,Select,Config,operationEx,credit));
  starts.addSubChild("main","stage",toSet(stageList));
  starts.addSubChild("main","confMenu",toSet(confLayout,AbsMag,Colorinv,dispFPS,Quality,vsy,Lang,exit),toSet(confBox));
  starts.addSubChild("confMenu","Language",toSet(LangList));
  starts.addChild("main","operation",toSet(back_op,op_canvas));
  starts.addChild("main","credit",toSet(back_cr,cr_canvas));
  if(launched){
    starts.toChild("main");
  }else{
    launched=true;
  }
}

 public void Load(){
  background(0);
  scene=2;
}

 public void Result(){
  if(changeScene){
    resetMatrix();
    resultAnimation=true;
    resultTime=0;
    MenuButton resultButton=new MenuButton("OK");
    resultButton.setBounds(width*0.5f-60,height*0.7f,120,25);
    resultButton.addWindowResizeEvent(()->{
      resultButton.setBounds(width*0.5f-60,height*0.7f,120,25);
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
  text(StageFlag.contains("Game_Over")?"Game over":"Stage clear",width*0.5f,height*0.2f);
  resultSet.display();
  resultSet.update();
  if(resultAnimation){
    menuShader.set("time",resultTime);
    menuShader.set("xy",(float)main.x,(float)main.y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",230f/255f,230f/255f,230f/255f,1.0f);
    menuShader.set("tex",g);
    filter(menuShader);
  }
}

 public void initThread(){
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

 public void Field() {
  if (changeScene){
    main=new GameProcess();
    main.FieldSize=null;
    stage.name=StageName;
    JSONArray data=loadJSONArray(StageConfPath+StageName+".json");
    for(int i=0;i<data.size();i++){
      JSONObject config=data.getJSONObject(i);
      JSONObject param=config.getJSONObject("param");
      if(config.getString("type").equals("auto")){
        HashMap<Enemy,Float> map=new HashMap<Enemy,Float>();
        float sum=0;
        float mag;
        for(int j=0;j<param.getJSONArray("data").size();j++){
          sum+=param.getJSONArray("data").getJSONObject(j).getFloat("freq");
        }
        mag=1/sum;
        for(int j=0;j<param.getJSONArray("data").size();j++){
          try{
            map.put((Enemy)Class.forName("Simple_shooting_2_1$"+param.getJSONArray("data").getJSONObject(j).getString("name")).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet),param.getJSONArray("data").getJSONObject(j).getFloat("freq")*mag);
          }catch(ClassNotFoundException|NoSuchMethodException|InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
        }
        stage.addProcess(StageName,new TimeSchedule(config.getFloat("time"),s->{s.autoSpown(param.getBoolean("disp"),param.getFloat("freq"),map);}));
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
      }else if(config.getString("type").equals("wall")){
        //wall process
      }
    }
    stage.addProcess(StageName,new TimeSchedule(2000,s->{s.endSchedule=true;}));
  }
  main.process();
}

 public void eventProcess() {
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

 public void updateFPS() {
  Times.add(System.currentTimeMillis()-pTime);
  while (Times.size()>60) {
    Times.remove(0);
  }
  pTime=System.currentTimeMillis();
  vectorMagnification=60f/(1000f/Times.get(Times.size()-1));
}

 public void updatePreValue() {
  pMagnification=vectorMagnification;
  windowResized=false;
  keyRelease=false;
  keyPress=false;
  mouseWheel=false;
  mouseWheelCount=0;
  pmousePress=mousePressed;
  pscene=scene;
  pMenu=nowMenu;
  pEntityNum=EntityDataX.size();
  EntityDataX.clear();
}

 public void Shader(){
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

 public void printFPS() {
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

 public void applyShader(PShader s){
  pushMatrix();
  resetMatrix();
  noStroke();
  shader(s);
  image(g,0,0);
  blendMode(BLEND);
  resetShader();
  popMatrix();
}

 public void applyShader(PShader s,PGraphics g){
  g.pushMatrix();
  g.resetMatrix();
  g.noStroke();
  g.shader(s);
  g.image(g,0,0);
  g.blendMode(BLEND);
  g.resetShader();
  g.popMatrix();
}

 public PMatrix3D getMatrixLocalToWindow(PGraphics g) {
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

 public PVector unProject(float winX, float winY) {
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

 public PVector unProject(float winX, float winY,PGraphics g) {
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

 public PVector Project(float winX, float winY) {
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

 public PVector Project(float winX, float winY,PGraphics g) {
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

 public <T> T[] createArray(T... val){
  return val;
}

 public <P extends Collection,C extends Collection> boolean containsList(P p,C c){
  boolean ret=false;
  for(Object o:c){
    if(p.contains(o)){
      ret=true;
      break;
    }
  }
  return ret;
}

 public void updateUniform2f(String uniformName,float uniformValue1,float uniformValue2){
  int loc=gl4.glGetUniformLocation(compute_program,uniformName);
  gl4.glUniform2f(loc,uniformValue1,uniformValue2);
  if (loc!=-1){
    gl4.glUniform2f(loc,uniformValue1,uniformValue2);
  }
}

 public boolean onMouse(float x, float y, float dx, float dy) {
  return x<=mouseX&mouseX<=x+dx&y<=mouseY&mouseY<=y+dy;
}

 public boolean onBox(PVector p1,PVector p2,PVector v){
  return p2.x<=p1.x&&p1.x<=p2.x+v.x&&p2.y<=p1.y&&p1.y<=p2.y+v.y;
}

 public PVector unProject(PVector v){
  return unProject(v.x,v.y);
}

 public PVector Project(PVector v){
  return Project(v.x,v.y);
}

 public PVector unProject(PVector v,PGraphics g){
  return unProject(v.x,v.y,g);
}

 public PVector Project(PVector v,PGraphics g){
  return Project(v.x,v.y,g);
}

 public float Sigmoid(float t) {
  return 1f/(1+pow(2.7182818f, -t));
}

 public float ESigmoid(float t) {
  return pow(2.718281828f, 5-t)/pow(pow(2.718281828f, 5-t)+1, 2);
}

 public int sign(float f) {
  return f==0?0:f>0?1:-1;
}

 public void line(PVector s,PVector v){
  line(s.x,s.y,s.x+v.x,s.y+v.y);
}

 public float dist(PVector a, PVector b) {
  return dist(a.x, a.y, b.x, b.y);
}

 public float sqDist(PVector s, PVector e){
  return (s.x-e.x)*(s.x-e.x)+(s.y-e.y)*(s.y-e.y);
}

 public boolean qDist(PVector s, PVector e, float d) {
  return ((s.x-e.x)*(s.x-e.x)+(s.y-e.y)*(s.y-e.y))<=d*d;
}

 public boolean qDist(PVector s1, PVector e1, PVector s2, PVector e2) {
  return ((s1.x-e1.x)*(s1.x-e1.x)+(s1.y-e1.y)*(s1.y-e1.y))<=((s2.x-e2.x)*(s2.x-e2.x)+(s2.y-e2.y)*(s2.y-e2.y));
}

 public float atan2(PVector s,PVector e){
  return atan2(e.x-s.x,e.y-s.y);
}

 public float cross(PVector v1, PVector v2) {
  return v1.x*v2.y-v2.x*v1.y;
}

 public float dot(PVector v1, PVector v2) {
  return v1.x*v2.x+v1.y*v2.y;
}

 public PVector normalize(PVector s, PVector e) {
  float f=s.dist(e);
  return new PVector((e.x-s.x)/f, (e.y-s.y)/f);
}

 public PVector normalize(PVector v) {
  float f=sqrt(sq(v.x)+sq(v.y));
  return new PVector(v.x/f, v.y/f);
}

 public PVector createVector(PVector s, PVector e) {
  return e.copy().sub(s);
}

 public PVector clampOnRectangle(PVector p,PVector pos,PVector dist){
  PVector clamp = new PVector();
  clamp.x = constrain(p.x,pos.x,pos.x+dist.x );
  clamp.y = constrain(p.y,pos.y,pos.x+dist.y );
  return clamp;
}

 public boolean circleRectangleCollision(PVector c,float r,PVector pos,PVector dist){
  PVector clamped = clampOnRectangle(c,pos,dist);
  return qDist(c,clamped,r);
}

 public boolean circleOrientedRectangleCollision(PVector c,float r,PVector pos,PVector dist,float rotate){
  PVector distance = c.copy().sub(pos);
  distance.rotate(-rotate);
  return circleRectangleCollision(distance,r,new PVector(0,0),dist);
}

 public boolean SegmentOrientedRectangleCollision(PVector s,PVector v,PVector pos,PVector dist,float rotate){
  PVector dist1 = s.copy().sub(pos);
  dist1.rotate(-rotate);
  PVector dist2 = s.copy().add(v).sub(pos);
  dist2.rotate(-rotate);
  PVector vec=v.copy().rotate(-rotate);
  return onBox(dist1,new PVector(0,0),dist)||onBox(dist2,new PVector(0,0),dist)||
         SegmentCollision(dist1,vec,new PVector(0,0),new PVector(dist.x,0))||SegmentCollision(dist1,vec,new PVector(0,0).add(0,dist.y),new PVector(dist.x,0))||
         SegmentCollision(dist1,vec,new PVector(0,0),new PVector(0,dist.y))||SegmentCollision(dist1,vec,new PVector(0,0).add(dist.x,0),new PVector(0,dist.y));
}

 public boolean CircleCollision(PVector c,float size,PVector s,PVector v){
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
    return dist<size*0.5f;
}

 public PVector CircleMovePosition(PVector c,float size,PVector s,PVector v){
    PVector vecAP=createVector(s,c);
    PVector normalAB=normalize(v);
    float lenAX=dot(normalAB,vecAP);
    float dist;
    if(lenAX<0){
      if(dist(s.x,s.y,c.x,c.y)>=size*0.5f)return c;
      float rad=-atan2(c,s)-PI;
      return s.copy().add(new PVector(0,1).rotate(rad).mult(size*0.5f));
    }else if(lenAX>dist(0,0,v.x,v.y)){
      if(dist(s.x+v.x,s.y+v.y,c.x,c.y)>=size*0.5f)return c;
      float rad=-atan2(c,new PVector(s.x+v.x,s.y+v.y))-PI;
      return new PVector(s.x+v.x,s.y+v.y).add(new PVector(0,1).rotate(rad).mult(size*0.5f));
    }else{
      dist=cross(normalAB,vecAP);
      if(abs(dist)>=size*0.5f)return c;
      return c.copy().add(new PVector(-v.y,v.x).normalize().mult((size*0.5f-abs(dist))*sign(dist)));
    }
}

 public boolean CapsuleCollision(PVector p1,PVector v1,PVector p2,PVector v2,float r){
  if(SegmentCollision(p1,v1,p2,v2)){
    return true;
  }else{
    if(CircleCollision(p2,r,p1,v1)||CircleCollision(p2.copy().add(v2),r,p1,v1)){
      return true;
    }else{
      return false;
    }
  }
}

 public boolean SegmentCollision(PVector s1, PVector v1, PVector s2, PVector v2) {
  PVector v=new PVector(s2.x-s1.x, s2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return false;
  }
  float crs_v_v1=cross(v, v1);
  float crs_v_v2=cross(v, v2);
  float t1 = crs_v_v2/crs_v1_v2;
  float t2 = crs_v_v1/crs_v1_v2;
  if (t1+0.000000000001f<0||t1-0.000000000001f>1||t2+0.000000000001f<0||t2-0.000000000001f>1) {
    return false;
  }
  return true;
}

 public boolean LineCollision(PVector s1, PVector v1, PVector l2, PVector v2) {
  PVector v=new PVector(l2.x-s1.x, l2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return false;
  }
  float t=cross(v, v1);
  if (t+0.00001f<0|1<t-0.00001f) {
    return false;
  }
  return true;
}

 public PVector SegmentCrossPoint(PVector s1, PVector v1, PVector s2, PVector v2) {
  PVector v=new PVector(s2.x-s1.x, s2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return null;
  }
  float crs_v_v1=cross(v, v1);
  float crs_v_v2=cross(v, v2);
  float t1 = crs_v_v2/crs_v1_v2;
  float t2 = crs_v_v1/crs_v1_v2;
  if (t1+0.000000000001f<0||t1-0.000000000001f>1||t2+0.000000000001f<0||t2-0.000000000001f>1) {
    return null;
  }
  return s1.add(v1.copy().mult(t1));
}

 public PVector LineCrossPoint(PVector s1, PVector v1, PVector l2, PVector v2) {
  PVector v=new PVector(l2.x-s1.x, l2.y-s1.y);
  float crs_v1_v2=cross(v1, v2);
  if (crs_v1_v2==0) {
    return null;
  }
  float t=cross(v, v1);
  if (t+0.000000000001f<0||t-0.000000000001f>1) {
    return null;
  }
  return s1.add(v1.copy().mult(t));
}

 public PVector getCrossPoint(PVector pos,PVector vel,PVector C,float r) {
  
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

 public int toColor(Color c) {
  return color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
}

 public int toRGB(Color c) {
  return color(c.getRed(),c.getGreen(),c.getBlue(),255);
}

 public Color toAWTColor(int c) {
  return new Color((c>>16)&0xFF,(c>>8)&0xFF,c&0xFF,(c>>24)&0xFF);
}

 public Color mult(Color C, float c) {
  return new Color(round(C.getRed()*c),round(C.getGreen()*c),round(C.getBlue()*c),C.getAlpha());
}

 public Color cloneColor(Color c) {
  return new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
}

public boolean isParent(Entity e,Entity f){
  if(e instanceof Bullet||f instanceof Bullet){
    if(f instanceof Bullet)return false;
  }else if((e instanceof Enemy&&!(e instanceof Explosion))||(f instanceof Enemy&&!(f instanceof Explosion))){
    if(f instanceof Enemy)return false;
  }else if(e instanceof Myself||f instanceof Myself){
    if(f instanceof Myself)return false;
  }else if(e instanceof Explosion||f instanceof Explosion){
    if(f instanceof Explosion)return false;
  }else if(e instanceof WallEntity||f instanceof WallEntity){
    if(f instanceof WallEntity)return false;
  }
  return true;
}

 public void keyPressed(){
  keyPressTime=0;
  keyPress=true;
  ModifierKey=keyCode;
  PressedKey.add(str(key).toLowerCase());
  PressedKeyCode.add(str(keyCode));
  nowPressedKey=str(key);
  nowPressedKeyCode=keyCode;
  if(key==ESC)key=255;
}

 public void keyReleased(){
  keyPressTime=0;
  keyRelease=false;
  ModifierKey=-1;
  PressedKeyCode.remove(str(keyCode));
  PressedKey.remove(str(key).toLowerCase());
}

 public void mouseWheel(processing.event.MouseEvent e){
  mouseWheel=true;
  mouseWheelCount+=e.getCount();
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
  float accelSpeed=0.25f;
  float maxSpeed=7.5f;
  float Speed=0;
  float Mass=10;
  float e=0.5f;
  int threadNum=0;
  boolean isDead=false;
  boolean pDead=false;

  Entity() {
  }

   public void display(PGraphics g){
  }

   public void update(){
    if(isDead&&!pDead){
      dead.deadEvent(this);
      pDead=isDead;
    }
  }

   public void setColor(Color c) {
    this.c=c;
  }

   public void setMaxSpeed(float s) {
    maxSpeed=s;
  }

   public void setSpeed(float s) {
    Speed=s;
  }

   public void setMass(float m) {
    Mass=m;
  }
  
  void setSize(float s){
    size=s;
  }

  public Entity clone()throws CloneNotSupportedException {
    Entity clone=(Entity)super.clone();
    clone.pos=pos==null?null:pos.copy();
    clone.vel=vel==null?null:vel.copy();
    clone.c=cloneColor(c);
    return clone;
  }
  
  public void addDeadListener(DeadEvent e){
    dead=e;
  }
  
  protected void putAABB(){
    float x=AxisSize.x*0.5f;
    float min=Center.x-x;
    float max=Center.x+x;
    HeapEntityDataX.get(threadNum).add(new AABBData(min,"s",this));
    HeapEntityDataX.get(threadNum).add(new AABBData(max,"e",this));
  }
  
  public void Collision(Entity e){}
  
  public void ExplosionCollision(Explosion e){}
  
  public void EnemyCollision(Enemy e){}
  
  public void BulletCollision(Bullet b){}
  
  public void MyselfCollision(Myself e){}  
  
  public void WallCollision(WallEntity w){}  
  
  public void ExplosionHit(Explosion e,boolean p){}
  
  public void EnemyHit(Enemy e,boolean p){}
  
  public void BulletHit(Bullet b,boolean p){}
  
  public void MyselfHit(Myself e,boolean p){}  
  
  public void WallHit(WallEntity w,boolean p){}  
  
  public void displayAABB(PGraphics g){
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

   public void update() {
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

   public void setTarget(Entity e) {
    target=e;
    pos=new PVector(width/2, height/2).sub(e.pos);
  }

   public void reset() {
    pos=new PVector(width/2, height/2).sub(target.pos);
  }

   public void moveTo(float wx, float wy) {
    movePos=new PVector(-wx, -wy).add(width, height).sub(pos.x*2, pos.y*2);
    moveDist=movePos.dist(pos);
    moveEvent=true;
    moveTo=false;
  }

   public void resetMove() {
    moveEvent=false;
    resetMove=false;
    moveTo=false;
    pos=new PVector(width/2, height/2).sub(target.pos);
    moveTime=0;
    stopTime=60;
  }

   public void move() {
    if (moveTime<60) {
      float scala=ESigmoid((float)moveTime/6f/5.91950f);
      vel=new PVector((movePos.x-target.pos.x)*scala, (movePos.y-target.pos.y)*scala);
      pos.add(vel);
      moveTime++;
    } else {
      pos=new PVector(movePos.x, movePos.y);
      moveTo=true;
    }
  }

   public void returnMove() {
    if (moveTime>0) {
      float scala=ESigmoid((float)moveTime/6f/5.91950f);
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
