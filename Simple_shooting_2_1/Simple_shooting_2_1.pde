//You must add "--enable-preview" option (when you compie this program).

import processing.awt.*;

import java.awt.*;
import java.awt.event.*;

import java.lang.reflect.*;

import java.nio.*;
import java.nio.file.*;

import java.util.*;
import java.util.stream.*;
import java.util.concurrent.*;
import java.util.function.*;
import java.util.Map.Entry;
import java.util.Timer;
import java.util.TimerTask;

import net.java.games.input.*;

import com.jogamp.opengl.util.GLBuffers;
import com.jogamp.newt.opengl.*;
import com.jogamp.newt.event.*;
import com.jogamp.opengl.*;
import com.jogamp.newt.*;

import SSGUI.input.*;
import SSGUI.Component.*;

//import jdk.incubator.vector.*;

import static com.jogamp.common.util.IOUtil.ClassResources;

import static com.jogamp.newt.event.KeyEvent.*;

Simple_shooting_2_1 CopyApplet=this;

Myself player;

ExecutorService exec;

//VectorSpecies<Float> SPECIES = FloatVector.SPECIES_256;

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

HashMap<String,BackgroundShader>backgrounds=new HashMap<>();
PShader FXAAShader;
PShader colorInv;
PShader Lighting;
PShader GravityLens;
PShader menuShader;
PShader backgroundShader;
PShader titleShader;
PShader Title_HighShader;
PShader Oscillo;
PShader Oscillo_Otsu;
java.util.List<GravityBullet>LensData=Collections.synchronizedList(new ArrayList<GravityBullet>());
HashMap<String,PImage>confImage=new HashMap<>();

int oscilloState=0;

Input main_input;

AtomicInteger killCount=new AtomicInteger(0);
GameProcess main_game;
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

PFont font_70;
PFont font_50;
PFont font_30;
PFont font_20;
PFont font_15;

HashSet<String>moveKeyCode=new HashSet<String>(Arrays.asList(createArray(str(UP),str(DOWN),str(RIGHT),str(LEFT),"87","119","65","97","83","115","68","100")));

ArrayList<String>StageFlag=new ArrayList<String>();
ArrayList<Entity>Entities=new ArrayList<Entity>(50);
ArrayList<Entity>NextEntities=new ArrayList<Entity>();
HashSet<Entity>EntitySet=new HashSet<Entity>();
ArrayList<String>ArchiveEntity=new ArrayList<>();
ArrayList<ArrayList<Entity>>HeapEntity=new ArrayList<ArrayList<Entity>>();
HashSet<String>PressedKeyCode=new HashSet<String>();
HashSet<String>PressedKey=new HashSet<String>();
ArrayList<Long>Times=new ArrayList<Long>();
PVector scroll;
PVector pscreen=new PVector(1280, 720);
PVector localMouse;
boolean mouseWheel=false;
boolean pmousePress=false;
boolean keyRelease=false;
boolean keyPress=false;
boolean changeScene=true;
boolean pause=false;
boolean windowResized=false;
boolean resultAnimation=false;
boolean launched=false;
boolean ESCDown=false;
boolean confImageLoaded=false;
String nowPressedKey;
String nowMenu="Main";
String pMenu="Main";
String StageName="";
float keyPressTime=0;
float resultTime=0;
long pTime=0;
int fragmentCount=0;
int mouseWheelCount=0;
int compute_program;
int compute_shader;
int nowPressedKeyCode;
int ModifierKey=0;
int pEntityNum=0;
int pscene=0;
int scene=0;

int ShaderQuality=0;
boolean displayFPS=true;
boolean colorInverse=false;
boolean fullscreen=false;
boolean FXAA=false;

SoundManager soundManager;

static final int STAGE_COUNT=10;//Can release Stage1 to Stage[STAGE_COUNT].

static final String VERSION="1.1.6";

static final boolean Windows="\\".equals(System.getProperty("file.separator"));

static final String ShaderPath;
static final String ItemPath;
static final String LanguagePath;
static final String EnemyPath;
static final String StageConfPath;
static final String WeaponDataPath;
static final String SavePath;
static final String ImagePath;
static final String SoundPath;

