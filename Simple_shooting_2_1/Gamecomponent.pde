import java.awt.datatransfer.*;

Color menuRightColor=new Color(0,150,255);

abstract class GameComponent{
  protected FocusEvent Fe=new FocusEvent(){void getFocus(){} void lostFocus(){}};
  protected ResizeEvent re=(p,d)->{};
  protected WindowResizeEvent wre=()->{};
  protected PFont font;
  protected PVector pos;
  protected PVector dist;
  protected PVector center;
  protected boolean active=true;
  protected boolean focus=false;
  protected boolean pFocus=false;
  protected boolean canFocus=true;
  protected boolean focussable=true;
  protected boolean FocusEvent=false;
  protected boolean keyMove=false;
  protected boolean onMouse=false;
  protected Color background=new Color(200,200,200);
  protected Color selectbackground=new Color(255,255,255);
  protected Color foreground=new Color(0,0,0);
  protected Color selectforeground=new Color(0,0,0);
  protected Color border=new Color(0,0,0);
  protected Color nonSelectBorder=border;
  protected int resizeNumber=0;
  
  GameComponent(){
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    center=new PVector(x+dx/2,y+dy/2);
    re.resized(pos,dist);
    return this;
  }
  
  public void setBackground(Color c){
    background=c;
  }
  
  public void setSelectBackground(Color c){
    selectbackground=c;
  }
  
  public void setForeground(Color c){
    foreground=c;
  }
  
  public void setSelectForeground(Color c){
    selectforeground=c;
  }
  
  public void setBorderColor(Color c){
    border=c;
  }
  
  public void setNonSelectBorderColor(Color c){
    border=new Color(c.getRed(),c.getGreen(),c.getBlue());
  }
  
  public final void handleDisplay(){
    if(active)display();
  }
  
  public abstract void display();
  
  public final void handleUpdate(){
    if(active)update();
  }
  
  public void update(){
    pFocus=focus;
    if(windowResized||resizeNumber!=resizedNumber){
      wre.Event();
      resizeNumber=resizedNumber;
    }
  }
  
  public void executeEvent(){
    
  }
  
  public void requestFocus(){
    focus=true;
  }
  
  public void removeFocus(){
    focus=false;
  }
  
  public void addFocusListener(FocusEvent e){
    Fe=e;
  }
  
  public void addWindowResizeEvent(WindowResizeEvent e){
    wre=e;
  }
}

class Canvas extends GameComponent{
  protected CanvasContent content=(g)->{};
  protected PGraphics pg;
  
  {
    focussable=false;
    setBounds(0,0,0,0);
  }
  
  Canvas(PGraphics pg){
    this.pg=pg;
  }
  
  public void setContent(CanvasContent c){
    content=c;
  }
  
  @Override
  public void display(){
    content.display(pg);
  }
}

class HUDText extends GameComponent{
  disposeEvent de=()->{};
  Process p=()->{};
  Entity target;
  boolean flag=true;
  float offset=20;
  float mainWidth=0;
  String text="";
  String type="";
  float easeTime=0;
  
  {
    focussable=false;
    font=createFont("SansSerif.plain",15);
  }
  
  HUDText(String text){
    this.text=text;
    textFont(font);
    mainWidth=textWidth(text);
  }
  
  public void setTarget(Entity e){
    target=e;
    pos=new PVector(0,0);
  }
  
  public void display(){
    if(easeTime==0)return;
    float w=((Sigmoid(easeTime/7)-0.5)/0.5f)*(offset+mainWidth);
    pushMatrix();
    resetMatrix();
    translate(0,-ceil(offset+17));
    strokeWeight(1);
    noFill();
    stroke(255);
    beginShape(w>offset?POLYGON:LINES);
    vertex(target==null?pos.x:target.pos.x+scroll.x,(target==null?pos.y:target.pos.y+scroll.y)+offset+17);
    vertex((target==null?pos.x:target.pos.x+scroll.x)+min(w,offset),(target==null?pos.y:target.pos.y+scroll.y)+max(0,offset-w)+17);
    if(w>offset)vertex((target==null?pos.x:target.pos.x+scroll.x)+min(w,offset+mainWidth),(target==null?pos.y:target.pos.y+scroll.y)+17);
    endShape();
    if(easeTime<45){
      popMatrix();
      return;
    }
    fill(255);
    textFont(font);
    textAlign(LEFT);
    textSize(15);
    text(text,(target==null?pos.x:target.pos.x+scroll.x)+offset,(target==null?pos.y:target.pos.y+scroll.y)+15);
    popMatrix();
  }
  
  public void update(){
    if(type.equals("start")){
      easeTime+=vectorMagnification;
      if(easeTime>=45){
        easeTime=45;
        type="";
      }
    }else if(type.equals("end")){
      easeTime-=vectorMagnification;
      if(easeTime<=0){
        de.event();
        easeTime=0;
        type="";
      }
    }else if(easeTime>=45){
      if(flag)p.execute();
    }
    super.update();
  }
  
  public void Dispose(){
    type="";
    easeTime=0;
    de.event();
  }
  
  public void startDisplay(){
    type="start";
  }
  
  public void endDisplay(){
    type="end";
  }
  
  public void setFlag(boolean f){
    flag=f;
  }
  
  public void addDisposeListener(disposeEvent de){
    this.de=de;
  }
  
  public void setProcess(Process p){
    this.p=p;
  }
}

class LineTextField extends GameComponent{
  protected EnterEvent e=(l)->{};
  protected float textOffset=0;
  protected float offset=0;
  protected float time=0;
  protected int pIndex=0;
  protected int index=0;
  StringBuilder text;
  PFont font;
  
  LineTextField(){
    text=new StringBuilder();
  }
  
  public void display(){
    
  }
  
  public void mousePress(){
    onMouse=canFocus&&mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y;
    if(onMouse){
      requestFocus();
    }else{
      removeFocus();
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    super.update();
  }
  
  public void keyProcess(){
    pushStyle();
    textFont(font);
    if(focus&&(keyPress||(keyPressTime>0.5&&(keyPressTime-floor(keyPressTime))%0.1<0.05))){
      pIndex=index;
      if(nowPressedKeyCode==BACKSPACE&&index!=0){
        text.delete(index-1,index);
        index--;
      }else
      if(nowPressedKeyCode==147){
        text.delete(index,index+1);
      }else
      if(nowPressedKeyCode==LEFT){
        index=max(0,--index);
      }else
      if(nowPressedKeyCode==RIGHT){
        index=min(++index,text.length());
      }else
      if(nowPressedKeyCode==UP){
        upProcess();
      }else
      if(nowPressedKeyCode==DOWN){
        downProcess();
      }else
      if(nowPressedKeyCode==ENTER){
        EnterEvent();
      }else if(PressedKeyCode.size()==2&&PressedKeyCode.contains("17")&&PressedKeyCode.contains("86")){
        try{
          text=new StringBuilder((String)Toolkit.getDefaultToolkit().getSystemClipboard().getData(DataFlavor.stringFlavor));
          index=text.length();
        }catch(UnsupportedFlavorException|IOException e){
        }
      }else{
        if(nowPressedKeyCode==8||nowPressedKey.equals(str((char)-1)))if(nowPressedKeyCode!=0)return;
        if(index==text.length()){
          text.append(nowPressedKeyCode==0?(PressedKeyCode.contains("16")?'_':"\\"):nowPressedKey);
        }else{
          text.insert(index,nowPressedKeyCode==0?(PressedKeyCode.contains("16")?'_':"\\"):nowPressedKey);
        }
        ++index;
      }
      setOffset();
    }
    if(keyPressed)time=0;
    popStyle();
  }
  
  public void upProcess(){
    
  }
  
  public void downProcess(){
    
  }
  
  public void clearText(){
    index=0;
    text.setLength(0);
  }
  
  protected void setOffset(){
    offset=textWidth(text.substring(0,index));
  }
  
  public void EnterEvent(){
    e.Event(this);
  }
  
  public void addEnterListener(EnterEvent e){
    this.e=e;
  }
}

abstract class ButtonItem extends GameComponent{
  protected SelectEvent e=()->{};
  protected boolean pCursor=false;
  protected boolean setCursor=false;
  protected String text="";
  
