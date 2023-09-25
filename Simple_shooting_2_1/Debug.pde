import com.jogamp.newt.event.awt.AWTKeyAdapter;

import com.parser.command.*;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

LinkedHashMap<DebugText,Float>DebugWarning=new LinkedHashMap<>();
ArrayList<Float>updateStatistics=new ArrayList<>();
ArrayList<Float>collisionStatistics=new ArrayList<>();
ArrayList<Float>drawStatistics=new ArrayList<>();
ArrayList<Float>runStatistics=new ArrayList<>();
CommandField commandInput;
boolean Debug=false;
boolean Command=false;
long RunTimeBuffer=0;
float pProcessTime=0f;
float EntityTime=0;
float CollisionTime=0;
float DrawTime=0;
float RunTime=0f;
float statisticsCooltime=0f;
int statisticsFrame=0;

void Debug(){
  if(keyPress&&(nowPressedKeyCode==99||PressedKeyCode.contains("99"))){
    Debug=!Debug;
  }
  if(keyPress&&(nowPressedKeyCode==98||PressedKeyCode.contains("98"))){
    Command=!Command;
    if(Command){
      ((SurvivorHUD)main_game.mainHUD).getComponent().focussable=false;
    }else{
      ((SurvivorHUD)main_game.mainHUD).getComponent().focussable=true;
    }
    player.vel=new PVector(0,0);
  }
  if(Command){
    if(commandInput==null){
      commandInput=new CommandField();
      commandInput.setBounds(0,height-30,width,30);
      commandInput.addWindowResizeEvent(()->{
        commandInput.setBounds(0,height-30,width,30);
      });
    }
    commandInput.display();
    commandInput.update();
    LinkedHashMap<DebugText,Float>NextWarning=new LinkedHashMap<>();
    int[]count={0};
    DebugWarning.forEach((k,v)->{
      fill(k.isWarning()?#FF0000:#FFFFFF);
      textSize(20);
      textAlign(LEFT);
      text(k.getText(),10,height-(50+25*(DebugWarning.size()-1-count[0])));
      if(v<300)NextWarning.put(k,v+vectorMagnification);
      count[0]++;
    });
    DebugWarning=NextWarning;
  }
  RunTime=(System.nanoTime()-RunTimeBuffer)/1000000f;
  RunTimeBuffer=System.nanoTime();
  if(Debug){
    String Text="";
    fill(255);
    textFont(font_15);
    textSize(15);
    textAlign(LEFT);
    pushMatrix();
    resetMatrix();
    for(int i=0;i<5;i++){
      switch(i){
        case 0:fill(0,128,255,200);Text="EntityTime(ms):"+EntityTime;break;
        case 1:fill(0,255,0,200);Text="EntityCollision(ms):"+CollisionTime;break;
        case 2:fill(255,255,0,200);Text="EntityDraw(ms):"+DrawTime;break;
        case 3:fill(255,128,0,200);Text="RunTime(ms):"+RunTime;break;
        case 4:fill(255,200);Text="EntityNumber:"+Entities.size();break;
        case 5:fill(255,200);Text="Memory(MB)"+nf(((float)(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()))/1048576f,0,3);break;
      }
      text(Text,30,100+i*20);
    }
    addStatistics();
    strokeWeight(1);
    stroke(255,200);
    line(30,320,207,320);
    float pUpdate=updateStatistics.get(0);
    float pCollision=collisionStatistics.get(0);
    float pDraw=drawStatistics.get(0);
    float pRun=runStatistics.get(0);
    for(int i=1;i<60;i++){
      stroke(0,128,255,200);
      line(30+(i-1)*3,320-min(100,pUpdate),30+i*3,320-min(100,updateStatistics.get(i)));
      stroke(0,255,0,200);
      line(30+(i-1)*3,320-min(100,pCollision),30+i*3,320-min(100,collisionStatistics.get(i)));
      stroke(255,255,0,200);
      line(30+(i-1)*3,320-min(100,pDraw),30+i*3,320-min(100,drawStatistics.get(i)));
      stroke(255,128,0,200);
      line(30+(i-1)*3,320-min(100,pRun),30+i*3,320-min(100,runStatistics.get(i)));
      pUpdate=updateStatistics.get(i);
      pCollision=collisionStatistics.get(i);
      pDraw=drawStatistics.get(i);
      pRun=runStatistics.get(i);
    }
    popMatrix();
  }
}

void addStatistics(){
  if(statisticsCooltime==0){
    updateStatistics.add(0f);
    collisionStatistics.add(0f);
    drawStatistics.add(0f);
    runStatistics.add(0f);
  }
  statisticsCooltime+=RunTime;
  ++statisticsFrame;
  if(statisticsCooltime>=1000f){
    updateStatistics.set(60,(updateStatistics.get(60)+EntityTime)/statisticsFrame);
    updateStatistics.remove(0);
    collisionStatistics.set(60,(collisionStatistics.get(60)+CollisionTime)/statisticsFrame);
    collisionStatistics.remove(0);
    drawStatistics.set(60,(drawStatistics.get(60)+DrawTime)/statisticsFrame);
    drawStatistics.remove(0);
    runStatistics.set(60,(runStatistics.get(60)+RunTime)/statisticsFrame);
    runStatistics.remove(0);
    statisticsFrame=0;
    statisticsCooltime=0;
  }else{
    updateStatistics.set(60,updateStatistics.get(60)+EntityTime);
    collisionStatistics.set(60,collisionStatistics.get(60)+CollisionTime);
    drawStatistics.set(60,drawStatistics.get(60)+DrawTime);
    runStatistics.set(60,runStatistics.get(60)+RunTime);
  }
}

class CommandField extends LineTextField{
  ArrayList<String>EnteredCommand=new ArrayList<String>();
  String nowInput="";
  float textHeight;
  int memoryOffset=0;
  
  CommandField(){
    super();
    e=(t)->{
      memoryOffset=0;
      EnteredCommand.add(text.toString());
      CharStream cs=CharStreams.fromString(text.toString());
      command_lexer lexer=new command_lexer(cs);
      CommonTokenStream tokens=new CommonTokenStream(lexer);
      command_parser parser=new command_parser(tokens);
      parser.removeErrorListeners();
      parser.addErrorListener(ThrowingErrorListener.INSTANCE.setWarningMap(DebugWarning));
      parser.command();
      text=new StringBuilder();
      index=0;
      if(parser.getNumberOfSyntaxErrors()>0)return;
      main_game.commandProcess(tokens.getTokens());
    };
  }
  
  public void display(){
    push();
    if(font==null)font=createFont("SansSerif.plain",dist.y*0.8);
    textHeight=pos.y+dist.y*0.75;
    rectMode(CORNER);
    noStroke();
    fill(0,150);
    rect(pos.x,pos.y,dist.x,dist.y);
    fill(255);
    textAlign(CENTER);
    textSize(dist.y*0.8);
    textFont(font);
    text(">",pos.x+2+textWidth(">")*0.5,textHeight);
    drawText(pos.x+2+textWidth("> "));
    stroke(255);
    strokeWeight(2);
    if(focus&&time<0.5)line(pos.x+2+textWidth("> ")+offset,pos.y+1,pos.x+2+textWidth("> ")+offset,pos.y+dist.y-1);
    time+=vectorMagnification/60;
    time=time>1?time-1:time;
    pop();
  }
  
  public void update(){
    if(main_input.getMouse().mousePress())mousePress();
    keyProcess();
    if(keyPress&&!nowPressedKey.equals(str((char)-1)))memoryOffset=0;
    super.update();
  }
  
  public void drawText(float offset){
    text(text.toString(),offset+textWidth(text.toString())*0.5,textHeight);
  }
  
  @Override
  public void upProcess(){
    if(memoryOffset<EnteredCommand.size()){
      if(memoryOffset==0)nowInput=text.toString();
      ++memoryOffset;
      text=new StringBuilder(EnteredCommand.get(EnteredCommand.size()-memoryOffset));
      index=text.length();
    }
  }
  
  @Override
  public void downProcess(){
    if(memoryOffset>0){
      --memoryOffset;
      text=memoryOffset==0?new StringBuilder(nowInput):new StringBuilder(EnteredCommand.get(EnteredCommand.size()-memoryOffset));
      index=text.length();
    }
  }
}

void addDebugText(String s,boolean b){
  if(!DebugWarning.containsKey(s))DebugWarning.put(new DebugText(s,b),0f);
}

void addWarning(String s){
  if(!DebugWarning.containsKey(s))DebugWarning.put(new DebugText(s,true),0f);
}