static{
  ShaderPath=Windows?".\\data\\shader\\":"../data/shader/";
  ItemPath=Windows?".\\data\\item\\":"../data/item/";
  LanguagePath=Windows?".\\data\\lang\\":"../data/lang/";
  EnemyPath=Windows?".\\data\\enemy\\":"../data/enemy/";
  StageConfPath=Windows?".\\data\\StageConfig\\":"../data/StageConfig/";
  WeaponDataPath=Windows?".\\data\\WeaponData\\":"../data/WeaponData/";
  SavePath=Windows?".\\data\\save\\":"../data/save/";
  ImagePath=Windows?".\\data\\images\\":"../data/images/";
  SoundPath=Windows?".\\data\\sound\\":"../data/sound/";
}

boolean vsync=false;
int RefleshRate=0;
int FrameRateConfig=60;

{
  PJOGL.profile=4;
}

void settings(){
  size(1280,720,P2D);
  pixelDensity(displayDensity());
  noSmooth();
  try{
    Field icon=PJOGL.class.getDeclaredField("icons");
    icon.setAccessible(true);
    icon.set(surface,new String[]{ImagePath+"icon_16.png",ImagePath+"icon_48.png"});
  }catch(Exception e){e.printStackTrace();}
}

void setup(){
  NewtFactory.setWindowIcons(new ClassResources(new String[]{ImagePath+"icon_16.png",ImagePath+"icon_48.png"},this.getClass().getClassLoader(),this.getClass()));
  hint(DISABLE_OPENGL_ERRORS);
  hint(DISABLE_DEPTH_SORT);
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_DEPTH_MASK);
  hint(DISABLE_TEXTURE_MIPMAPS);
  ((GLWindow)surface.getNative()).addWindowListener(new com.jogamp.newt.event.WindowListener() {
    public void windowDestroyed(com.jogamp.newt.event.WindowEvent e) {
    }

    public void windowDestroyNotify(com.jogamp.newt.event.WindowEvent e) {
    }

    public void windowGainedFocus(com.jogamp.newt.event.WindowEvent e){
    }

    public void windowLostFocus(com.jogamp.newt.event.WindowEvent e){
    }

    public void  windowMoved(com.jogamp.newt.event.WindowEvent e) {
    }

    public void windowRepaint(WindowUpdateEvent e) {
    }

    @Override
      public void windowResized(com.jogamp.newt.event.WindowEvent e) {
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
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice device = ge.getDefaultScreenDevice();
  DisplayMode[] modes = device.getDisplayModes();
  for(DisplayMode s:modes){
    RefleshRate=max(RefleshRate,s.getRefreshRate());
  }
  ((GLWindow)surface.getNative()).addKeyListener(new com.jogamp.newt.event.KeyListener() {
    public void keyPressed(com.jogamp.newt.event.KeyEvent e){
    }
    public void keyReleased(com.jogamp.newt.event.KeyEvent e){
    }
  });
  for(int i=0;i<60;i++){
    updateStatistics.add(-1f);
    collisionStatistics.add(-1f);
    drawStatistics.add(-1f);
    runStatistics.add(-1f);
  }
  font_15=createFont("SansSerif.plain",15);
  font_20=createFont("SansSerif.plain",20);
  font_30=createFont("SansSerif.plain",30);
  font_50=createFont("SansSerif.plain",50);
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
  Oscillo=loadShader(ShaderPath+"Oscillo.glsl");
  Oscillo_Otsu=loadShader(ShaderPath+"Oscillo_Otsu.glsl");
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
  try{
  soundManager=new SoundManager();
  }catch(Exception e){e.printStackTrace();}
  LoadData();
  initThread();
  exec.execute(()->{
    confImage.put("mouse",loadImage(ImagePath+"mouse.png"));
    confImage.put("w",loadImage(ImagePath+"key_w.png"));
    confImage.put("a",loadImage(ImagePath+"key_a.png"));
    confImage.put("s",loadImage(ImagePath+"key_s.png"));
    confImage.put("d",loadImage(ImagePath+"key_d.png"));
    confImage.put("up",loadImage(ImagePath+"key_up.png"));
    confImage.put("down",loadImage(ImagePath+"key_down.png"));
    confImage.put("right",loadImage(ImagePath+"key_right.png"));
    confImage.put("left",loadImage(ImagePath+"key_left.png"));
    confImage.put("ctrl",loadImage(ImagePath+"key_Ctrl.png"));
    confImage.put("shift",loadImage(ImagePath+"key_Shift.png"));
    confImage.put("tab",loadImage(ImagePath+"key_Tab.png"));
    confImage.put("enter",loadImage(ImagePath+"key_Enter.png"));
    confImage.put("w_p",loadImage(ImagePath+"key_w_p.png"));
    confImage.put("a_p",loadImage(ImagePath+"key_a_p.png"));
    confImage.put("s_p",loadImage(ImagePath+"key_s_p.png"));
    confImage.put("d_p",loadImage(ImagePath+"key_d_p.png"));
    confImage.put("up_p",loadImage(ImagePath+"key_up_p.png"));
    confImage.put("down_p",loadImage(ImagePath+"key_down_p.png"));
    confImage.put("right_p",loadImage(ImagePath+"key_right_p.png"));
    confImage.put("left_p",loadImage(ImagePath+"key_left_p.png"));
    confImage.put("ctrl_p",loadImage(ImagePath+"key_Ctrl_p.png"));
    confImage.put("shift_p",loadImage(ImagePath+"key_Shift_p.png"));
    confImage.put("tab_p",loadImage(ImagePath+"key_Tab_p.png"));
    confImage.put("enter_p",loadImage(ImagePath+"key_Enter_p.png"));
    confImageLoaded=true;
  });
  exec.execute(()->{
    JSONObject ex=loadJSONObject(StageConfPath+"Stage_ex.json");
    JSONArray Stages=conf.getJSONArray("Stage");
    for(int i=0;i<Stages.size();i++){
      if(conf.getJSONObject("Record").hasKey(Stages.getString(i))){
        JSONObject o=conf.getJSONObject("Record").getJSONObject(Stages.getString(i));
        float time=o.getInt("time");
        stageList.addExplanation(Stages.getString(i),ex.getJSONObject(Stages.getString(i)).getString(conf.getString("Language"))+
          "\n\nRecord\n  Time: "+nf(floor(time/60),floor(time/6000)>=1?0:2,0)+":"+nf(floor(time%60),2,0)+
          "\n  Score: "+o.getInt("score"));
      }else{
        stageList.addExplanation(Stages.getString(i),ex.getJSONObject(Stages.getString(i)).getString(conf.getString("Language")));
      }
    }
  });
  //get controller
  main_input=new Input(this,(PSurfaceJOGL)surface);
  main_game=new GameProcess();
  exec.execute(()->{
    soundManager.loadSound();
  });
  exec.execute(()->{
    backgrounds.put("default",new DefaultBackgroundShader().load());
    backgrounds.put("pixel",new PixelBackgroundShader().load());
  });
}

public void draw(){
  if(frameCount==2){
    noLoop();
    ((GLWindow)surface.getNative()).setFullscreen(fullscreen);
    if(!fullscreen){
      surface.setLocation(displayWidth/2-640,displayHeight/2-360);
    }
    loop();
  }
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
  Shader();
  if(displayFPS)printFPS();
  updatePreValue();
  main_input.update();
  updateFPS();
}

public void LoadData(){
  conf=loadJSONObject(SavePath+"config.json");
  ErrorCorrect();
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
      masterTable.addTable(build(o,o.getString("type")),o.getFloat("weight"));
    }catch(ClassNotFoundException|NoSuchMethodException g){g.printStackTrace();}
  }
  Arrays.asList(conf.getJSONArray("Weapons").toStringArray()).forEach(s->{playerTable.addTable(masterTable.get(s),masterTable.get(s).getWeight());});
  stageList.clearContent();
  stageList.addContent(conf.getJSONArray("Stage").toStringArray());
  displayFPS=conf.getBoolean("FPS");
  fullscreen=conf.getBoolean("Fullscreen");
  ShaderQuality=conf.getInt("ShaderQuality");
  fragmentCount=conf.getInt("Fragment");
  vsync=conf.getBoolean("vsync");
  if(vsync){
    FrameRateConfig=RefleshRate;
    frameRate(FrameRateConfig);
  }else{
    frameRate(60);
  }
  ArchiveEntity=new ArrayList<>(Arrays.asList(conf.getJSONArray("Enemy").toStringArray()));
}