  {
    re=(p,d)->{
      font=createFont("SansSerif.plain",d.y*0.5);
    };
  }
  
  ButtonItem(){
    
  }
  
  ButtonItem(String s){
    text=s;
  }
  
  public void addListener(SelectEvent e){
    this.e=e;
  }
  
  public void mouseProcess(){
    onMouse=canFocus&&mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y;
    if(onMouse){
      setCursor=true;
      requestFocus();
    }else{
      setCursor=false;
    }
    if(mousePress&onMouse){
      executeEvent();
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pCursor=setCursor;
    super.update();
  }
  
  public void executeEvent(){
    e.selectEvent();
  }
}

abstract class CheckBox extends GameComponent{
  protected SelectEvent e=()->{};
  boolean value=false;
  protected boolean pCursor=false;
  protected boolean setCursor=false;
  protected String text="";
  
  {
    re=(p,d)->{
      font=createFont("SansSerif.plain",d.y*0.5);
    };
  }
  
  CheckBox(boolean value){
    this.value=value;
  }
  
  public void addListener(SelectEvent e){
    this.e=e;
  }
  
  public void update(){
    mouseProcess();
    keyProcess();
  }
  
  public void mouseProcess(){
    onMouse=canFocus&&mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y;
    if(onMouse){
      setCursor=true;
      requestFocus();
    }else{
      setCursor=false;
    }
    if(mousePress&onMouse){
      value=!value;
      executeEvent();
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pCursor=setCursor;
    super.update();
  }
  
  public void keyProcess(){
    if(focus&&getInputState("enter")){
      value=!value;
    }
  }
  
  public void executeEvent(){
    e.selectEvent();
  }
}

abstract class ToggleBox extends GameComponent{
  protected SelectEvent e=()->{};
  protected HashMap<Integer,String>textMap=new HashMap<>();
  int value=0;
  int num=0;
  protected boolean pCursor=false;
  protected boolean setCursor=false;
  protected String text="";
  
  {
    re=(p,d)->{
      font=createFont("SansSerif.plain",d.y*0.5);
    };
  }
  
  ToggleBox(int value,int num){
    this.value=value;
    this.num=num;
  }
  
  public void addListener(SelectEvent e){
    this.e=e;
  }
  
  public void update(){
    mouseProcess();
    keyProcess();
  }
  
  public void mouseProcess(){
    onMouse=canFocus&&mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y;
    if(onMouse){
      setCursor=true;
      requestFocus();
    }else{
      setCursor=false;
    }
    if(mousePress&onMouse){
      ++value;
      value%=num;
      executeEvent();
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pCursor=setCursor;
    super.update();
  }
  
  public void keyProcess(){
    if(focus&&getInputState("enter")){
      ++value;
      value%=num;
    }
  }
  
  public void executeEvent(){
    e.selectEvent();
  }
}

class SliderItem extends GameComponent{
  protected ChangeEvent e=()->{};
  protected boolean smooth=true;
  protected boolean move=false;
  protected float Xdist=0;
  protected int Value=1;
  protected int pValue=1;
  protected int elementNum=2;
  
  SliderItem(){
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  SliderItem(int element){
    elementNum=element;
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  public void setSmooth(boolean b){
    smooth=b;
  }
  
  public void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?color(background.getRed(),background.getGreen(),background.getBlue(),background.getAlpha()):
         color(selectbackground.getRed(),selectbackground.getGreen(),selectbackground.getBlue(),selectbackground.getAlpha()));
    stroke(0);
    line(pos.x,pos.y,pos.x+dist.x,pos.y);
    fill(!focus?color(foreground.getRed(),foreground.getGreen(),foreground.getBlue(),foreground.getAlpha()):
         color(selectforeground.getRed(),selectforeground.getGreen(),selectforeground.getBlue(),selectforeground.getAlpha()));
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CENTER);
    rect(pos.x+Xdist,pos.y,dist.y/3,dist.y,dist.y/12);
  }
  
  public void update(){
    mouseProcess();
    keyProcess();
    pValue=Value;
  }
  
  public void mouseProcess(){
    if(mousePress){
      if(pos.x+Xdist-dist.y/6<mouseX&mouseX<pos.x+Xdist+dist.y/6&
         pos.y-dist.y/2<mouseY&mouseY<pos.y+dist.y/2){
        move=true;
        requestFocus();
      }
    }else if(move&mousePressed){
      move=true;
    }else {
      move=false;
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    super.update();
    if(move){
      Xdist=constrain(mouseX,pos.x,pos.x+dist.x)-pos.x;
      Value=constrain(round(Xdist/(dist.x/elementNum))+1,1,elementNum);
    }
    if(!smooth){
      Xdist=(dist.x/elementNum)*Value;
    }
    if(Value!=pValue)executeEvent();
  }
  
  public void keyProcess(){
    switch(nowPressedKeyCode){
      case RIGHT:Value=constrain(Value+1,1,elementNum);break;
      case LEFT:Value=constrain(Value-1,1,elementNum);break;
    }
    Xdist=(dist.x/elementNum)*(Value-1);
  }
  
  public void addListener(ChangeEvent e){
    this.e=e;
  }
  
  public void executeEvent(){
    e.changeEvent();
  }
  
  int getValue(){
    return Value;
  }
  
  @Deprecated
  public void setValue(int v){
    Value=constrain(v,1,elementNum);
    Xdist=(dist.x/elementNum)*Value;
  }
}

abstract class TextBox extends GameComponent{
  boolean Parsed;
  String title="";
  String text="";
  float fontSize=15;
  
  {
    re=(p,d)->{
      font=createFont("SansSerif.plain",fontSize);
    };
  }
  
  TextBox(){
    Parsed=false;
  }
  
  TextBox(String t){
    Parsed=false;
    title=t;
  }
  
  public void setText(String t){
    Parsed=false;
    Parse(t);
  }
  
  private void Parse(String s){
    if(dist!=null){
      String t="";
      float l=0;
      for(char c:s.toCharArray()){
        l+=g.textFont.width(c)*fontSize;
        if((l>dist.x||c=='\n')&&c!=','&&c!='.'&&(int)c!=12289&&(int)c!=12290){
          l=0;
          t+=c=='\n'?"":"\n";
          t+=c;
        }else{
          t+=c;
        }
      }
      text=t;
      Parsed=true;
    }
  }
  
  public void update(){
    super.update();
    if(!Parsed)Parse(text);
  }
}

class MultiButton extends GameComponent{
  protected ArrayList<NormalButton>Buttons=new ArrayList<NormalButton>();
  protected boolean resize=true;
  protected int focusIndex=0;
  protected int pFocusIndex=0;
  
