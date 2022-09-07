class GameProcess{
  HashMap<String,String>EventSet;
  ComponentSet HUDSet;
  ComponentSet UpgradeSet;
  WallEntity[] wall=null;
  Color menuColor=new Color(230,230,230);
  PVector FieldSize=null;
  PFont font_20;
  PFont font_15;
  PShader menuShader;
  PShader backgroundShader;
  float UItime=0;
  boolean gameOver=false;
  boolean animation=false;
  boolean upgrade=false;
  boolean done=false;
  boolean menu=false;
  float deadTimer=0;
  int ssbo;
  int[] vbo=new int[1];
  int x=16;
  int y=9;
  
  final float maxDeadTime=3;
  
  GameProcess(){
    setup();
  }
  
   public void setup(){
    init();
    font_20=createFont("SansSerif.plain",20);
    font_15=createFont("SansSerif.plain",15);
  }
  
   public void init(){
     FieldSize=null;
     EventSet=new HashMap<String,String>();
     HUDSet=new ComponentSet();
     UpgradeSet=new ComponentSet();
     stageLayer=new ComponentSetLayer();
     stageLayer.addLayer("root",UpgradeSet);
     stageLayer.addSubChild("root","HUD",HUDSet);
     initStatus();
     Entities=new ArrayList<Entity>();
     nearEnemy.clear();
     player=new Myself();
     stage=new Stage();
     StageFlag.clear();
     pause=false;
     sumLevel=0;
     addtionalProjectile=0;
     addtionalScale=1;
     addtionalPower=1;
     addtionalSpeed=1;
     addtionalDuration=1;
     reductionCoolTime=1;
     backgroundShader=loadShader(ShaderPath+"2Dnoise.glsl");
     playerTable.clear();
     Arrays.asList(conf.getJSONArray("Weapons").getStringArray()).forEach(s->{
       playerTable.addTable(masterTable.get(s),masterTable.get(s).getWeight());
     });
     playerTable.getAll().forEach(i->{
       i.reset();
       playerTable.addTable(i,i.weight);
     });
     player.subWeapons.clear();
     switch(StageName){
       case "Tutorial":initTutorial();break;
       case "Stage1":player.subWeapons.add(masterTable.get("Laser").getWeapon());
                     player.subWeapons.add(masterTable.get("PlasmaField").getWeapon());
                     break;
       case "Stage2":player.subWeapons.add(masterTable.get("Mirror").getWeapon());
                     player.subWeapons.add(masterTable.get("Reflector").getWeapon());break;
     }
  }
  
  private void initTutorial(){
    player.canMagnet=false;
    HUDText tu_upgrade=new HUDText(Language.getString("tu_upgrade"));
    tu_upgrade.setBounds(width*0.5f+200,height*0.5f-200,0,0);
    tu_upgrade.addWindowResizeEvent(()->{
      tu_upgrade.setBounds(width*0.5f+200,height*0.5f-200,0,0);
    });
    tu_upgrade.setProcess(()->{
      if(!upgrade){
        tu_upgrade.Dispose();
        tu_upgrade.setFlag(false);
      }
    });
    tu_upgrade.addDisposeListener(()->{
      stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+3,s->{if(!stageList.contains("Stage1"))stageList.addContent("Stage1");StageFlag.add("Clear_Tutorial");scene=3;}));
    });
    HUDText tu_exp=new HUDText(Language.getString("tu_exp"));
    tu_exp.setProcess(()->{
      if(player.levelup){
        tu_exp.Dispose();
        tu_exp.setFlag(false);
      }
    });
    tu_exp.addDisposeListener(()->{
      tu_upgrade.startDisplay();
    });
    HUDText tu_attack=new HUDText(Language.getString("tu_attack"));
    tu_attack.setProcess(()->{
      if(tu_attack.target.isDead){
        stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_attack.endDisplay()));
        tu_attack.setFlag(false);
      }
    });
    tu_attack.addDisposeListener(()->{
      tu_exp.startDisplay();
      stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+1,s->player.canMagnet=true));
    });
    HUDText tu_shot_2=new HUDText(Language.getString("tu_shot_2"));
    tu_shot_2.setTarget(player);
    tu_shot_2.setProcess(()->{
      if(mousePressed&&mouseButton==LEFT){
        stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_shot_2.endDisplay()));
        tu_shot_2.setFlag(false);
      }
    });
    tu_shot_2.addDisposeListener(()->{
      stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->{
        DummyEnemy e=new DummyEnemy();
        tu_attack.setTarget(e);
        if(dist(new PVector(0,0),player.pos)<100){
          stage.addSpown(player.pos.copy().add(0,200),e);
        }else{
          stage.addSpown(new PVector(0,0),e);
        }
        stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+3,s2->{tu_attack.startDisplay();}));
      }));
    });
    HUDText tu_shot=new HUDText(Language.getString("tu_shot"));
    tu_shot.setTarget(player);
    tu_shot.setProcess(()->{
      if(mousePressed&&mouseButton==LEFT){
        stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_shot.endDisplay()));
        tu_shot.setFlag(false);
      }
    });
    tu_shot.addDisposeListener(()->{
      stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_shot_2.startDisplay()));
    });
    HUDText tu_move=new HUDText(Language.getString("tu_move"));
    tu_move.setTarget(player);
    tu_move.setProcess(()->{
      if(player.Speed>=3){
        stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_move.endDisplay()));
        tu_move.setFlag(false);
      }
    });
    tu_move.addDisposeListener(()->{
      stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_shot.startDisplay()));
    });
    stage.addProcess("Tutorial",new TimeSchedule(2,s->tu_move.startDisplay()));
    HUDSet.addAll(tu_move,tu_shot,tu_shot_2,tu_attack,tu_exp,tu_upgrade);
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
      StageFlag.add("Game_Over");
      scene=3;
      done=true;
      return;
    }
    Debug();
    updateShape();
    keyProcess();
    EventProcess();
    EventSet.clear();
    done=true;
  }

  public void updateShape(){
    if(!pause){
      EntitySet=new HashSet(Entities);
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
      applyStaus();
      player.update();
      stage.update();
    }else{
      EntityTime=0;
      if(player.levelup||upgrade){
        if(player.levelupNumber>0){
          upgrade();
        }
      }
      if(player.isDead&&!menu){
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
          if(StageName.equals("Tutorial")){
            player.pos=new PVector(0,0);
            player.rotate=0;
          }
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
      byte ThreadNumber=(byte)min(Entities.size(),(int)updateNumber);
      float block=Entities.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber;b++){
        UpdateProcess.get(b).setData(round(block*b),round(block*(b+1)),b);
      }
      try{
        entityFuture.clear();
        for(int i=0;i<ThreadNumber;i++){
          entityFuture.add(exec.submit(UpdateProcess.get(i)));
        }
      }catch(Exception e){println(e);
      }
      if(doGPGPU){
      //getPixelData();
      //updatePixels();
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
      HeapEntityDataX.forEach(m->{
        m.forEach(d->{
          EntityDataX.add(d);
        });
        m.clear();
      });
      SortedDataX=EntityDataX.toArray(new AABBData[0]);
      Arrays.parallelSort(SortedDataX,new Comparator<AABBData>(){
        @Override
        public int compare(AABBData d1, AABBData d2) {
          return Float.valueOf(d1.getPos()).compareTo(d2.getPos());
        }
      });
    }
  }
  
  public void drawShape(){
    long pTime=System.nanoTime();
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    stage.display();
    if(doGPGPU){
      loadPixels();
      byte ThreadNumber=(byte)min(Entities.size(),(int)drawNumber);
      float block=Entities.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber-1;b++){
        DrawProcess.get(b).setData(round(block*b),round(block*(b+1)));
      }
      try{
        drawFuture.clear();
        for(int i=0;i<ThreadNumber-1;i++){
          drawFuture.add(exec.submit(DrawProcess.get(i)));
        }
      }catch(Exception e){println(e);
      }
      for(int i=round(block*(ThreadNumber-1));i<round(block*ThreadNumber);i++){
        Entities.get(i).display(g);
      }
      for(Future<PGraphics> f:drawFuture){
        try{
          image(f.get(),-scroll.x,-scroll.y);
        }
        catch(ConcurrentModificationException e) {
          e.printStackTrace();
        }
        catch(InterruptedException|ExecutionException F) {println(F);F.printStackTrace();
        }
        catch(NullPointerException g) {
        }
      }
    }else{
      Entities.forEach(e->{e.display(g);});
    }
    if(!player.isDead)player.display(g);
    if(LensData.size()>0){
      loadPixels();
      float[] centers=new float[20];
      float[] rads=new float[10];
      for(int i=0;i<10;i++){
        if(i<LensData.size()){
          centers[2*i]=LensData.get(i).screen.x;
          centers[2*i+1]=LensData.get(i).screen.y;
          rads[i]=LensData.get(i).scale*0.1f;
        }else{
          centers[2*i]=0;
          centers[2*i+1]=0;
          rads[i]=1;
        }
      }
      GravityLens.set("center",centers,2);
      GravityLens.set("g",rads);
      GravityLens.set("len",LensData.size());
      GravityLens.set("texture",g);
      GravityLens.set("resolution",width,height);long l=System.nanoTime();
      applyShader(GravityLens);println(System.nanoTime()-l);
    }
    LensData.clear();
    displayHUD();
    popMatrix();
    DrawTime=(System.nanoTime()-pTime)/1000000f;
  }
  
  public void displayHUD(){
    push();
    resetMatrix();
    if(upgrade){
      fill(240);
      noStroke();
      rectMode(CENTER);
      rect(width/2,height/2,400,600);
    }
    stageLayer.display();
    stageLayer.update();
    rectMode(CORNER);
    noFill();
    stroke(200);
    strokeWeight(1);
    rect(200,30,width-230,30);
    fill(255);
    noStroke();
    rect(202.5f,32.5f,(width-225)*player.exp/player.nextLevel,25);
    textSize(20);
    textFont(font_20);
    textAlign(RIGHT);
    text("LEVEL "+player.Level,190,52);
    textFont(font_15);
    textAlign(CENTER);
    text("Time "+nf(floor(stage.time/3600),2,0)+":"+nf(floor((stage.time/60)%60),2,0),width*0.5f,78);
    pop();
  }
  
   public void keyProcess(){
    if(keyPress&&keyCode==CONTROL){
      menu=!menu;
      if(!upgrade)pause=menu;
    }
  }
  
   public void EventProcess(){
    if(EventSet.containsKey("end_upgrade")){
      UpgradeSet.removeAll();
      if(player.levelupNumber<1){
        pause=false;
      }else{
        player.levelup=true;
      }
    }
    if(EventSet.containsKey("getNextWeapon")){
      String[] src=EventSet.get("getNextWeapon").split("_");
      for(String s:src){
        JSONArray a=nextDataMap.get(s);
        for(int i=0;i<a.size();i++){
          if(a.getJSONObject(i).getString("type").equals("use")){
            player.subWeapons.remove(masterTable.get(a.getJSONObject(i).getString("name")).w);
          }
        }
        playerTable.addTable(playerTable.get(s),playerTable.get(s).weight);
      }
    }
    if(EventSet.containsKey("addNextWeapon")){
      String[] src=EventSet.get("addNextWeapon").split("_");
      for(String s:src){
        Item i=masterTable.get(s);
        playerTable.addTable(i,i.weight);
      }
    }
  }
  
   public void upgrade(){
    if(player.levelup){
      EventSet.put("start_upgrade","");
      upgrade=true;
      int num=min(playerTable.probSize(),round(random(3,3.55)));
      Item[]list=new Item[num];
      ItemTable copy=playerTable.clone();
      for(int i=0;i<num;i++){
        list[i]=copy.getRandomWeapon();
        switch(i){
          case 0:if((sumLevel>=17&&0.5f>random(1))||list[i]==null)list[i]=copy.getRandomItem();break;
          case 1:if((sumLevel>=9&&0.5f>random(1))||list[i]==null)list[i]=copy.getRandomItem();break;
          case 2:if((sumLevel>=4&&0.5f>random(1))||list[i]==null)list[i]=copy.getRandomItem();break;
          case 3:if((sumLevel>=2&&0.4f>random(1))||list[i]==null)list[i]=copy.getRandomItem();break;
        }
        if(list[i]==null)list[i]=copy.getRandom();
        copy.removeTable(list[i].getName());
      }
      UpgradeSet.removeAll();
      MenuButton[]buttons=new MenuButton[num];
      for(int i=0;i<num;i++){
        buttons[i]=(MenuButton)(list[i].type.equals("next_weapon")?new MenuButton_B(list[i].getName()+"  Level"+(player.subWeapons.contains(list[i].getWeapon())?(list[i].level+1):1))
                   :new MenuButton(list[i].getName()+"  Level"+(player.subWeapons.contains(list[i].getWeapon())?(list[i].level+1):1))).setBounds(width/2-150,height/2-60+45*i,300,30);
        int[] lambdaI={i};
        buttons[i].addWindowResizeEvent(()->{
          buttons[lambdaI[0]].setBounds(width/2-150,height/2-60+45*lambdaI[0],300,30);
        });
        Item item=list[i];
        buttons[i].addListener(()->{
          if(player.subWeapons.contains(item.getWeapon())){
            ++item.level;
            item.update();
            ++sumLevel;
          }else if(item.getType().equals("weapon")){
            player.subWeapons.add(item.getWeapon());
            ++sumLevel;
          }else if(item.getType().equals("item")){
            player.subWeapons.add(item.getWeapon());
            item.getWeapon().update();
          }else if(item.getType().equals("next_weapon")){
            item.update();
            player.subWeapons.add(item.getWeapon());
          }
          applyStaus();
          --player.levelupNumber;
          playerTable.table.forEach((k,v)->{
            v.checkNext();
          });
          upgrade=false;
          EventSet.put("end_upgrade","");
        });
      }
      UpgradeSet.addAll(buttons);
      player.levelup=false;
    }
  }
  
   public void setWall(){
    if(FieldSize==null)return;
    if(wall==null){
      wall=new WallEntity[4];
      wall[0]=new WallEntity(FieldSize.copy().mult(-0.5f),new PVector(FieldSize.x,0));
      wall[1]=new WallEntity(new PVector(FieldSize.x*-0.5f,FieldSize.y*0.5f),new PVector(FieldSize.x,0));
      wall[2]=new WallEntity(new PVector(FieldSize.x*0.5f,FieldSize.y*-0.5f),new PVector(0,FieldSize.y));
      wall[3]=new WallEntity(FieldSize.copy().mult(-0.5f),new PVector(0,FieldSize.y));
      Entities.addAll(Arrays.asList(wall));
    }
  }
  
   public void commandProcess(java.util.List<Token>tokens){
    java.util.List<Token>ex_space_tokens=new ArrayList<Token>();
    tokens.forEach(t->{
      if(!t.getText().matches(" +"))ex_space_tokens.add(t);
    });
    switch(ex_space_tokens.get(0).getText()){
      case "time":command_time(ex_space_tokens);break;
      case "level":command_level(ex_space_tokens);break;
      case "give":command_give(ex_space_tokens);break;
      case "kill":command_kill(ex_space_tokens);break;
      case "function":command_function(ex_space_tokens);break;
      case "exit":command_exit();break;
    }
  }
  
   public void command_time(java.util.List<Token>tokens){
    stage.time=max(0,setParameter(stage.time,tokens.get(1).getText(),PApplet.parseFloat(tokens.get(2).getText())*60));
    stage.scheduleUpdate();
    stage.clearSpown();
  }
  
   public void command_level(java.util.List<Token>tokens){
    if(tokens.get(1).getText().equals("@p")){
      int targetLevel=(int)setParameter((float)player.Level,tokens.get(2).getText(),PApplet.parseFloat(tokens.get(3).getText()));
      if(player.Level<targetLevel){
        player.levelup=true;
        player.levelupNumber=targetLevel-player.Level;
        player.Level=targetLevel;
      }else{
        player.Level=targetLevel;
      }
      player.nextLevel=10+(player.Level-1)*10*ceil(player.Level/10f);
    }else{
      Item i=masterTable.get(tokens.get(1).getText().replace("\"",""));
      SubWeapon w=i.getWeapon();
      if(player.subWeapons.contains(w)){
        int targetLevel=(int)setParameter((float)i.level,tokens.get(2).getText(),PApplet.parseFloat(tokens.get(3).getText()));
        try{
          if(i.level<targetLevel){
            while(i.level<targetLevel){
              ++i.level;
              i.update();
              if(i.getType().equals("item"))w.update();
              ++sumLevel;
            }
          }else{
            i.reset();
            while(i.level<targetLevel){
              ++i.level;
              i.update();
              if(i.getType().equals("item"))w.update();
              ++sumLevel;
            }
          }
        }catch(NullPointerException e){
        }finally{
          i.level=constrain(i.level,1,i.upgradeData.size()+1);
          applyStaus();
        }
      }
    }
  }
  
   public void command_give(java.util.List<Token>tokens){
    String src=tokens.get(1).getText();
    if(tokens.get(1).getText().length()>2&&masterTable.contains(src.replace("\"",""))){
      SubWeapon w=masterTable.get(src.replace("\"","")).getWeapon();
      if(!player.subWeapons.contains(w)){
        player.subWeapons.add(w);
        if(masterTable.get(src.replace("\"","")).getType().equals("item"))w.update();
        applyStaus();
      }else{
        addWarning("You already have "+src);
      }
    }else{
      addWarning(src+" doesn't exist");
    }
  }
  
   public void command_weapon(java.util.List<Token>tokens){
    if(tokens.get(1).getText().length()>2&&masterTable.contains(tokens.get(1).getText().replace("\"",""))&&!player.subWeapons.contains(masterTable.get(tokens.get(1).getText().replace("\"","")).getWeapon())){}
  }
  
   public void command_kill(java.util.List<Token>tokens){
    if(tokens.get(1).getText().equals("@p")){
      player.HP.set(0);
    }else{
      try{
        Class c=Class.forName("Simple_shooting_2_1$"+tokens.get(1).getText().replace("\"",""));
        Entities.forEach(e->{
          if(c.isInstance(e))e.isDead=true;
        });
      }catch(ClassNotFoundException e){
        addWarning("Class "+tokens.get(1).getText()+" doesn't exist");
      }
    }
  }
  
   public void command_function(java.util.List<Token>tokens){
    try{
      String[] functions=loadStrings(tokens.get(1).getText().replace("\"",""));
      for(String s:functions){
        CharStream cs=CharStreams.fromString(s);
        command_lexer lexer=new command_lexer(cs);
        CommonTokenStream command_tokens=new CommonTokenStream(lexer);
        command_parser parser=new command_parser(command_tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(ThrowingErrorListener.INSTANCE.setWarningMap(DebugWarning));
        parser.command();
        if(parser.getNumberOfSyntaxErrors()>0)continue;
        main.commandProcess(command_tokens.getTokens());
      }
    }catch(NullPointerException e){
      addWarning("No such file");
    }
  }
  
   public void command_exit(){
    scene=0;
    done=true;
  }
  
   public float setParameter(float data,String type,float num){
    if(type.equals("add")){
      return data+num;
    }else if(type.equals("set")){
      return num;
    }else if(type.equals("sub")){
      return data-num;
    }
    return data;
  }
}

