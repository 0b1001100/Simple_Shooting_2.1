Color menuRightColor=new Color(0,150,255);

class GameComponent{
  protected FocusEvent Fe=new FocusEvent(){void getFocus(){} void lostFocus(){}};
  protected int Depth=0;
  protected PVector pos;
  protected PVector dist;
  protected PVector center;
  protected boolean focus=false;
  protected boolean pFocus=false;
  protected boolean FocusEvent=false;
  protected boolean keyMove=false;
  protected Color background=new Color(200,200,200);
  protected Color selectbackground=new Color(255,255,255);
  protected Color foreground=new Color(0,0,0);
  protected Color selectforeground=new Color(0,0,0);
  protected Color border=new Color(0,0,0);
  protected Color nonSelectBorder=border;
  
  GameComponent(){
    
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    center=new PVector(x+dx/2,y+dy/2);
    return this;
  }
  
  void setBackground(Color c){
    background=c;
  }
  
  void setSelectBackground(Color c){
    selectbackground=c;
  }
  
  void setForeground(Color c){
    foreground=c;
  }
  
  void setSelectForeground(Color c){
    selectforeground=c;
  }
  
  void setBorderColor(Color c){
    border=c;
  }
  
  void setNonSelectBorderColor(Color c){
    border=new Color(c.getRed(),c.getGreen(),c.getBlue());
  }
  
  void display(){
    
  }
  
  void update(){
    pFocus=focus;
  }
  
  void executeEvent(){
    
  }
  
  void requestFocus(){
    focus=true;
  }
  
  void removeFocus(){
    focus=false;
  }
  
  void addFocusListener(FocusEvent e){
    Fe=e;
  }
  
  int getDepth(){
    return Depth;
  }
  
  void back(){}
}

class ButtonItem extends GameComponent{
  protected SelectEvent e=()->{};
  protected boolean pCursor=false;
  protected boolean setCursor=false;
  protected boolean setCursorEvent=false;
  protected String text="";
  
  ButtonItem(){
    
  }
  
  ButtonItem(String s){
    text=s;
  }
  
  void addListener(SelectEvent e){
    this.e=e;
  }
  