  MultiButton(NormalButton... b){
    Buttons=new ArrayList<NormalButton>(java.util.Arrays.asList(b));
    for(NormalButton B:Buttons){
      B.setNonSelectBorderColor(new Color(0,0,0));
      B.removeFocus();
    }
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  public void add(NormalButton b){
    Buttons.add(b);
  }
  
  public void display(){
    if(resize){
      for(int i=0;i<Buttons.size();i++){
        Buttons.get(i).setBounds(pos.x+i*(dist.x/Buttons.size()),pos.y,dist.x/Buttons.size(),dist.y);
      }
      resize=false;
    }
    reloadIndex();
    for(NormalButton b:Buttons){
      b.display();
    }
    blendMode(BLEND);
    strokeWeight(2);
    noFill();
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y,dist.y/4);
  }
  
  public void update(){
    mouseProcess();
    for(NormalButton b:Buttons){
      b.update();
    }
    pFocusIndex=focusIndex;
  }
  
  public void mouseProcess(){
    onMouse=canFocus&&mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y;
    if(onMouse){
      requestFocus();
      focusIndex=floor((mouseX-pos.x)/(dist.x/Buttons.size()));
      reloadIndex();
    }
    if(focus){
      if(keyPress)
        switch(nowPressedKeyCode){
          case RIGHT:focusIndex=constrain(focusIndex+1,0,Buttons.size()-1);reloadIndex();break;
          case LEFT:focusIndex=constrain(focusIndex-1,0,Buttons.size()-1);reloadIndex();break;
          case ENTER:Buttons.get(focusIndex).executeEvent();break;
        }
      if(!pFocus)FocusEvent=true;else FocusEvent=false;
    }
    super.update();
  }
  
  public void reloadIndex(){
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
    if(focus){
      Buttons.get(focusIndex).requestFocus();
    }
  }
  
  public void requestFocus(){
    super.requestFocus();
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
    Buttons.get(focusIndex).requestFocus();
  }
  
  public void removeFocus(){
    super.removeFocus();
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
  }
}

class ItemList extends GameComponent{
  PGraphics pg;
  ArrayList<String>Contents=new ArrayList<String>();
  HashMap<String,String>Explanation=new HashMap<String,String>();
  String selectedItem=null;
  KeyEvent e=(int k)->{};
  ItemSelect s=(String s)->{};
  PVector sPos;
  PVector sDist;
  boolean showSub=true;
  boolean moving=false;
  boolean pDrag=false;
  boolean drag=false;
  float Height=25;
  float scroll=0;
  float keyTime=0;
  int selectedNumber=0;
  int menuNumber=0;
  int alpha=255;
  
  {
    re=(p,d)->{
      font=createFont("SansSerif.plain",15);
    };
  }
  
  ItemList(){
    keyMove=true;
  }
  
  ItemList(String... s){
    Contents.addAll(Arrays.asList(s));
    changeEvent();
    keyMove=true;
  }
  
  public void setAlpha(int a){
    alpha=a;
    background=new Color(background.getRed(),background.getGreen(),background.getBlue(),a);
  }
  
  public void addContent(String... s){
    Contents.addAll(Arrays.asList(s));
    selectedNumber=0;
    changeEvent();
  }
  
  int getSize(){
    return Contents.size();
  }
  
  boolean contains(String s){
    return Contents.contains(s);
  }
  
  public void addExplanation(String s,String e){
    Explanation.put(s,e);
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pg=createGraphics(round(dx),round(dy),P2D);
    pg.beginDraw();
    pg.textFont(createFont("SansSerif.plain",15));
    pg.endDraw();
    return super.setBounds(x,y,dx,dy);
  }
  
  GameComponent setSubBounds(float x,float y,float dx,float dy){
    sPos=new PVector(x,y);
    sDist=new PVector(dx,dy);
    return this;
  }
  
  public void setSub(boolean b){
    showSub=b;
  }
  
  public void display(){
    blendMode(BLEND);
    int num=0;
    pg.beginDraw();
    pg.background(toColor(background));
    pg.textSize(15);
    pg.textFont(font);
    for(String s:Contents){
      if(floor(scroll/Height)<=num&num<=floor((scroll+dist.y)/Height)){
        if(selectedNumber==num){
          pg.fill(max(0,background.getRed()-30),max(0,background.getGreen()-30),max(0,background.getBlue()-30),alpha);
          pg.rect(0,num*Height-scroll,dist.x,Height);
          pg.stroke(toColor(menuRightColor));
          pg.line(0,num*Height-scroll,0,(num+1)*Height-scroll);
        }
        pg.fill(0,alpha);
        pg.noStroke();
        pg.text(s,10,num*Height+Height*0.7-scroll);
      }
      num++;
    }
    sideBar();
    pg.endDraw();
    image(pg,pos.x,pos.y);
    if(showSub&selectedItem!=null)subDraw();
  }
  
  public void sideBar(){
    if(dist.y<Height*Contents.size()){
      float len=Height*Contents.size();
      float mag=pg.height/len;
      pg.noStroke();
      pg.fill(255,alpha);
      pg.rect(pg.width-10,0,10,pg.height);
      pg.fill(drag?200:128,alpha);
      pg.rect(pg.width-10,pg.height*(1-mag)*scroll/(len-pg.height),10,pg.height*mag);
    }
  }
  