class WallEntity extends Entity{
  PVector dist;
  PVector norm;
  boolean move=false;
  float time=0;
  float weight=2;
  
  {
    size=0;
  }
  
  WallEntity(PVector pos,PVector dist){
    this.pos=pos;
    this.dist=dist;
    this.norm=new PVector(-dist.y,dist.x).normalize();
  }
  
  @Override
  void display(PGraphics g){
    if(Debug)displayAABB(g);
    g.strokeWeight(2);
    g.stroke(255);
    g.line(pos.x,pos.y,pos.x+dist.x,pos.y+dist.y);
  }
  
  @Override
  void update(){
    Center=new PVector(pos.x+dist.x*0.5,pos.y+dist.y*0.5);
    AxisSize=new PVector(dist.x==0?1:dist.x,dist.y==0?1:dist.y);
    putAABB();
    super.update();
  }
  
  void Process(Entity e){
    
  }
  
  @Override
  void Collision(Entity e){
    if(((e instanceof Enemy)&&!(e instanceof Explosion))){
      PVector copy=e.pos.copy();
      e.pos=CircleMovePosition(e.pos,e.size,pos,dist);
      e.vel=new PVector(pos.x-copy.x,pos.y-copy.y);
    }else if(e instanceof Myself){
      PVector copy=e.pos.copy();
      e.pos=CircleMovePosition(e.pos,e.size,pos,dist);
      e.vel=new PVector(pos.x-copy.x,pos.y-copy.y);
    }else if(e instanceof Bullet){
      e.Collision(this);
    }
    Process(e);
  }
}

class DynamicWall extends WallEntity{
  double strength=10;
  
  DynamicWall(PVector pos,PVector dist){
    super(pos,dist);
  }
  
  DynamicWall setStrength(double s){
    strength=s;
    return this;
  }
}