public void ErrorCorrect(){
  JSONObject conf_base=loadJSONObject(SavePath+"config_base.json");
  CorrectJSON(conf_base,conf);
}

public void CorrectJSON(JSONObject src,JSONObject target){
  src.keys().forEach(k->{
    if(!target.hasKey((String)k)){
      target.put((String)k,src.get((String)k));
    }else if(src.get((String)k) instanceof JSONObject){
      CorrectJSON(src.getJSONObject((String)k),target.getJSONObject((String)k));
    }
  });
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

void applyStatus(){
  StatusList.forEach((k1,v1)->{
    AddtionalStatus.put(k1,k1.equals("projectile")?0f:1f);
    v1.forEach((k2,v2)->{
      AddtionalStatus.replace(k1,AddtionalStatus.get(k1)+v2);
    });
  });
  player.attackWeapons.forEach(w->{
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
    absoluteMagnification=1;
    initMenu();
  }
  switch(starts.nowLayer){
    case "root":background(0);break;
    default:background(230);break;
  }
  menu_animation.update();
  menu_animation.display();
  starts.display();
  if(!starts.nowLayer.equals("root"))menu_op_canvas.display();
  starts.update();
  if(colorInverse&&!starts.nowLayer.equals("root")){
    colorInv.set("tex",g);
    colorInv.set("resolution",width,height);
    try{
      filter(colorInv);
    }catch(Exception e){
      e.printStackTrace();
    }
  }
}

 public void Load(){
  background(0);
  scene=2;
}

String resultText;

public void Result(){
  if(changeScene){
    resetMatrix();
    resultAnimation=true;
    resultTime=0;
    resultText=Language.getString("ui_kill")+": "+killCount+"\n"+
               Language.getString("ui_frag")+": "+player.fragment+"\n"+
               "Time: "+nf(floor(stage.time/3600),floor(stage.time/360000)>=1?0:2,0)+":"+nf(floor((stage.time/60)%60),2,0)+"\n"+
               "Score: "+(player.score_kill.get()+player.score_tech.get());
    MenuButton resultButton=new MenuButton("OK");
    resultButton.setBounds(width*0.5f-60,height*0.7f,120,25);
    resultButton.addWindowResizeEvent(()->{
      resultButton.setBounds(width*0.5f-60,height*0.7f,120,25);
    });
    resultButton.addListener(()->{
      scene=0;
      exec.execute(()->{
        stageList.clearExplanation();
        JSONObject ex=loadJSONObject(StageConfPath+"Stage_ex.json");
        JSONArray Stages=conf.getJSONArray("Stage");
        for(int i=0;i<Stages.size();i++){
          if(conf.getJSONObject("Record").hasKey(Stages.getString(i))){
            JSONObject o=conf.getJSONObject("Record").getJSONObject(Stages.getString(i));
            float time=o.getInt("time");
            stageList.addExplanation(Stages.getString(i),ex.getJSONObject(Stages.getString(i)).getString(conf.getString("Language"))+
              "\n\nRecord\n  Time: "+nf(floor(time/60),floor(time/6000)>=1?0:2,0)+":"+nf(floor(time%60),2,0)+
              "\n  Score: "+o.getInt("score"));
          }else{
            stageList.addExplanation(Stages.getString(i),ex.getJSONObject(Stages.getString(i)).getString(conf.getString("Language")));
          }
        }
      });
    });
    resultButton.requestFocus();
    resultSet=toSet(resultButton);
    fragmentCount+=player.fragment;
    if(!StageFlag.contains("Game_Over")){
      JSONObject rec=conf.getJSONObject("Record");
      if(rec.hasKey(StageName)){
        JSONObject data=rec.getJSONObject(StageName);
        data.setInt("time",min(data.getInt("time"),floor(stage.time/60f)));
        data.setInt("score",max(player.score_kill.get()+player.score_tech.get(),data.getInt("score")));
      }else{
        JSONObject data=new JSONObject();
        data.setInt("time",floor(stage.time/60f));
        data.setInt("score",player.score_kill.get()+player.score_tech.get());
        rec.setJSONObject(StageName,data);
      }
    }
    saveConfig save=new saveConfig();
    exec.submit(save);
  }
  background(230);
  if(resultAnimation){
    float normUItime=resultTime/30;
    background(320*normUItime);
    blendMode(BLEND);
    float Width=width/main_game.x;
    float Height=height/main_game.y;
    for(int i=0;i<main_game.y;i++){
      for(int j=0;j<main_game.x;j++){
        fill(230);
        noStroke();
        rectMode(CENTER);
        float scale=min(max(resultTime*(main_game.y/9)-(j+i),0),1);
        rect(Width*j+Width/2,Height*i+Height/2,Width*scale,Height*scale);
      }
    }
    resultTime+=vectorMagnification;
    if(resultTime>30)resultAnimation=false;
  }
  textAlign(CENTER);
  fill(0);
  textSize(50);
  textFont(font_50);
  text(StageFlag.contains("Game_Over")?"Game over":"Stage clear",width*0.5f,height*0.2f);
  textAlign(LEFT);
  textSize(20);
  textFont(font_20);
  text(resultText,width*0.5-150,height*0.2+100);
  resultSet.display();
  resultSet.update();
  if(resultAnimation){
    menuShader.set("time",resultTime);
    menuShader.set("xy",(float)main_game.x,(float)main_game.y);
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
    stage.name=StageName;
    main_game.init();
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
            String option=param.getString("option","");
            if(option.equals("")){
              s.addSpown(param.getInt("number"),param.getFloat("dist"),param.getFloat("offset"),
              (Enemy)Class.forName("Simple_shooting_2_1$"+param.getString("name")).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet));
            }else if(option.equals("center")){
              s.addSpown_Center(param.getInt("number"),param.getFloat("dist"),param.getFloat("offset"),
              (Enemy)Class.forName("Simple_shooting_2_1$"+param.getString("name")).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet));
            }
          }catch(ClassNotFoundException|NoSuchMethodException|InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
        }));
      }else if(config.getString("type").equals("setting")){
        JSONArray walls=config.getJSONArray("wall");
        for(int j=0;j<walls.size();j++){
          JSONArray wall=walls.getJSONArray(j);
          main_game.addWall(wall.getFloat(0),wall.getFloat(1),wall.getFloat(2),wall.getFloat(3));
        }
      }
    }
    stage.addProcess(StageName,new TimeSchedule(Float.MAX_VALUE,s->{s.endSchedule=true;}));
  }
  main_game.process();
}

 public void eventProcess() {
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
  if(!keyPressed){
    PressedKey.clear();
    PressedKeyCode.clear();
    keyPressTime=0;
  }
}

 public void updateFPS() {
  Times.add(System.currentTimeMillis()-pTime);
  while (Times.size()>60) {
    Times.remove(0);
  }
  pTime=System.currentTimeMillis();
  vectorMagnification=60f/(1000f/Times.get(Times.size()-1));
}