  public void subDraw(){
    pushStyle();
    blendMode(BLEND);
    rectMode(CORNER);
    fill(#707070,alpha);
    noStroke();
    rect(sPos.x,sPos.y,sDist.x,25);
    fill(toColor(background));
    rect(sPos.x,sPos.y+25,sDist.x,sDist.y-25);
    textSize(15);
    textAlign(CENTER);
    textFont(font);
    fill(0,alpha);
    text(Language.getString("ex"),sPos.x+5+textWidth(Language.getString("ex"))/2,sPos.y+17.5);
    textAlign(LEFT);
    text(Explanation.containsKey(selectedItem)&&Contents.size()>0?
         Explanation.get(selectedItem):"Error : no_data\nError number : 0x2DA62C9",sPos.x+5,sPos.y+45);
    popStyle();
  }
  
  public void update(){
    if(focus&&Contents.size()!=0){
      onMouse=canFocus&&onMouse(pos.x,pos.y,dist.x,min(Height*Contents.size(),dist.y));
      mouseProcess();
      if(mousePressed)moving=false;
      keyProcess();
    }
    pDrag=drag;
    super.update();
  }
  
  public void mouseProcess(){
    float len=Height*Contents.size();
    float mag=pg.height/len;
    if(dist.y<len&&onMouse(pos.x+pg.width-10,pos.y+pg.height*(1-mag)*scroll/(len-pg.height),10,pg.height*mag)&&mousePress){
        drag=true;
    }
    if(!mousePressed){
      drag=false;
    }
    if(pDrag&drag){
      scroll+=(mouseY-pmouseY)*(len-dist.y)/(dist.y*(1-mag));
      scroll=constrain(scroll,0,len-dist.y);
    }else if(dist.y<len&&mouseWheel&&onMouse(pos.x,pos.y,dist.x,dist.y)){
      scroll+=mouseWheelCount*16;
      scroll=constrain(scroll,0,len-dist.y);
    }
    if(mousePress&&onMouse(pos.x,pos.y,dist.x-(dist.y<len?10:0),max(len-scroll,0))){
      if(selectedNumber==floor((mouseY-pos.y+scroll)/Height)){
        Select();
      }else{
        selectedNumber=floor((mouseY-pos.y+scroll)/Height);
        changeEvent();
      }
    }
  }
  
  public void keyProcess(){
    if(isInput()){
      switch(getInputState()){
        case "up":subSelect();break;
        case "down":addSelect();break;
      }
      scroll();
    }
    if(getInputState("enter")||getInputState("right"))Select();
    if(!moving&&(getInputState().equals("up")||getInputState().equals("down"))){
      keyTime+=vectorMagnification;
    }
    if(!moving&keyTime>=30){
      moving=true;
      keyTime=0;
    }
    if(moving){
      keyTime+=vectorMagnification;
    }
    if(moving&&keyTime>=5){
      switch(getInputState()){
        case "up":subSelect();break;
        case "down":addSelect();break;
      }
      keyTime=0;
      scroll();
    }
    if(!(getInputState().equals("up")||getInputState().equals("down"))){
      moving=false;
      keyTime=0;
    }
  }
  
  public void changeEvent(){
    if(Contents.size()>0){
      int i=0;
      for(String s:Contents){
        if(i==selectedNumber){
          selectedItem=s;
          return;
        }
        i++;
      }
    }
  }
  
  public void addSelect(){
    selectedNumber=selectedNumber<Contents.size()-1?selectedNumber+1:0;
    changeEvent();
  }
  
  public void subSelect(){
    selectedNumber=selectedNumber>0?selectedNumber-1:Contents.size()-1;
    changeEvent();
  }
  
  public void resetSelect(){
    selectedNumber=constrain(selectedNumber,0,Contents.size()-1);
  }
  
  public void scroll(){
    if(dist.y<Height*Contents.size()){
      if(selectedNumber==0)scroll=0;else
      if(selectedNumber==Contents.size()-1)scroll=Contents.size()*Height-dist.y;
      scroll+=selectedNumber*Height-scroll<0?selectedNumber*Height-scroll:
              (selectedNumber+1)*Height-scroll>dist.y?(selectedNumber+1)*Height-scroll-dist.y:0;
    }
  }
  
  public void Select(){
    s.itemSelect(selectedItem);
  }
  
  public void addListener(KeyEvent e){
    this.e=e;
  }
  
  public void addSelectListener(ItemSelect s){
    this.s=s;
  }
}

class ListTemplate extends GameComponent{
  ArrayList<ListDisp>contents=new ArrayList<ListDisp>();
  ArrayList<Integer>separators=new ArrayList<Integer>();
  Color TitleColor=new Color(0x70,0x70,0x70);
  String name;
  float Height=25;
  
  ListTemplate(){
    
  }
  
  ListTemplate(float h){
    Height=h;
  }
  
  ListTemplate(String s){
    name=s;
  }
  
  public void addSeparator(int index){
    if(!separators.contains(index))separators.add(index);
  }
  
  public void display(){
    float offset=0;
    blendMode(BLEND);
    noStroke();
    fill(toColor(TitleColor));
    rect(pos.x,pos.y,dist.x,Height);
    fill(toColor(foreground));
    textAlign(CENTER);
    textSize(Height*0.6);
    text(name,pos.x+4+textWidth(name)/2,pos.y+Height*0.7);
    fill(toColor(background));
    rect(pos.x,pos.y+Height,dist.x,contents.size()*Height+(separators.size()+1)*Height/2);
    for(int i=0;i<contents.size();i++){
      if(separators.contains(i)){
        float h=pos.y+Height*(1.25+i)+offset;
        stroke(175);
        line(pos.x+dist.x*0.025,h,pos.x+dist.x*0.975,h);
        offset+=Height/2;
      }
      fill(toColor(foreground));
      contents.get(i).display(new PVector(pos.x,pos.y+offset+Height*(i+1)),new PVector(dist.x,Height));
    }
  }
  
  public void addContent(ListDisp l){
    contents.add(l);
  }
}

class ProgressBar extends GameComponent{
  Number progress=0;
  boolean unknown=false;
  float rad=0;
  
  ProgressBar(){
    setForeground(new Color(250,250,250));
    setBorderColor(new Color(0,90,200));
    keyMove=true;
  }
  
  public void isUnknown(boolean b){
    unknown=b;
  }
  
  public void display(){
    blendMode(BLEND);
    if(unknown){
      noFill();
      stroke(toColor(foreground));
      ellipse(pos.x,pos.y,dist.x,dist.y);
      strokeWeight(min(dist.x,dist.y)*0.15);
      ellipse(pos.x,pos.y,dist.x*0.75,dist.y*0.75);
      fill(toColor(foreground));
      noStroke();
      ellipse(pos.x,pos.y,dist.x/2,dist.y/2);
      noFill();
      stroke(toColor(border));
      strokeWeight(2);
      arc(pos.x,pos.y,dist.x/1.1,dist.y/1.1,rad,rad+PI/3);
      rad+=QUARTER_PI/10*vectorMagnification;
    }else{
      fill(toColor(foreground));
      stroke(toColor(border));
      strokeWeight(1);
      line(pos.x,pos.y,pos.x,pos.y+dist.y);
      line(pos.x+dist.x,pos.y,pos.x+dist.x,pos.y+dist.y);
      noStroke();
      rect(pos.x+2,pos.y,(dist.x-4)*float(progress.toString())/100,dist.y);
    }
  }
  
  public void setProgress(Number n){
    progress=n;
  }
}

class StatusList extends ListTemplate{
  Myself m;
  float addHP=0;
  
  StatusList(Myself m){
    this.m=m;
    name="Status";
    setBackground(new Color(220,220,220));
    addContent((PVector pos,PVector dist)->{
      text("player",pos.x+4+textWidth("player")/2,pos.y+dist.y*0.7);
    });
    addContent((PVector pos,PVector dist)->{
      text("Funds(U):",pos.x+4+textWidth("Funds(U):")/2,pos.y+dist.y*0.7);
    });
    addContent((PVector pos,PVector dist)->{
      text("HP:",pos.x+4+textWidth("HP:")/2,pos.y+dist.y*0.7);
      push();
      textAlign(RIGHT);
      text(m.HP.get().longValue()+"/"+m.HP.getMax().longValue(),pos.x+dist.x-5,pos.y+dist.y*0.7);
      pop();
      noStroke();
      fill(200);
      rect(pos.x+9+textWidth("HP:"),pos.y+dist.y/2,100,6);
      fill(toColor(menuRightColor));
      rect(pos.x+9+textWidth("HP:"),pos.y+dist.y/2,m.HP.getPercentage()*100,6);
      fill(100,128);
      rect(pos.x+9+textWidth("HP:")+m.HP.getPercentage()*100,
           pos.y+dist.y/2,(constrain(m.HP.getPercentage()+addHP/m.HP.getMax().floatValue(),0,1)-m.HP.getPercentage())*100,6);
    });
    addContent((PVector pos,PVector dist)->{
      push();
      textAlign(RIGHT);
      text(m.Attak.maxDoubleValue().toString(),pos.x+dist.x-5,pos.y+dist.y*0.7);
      pop();
      text("Attack(Basic):",pos.x+4+textWidth("Attack(Basic):")/2,pos.y+dist.y*0.7);
    });
    addContent((PVector pos,PVector dist)->{
      push();
      textAlign(RIGHT);
      text(m.Defence.maxDoubleValue().toString(),pos.x+dist.x-5,pos.y+dist.y*0.7);
      pop();
      text("Defence(Basic):",pos.x+4+textWidth("Defence(Basic):")/2,pos.y+dist.y*0.7);
    });
    addSeparator(1);
    addSeparator(3);
  }
  
