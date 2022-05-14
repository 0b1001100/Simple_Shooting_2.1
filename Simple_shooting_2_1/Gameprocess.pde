class GameProcess{
  ComponentSet UpgradeSet;
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  float UItime=0;
  boolean gameOver=false;
  boolean animation=false;
  boolean upgrade=false;
  boolean pause=false;
  boolean done=false;
  String menu="Main";
  float deadTimer=0;
  int x=16;
  int y=9;
  
  final float maxDeadTime=3;
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    init();
  }
  
  void init(){
    Particles=Collections.synchronizedList(new ArrayList<Particle>());
    eneBullets=Collections.synchronizedList(new ArrayList<Bullet>());
    Bullets=Collections.synchronizedList(new ArrayList<Bullet>());
    Enemies=Collections.synchronizedList(new ArrayList<Enemy>());
    Exps=Collections.synchronizedList(new ArrayList<Exp>());
    ParticleHeap=Collections.synchronizedList(new ArrayList<Particle>());
    eneBulletHeap=Collections.synchronizedList(new ArrayList<Bullet>());
    BulletHeap=Collections.synchronizedList(new ArrayList<Bullet>());
    EnemyHeap=Collections.synchronizedList(new ArrayList<Enemy>());
    ExpHeap=Collections.synchronizedList(new ArrayList<Exp>());
    UpgradeSet=new ComponentSet();
    mainMenu=new menuManage();
    player=new Myself();
    stage=new Stage();
  }
  
  void process(){
    if(player.levelup)pause=true;
    if(player.isDead){
      pause=true;
    }
    done=false;
    background(0);
    drawShape();
    if(gameOver){
      scene=0;
      done=true;
      return;
    }
    Debug();
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
    for(Particle p:Particles){
        p.display();
    }
    for(Exp e:Exps){
      e.display();
    }
    Lighting.set("resolution", width, height);
    for(int i=0;i<1;i++){
      Lighting.set("texture",g);
      filter(Lighting);
    }
    for(Bullet b:eneBullets){
      b.display();
    }
    for(Bullet b:Bullets){
      b.display();
    }
    if(!player.isDead)player.display();
    for(Enemy e:Enemies){
      e.display();
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
    rect(202.5,32.5,(width-225)*player.exp/player.nextLevel,25);
    textSize(20);
    textAlign(RIGHT);
    text("LEVEL "+player.Level,190,52);
    popMatrix();
  }
  
  void pauseProcess(){
    EnemyTime=BulletTime=ParticleTime=0;
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
      deadTimer+=0.016*vectorMagnification;
      if(deadTimer>maxDeadTime){
        player.remain--;
        if(player.remain<=0){
          gameOver=true;
          pause=false;
          return;
        }
        player.isDead=player.pDead=false;
        player.invincibleTime=3;
        player.HP.reset();
        pause=false;
        deadTimer=0;
        return;
      }
      try{
        particleFuture=exec.submit(particleTask);
        enemyFuture=exec.submit(enemyTask);
        bulletFuture=exec.submit(bulletTask);
      }catch(Exception e){
      }
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
