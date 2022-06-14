class GameProcess{
  ComponentSet UpgradeSet;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  PShader backgroundShader;
  float UItime=0;
  boolean gameOver=false;
  boolean animation=false;
  boolean upgrade=false;
  boolean pause=false;
  boolean done=false;
  boolean menu=false;
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
    if(menu){
      rectMode(CORNER);
      noStroke();
      fill(0,100);
      pushMatrix();
      resetMatrix();
      rect(0,0,width,height);
      popMatrix();
    }
    if(!(upgrade||menu)){
      stage.update();
      UpdateProcess.clear();
      byte ThreadNumber=(byte)min(Entities.size(),(int)updateNumber);
      float block=Entities.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber;b++){
        UpdateProcess.add(new EntityProcess(round(block*b),round(block*(b+1)),b));
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
      HeapEntity.forEach(l->{
        Entities.addAll(l);
        l.clear();
      });
      Entities.addAll(NextEntities);
      NextEntities.clear();
      HeapEntityX.forEach(m->{
        m.forEach((k,v)->{
          EntityX.put(k,v);
        });
        m.clear();
      });
      SortedX=EntityX.keySet().toArray(new Float[EntityX.size()]);
      Arrays.parallelSort(SortedX);
      HeapEntityDataX.forEach(m->{
        m.forEach((k,v)->{
          EntityDataX.put(k,v);
        });
        m.clear();
      });
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
  
   public void keyProcess(){
    if(!upgrade&&keyPress&&(key=='c'|keyCode==CONTROL)){
      menu=!menu;
      pause=menu;
    }
  }
}