  public void display(){
    super.display();
  }
  
  public void setAddHP(float d){
    addHP=d;
  }
}

class WeaponList extends ListTemplate{
  Myself m;
  float addHP=0;
  
  WeaponList(Myself m){
    this.m=m;
    name="Status";
    setBackground(new Color(220,220,220));
    addContent((PVector pos,PVector dist)->{
      text("player",pos.x+4+textWidth("player")/2,pos.y+dist.y*0.7);
    });
    addContent((PVector pos,PVector dist)->{
      text("Funds(U):",pos.x+4+textWidth("Funds(U):")/2,pos.y+dist.y*0.7);
    });
    addContent((PVector pos,PVector dist)->{
      text("HP:",pos.x+4+textWidth("HP:")/2,pos.y+dist.y*0.7);
      push();
      textAlign(RIGHT);
      text(m.HP.get().longValue()+"/"+m.HP.getMax().longValue(),pos.x+dist.x-5,pos.y+dist.y*0.7);
      pop();
      noStroke();
      fill(200);
      rect(pos.x+9+textWidth("HP:"),pos.y+dist.y/2,100,6);
      fill(toColor(menuRightColor));
      rect(pos.x+9+textWidth("HP:"),pos.y+dist.y/2,m.HP.getPercentage()*100,6);
      fill(100,128);
      rect(pos.x+9+textWidth("HP:")+m.HP.getPercentage()*100,
           pos.y+dist.y/2,(constrain(m.HP.getPercentage()+addHP/m.HP.getMax().floatValue(),0,1)-m.HP.getPercentage())*100,6);
    });
    addContent((PVector pos,PVector dist)->{
      text("Attack(Basic):",pos.x+4+textWidth("Attack(Basic):")/2,pos.y+dist.y*0.7);
    });
    addContent((PVector pos,PVector dist)->{
      text("Defence(Basic):",pos.x+4+textWidth("Defence(Basic):")/2,pos.y+dist.y*0.7);
    });
    addSeparator(1);
    addSeparator(3);
  }
  
  public void display(){
    super.display();
  }
  
  public void setAddHP(float d){
    addHP=d;
  }
}

class TextButton extends ButtonItem{
  
  TextButton(){
    
  }
  
  TextButton(String s){
    super(s);
  }
  
  public void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(focus?toColor(border):toColor(nonSelectBorder));
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  public void update(){
    mouseProcess();
    super.update();
  }
  
  TextButton setText(String s){
    text=s;
    return this;
  }
}

class NormalButton extends TextButton{
  
  NormalButton(){
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  NormalButton(String s){
    super(s);
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  public void display(){
    blendMode(BLEND);
    strokeWeight(2);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(toColor(border));
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y,dist.y/4);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  public void update(){
    super.update();
  }
}

class MenuButton extends TextButton{
  Color sideLineColor=new Color(toColor(menuRightColor));
  
  MenuButton(){
    setBackground(new Color(220,220,220));
    setForeground(new Color(0,0,0));
    setSelectBackground(new Color(200,200,200));
    setSelectForeground(new Color(40,40,40));
    setBorderColor(new Color(0,0,0,0));
  }
  
  MenuButton(String s){
    super(s);
    setBackground(new Color(220,220,220));
    setForeground(new Color(0,0,0));
    setSelectBackground(new Color(200,200,200));
    setSelectForeground(new Color(40,40,40));
    setBorderColor(new Color(0,0,0,0));
  }
  
  public void display(){
    pushStyle();
    if(font==null)font=createFont("SansSerif.plain",dist.y*0.5);
    textFont(font);
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(0,0,0,0);
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    stroke(!focus?color(0,0,0,0):toColor(sideLineColor));
    line(pos.x,pos.y,pos.x,pos.y+dist.y);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    popStyle();
  }
}

class SkeletonButton extends MenuButton{
  
  SkeletonButton(){
    init();
  }
  
  SkeletonButton(String s){
    super(s);
    init();
  }
  
  public void init(){
    setBackground(new Color(35,35,35,40));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(35,35,35,40));
    setSelectForeground(new Color(255,255,255));
    sideLineColor=new Color(0,0,0,0);
    setBorderColor(new Color(0,150,255));
  }
  
  public void display(){
    pushStyle();
    if(font==null)font=createFont("SansSerif.plain",dist.y*0.5);
    textFont(font);
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(!focus?color(25,25,25,80):toColor(border));
    beginShape();
    vertex(pos.x,pos.y);
    vertex(pos.x,pos.y+dist.y*0.9);
    vertex(pos.x+dist.x*0.1,pos.y+dist.y);
    vertex(pos.x+dist.x,pos.y+dist.y);
    vertex(pos.x+dist.x,pos.y);
    endShape(CLOSE);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    noStroke();
    textAlign(CENTER,CENTER);
    textSize(dist.y*0.5);
    text(text,pos.x+dist.x*0.5,pos.y+dist.y*0.4);
    popStyle();
  }
}

class UpgradeButton extends MenuButton{
  String expText="";
  String type="";
  
  {
    re=(p,d)->{
      font=createFont("SansSerif.plain",d.y*0.2);
    };
  }
  
  UpgradeButton(){
    init();
  }
  
  UpgradeButton(String s){
    super(s);
    init();
  }
  
  public void init(){
    setBackground(new Color(35,35,35,40));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(35,35,35,40));
    setSelectForeground(new Color(255,255,255));
    sideLineColor=new Color(0,0,0,0);
    setBorderColor(new Color(0,150,255));
  }
  
  public void display(){
    pushStyle();
    if(font==null)font=createFont("SansSerif.plain",dist.y*0.2);
    textFont(font);
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(!focus?color(25,25,25,80):toColor(border));
    beginShape();
    vertex(pos.x,pos.y);
    vertex(pos.x,pos.y+dist.y*0.9);
    vertex(pos.x+dist.x*0.1,pos.y+dist.y);
    vertex(pos.x+dist.x,pos.y+dist.y);
    vertex(pos.x+dist.x,pos.y);
    endShape(CLOSE);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    noStroke();
    textAlign(RIGHT,TOP);
    textSize(dist.y*0.2);
    text(type,pos.x+dist.x*0.95,pos.y+2);
    textAlign(LEFT,TOP);
    text(text,pos.x+dist.x*0.1,pos.y+2);
    textLeading(dist.y*0.2);
    text(expText,pos.x+dist.x*0.1,pos.y+dist.y*0.3+2,dist.x*0.9,dist.y*0.65);
    stroke(255);
    line(pos.x+dist.x*0.05,pos.y+dist.y*0.25+2,pos.x+dist.x*0.95,pos.y+dist.y*0.25+2);
    popStyle();
  }
  
  public void setExplanation(String s){
    expText=s;
  }
  
  public void setType(String s){
    String res=s.toUpperCase().substring(0,1);
    res+=s.substring(1,s.length());
    type=res;
  }
}

class MenuTextBox extends TextBox{
  
