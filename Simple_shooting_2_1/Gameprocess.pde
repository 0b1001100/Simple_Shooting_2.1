class GameProcess{
  ComponentSet UpgradeSet;
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  float UItime=0;
  boolean animation=false;
  boolean upgrade=false;
  boolean pause=false;
  boolean done=false;
  String menu="Main";
  int x=16;
  int y=9;
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    UpgradeSet=new ComponentSet();
    stage=new Stage();
    mainMenu=new menuManage();
    player=new Myself();
    stage.addProcess("1.1",new TimeSchedule(120,s->{s.addSpown(EnemySpown.Triangle,0,new Turret());s.autoSpown(false,0.02,new Turret());}),
                           new TimeSchedule(420,s->{s.addSpown(EnemySpown.Pentagon,0,new Turret());}),
                           new TimeSchedule(660,s->{s.addSpown(EnemySpown.Rect,0,new Turret());}),
                           new TimeSchedule(1080,s->{s.addSpown(EnemySpown.Octagon,0,new Turret());}),
                           new TimeSchedule(1200,s->{s.autoSpown(false,0.02,new White());}),
                           new TimeSchedule(1300,s->{s.addSpown(EnemySpown.Octagon,0,new Plus());}),
                           new TimeSchedule(1500,s->{s.addSpown(10,2,0,new White());}),
                           new TimeSchedule(1700,s->{s.addSpown(30,3,0,new Turret());}),
                           new TimeSchedule(1900,s->{s.addSpown(15,2,0,new White());}),
                           new TimeSchedule(2100,s->{s.addSpown(40,3,0,new Turret());}),
                           new TimeSchedule(2400,s->{s.autoSpown(false,0.03,new Plus(),new Turret());}),
                           new TimeSchedule(2600,s->{s.addSpown(20,3,0,new Plus());}),
                           new TimeSchedule(2900,s->{s.addSpown(30,3,0,new Plus());}),
                           new TimeSchedule(3200,s->{s.addSpown(20,3,0,new Normal());}),
                           new TimeSchedule(3600,s->{s.addSpown(30,3,0,new Normal());s.autoSpown(false,0.03,new Plus(),new White(),new Normal());}),
                           new TimeSchedule(3700,s->{s.endSchedule=true;}));
  }
  
  void process(){
    if(player.levelup)pause=true;
    if(player.isDead){
      addExplosion(player,250);
      pause=true;
    }
    done=false;
    background(0);
    drawShape();
    if(!pause){
      updateShape();
    }else{
      pauseProcess();
    }
    keyProcess();
    done=true;
  }

  void updateShape(){
    try{
      particleFuture=exec.submit(particleTask);
      enemyFuture=exec.submit(enemyTask);
      bulletFuture=exec.submit(bulletTask);
    }catch(Exception e){
    }
    stage.update();
  }
  
  void drawShape(){
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    stage.display();
    player.display();
    for(Exp e:Exps){
      e.display();
    }
    for(Enemy e:Enemies){
      e.display();
    }
    for(Bullet b:eneBullets){
      b.display();
    }
    for(Bullet b:Bullets){
      b.display();
    }
    for(Particle p:Particles){
        p.display();
    }
    displayHUD();
    popMatrix();
  }
  
  void displayHUD(){
    pushMatrix();
    resetMatrix();
    rectMode(CORNER);
    noFill();
    stroke(200);
    strokeWeight(1);
    rect(200,30,width-230,30);
    fill(255);
    noStroke();
    rect(202.5,32.5,(width-225)*player.exp/(10+(player.Level-1)*10),25);
    textSize(20);
    textAlign(RIGHT);
    text("LEVEL "+player.Level,190,52);
    popMatrix();
  }
  
  void pauseProcess(){
    if(player.levelup){
      upgrade=true;
      UpgradeSet.removeAll();
      MenuButton first=(MenuButton)new MenuButton("Green").setBounds(width/2-150,height/2-45,300,30);
      first.addListener(()->{
        player.weapons.get(0).bulletNumber++;
        pause=false;
        upgrade=false;
      });
      MenuButton second=(MenuButton)new MenuButton("Red").setBounds(width/2-150,height/2,300,30);
      second.addListener(()->{
        pause=false;
        upgrade=false;
      });
      MenuButton third=(MenuButton)new MenuButton("Blue").setBounds(width/2-150,height/2+45,300,30);
      third.addListener(()->{
        player.weapons.get(2).bulletNumber++;
        pause=false;
        upgrade=false;
      });
      UpgradeSet.addAll(first,second,third);
      player.levelup=false;
    }
    if(upgrade){
      fill(240);
      noStroke();
      rectMode(CENTER);
      rect(width/2,height/2,400,600);
      UpgradeSet.display();
      UpgradeSet.update();
    }
    if(player.isDead){
      
    }
  }
  
  void switchMenu(){
    if((key=='c'|keyCode==CONTROL)&menu.equals("Main")&!animation){
      mainMenu.init();
      menu="Menu";
      UItime=0f;
      animation=true;
    }else
    if((key=='x'|keyCode==SHIFT|keyCode==LEFT)&menu.equals("Menu")&!animation){
      if(mainMenu.layer.getDepth()>0){
        mainMenu.back();
        return;
      }
      menu="Main";
      UItime=30f;
      animation=true;
    }
    if(!animation)return;
    float normUItime=UItime/30;
    background(menuColor.getRed()*normUItime,menuColor.getGreen()*normUItime,
               menuColor.getBlue()*normUItime);
    blendMode(BLEND);
    float Width=width/x;
    float Height=height/y;
    for(int i=0;i<y;i++){//y
      for(int j=0;j<x;j++){//x
        fill(toRGB(menuColor));
        noStroke();
        rectMode(CENTER);
        float scale=min(max(UItime*(y/9)-(j+i),0),1);
        rect(Width*j+Width/2,Height*i+Height/2,Width*scale,Height*scale);
      }
    }
    drawMenu();
    updateMenu();
    menuShading();
    switch(menu){
      case "Main":UItime-=vectorMagnification;if(UItime<0){animation=false;mainMenu.dispose();}break;
      case "Menu":UItime+=vectorMagnification;if(UItime>30)animation=false;break;
    }
  }
  
  void drawMenu(){
    mainMenu.display();
  }
  
  void updateMenu(){
    mainMenu.update();
  }
  
  void keyProcess(){
    if(keyPress&(key=='c'|keyCode==CONTROL|key=='x'|keyCode==SHIFT|keyCode==LEFT))switchMenu();
  }
  
  void menuShading(){
    menuShader.set("time",UItime);
    menuShader.set("xy",(float)x,(float)y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",(float)menuColor.getRed()/255,(float)menuColor.getGreen()/255,(float)menuColor.getBlue()/255,1.0);
    menuShader.set("tex",g);
    filter(menuShader);
  }
  
  class menuManage{
    ComponentSetLayer layer;
    HashMap<String,ComponentSet>componentMap=new HashMap<String,ComponentSet>();
    ComponentSet main;
    boolean pStack=false;
    boolean first=true;
    
    menuManage(){
    }
    
    void init(){
      layer=new ComponentSetLayer();
      main=null;
      initMain();
      if(first){
        first=false;
      }
    }
    
    void initMain(){
      main=new ComponentSet();
      layer.addLayer("Main",main);
      MenuButton equip=new MenuButton("装備");
      equip.setBounds(100,120,120,25);
      equip.addListener(()->{
        layer.toChild("equ");
      });
      MenuButton item=new MenuButton("アイテム");
      item.setBounds(100,160,120,25);
      item.addListener(()->{
        layer.toChild("Item");
      });
      MenuButton archive=new MenuButton("アーカイブ");
      archive.setBounds(100,200,120,25);
      archive.addListener(()->{
        layer.toChild("arc");
      });
      MenuButton setting=new MenuButton("設定");
      setting.setBounds(100,240,120,25);
      setting.addListener(()->{
        layer.toChild("conf");
      });
      main.add(equip);
      main.add(item);
      main.add(archive);
      main.add(setting);
      main.setSubSelectButton(RIGHT);
      componentMap.put("main",main);
    }
    
    void display(){
      layer.display();
    }
    
    void update(){
      boolean Stack=false;
      layer.update();
      pStack=Stack;
    }
    
    void dispose(){
      main=null;
    }
    
    boolean isMain(){
      return layer.getLayerName().equals("Main");
    }
    
    void back(){
      layer.toParent();
    }
  }
}
