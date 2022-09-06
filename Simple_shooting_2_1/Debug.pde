import com.jogamp.newt.event.awt.AWTKeyAdapter;

import com.parser.command.*;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

LinkedHashMap<String,Float>DebugWarning=new LinkedHashMap<String,Float>();
CommandField commandInput;
boolean Debug=false;
boolean Command=false;
long RunTimeBuffer=0;
float EntityTime=0;
float DrawTime=0;

void Debug(){
  if(keyPress&&(nowPressedKeyCode==99||PressedKeyCode.contains("99"))){
    Debug=!Debug;
  }
  if(keyPress&&(nowPressedKeyCode==98||PressedKeyCode.contains("98"))){
    Command=!Command;
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
    LinkedHashMap<String,Float>NextWarning=new LinkedHashMap<String,Float>();
    int[]count={0};
    DebugWarning.forEach((k,v)->{
      fill(255,0,0);
      textSize(20);
      textAlign(LEFT);
      text(k,10,height-(50+25*(DebugWarning.size()-1-count[0])));
      if(v<300)NextWarning.put(k,v+vectorMagnification);
      count[0]++;
    });
    DebugWarning=NextWarning;
  }
  if(Debug){
    String Text="";
    fill(255);
    textFont(main.font_15);
    textSize(15);
    textAlign(LEFT);
    pushMatrix();
    resetMatrix();
    for(int i=0;i<5;i++){
      switch(i){
        case 0:Text="RunTime(ms):"+(System.nanoTime()-RunTimeBuffer)/1000000f;break;
        case 1:Text="EntityDraw(ms):"+DrawTime;break;
        case 2:Text="EntityTime(ms):"+EntityTime;break;
        case 3:Text="EntityNumber:"+Entities.size();break;
        case 4:Text="Memory(MB)"+nf(((float)(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()))/1048576f,0,3);break;
      }
      text(Text,30,100+i*20);
    }
    RunTimeBuffer=System.nanoTime();
    popMatrix();
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
      main.commandProcess(tokens.getTokens());
    };
  }
  
  void display(){
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
  
  void update(){
    if(mousePress)mousePress();
    keyProcess();
    if(keyPress&&!nowPressedKey.equals(str((char)-1)))memoryOffset=0;
    super.update();
  }
  
  void drawText(float offset){
    text(text.toString(),offset+textWidth(text.toString())*0.5,textHeight);
  }
  
  @Override
  void upProcess(){
    if(memoryOffset<EnteredCommand.size()){
      if(memoryOffset==0)nowInput=text.toString();
      ++memoryOffset;
      text=new StringBuilder(EnteredCommand.get(EnteredCommand.size()-memoryOffset));
      index=text.length();
    }
  }
  
  @Override
  void downProcess(){
    if(memoryOffset>0){
      --memoryOffset;
      text=memoryOffset==0?new StringBuilder(nowInput):new StringBuilder(EnteredCommand.get(EnteredCommand.size()-memoryOffset));
      index=text.length();
    }
  }
}

void addWarning(String s){
  if(!DebugWarning.containsKey(s))DebugWarning.put(s,0f);
}