  MenuTextBox(){
    super();
  }
  
  MenuTextBox(String t){
    super(t);
  }
  
  public void display(){
    blendMode(BLEND);
    rectMode(CORNER);
    noStroke();
    fill(toColor(background));
    rect(pos.x,pos.y,dist.x,dist.y);
    fill(#707070);
    rect(pos.x,pos.y,dist.x,25);
    fill(toColor(foreground));
    textFont(font);
    textSize(fontSize);
    textAlign(CENTER);
    fill(0);
    text(title,pos.x+5+textWidth(title)/2,pos.y+17.5);
    textAlign(LEFT);
    text(text,pos.x+5,pos.y+45);
  }
  
  public void update(){
    super.update();
  }
}

class MenuCheckBox extends CheckBox{
  MenuTextBox box=new MenuTextBox();
  private String cust_true=null;
  private String cust_false=null;
  boolean displayBox=false;
  
  MenuCheckBox(String text,boolean value){
    super(value);
    this.text=text;
    setBackground(new Color(220,220,220));
    setForeground(new Color(0,0,0));
    setSelectBackground(new Color(200,200,200));
    setSelectForeground(new Color(40,40,40));
    setBorderColor(new Color(0,0,0,0));
  }
  
  public void setTextBoxBounds(float x,float y,float dx,float dy){
    box.setBounds(x,y,dx,dy);
  }
  
  public void setExplanation(String s){
    box.setText(s);
  }
  
  public void display(){
    pushStyle();
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(0,0,0,0);
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    stroke(!focus?color(0,0,0,0):toColor(menuRightColor));
    line(pos.x,pos.y,pos.x,pos.y+dist.y);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textFont(font);
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text+":"+(value?cust_true==null?"ON":cust_true:cust_false==null?"OFF":cust_false),center.x,center.y+dist.y*0.2);
    if(displayBox)box.display();
    popStyle();
  }
  
  public void update(){
    super.update();
    if(displayBox)box.update();
  }
  
  public void displayBox(boolean b){
    displayBox=b;
  }
  
  public void setCustomizeText(String t,String f){
    cust_true=t;
    cust_false=f;
  }
}

class MenuToggleBox extends ToggleBox{
  MenuTextBox box=new MenuTextBox();
  boolean displayBox=false;
  
  MenuToggleBox(String text,int value,int num){
    super(value,num);
    this.text=text;
    setBackground(new Color(220,220,220));
    setForeground(new Color(0,0,0));
    setSelectBackground(new Color(200,200,200));
    setSelectForeground(new Color(40,40,40));
    setBorderColor(new Color(0,0,0,0));
  }
  
  public void setTextBoxBounds(float x,float y,float dx,float dy){
    box.setBounds(x,y,dx,dy);
  }
  
  public void setExplanation(String s){
    box.setText(s);
  }
  
  public void display(){
    pushStyle();
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(0,0,0,0);
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    stroke(!focus?color(0,0,0,0):toColor(menuRightColor));
    line(pos.x,pos.y,pos.x,pos.y+dist.y);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textFont(font);
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text+":"+(textMap.containsKey(value)?(textMap.get(value)==null?value:textMap.get(value)):value),center.x,center.y+dist.y*0.2);
    if(displayBox)box.display();
    popStyle();
  }
  
  public void update(){
    super.update();
    if(displayBox)box.update();
  }
  
  public void displayBox(boolean b){
    displayBox=b;
  }
  
  public MenuToggleBox addCustomizeText(int i,String f){
    textMap.put(i,f);
    return this;
  }
}

class ComponentSet{
  Layout layout;
  ArrayList<GameComponent>components=new ArrayList<GameComponent>();
  boolean keyMove=true;
  boolean Active=true;
  boolean Focus=true;
  int subSelectButton=-0xFFFFFF;
  int pSelectedIndex=0;
  int selectedIndex=0;
  int memoryIndex=0;
  int resizeNumber=0;
  int type=0;
  
  static final int Down=0;
  static final int Up=1;
  static final int Right=2;
  static final int Left=3;
  
  ComponentSet(){
  }
  
  ComponentSet setLayout(Layout l){
    layout=l;
    return this;
  }
  
  public void add(GameComponent val){
    if(layout!=null)layout.alignment(val);
    components.add(val);
    if(components.size()==1){
      if(val.canFocus&&Focus){
        val.requestFocus();
        selectedIndex=0;
      }else{
        val.removeFocus();
      }
    }else if(!components.get(min(selectedIndex,components.size()-2)).canFocus){
      if(val.canFocus){
        val.requestFocus();
        selectedIndex=components.size()-1;
      }
    }
  }
  
  public void addAll(GameComponent... val){
    if(layout!=null)layout.alignment(val);
    for(GameComponent c:val){
      add(c);
    }
    if(components.get(selectedIndex).canFocus){
      for(int i=0;i<components.size();i++){
        if(components.get(i).canFocus){
          components.get(i).requestFocus();
          selectedIndex=i;
        }
      }
    }
  }
  
  public void remove(GameComponent val){
    if(layout!=null)layout.remove(val);
    components.remove(val);
  }
  
  public void removeAll(){
    if(layout!=null)layout.reset();
    components.clear();
  }
  
  public void removeFocus(){
    Focus=false;
    if(components.size()>0){
      for(GameComponent c:components){
        c.removeFocus();
        c.canFocus=false;
      }
      components.get(selectedIndex).Fe.lostFocus();
    }
  }
  
  public void requestFocus(){
    Focus=true;
    if(components.size()>0){
      for(GameComponent c:components){
        c.canFocus=true;
      }
      components.get(memoryIndex).requestFocus();
      components.get(memoryIndex).Fe.getFocus();
      selectedIndex=memoryIndex;
    }
  }
  
  public void display(){
    if(components.size()==0)return;
    for(GameComponent c:components){
      c.handleDisplay();
    }
  }
  
  public void update(){
    if(!Active)return;
    if(components.size()==0)return;
    for(GameComponent c:components){
      c.handleUpdate();
      if(c.FocusEvent){
        for(GameComponent C:components){
          C.removeFocus();
        }
        c.requestFocus();
      }
      if(c.focus)selectedIndex=components.indexOf(c);
    }
    if(Focus)keyEvent();
    if(pSelectedIndex!=selectedIndex){
      if(pSelectedIndex!=-1&&!(pSelectedIndex>=components.size()))components.get(pSelectedIndex).Fe.lostFocus();
      if(selectedIndex!=-1&&!(selectedIndex>=components.size()))components.get(selectedIndex).Fe.getFocus();
    }
    resized();
    pSelectedIndex=selectedIndex;
  }
  
  public void updateExcludingKey(){
    if(!Active)return;
    for(GameComponent c:components){
      c.handleUpdate();
      if(c.FocusEvent){
        for(GameComponent C:components){
          C.removeFocus();
        }
        c.requestFocus();
      }
      if(c.focus)selectedIndex=components.indexOf(c);
    }
    if(pSelectedIndex!=selectedIndex){
      if(pSelectedIndex!=-1)components.get(pSelectedIndex).Fe.lostFocus();
      if(selectedIndex!=-1)components.get(selectedIndex).Fe.getFocus();
    }
    pSelectedIndex=selectedIndex;
  }
  
  public void setSubSelectButton(int b){
    subSelectButton=b;
  }
  