  void mouseProcess(){
    boolean onMouse=mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y;
    if(onMouse){
      setCursor=true;
      setCursorEvent=pCursor!=setCursor;
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
  
  void executeEvent(){
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
  
  void setSmooth(boolean b){
    smooth=b;
  }
  
  void display(){
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
  
  void update(){
    mouseProcess();
    keyProcess();
    pValue=Value;
  }
  
  void mouseProcess(){
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
  
  void keyProcess(){
    switch(nowPressedKeyCode){
      case RIGHT:Value=constrain(Value+1,1,elementNum);break;
      case LEFT:Value=constrain(Value-1,1,elementNum);break;
    }
    Xdist=(dist.x/elementNum)*(Value-1);
  }
  
  void addListener(ChangeEvent e){
    this.e=e;
  }
  
  void executeEvent(){
    e.changeEvent();
  }
  
  int getValue(){
    return Value;
  }
  
  @Deprecated
  void setValue(int v){
    Value=constrain(v,1,elementNum);
    Xdist=(dist.x/elementNum)*Value;
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
  
  void add(NormalButton b){
    Buttons.add(b);
  }
  
  void display(){
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
  
  void update(){
    mouseProcess();
    for(NormalButton b:Buttons){
      b.update();
    }
    pFocusIndex=focusIndex;
  }
  
  void mouseProcess(){
    if(mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y){
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
  
  void reloadIndex(){
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
    if(focus){
      Buttons.get(focusIndex).requestFocus();
    }
  }
  
  void requestFocus(){
    super.requestFocus();
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
    Buttons.get(focusIndex).requestFocus();
  }
  
  void removeFocus(){
    super.removeFocus();
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
  }
}

class ItemList extends GameComponent{
  PGraphics pg;
  ItemTable table;
  Item selectedItem=null;
  KeyEvent e=(int k)->{};
  ItemSelect s=(Item i)->{};
  PVector sPos;
  PVector sDist;
  boolean showSub=true;
  boolean menu=false;
  boolean onMouse=false;
  boolean moving=false;
  boolean pDrag=false;
  boolean drag=false;
  float Height=25;
  float scroll=0;
  float keyTime=0;
  int selectedNumber=0;
  int menuNumber=0;
  
  ItemList(){
    keyMove=true;
  }
  
  ItemList(ItemTable t){
    table=t;
    changeEvent();
    keyMove=true;
  }
  
  void LinkTable(ItemTable t){
    table=t;
    selectedNumber=0;
    changeEvent();
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pg=createGraphics(round(dx),round(dy),P2D);
    return super.setBounds(x,y,dx,dy);
  }
  
  GameComponent setSubBounds(float x,float y,float dx,float dy){
    sPos=new PVector(x,y);
    sDist=new PVector(dx,dy);
    return this;
  }
  
  void setSub(boolean b){
    showSub=b;
  }
  
  void display(){
    blendMode(BLEND);
    int num=0;
    pg.beginDraw();
    pg.background(toColor(background));
    pg.fill(0,255);
    for(Item i:table.table.values()){
      if(floor(scroll/Height)<=num&num<=floor((scroll+dist.y)/Height)){
        pg.text(i.getName(),0,num*Height-scroll);
        if(selectedNumber==num){
          pg.fill(0,30);
          pg.rect(0,num*Height-scroll,dist.x,Height);
        }
      }
      num++;
    }
    sideBar();
    pg.endDraw();
    image(pg,pos.x,pos.y);
    if(showSub&selectedItem!=null)subDraw();
    if(menu)menuDraw();
  }
  
  void sideBar(){
    if(dist.y<Height*table.table.size()){
      float len=Height*table.table.size();
      float mag=pg.height/len;
      pg.fill(255);
      pg.rect(pg.width-10,0,10,pg.height);
      pg.fill(drag?200:128);
      pg.rect(pg.width-10,pg.height*(1-mag)*scroll/(len-pg.height),10,pg.height*mag);
    }
  }
  
  void subDraw(){
    blendMode(BLEND);
    fill(#707070);
    noStroke();
    rect(sPos.x,sPos.y,sDist.x,25);
    fill(toColor(background));
    rect(sPos.x,sPos.y+25,sDist.x,sDist.y-25);
    textSize(15);
    textAlign(CENTER);
    fill(0);
    text("説明",sPos.x+5+textWidth("説明")/2,sPos.y+17.5);
    textAlign(LEFT);
    text(MastarTable.table.containsKey(selectedItem.getName())&table.table.size()>0?
         MastarTable.get(selectedItem.getName()).getExplanation():"Error : no_data\nError number : 0x2DA62C9",sPos.x+5,sPos.y+45);
  }
  
  void menuDraw(){
    fill(10,40);
    noStroke();
    rect(0,0,width,height);
    fill(210);
    blendMode(BLEND);
    rectMode(CORNER);
    textAlign(CENTER);
    textSize(15);
    if(selectedItem.getType()==1){
      rect(pos.x+dist.x,pos.y+selectedNumber*Height-scroll-Height/2,120,Height*2);
      fill(0);
      text("使用",pos.x+dist.x+60,pos.y+selectedNumber*Height-scroll+Height*0.2);
      text("破棄",pos.x+dist.x+60,pos.y+(selectedNumber+1)*Height-scroll+Height*0.2);
      fill(0,30);
      rect(pos.x+dist.x,pos.y+(selectedNumber+menuNumber)*Height-scroll-Height/2,120,Height);
      stroke(toColor(menuRightColor));
      line(pos.x+dist.x,pos.y+(selectedNumber+menuNumber)*Height-scroll-Height/2,
           pos.x+dist.x,pos.y+(selectedNumber+menuNumber+1)*Height-scroll-Height/2);
    }else if(selectedItem.getType()==2){
      rect(pos.x+dist.x,pos.y+selectedNumber*Height-scroll,120,Height);
      fill(0);
      text("破棄",pos.x+dist.x+60,pos.y+(selectedNumber+0.5)*Height-scroll+Height*0.2);
      fill(0,30);
      rect(pos.x+dist.x,pos.y+selectedNumber*Height-scroll,120,Height);
      stroke(toColor(menuRightColor));
      line(pos.x+dist.x,pos.y+selectedNumber*Height-scroll,pos.x+dist.x,pos.y+(selectedNumber+1)*Height-scroll);
    }else if(selectedItem.getType()==3){
      rect(pos.x+dist.x,pos.y+selectedNumber*Height-scroll,120,Height);
      fill(0);
      text("使用",pos.x+dist.x+60,pos.y+(selectedNumber+0.5)*Height-scroll+Height*0.2);
      fill(0,30);
      rect(pos.x+dist.x,pos.y+selectedNumber*Height-scroll,120,Height);
      stroke(toColor(menuRightColor));
      line(pos.x+dist.x,pos.y+selectedNumber*Height-scroll,pos.x+dist.x,pos.y+(selectedNumber+1)*Height-scroll);
    }
  }
  
  void update(){
    if(focus&&table!=null){
      onMouse=!menu?onMouse(pos.x,pos.y,dist.x,min(Height*table.table.size(),dist.y)):
                    onMouse(pos.x+dist.x,pos.y+selectedNumber*Height-scroll-Height/2,120,Height*2);
      if(!menu)mouseProcess();else menuMouse();
      if(mousePressed)moving=false;
      if(!menu)keyProcess();else menuKey();
    }
    pDrag=drag;
    super.update();
  }
  
  void mouseProcess(){
    float len=Height*table.table.size();
    float mag=pg.height/len;
    if(dist.y<len&onMouse(pos.x+pg.width-10,pos.y+pg.height*(1-mag)*scroll/(len-pg.height),10,pg.height*mag)&mousePress){
      drag=true;
    }
    if(!mousePressed){
      drag=false;
    }
    if(pDrag&drag){
      scroll+=(mouseY-pmouseY)*(len-dist.y)/(dist.y*(1-mag));
      scroll=constrain(scroll,0,len-dist.y);
    }
    if(onMouse(pos.x,pos.y,dist.x-(dist.y<len?10:0),max(len-scroll,0))&mousePress){
      if(selectedNumber==floor((mouseY-pos.y+scroll)/Height)){
        Select();
      }else{
        selectedNumber=floor((mouseY-pos.y+scroll)/Height);
        changeEvent();
      }
    }
  }
  
  void menuMouse(){
    if(selectedItem.getType()==1){
      if(onMouse&&mousePress){
        float y=pos.y+selectedNumber*Height-scroll-Height/2;
        if(y<=mouseY&&mouseY<=y+Height){
          if(menuNumber==0){
            menuSelect();
            return;
          }
          menuNumber=0;
        }else{
          if(menuNumber==1){
            menuSelect();
            return;
          }
          menuNumber=1;
        }
      }
    }else if(selectedItem.getType()==2){
      if(mousePress)menuSelect();
    }else if(selectedItem.getType()==3){
      if(mousePress)menuSelect();
    }
  }
  
  void keyProcess(){
    if(keyPress){
      e.keyEvent(nowPressedKeyCode);
      switch(nowPressedKeyCode){
        case UP:subSelect();changeEvent();break;
        case DOWN:addSelect();changeEvent();break;
      }
      scroll();
      if(nowPressedKeyCode==ENTER|nowPressedKeyCode==RIGHT)Select();
    }
    if(!moving&keyPressed&(nowPressedKeyCode==UP|nowPressedKeyCode==DOWN)){
      keyTime+=vectorMagnification;
    }
    if(!moving&keyTime>=30){
      moving=true;
      keyTime=0;
    }
    if(moving){
      keyTime+=vectorMagnification;
    }
    if(moving&keyTime>=15){
      switch(nowPressedKeyCode){
        case UP:subSelect();break;
        case DOWN:addSelect();break;
      }
      scroll();
    }
    if(!keyPressed){
      moving=false;
      keyTime=0;
    }
  }
  
  void menuKey(){
    if(keyPress){
      if(selectedItem.getType()==1){
        switch(nowPressedKeyCode){
          case UP:menuNumber=abs(menuNumber-1);break;
          case DOWN:menuNumber=menuNumber==1?0:1;break;
        }
        if(nowPressedKeyCode==ENTER|nowPressedKeyCode==RIGHT){
          menuSelect();
        }
      }else if(selectedItem.getType()==2){
        
      }else if(selectedItem.getType()==3){
        
      }
    }
  }
  
  void changeEvent(){
    if(table!=null){
      int i=0;
      for(Item I:table.table.values()){
        if(i==selectedNumber){
          selectedItem=I;
          return;
        }
        i++;
      }
    }
  }
  
  void menuSelect(){
    boolean b=true;
    switch(menuNumber){
      case 0:selectedItem.ExecuteEvent();b=table.removeStorage(selectedItem.getName(),1);menu=false;break;
      case 1:if(selectedItem.getType()<=2){b=table.removeStorage(selectedItem.getName(),1);}else
                                          {selectedItem.ExecuteEvent();}menu=false;break;
    }
    if(!b)selectedNumber--;
    resetSelect();
    changeEvent();
  }
  
  void addSelect(){
    selectedNumber=selectedNumber<table.table.size()-1?selectedNumber+1:0;
    changeEvent();
    itemSelect();
  }
  
  void subSelect(){
    selectedNumber=selectedNumber>0?selectedNumber-1:table.table.size()-1;
    changeEvent();
    itemSelect();
  }
  
  void resetSelect(){
    selectedNumber=constrain(selectedNumber,0,table.table.size()-1);
  }
  
  void scroll(){
    if(dist.y<Height*table.table.size()){
      if(selectedNumber==0)scroll=0;else
      if(selectedNumber==table.table.size()-1)scroll=table.table.size()*Height-dist.y;
      scroll+=selectedNumber*Height-scroll<0?selectedNumber*Height-scroll:
              (selectedNumber+1)*Height-scroll>dist.y?(selectedNumber+1)*Height-scroll-dist.y:0;
    }
  }
  
  void Select(){
    Item s=new Item("");
    int i=0;
    for(Item I:table.table.values()){
      if(i==selectedNumber){
        s=I;
        break;
      }
      i++;
    }
    if(table.num.size()>=1&s.getType()!=s.COLLECTION){
      menu=true;
      Depth=1;
    }
  }
  
  void itemSelect(){
    s.ItemSelect(selectedItem);
  }
  
  void addListener(KeyEvent e){
    this.e=e;
  }
  
  void addItemListener(ItemSelect s){
    this.s=s;
  }
  
  void back(){
    menu=false;
    Depth=0;
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
  
  void addSeparator(int index){
    if(!separators.contains(index))separators.add(index);
  }
  
  void display(){
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
  
  void addContent(ListDisp l){
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
  
  void isUnknown(boolean b){
    unknown=b;
  }
  
  void display(){
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
      rect(pos.x+2,pos.y,(dist.x-4)*new Float(progress.toString())/100,dist.y);
    }
  }
  
  void setProgress(Number n){
    progress=n;
  }
}

class TextBox extends GameComponent{
  String Title="";
  
  TextBox(){
    
  }
  
  TextBox(String s){
    Title=s;
  }
  
  void setTitle(String s){
    Title=s;
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
  
  void display(){
    super.display();
  }
  
  void setAddHP(float d){
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
  
  void display(){
    super.display();
  }
  
  void setAddHP(float d){
    addHP=d;
  }
}

class TextButton extends ButtonItem{
  
  TextButton(){
    
  }
  
  TextButton(String s){
    super(s);
  }
  
  void display(){
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
  
  void update(){
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
  
  void display(){
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
  
  void update(){
    super.update();
  }
  
  TextButton setText(String s){
    return super.setText(s);
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
  
  void display(){
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
    blendMode(ADD);
  }
  
  void update(){
    super.update();
  }
  
  TextButton setText(String s){
    return super.setText(s);
  }
}

class Menu extends ButtonItem{
  
  Menu(){
    
  }
  
  
}

class ComponentSet{
  ArrayList<GameComponent>conponents=new ArrayList<GameComponent>();
  boolean keyMove=true;
  boolean Focus=true;
  int subSelectButton=-0xFFFFFF;
  int pSelectedIndex=0;
  int selectedIndex=0;
  int type=0;
  
  static final int Down=0;
  static final int Up=1;
  static final int Right=2;
  static final int Left=3;
  
  ComponentSet(){
    
  }
  
  void add(GameComponent val){
    conponents.add(val);
    if(conponents.size()==1){
      if(Focus){
        val.requestFocus();
      }else{
        val.removeFocus();
      }
    }
  }
  
  void addAll(GameComponent... val){
    for(GameComponent c:val){
      add(c);
    }
  }
  
  void remove(GameComponent val){
    conponents.remove(val);
  }
  
  void removeAll(){
    conponents.clear();
  }
  
  void removeFocus(){
    Focus=false;
    if(conponents.size()>0){
      for(GameComponent c:conponents){
        c.removeFocus();
      }
      conponents.get(selectedIndex).Fe.lostFocus();
    }
  }
  
  void requestFocus(){
    Focus=true;
    if(conponents.size()>0){
      conponents.get(selectedIndex).requestFocus();
      conponents.get(selectedIndex).Fe.getFocus();
    }
  }
  
  void display(){
    for(GameComponent c:conponents){
      c.display();
    }
  }
  
  void update(){
    for(GameComponent c:conponents){
      c.update();
      if(c.FocusEvent){
        for(GameComponent C:conponents){
          C.removeFocus();
        }
        c.requestFocus();
      }
      if(c.focus)selectedIndex=conponents.indexOf(c);
    }
    keyEvent();
    if(pSelectedIndex!=selectedIndex){
      conponents.get(pSelectedIndex).Fe.lostFocus();
      conponents.get(selectedIndex).Fe.getFocus();
    }
    pSelectedIndex=selectedIndex;
  }
  
  void setSubSelectButton(int b){
    subSelectButton=b;
  }
  
  boolean onMouse(){
    for(GameComponent c:conponents){
      if(c.pos.x<=mouseX&&mouseX<=c.pos.x+c.dist.x&&c.pos.y<=mouseY&&mouseY<=c.pos.y+c.dist.y)return true;
    }
    return false;
  }
  
  void keyEvent(){
    if(keyPress&!conponents.get(selectedIndex).keyMove){
      if(!onMouse()){
        if(type==0|type==1){
          switch(nowPressedKeyCode){
            case DOWN:if(type==0)addSelect();else subSelect();break;
            case UP:if(type==0)subSelect();else addSelect();break;
          }
        }else if(type==2|type==3){
          switch(nowPressedKeyCode){
            case RIGHT:break;
            case LEFT:break;
          }
        }
      }
      if(nowPressedKeyCode==ENTER|keyCode==subSelectButton){
        conponents.get(selectedIndex).executeEvent();
      }
    }
  }
  
  void addSelect(){
    for(GameComponent c:conponents){
      c.removeFocus();
    }
    selectedIndex=selectedIndex>=conponents.size()-1?0:selectedIndex+1;
    conponents.get(selectedIndex).requestFocus();
  }
  
  void subSelect(){
    for(GameComponent c:conponents){
      c.removeFocus();
    }
    selectedIndex=selectedIndex<=0?conponents.size()-1:selectedIndex-1;
    conponents.get(selectedIndex).requestFocus();
  }
  
  GameComponent getSelected(){
    return conponents.get(selectedIndex);
  }
}

class Layout{
  PVector pos;
  PVector dist;
  PVector nextPos;
  int size=0;
  
  Layout(){
    pos=new PVector(0,0);
    dist=new PVector(0,0);
    nextPos=new PVector(0,0);
  }
  
  Layout(float x,float y,float dx,float dy){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    nextPos=new PVector(x,y);
  }
  
  void setPos(PVector p){
    pos=p;
    nextPos=pos.copy();
  }
  
  void setXdist(float x){
    dist.x=x;
  }
  
  void setYdist(float y){
    dist.y=y;
  }
  
  void alignment(GameComponent c){
    c.setBounds(nextPos.x,nextPos.y,c.dist.x,c.dist.y);
    ++size;
    nextPos=pos.copy().add(dist.mult(size));
  }
  
  void alignment(GameComponent[] c){
    for(int i=0;i<c.length;i++){
      c[i].setBounds(nextPos.x,nextPos.y,c[i].dist.x,c[i].dist.y);
      ++size;
      nextPos=pos.copy().add(dist.mult(size));
    }
  }
}

class ComponentSetLayer{
  HashMap<String,Layer>Layers;
  HashMap<String,Line<String,String>>Lines;
  HashMap<String,String>Parents;
  String nowLayer=null;
  String nowParent=null;
  int selectNumber=0;
  int showType=0;
  
  static final int ALL=0;
  static final int SELECT=1;
  static final int MIN=2;
  static final int MAX=3;
  
  ComponentSetLayer(){
    Layers=new HashMap<String,Layer>();
    Lines=new HashMap<String,Line<String,String>>();
    Parents=new HashMap<String,String>();
  }
  
  void addLayer(String name,ComponentSet... c){
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
  
  void addContent(String name,ComponentSet... c){
    Layers.get(name).addComponent(c);
  }
  
  void addChild(String parent,String name,ComponentSet... c){
    if(Lines.containsKey(parent)&!Layers.containsKey(name)){
      Layers.put(name,new Layer(Layers.get(parent).getDepth()+1,c));
      Lines.get(parent).addChild(name);
      Lines.put(name,new Line<String,String>(name));
      Parents.put(name,parent);
      addContent(name,c);
      for(ComponentSet C:c){
        C.removeFocus();
      }
    }
  }
  
  void addSubChild(String parent,String name,ComponentSet... c){
    if(Lines.containsKey(parent)&!Layers.containsKey(name)){
      Layers.put(name,new Layer(Layers.get(parent).getDepth()+1,true,c));
      Lines.get(parent).addChild(name);
      Lines.put(name,new Line<String,String>(name));
      Parents.put(name,parent);
      addContent(name,c);
      for(ComponentSet C:c){
        C.removeFocus();
      }
    }
  }
  
  void toChild(String name){
    if(Lines.get(nowLayer).getChild().contains(name)){
      Layers.get(nowLayer).getSelectedComponent().removeFocus();
      nowLayer=name;
      nowParent=Layers.get(name).isSub()?nowParent:nowLayer;
      Layers.get(nowLayer).getSelectedComponent().requestFocus();
    }else{
      return;
    }
  }
  
  void toParent(){
    if(nowLayer.equals(nowParent)){
      if(Layers.get(nowLayer).getSelectedComponent().getSelected().getDepth()>0){
        Layers.get(nowLayer).getSelectedComponent().getSelected().back();
        return;
      }
      Layers.get(nowLayer).getSelectedComponent().removeFocus();
      nowLayer=Parents.get(nowLayer);
      nowParent=new String(nowLayer);
      Layers.get(nowLayer).getSelectedComponent().requestFocus();
    }else{
      if(Layers.get(nowLayer).getSelectedComponent().getSelected().getDepth()>0){
        Layers.get(nowLayer).getSelectedComponent().getSelected().back();
        return;
      }
      Layers.get(nowLayer).getSelectedComponent().removeFocus();
      nowLayer=Parents.get(nowLayer);
      Layers.get(nowLayer).getSelectedComponent().requestFocus();
    }
  }
  
  int getDepth(){
    return Layers.get(nowLayer).getDepth();
  }
  
  void display(){
    if(nowLayer==null){
      return;
    }else{
      int count=0;
      for(ComponentSet c:Layers.get(nowParent).getComponents()){
        switch(showType){
          case 0:c.display();break;
          case 1:if(count==selectNumber)c.display();break;
          case 2:if(count<=selectNumber)c.display();break;
          case 3:if(count>=selectNumber)c.display();break;
        }
        ++count;
      }
      displaySub(nowParent);
    }
  }
  
  void update(){
    Layers.get(nowLayer).update();
  }
  
  void setIndex(int i){
    Layers.get(nowLayer).setIndex(i);
  }
  
  void toLayer(String name){
    if(Lines.get(nowLayer).getChild().contains(name)){
      nowLayer=name;
    }else{
      return;
    }
  }
  
  String getLayerName(){
    return new String(nowLayer);
  }
  
  private void displaySub(String n){
    if(Lines.containsKey(n)){
      for(String s:Lines.get(n).getChild()){
        if(Layers.get(s).isSub()){
          for(ComponentSet c:Layers.get(s).getComponents()){
            c.display();
          }
          displaySub(s);
        }
      }
    }
  }
  
  protected final class Line<P,C>{
    private P parent;
    private ArrayList<C> child;
    
    Line(P parent,C... child){
      this.parent=parent;
      this.child=new ArrayList<C>();
      this.child.addAll(Arrays.asList(child));
    }
    
    void addChild(C... child){
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
    
    void display(){
      for(ComponentSet c:Components){
        c.display();
      }
    }
    
    void update(){
      Components.get(index).update();
    }
    
    void addComponent(ComponentSet... c){
      Components.addAll(Arrays.asList(c));
    }
    
    void setIndex(int i){
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

interface FocusEvent{
  void getFocus();
  
  void lostFocus();
}

interface SelectEvent{
  void selectEvent();
}

interface ChangeEvent{
  void changeEvent();
}

interface KeyEvent{
  void keyEvent(int Key);
}

interface ItemSelect{
  void ItemSelect(Item i);
}

interface ListDisp{
  void display(PVector pos,PVector dist);
}
