class GameProcess{
  ComponentSet UpgradeSet;
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  PShader backgroundShader;
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
  
   public void setup(){
    init();
  }
  
   public void init(){
    Entities=new ArrayList<Entity>();
    UpgradeSet=new ComponentSet();
    mainMenu=new menuManage();
    player=new Myself();
    stage=new Stage();
    backgroundShader=loadShader(ShaderPath+"2Dnoise.glsl");
  }
  
   public void process(){
    if(player.levelup)pause=true;
    if(player.isDead){
      pause=true;
    }
    done=false;
    background(0);
    backgroundShader.set("offset",player.pos.x,-player.pos.y);
    filter(backgroundShader);
    drawShape();
    if(gameOver){
      scene=0;
      done=true;
      return;
    }
    Debug();
    updateShape();
    keyProcess();
    done=true;
  }

  public void updateShape(){
    if(!pause){
      for(int i=0;i<nearEnemy.size();i++){
        Enemy e=nearEnemy.get(i);
        if(e!=null&&(e.isDead||!e.inScreen)){
          nearEnemy.remove(e);
          i--;
        }
      }
      Collections.sort(nearEnemy,new Comparator<Enemy>(){
        @Override
        public int compare(Enemy e1,Enemy e2) {
          return Float.compare(e1.playerDistsq,e2.playerDistsq);
        }
      });
      player.update();
    }else{
      EnemyTime=BulletTime=ParticleTime=0;
      if(player.levelup){
        upgrade=true;
        int num=3;
        Item[]list=new Item[num];
        ItemTable copy=playerTable.clone();
        for(int i=0;i<num;i++){
          list[i]=copy.getRandom();
          copy.removeTable(list[i].getName());
        }
        UpgradeSet.removeAll();
        MenuButton[]buttons=new MenuButton[num];
        for(int i=0;i<num;i++){
          buttons[i]=(MenuButton)new MenuButton(list[i].getName()).setBounds(width/2-150,height/2-60+45*i,300,30);
          Item item=list[i];
          buttons[i].addListener(()->{
            if(player.subWeapons.contains(item.getWeapon())){
              item.getWeapon().upgrade(item.getUpgradeArray(),item.getWeapon().level+1);
            }else{
              player.subWeapons.add(item.getWeapon());
            }
            pause=false;
            upgrade=false;
          });
        }
        UpgradeSet.addAll(buttons);
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
        deadTimer+=0.016f*vectorMagnification;
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
        }
        player.update();
      }
    }
    if(!upgrade){
      stage.update();
      UpdateProcess.clear();
      byte ThreadNumber=(byte)min(Entities.size(),(int)updateNumber);
      float block=Entities.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber;b++){
        UpdateProcess.add(new EntityProcess(round(block*b),round(block*(b+1))));
      }
      try{
        for(EntityProcess e:UpdateProcess){
          entityFuture.add(exec.submit(e));
        }
      }catch(Exception e){println(e);
      }
      for(Future<?> f:entityFuture){
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
      Entities.clear();
      Entities.addAll(NextEntities);
      NextEntities.clear();
    }
  }
  
  public void drawShape(){
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    stage.display();
    for(Entity e:Entities){
      e.display();
    }
    if(!player.isDead)player.display();
    for(GravityBullet G:LensData){
      GravityLens.set("texture",g);
      GravityLens.set("center",G.screen.x,G.screen.y);
      GravityLens.set("resolution",width,height);
      GravityLens.set("g",G.scale*0.1);
      applyShader(GravityLens);
    }
    LensData.clear();
    displayHUD();
    popMatrix();
  }
  
  public void displayHUD(){
    pushMatrix();
    resetMatrix();
    rectMode(CORNER);
    noFill();
    stroke(200);
    strokeWeight(1);
    rect(200,30,width-230,30);
    fill(255);
    noStroke();
    rect(202.5f,32.5f,(width-225)*player.exp/player.nextLevel,25);
    textSize(20);
    textAlign(RIGHT);
    text("LEVEL "+player.Level,190,52);
    popMatrix();
  }
  
   public void switchMenu(){
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
  
   public void drawMenu(){
    mainMenu.display();
  }
  
   public void updateMenu(){
    mainMenu.update();
  }
  
   public void keyProcess(){
    if(keyPress&(key=='c'|keyCode==CONTROL|key=='x'|keyCode==SHIFT|keyCode==LEFT))switchMenu();
  }
  
   public void menuShading(){
    menuShader.set("time",UItime);
    menuShader.set("xy",(float)x,(float)y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",(float)menuColor.getRed()/255,(float)menuColor.getGreen()/255,(float)menuColor.getBlue()/255,1.0f);
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
    
     public void init(){
      layer=new ComponentSetLayer();
      main=null;
      initMain();
      if(first){
        first=false;
      }
    }
    
     public void initMain(){
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
    
     public void display(){
      layer.display();
    }
    
     public void update(){
      boolean Stack=false;
      layer.update();
      pStack=Stack;
    }
    
     public void dispose(){
      main=null;
    }
    
     public boolean isMain(){
      return layer.getLayerName().equals("Main");
    }
    
     public void back(){
      layer.toParent();
    }
  }
}