  public void setIndex(int i){
    if(selectedIndex!=-1)memoryIndex=selectedIndex;
    selectedIndex=i;
  }
  
  boolean onMouse(){
    for(GameComponent c:components){
      if(c.pos.x<=mouseX&&mouseX<=c.pos.x+c.dist.x&&c.pos.y<=mouseY&&mouseY<=c.pos.y+c.dist.y)return true;
    }
    return false;
  }
  
  public void keyEvent(){
    if(selectedIndex!=-1&&!components.get(selectedIndex).keyMove&&isInput()){
      if(type==0|type==1){
        switch(getInputState()){
          case "down":if(type==0)addSelect();else subSelect();break;
          case "up":if(type==0)subSelect();else addSelect();break;
        }
      }else if(type==2|type==3){
        switch(getInputState()){
          case "right":break;
          case "left":break;
        }
      }
      if(getInputState("enter")){
        components.get(selectedIndex).executeEvent();
      }
    }
  }
  
  public void addSelect(){
    if(components.size()==1)return;
    for(GameComponent c:components){
      if(c.focus){
        c.removeFocus();
      }
    }
    selectedIndex=selectedIndex>=components.size()-1?0:selectedIndex+1;
    if(!components.get(selectedIndex).focussable){
      addSelect();
    }
    components.get(selectedIndex).requestFocus();
  }
  
  public void subSelect(){
    if(components.size()==1)return;
    for(GameComponent c:components){
      if(c.focus){
        c.removeFocus();
      }
    }
    selectedIndex=selectedIndex<=0?components.size()-1:selectedIndex-1;
    if(!components.get(selectedIndex).focussable){
      subSelect();
    }
    components.get(selectedIndex).requestFocus();
  }
  
  GameComponent getSelected(){
    return components.get(selectedIndex);
  }
  
  public void resized(){
    if(windowResized||resizeNumber!=resizedNumber){
      if(layout!=null)layout.resized();else components.forEach(c->c.wre.Event());
      resizeNumber=resizedNumber;
    }
  }
}

class Layout{
  WindowResizeEvent e=()->{};
  ArrayList<GameComponent>list;
  PVector pos;
  PVector dist;
  PVector nextPos;
  float Space;
  
  {
    list=new ArrayList<GameComponent>();
  }
  
  Layout(){
    pos=new PVector(0,0);
    dist=new PVector(0,0);
    nextPos=new PVector(0,0);
    Space=0;
  }
  
  Layout(float x,float y,float dx,float dy,float space){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    nextPos=new PVector(x,y);
    Space=space;
  }
  
  public void setBounds(float x,float y,float dx,float dy,float space){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    nextPos=new PVector(x,y);
    Space=space;
  }
  
  public void reset(){
    list.clear();
    nextPos=pos.copy();
  }
  
  public void remove(GameComponent c){
    list.remove(c);
    resized();
  }
  
  public void setWindowResizedListener(WindowResizeEvent e){
    this.e=e;
  }
  
  public void alignment(GameComponent c){
  }
  
  public void alignment(GameComponent[] c){
  }
  
  public void resized(){
  }
}

class Y_AxisLayout extends Layout{
  
  Y_AxisLayout(){
    super();
  }
  
  Y_AxisLayout(float x,float y,float dx,float dy,float space){
    super(x,y,dx,dy,space);
  }
  
  @Override
  public void alignment(GameComponent c){
    if(!list.contains(c)){
      c.setBounds(nextPos.copy().x,nextPos.copy().y,dist.x,dist.y);
      nextPos.add(0,dist.y+Space);
      list.add(c);
    }
  }
  
  @Override
  public void alignment(GameComponent[] c){
    for(int i=0;i<c.length;i++){
      if(!list.contains(c[i])){
        c[i].setBounds(nextPos.copy().x,nextPos.copy().y,dist.x,dist.y);
        nextPos.add(0,dist.y+Space);
        list.add(c[i]);
      }
    }
  }
  
  @Override
  public void resized(){
    e.Event();
    nextPos=pos.copy();
    for(int i=0;i<list.size();i++){
      list.get(i).setBounds(nextPos.copy().x,nextPos.copy().y,dist.x,dist.y);
      nextPos=nextPos.add(0,dist.y+Space);
    }
  }
}

class ComponentSetLayer{
  HashMap<String,Layer>Layers;
  HashMap<String,Line<String,String>>Lines;
  HashMap<String,String>Parents;
  ArrayList<Float>returnKey;
  boolean layerChanged=false;
  String nowLayer=null;
  String nowParent=null;
  int selectNumber=0;
  int resizeNumber=0;
  int SubChildshowType=0;
  int showType=0;
  
  static final int ALL=0;
  static final int SELECT=1;
  static final int MIN=2;
  static final int MAX=3;
  
  ComponentSetLayer(){
    Layers=new HashMap<String,Layer>();
    Lines=new HashMap<String,Line<String,String>>();
    Parents=new HashMap<String,String>();
    returnKey=new ArrayList<Float>();
    returnKey.add((float)SHIFT);
  }
  
  public void addLayer(String name,ComponentSet... c){
    if(Layers.containsKey(name)){
      throw new Error("The layer"+" \""+name+"\" +"+"is already added");
    }else{
      Layers.put(name,new Layer(0,c));
      Lines.put(name,new Line<String,String>(name));
      Parents.put(name,null);
      if(Layers.size()==1){
        nowLayer=name;
        nowParent=name;
        if(c.length>1){
          for(int i=1;i<c.length;i++){
            c[i].removeFocus();
          }
        }
      }else{
        for(ComponentSet C:c){
          C.removeFocus();
        }
      }
    }
  }
  
  public void addContent(String name,ComponentSet... c){
    Layers.get(name).addComponent(c);
  }
  
  public void addChild(String parent,String name,ComponentSet... c){
    if(Lines.containsKey(parent)&!Layers.containsKey(name)){
      Layers.put(name,new Layer(Layers.get(parent).getDepth()+1,c));
      Lines.get(parent).addChild(name);
      Lines.put(name,new Line<String,String>(name));
      Parents.put(name,parent);
      for(ComponentSet C:c){
        C.removeFocus();
      }
    }
  }
  
  public void addSubChild(String parent,String name,ComponentSet... c){
    if(Lines.containsKey(parent)&!Layers.containsKey(name)){
      Layers.put(name,new Layer(Layers.get(parent).getDepth()+1,true,c));
      Lines.get(parent).addChild(name);
      Lines.put(name,new Line<String,String>(name));
      Parents.put(name,parent);
      for(ComponentSet C:c){
        C.removeFocus();
      }
    }
  }
  
  public void toChild(String name){
    layerChanged=true;
    if(Lines.get(nowLayer).getChild().contains(name)){
      Layers.get(nowLayer).getSelectedComponent().removeFocus();
      Layers.get(nowLayer).getSelectedComponent().setIndex(-1);
      nowLayer=name;
      nowParent=Layers.get(name).isSub()?nowParent:nowLayer;
      Layers.get(nowLayer).getSelectedComponent().requestFocus();
    }else{
      return;
    }
  }
  