@Override
public void exit(){
  Future f=exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
  try {
    f.get();
  }
  catch(ConcurrentModificationException e) {
    e.printStackTrace();
  }
  catch(InterruptedException|ExecutionException F) {
    F.printStackTrace();
  }
  catch(NullPointerException g) {
  }
  finally{
    exec.shutdown();
    super.exit();
  }
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
  if(FXAA){
    FXAAShader.set("resolution",width,height);
    FXAAShader.set("input_texture",g);
    if(scene==2){
      applyShader(FXAAShader);
    }else{
      filter(FXAAShader);
    }
  }
  Oscillo.set("resolution",width,height);
  Oscillo.set("time",second()+millis()*0.001);
  Oscillo.set("input_texture",g);
  if(frameCount>10)
  switch(oscilloState){
    case 1:
      Oscillo.set("resolution",width,height);
      Oscillo.set("time",second()+millis()*0.001);
      Oscillo.set("input_texture",g);
      filter(Oscillo);
      break;
    case 2:
      Oscillo_Otsu.set("resolution",width,height);
      Oscillo_Otsu.set("time",second()+millis()*0.001);
      Oscillo_Otsu.set("input_texture",g);
      filter(Oscillo_Otsu);
      break;
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
  return f>0?1:f<0?-1:0;
}

 public void line(PVector s,PVector v){
  line(s.x,s.y,s.x+v.x,s.y+v.y);
}

public void vertex(PGraphics g,PVector p){
  g.vertex(p.x,p.y);
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

 public float atan2(PVector from,PVector to){
  return atan2(to.y-from.y,to.x-from.x);
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
      float rad=atan2(c,s);
      return s.copy().add(new PVector(0,1).rotate(rad).mult(size*0.5f));
    }else if(lenAX>dist(0,0,v.x,v.y)){
      if(dist(s.x+v.x,s.y+v.y,c.x,c.y)>=size*0.5f)return c;
      float rad=atan2(c,new PVector(s.x+v.x,s.y+v.y));
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
  
  float theta = atan2(a,b);
  
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

public float grayScale(int c){
  return ((c>>16)&0xFF)*0.298912f+((c>>8)&0xFF)*0.586611f+(c&0xFF)*0.114478;
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

public int getMax(Color c){
  return max(c.getRed(),c.getGreen(),c.getBlue());
}

public float mix(float x,float y,float a){
  return x*(1-a)+y*a;
}

public Color mixColor(Color x,Color y,float a){
  return new Color((int)mix(x.getRed(),y.getRed(),a),(int)mix(x.getGreen(),y.getGreen(),a),(int)mix(x.getBlue(),y.getBlue(),a),(int)mix(x.getAlpha(),y.getAlpha(),a));
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

 public void keyPressed(processing.event.KeyEvent e){
  keyPressTime=0;
  keyPress=true;
  ModifierKey=e.getKeyCode();
  PressedKey.add(str(e.getKey()).toLowerCase());
  PressedKeyCode.add(str(e.getKeyCode()));
  nowPressedKey=str(e.getKey());
  nowPressedKeyCode=e.getKeyCode();
  if(keyCode==101)oscilloState=(oscilloState+1)%3;
  if(key==ESC)key=255;
}

 public void keyReleased(processing.event.KeyEvent e){
  keyPressTime=0;
  keyRelease=true;
  ModifierKey=-1;
  PressedKeyCode.remove(str(e.getKeyCode()));
  PressedKey.remove(str(e.getKey()).toLowerCase());
}

 public void mouseWheel(processing.event.MouseEvent e){
  mouseWheel=true;
  mouseWheelCount+=e.getCount();
}

abstract class Entity implements Cloneable{
  protected Controller control=new VoidController();
  protected DeadEvent dead=(e)->{};
  protected float size=20;
  protected PVector pos=new PVector(0,0);
  protected PVector vel=new PVector(0,0);
  protected PVector Center=new PVector();
  protected PVector AxisSize=new PVector();
  protected Color c=new Color(0,255,0);
  protected float rotate=0;
  protected float accelSpeed=0.25f;
  protected float maxSpeed=7.5f;
  protected float Speed=0;
  protected float Mass=10;
  protected float e=0.5f;
  public int threadNum=0;
  protected boolean mark=false;
  protected boolean displayAABB=true;
  protected boolean isDead=false;
  protected boolean pDead=false;
  protected boolean inScreen=true;

  Entity() {
  }
  
  void setController(Controller c){
    control=c;
  }
  
  Controller getController(){
    return control;
  }
  
  public final void handleDisplay(PGraphics g){
    if(!inScreen||isDead)return;
    if(Debug&&displayAABB){
      displayAABB(g);
    }
    display(g);
  }

  protected abstract void display(PGraphics g);
  
  public final void handleUpdate(){
    getController().update(this);
    if(isDead&&!pDead){
      dead.deadEvent(this);
      pDead=isDead;
    }
    update();
  }

  protected abstract void update();

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
  
  public void setSize(float s){
    size=s;
  }
  
  public void destruct(Entity e){
    isDead=true;
  }

  public Entity clone()throws CloneNotSupportedException {
    Entity clone=(Entity)super.clone();
    clone.pos=pos.copy();
    clone.vel=vel.copy();
    clone.c=cloneColor(c);
    return clone;
  }
  
  public void addDeadListener(DeadEvent e){
    dead=e;
  }
  
  protected void putAABB(){
    inScreen=-scroll.x<Center.x+AxisSize.x/2&&Center.x-AxisSize.x/2<-scroll.x+width&&-scroll.y<Center.y+AxisSize.y/2&&Center.y-AxisSize.y/2<-scroll.y+height;
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
    if(mark){
      g.stroke(255,0,0,200);
      mark=false;
    }else{
      g.stroke(255,200);
    }
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

interface DeadEvent{
  public void deadEvent(Entity e);
}