  public void toParent(){
    if(Parents.get(nowLayer)==null)return;
    if(nowLayer.equals(nowParent)){
      Layers.get(nowLayer).getSelectedComponent().removeFocus();
      Layers.get(nowLayer).getSelectedComponent().setIndex(-1);
      nowLayer=Parents.get(nowLayer);
      nowParent=new String(nowLayer);
      Layers.get(nowLayer).getSelectedComponent().requestFocus();
    }else{
      Layers.get(nowLayer).getSelectedComponent().removeFocus();
      Layers.get(nowLayer).getSelectedComponent().setIndex(-1);
      nowLayer=Parents.get(nowLayer);
      Layers.get(nowLayer).getSelectedComponent().requestFocus();
    }
  }
  
  int getDepth(){
    return Layers.get(nowLayer).getDepth();
  }
  
  ArrayList<ComponentSet> getNowComponents(){
    return Layers.get(nowLayer).getComponents();
  }
  
  public void display(){
    if(nowLayer==null||Layers.get(nowLayer).getComponents().size()==0){
      return;
    }else{
      if(windowResized||resizeNumber!=resizedNumber){
        Layers.forEach((k,v)->v.Components.forEach(cs->{cs.resized();}));
        resizeNumber=resizedNumber;
      }
      int count=0;
      for(ComponentSet c:Layers.get(nowLayer).getComponents()){
        if(c==null)continue;
        switch(showType){
          case 0:c.display();break;
          case 1:if(count==selectNumber)c.display();break;
          case 2:if(count<=selectNumber)c.display();break;
          case 3:if(count>=selectNumber)c.display();break;
        }
        ++count;
      }
      if(SubChildshowType==1&&!Layers.get(nowLayer).isSub())return;
      displaySub(nowLayer);
    }
  }
  
  public void update(){
    if(nowLayer==null){
      return;
    }else{
      int count=0;
      for(ComponentSet c:Layers.get(nowLayer).getComponents()){
        if(c==null)continue;
        switch(showType){
          case 0:c.update();break;
          case 1:if(count==selectNumber)c.update();break;
          case 2:if(count<=selectNumber)c.update();break;
          case 3:if(count>=selectNumber)c.update();break;
        }
        ++count;
      }
      if(SubChildshowType==1&&!Layers.get(nowLayer).isSub())return;
      updateSub(nowLayer);
      layerChanged=false;
    }
    keyProcess();
  }
  
  public void keyProcess(){
    if(getInputState("back")){
      toParent();
    }
  }
  
  public void addReturnKey(int keycode){
    returnKey.add((float)keycode);
  }
  
  public void removeReturnKey(int keycode){
    returnKey.remove((float)keycode);
  }
  
  public void clearReturnKey(){
    returnKey.clear();
  }
  
  public void setIndex(int i){
    Layers.get(nowLayer).setIndex(i);
  }
  
  public void toLayer(String name){
    if(Lines.get(nowLayer).getChild().contains(name)){
      nowLayer=name;
    }else{
      return;
    }
  }
  
  String getLayerName(){
    return new String(nowLayer);
  }
  
  public void setSubChildDisplayType(int t){
    SubChildshowType=t;
  }
  
  private void displaySub(String n){
    if(Lines.containsKey(n)){
      displayParent(n);
      if(SubChildshowType==1&&n.equals(nowLayer))return;
      displayChild(n);
    }
  }
  
  private void displayChild(String n){
      for(String s:Lines.get(n).getChild()){
        if(Layers.get(s).isSub()){
          for(ComponentSet c:Layers.get(s).getComponents()){
            c.display();
          }
          if(SubChildshowType==1&&s.equals(nowLayer))return;
          displayChild(s);
        }
      }
  }
  
  private void displayParent(String n){
    String s=Parents.get(n);
    if(s==null)return;
    if(SubChildshowType==2&&s.equals(nowParent))return;
    for(ComponentSet c:Layers.get(s).getComponents()){
      c.display();
    }
    if(s.equals(nowParent))return;
    displayParent(s);
  }
  
  private void updateSub(String n){
    if(Lines.containsKey(n)){
      updateParent(n);
      if(SubChildshowType==1&&n.equals(nowLayer))return;
      updateChild(n);
    }
  }
  
  private void updateChild(String n){
      for(String s:Lines.get(n).getChild()){
        if(Layers.get(s).isSub()){
          for(ComponentSet c:Layers.get(s).getComponents()){
            c.updateExcludingKey();
          }
          if(SubChildshowType==1&&s.equals(nowLayer))return;
          updateChild(s);
        }
      }
  }
  
  private void updateParent(String n){
    String s=Parents.get(n);
    if(s==null)return;
    if(SubChildshowType==2&&s.equals(nowParent))return;
    for(ComponentSet c:Layers.get(s).getComponents()){
      c.updateExcludingKey();
      if(!layerChanged&&c.onMouse()&&mousePress){
        String target=s;
        while(!nowLayer.equals(target))toParent();
      }
    }
    if(s.equals(nowParent))return;
    updateParent(s);
  }
  
  protected final class Line<P,C>{
    private P parent;
    private ArrayList<C> child;
    
    Line(P parent,C... child){
      this.parent=parent;
      this.child=new ArrayList<C>();
      this.child.addAll(Arrays.asList(child));
    }
    
    public void addChild(C... child){
      this.child.addAll(Arrays.asList(child));
    }
    
    P getParent(){
      return parent;
    }
    
    ArrayList<C> getChild(){
      return child;
    }
    
    C getChild(int index){
      return child.get(index);
    }
  }
  
  protected final class Layer{
    private ArrayList<ComponentSet>Components;
    private boolean sub=false;
    private int depth=0;
    private int index=0;
    
    Layer(int d,ComponentSet... c){
      depth=d;
      Components=new ArrayList<ComponentSet>(Arrays.asList(c));
    }
    
    Layer(int d,boolean s,ComponentSet... c){
      sub=s;
      depth=d;
      Components=new ArrayList<ComponentSet>(Arrays.asList(c));
    }
    
    public void display(){
      for(ComponentSet c:Components){
        c.display();
      }
    }
    
    public void update(){
      Components.get(index).update();
    }
    
    public void addComponent(ComponentSet... c){
      Components.addAll(Arrays.asList(c));
    }
    
    public void setIndex(int i){
      index=constrain(i,0,Components.size()-1);
    }
    
    ArrayList<ComponentSet> getComponents(){
      return Components;
    }
    
    ComponentSet getSelectedComponent(){
      return Components.get(index);
    }
    
    boolean isSub(){
      return sub;
    }
    
    int getDepth(){
      return depth;
    }
    
    int size(){
      return Components.size();
    }
  }
}

ComponentSet toSet(GameComponent... c){
  ComponentSet r=new ComponentSet();
  r.addAll(c);
  return r;
}

ComponentSet toSet(Layout l,GameComponent... c){
  ComponentSet r=new ComponentSet();
  r.setLayout(l);
  r.addAll(c);
  return r;
}

interface FocusEvent{
  public void getFocus();
  
  public void lostFocus();
}

interface ResizeEvent{
  public void resized(PVector p,PVector d);
}

interface SelectEvent{
  public void selectEvent();
}

interface ChangeEvent{
  public void changeEvent();
}

interface KeyEvent{
  public void keyEvent(int Key);
}

interface ItemSelect{
  public void itemSelect(String s);
}

interface ListDisp{
  public void display(PVector pos,PVector dist);
}

interface EnterEvent{
  public void Event(LineTextField l);
}

interface WindowResizeEvent{
  public void Event();
}

interface CanvasContent{
  public void display(PGraphics pg);
}

interface Process{
  public void execute();
}

interface disposeEvent{
  public void event();
}
