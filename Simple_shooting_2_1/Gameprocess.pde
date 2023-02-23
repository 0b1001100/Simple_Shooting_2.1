class GameProcess{
  private GameHUD mainHUD;
  HashMap<String,String>EventSet;
  HashMap<String,Command>CommandQue=new HashMap<String,Command>();
  ComponentSet HUDSet;
  ComponentSet UpgradeSet;
  ArrayList<WallEntity>wall;
  Color menuColor=new Color(230,230,230);
  float UItime=0;
  boolean gameOver=false;
  boolean animation=false;
  boolean upgrade=false;
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
     EventSet=new HashMap<String,String>();
     HUDSet=new ComponentSet();
     UpgradeSet=new ComponentSet();
     stageLayer=new ComponentSetLayer();
     stageLayer.addLayer("root",UpgradeSet);
     stageLayer.addSubChild("root","HUD",HUDSet);
     mainHUD=new SurvivorHUD(this);
     initStatus();
     Entities=new ArrayList<Entity>();
     wall=new ArrayList<>();
     nearEnemy.clear();
     player=new Myself();
     stage=new Stage();
     StageFlag.clear();
     gameOver=animation=upgrade=done=menu=pause=false;
     killCount.set(0);
     sumLevel=0;
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
                     player.subWeapons.add(masterTable.get("Reflector").getWeapon());
                     break;
       case "Stage3":player.subWeapons.add(masterTable.get("Turret").getWeapon());
                    player.subWeapons.add(masterTable.get("Absorption").getWeapon());
                     break;
       case "Stage4":player.subWeapons.add(masterTable.get("G_Shot").getWeapon());
                     player.subWeapons.add(masterTable.get("Grenade").getWeapon());
                     break;
       case "Stage5":player.subWeapons.add(masterTable.get("Fire").getWeapon());
                     player.subWeapons.add(masterTable.get("Lightning").getWeapon());
                     break;
       case "Stage6":player.subWeapons.add(masterTable.get("Mirror").getWeapon());
                     player.subWeapons.add(masterTable.get("BLAS").getWeapon());
                     player.subWeapons.add(masterTable.get("Ice").getWeapon());
                     break;
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
      if((mousePressed&&mouseButton==LEFT)||(useController&&dist(0,0,ctrl_sliders.get(2).getValue(),ctrl_sliders.get(3).getValue())>0.1f)){
        stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->tu_shot_2.endDisplay()));
        tu_shot_2.setFlag(false);
      }
    });
    tu_shot_2.addDisposeListener(()->{
      stage.addProcess("Tutorial",new TimeSchedule(stage.time/60+2,s->{
        DummyEnemy e=new DummyEnemy();
        tu_attack.setTarget(e);
        tu_exp.setTarget(e);
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
      if((mousePressed&&mouseButton==LEFT)||(useController&&dist(0,0,ctrl_sliders.get(2).getValue(),ctrl_sliders.get(3).getValue())>0.1f)){
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
    drawShape();
    if(gameOver){
      StageFlag.add("Game_Over");
      scene=3;
      done=true;
      return;
    }
    Debug();
    updateShape();
    if(player!=null){
      player.camera.update();
    }
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
      applyStatus();
      stage.update();
    }else{
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
    if(!upgrade)keyProcess();
    if(!(upgrade||menu)){
      player.update();
      EntityUpdateAndCollision(()->{},()->{EventProcess();EventSet.clear();});
    }
    HashMap<String,Command>nextQue=new HashMap<String,Command>();
    CommandQue.forEach((k,v)->{
      v.update();
      if(!v.isDead())nextQue.put(k,v);
    });
    CommandQue=nextQue;
  }
  
  public void EntityUpdateAndCollision(Runnable whileUpdate,Runnable whileCollision){
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
    whileUpdate.run();
    for(Future<?> f:entityFuture){
      try {
        f.get();
      }
      catch(ConcurrentModificationException e) {
        e.printStackTrace();
      }
      catch(InterruptedException|ExecutionException F) {F.printStackTrace();
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
    exec.execute(()->{EntitySet=new HashSet(Entities);});
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
    ThreadNumber=(byte)min(floor(EntityDataX.size()/(float)minDataNumber),(int)collisionNumber);
    if(pEntityNum!=EntityDataX.size()){
      block=EntityDataX.size()/(float)ThreadNumber;
      for(byte b=0;b<ThreadNumber;b++){
        CollisionProcess.get(b).setData(round(block*b),round(block*(b+1)),b);
      }
    }
    CollisionFuture.clear();
    for(int i=0;i<ThreadNumber;i++){
      CollisionFuture.add(exec.submit(CollisionProcess.get(i)));
    }
    whileCollision.run();
    for(Future<?> f:CollisionFuture){
      try {
        f.get();
      }
      catch(ConcurrentModificationException e) {
        e.printStackTrace();
      }
      catch(InterruptedException|ExecutionException F) {F.printStackTrace();
      }
      catch(NullPointerException g) {
      }
    }
  }
  
  public void drawShape(){
    pProcessTime=System.nanoTime();
    drawMain();
    mainHUD.display();
    DrawTime=(System.nanoTime()-pProcessTime)/1000000f;
  }
  
  public void drawMain(){
    background(0);
    if(ShaderQuality==2){
      Title_HighShader.set("time",0);
      Title_HighShader.set("mouse",-scroll.x/4096f,scroll.y/4096f);
      Title_HighShader.set("volsteps",10);
      filter(Title_HighShader);
    }else if(ShaderQuality==1){
      Title_HighShader.set("time",0);
      Title_HighShader.set("mouse",-scroll.x/4096f,scroll.y/4096f);
      Title_HighShader.set("volsteps",5);
      filter(Title_HighShader);
    }else{
      backgroundShader.set("offset",player.pos.x,-player.pos.y);
      filter(backgroundShader);
    }
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    Entities.forEach(e->{e.display(g);});
    popMatrix();
  }
  
   public void keyProcess(){
    if(useController){
      if(ctrl_button_press&&controllerBinding.getControllerState("menu")){
        menu=!menu;
        if(!upgrade)pause=menu;
      }
    }else{
      if(keyPress&&keyCode==CONTROL){
        menu=!menu;
        if(!upgrade)pause=menu;
      }
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
  
  ComponentSet getHUDComponentSet(){
    return HUDSet;
  }
  
   public void upgrade(){
    if(player.levelup){
      EventSet.put("start_upgrade","");
      upgrade=true;
      menu=false;
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
      UpgradeButton[]buttons=new UpgradeButton[num];
      for(int i=0;i<num;i++){
        buttons[i]=(UpgradeButton)new UpgradeButton(list[i].getName()+"  Level"+(player.subWeapons.contains(list[i].getWeapon())?(list[i].level+1):1)).setBounds(width*0.45,100+(height-100)*0.25*i,width*0.5,(height-100)*0.225);
        if(player.subWeapons.contains(list[i].w)){
          if(list[i].type.equals("item")){
            buttons[i].setExplanation(getLanguageText("ex_"+list[i].getName()));
          }else{
            String res="";
            for(String t:list[i].upgradeData.getJSONObject(list[i].level-1).getJSONArray("name").getStringArray()){
              if(!t.equals("weight"))res+=getLanguageText("ex_param_"+t)+list[i].upgradeData.getJSONObject(list[i].level-1).getInt(t)+"\n";
            }
            buttons[i].setExplanation(res);
          }
        }else{
          buttons[i].setExplanation(getLanguageText("ex_"+list[i].getName()));
        }
        buttons[i].setType(list[i].type);
        int[] lambdaI={i};
        buttons[i].addWindowResizeEvent(()->{
          buttons[lambdaI[0]].setBounds(width*0.45,100+(height-100)*0.25*lambdaI[0],width*0.5,(height-100)*0.225);
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
          applyStatus();
          --player.levelupNumber;
          playerTable.table.forEach((k,v)->{
            v.checkNext();
          });
          upgrade=false;
          EventSet.put("end_upgrade","");
        });
      }
      Canvas c=new Canvas(g);
      c.setContent((g->{
        rectMode(CORNER);
        noStroke();
        fill(0,50);
        rect(0,0,width,height);
      }));
      UpgradeSet.add(c);
      UpgradeSet.addAll(buttons);
      player.levelup=false;
    }
  }
  
  void addWall(float x,float y,float dx,float dy){
    WallEntity w=new WallEntity(new PVector(x,y),new PVector(dx,dy));
    wall.add(w);
    Entities.add(w);
  }
  
   public void commandProcess(java.util.List<Token>tokens){
    java.util.List<Token>ex_space_tokens=new ArrayList<Token>();
    tokens.forEach(t->{
      if(!t.getText().matches(" +"))ex_space_tokens.add(t);
    });
    switch(ex_space_tokens.get(0).getText()){
      case "time":command_time(ex_space_tokens);break;
      case "timescale":command_timescale(ex_space_tokens);break;
      case "level":command_level(ex_space_tokens);break;
      case "give":command_give(ex_space_tokens);break;
      case "kill":command_kill(ex_space_tokens);break;
      case "parameter":command_parameter(ex_space_tokens);break;
      case "function":command_function(ex_space_tokens);break;
      case "exit":command_exit();break;
    }
  }
  
   public void command_time(java.util.List<Token>tokens){
    stage.time=max(0,setParameter(stage.time,tokens.get(1).getText(),PApplet.parseFloat(tokens.get(2).getText())*60));
    stage.scheduleUpdate();
    stage.clearSpown();
  }
  
   public void command_timescale(java.util.List<Token>tokens){
    absoluteMagnification=max(0,PApplet.parseFloat(tokens.get(2).getText()));
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
      player.nextLevel=10+(player.Level-1)*5*ceil(player.Level/10f);
    }else{
      Item i=masterTable.get(tokens.get(1).getText().replace("\"",""));
      if(i==null)return;
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
          applyStatus();
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
        applyStatus();
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
  
  public void command_parameter(java.util.List<Token>tokens){
    itemWeapon w=(itemWeapon)masterTable.get(tokens.get(1).getText()).getWeapon();
    switch(tokens.get(1).getText()){
      case "projectile":w.bulletNumber=(int)setParameter(w.bulletNumber,tokens.get(2).getText(),Integer.valueOf(tokens.get(3).getText()));break;
      case "scale":w.scale=(int)setParameter(w.scale,tokens.get(2).getText(),Integer.valueOf(tokens.get(3).getText()));break;
      case "power":w.power=(int)setParameter(w.power,tokens.get(2).getText(),Integer.valueOf(tokens.get(3).getText()));break;
      case "speed":w.speed=(int)setParameter(w.speed,tokens.get(2).getText(),Integer.valueOf(tokens.get(3).getText()));break;
      case "duration":w.duration=(int)setParameter(w.duration,tokens.get(2).getText(),Integer.valueOf(tokens.get(3).getText()));break;
      case "cooltime":w.coolTime=(int)setParameter(w.coolTime,tokens.get(2).getText(),Integer.valueOf(tokens.get(3).getText()));break;
    }
    w.update();
    applyStatus();
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
        commandProcess(command_tokens.getTokens());
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

class Command{
  private Executable e=(s)->{};
  private String state="wait";
  private float cooltime=0;
  private float duration=0;
  private float offset=0;
  private float time=0;
  private int count=0;
  private int num=1;
  private boolean exec=false;
  private boolean isDead=false;
  
  Command(float c,float d,float o,Executable e){
    this.e=e;
    cooltime=c;
    duration=d;
    offset=o;
  }
  
  Command(float c,float d,float o,int i,Executable e){
    this.e=e;
    cooltime=c;
    duration=d;
    offset=o;
    num=i;
  }
  
  public void update(){
    if(isDead)return;
    time+=vectorMagnification;
    if(!exec&&offset<time){
      state="exec";
      exec=true;
      time=0;
      time+=vectorMagnification;
    }
    if(exec){
      if(cooltime<time){
        if(cooltime+duration<time){
          ++count;
          if(count>=num){
            isDead=true;
            state="shutdown";
          }else{
            time=0;
          }
        }
        e.exec(state);
      }
    }
  }
  
  boolean isDead(){
    return isDead;
  }
}

class StatusParameter{
  private String name;
  private float value=0f;
  private float duration;
  private Predicate<StatusParameter>predicate;
  private boolean apply=true;
  private boolean end=false;
  
  StatusParameter(float v,float d,String n,Predicate<StatusParameter>p){
    value=v;
    duration=d;
    name=n;
    predicate=p;
  }
  
  void update(){
    if(end)return;
    if(duration<=0){
      end=true;
    }else{
      apply=predicate.test(this);
    }
    duration-=16f*vectorMagnification;
  }
  
  boolean isEnd(){
    return end;
  }
  
  boolean isApply(){
    return apply;
  }
  
  float getDuration(){
    return duration;
  }
  
  float getValue(){
    return (end||!apply)?0f:value;
  }
  
  String getName(){
    return name;
  }
}

class KeyBinding{
  private HashMap<Integer,String>list;
  private int type=0;
  
  public final int KEY=0;
  public final int CONTROLLER=1;
  
  KeyBinding(){
    initKey();
    type=0;
  }
  
  KeyBinding(int type){
    switch(type){
      case 0:initKey();break;
      case 1:initController();break;
    }
    this.type=type;
  }
  
  void initKey(){
    list=new HashMap<>();
    addBinding((int)ENTER,"enter");
    addBinding((int)SHIFT,"back");
    addBinding((int)CONTROL,"menu");
    addBinding((int)TAB,"change");
    addBinding((int)UP,"up");
    addBinding((int)LEFT,"left");
    addBinding((int)RIGHT,"right");
    addBinding((int)DOWN,"down");
  }
  
  void initController(){
    list=new HashMap<>();
    addBinding(2,"enter");
    addBinding(1,"back");
    addBinding(3,"menu");
    addBinding(0,"change");
    addBinding(-3,"up");
    addBinding(-9,"left");
    addBinding(-5,"right");
    addBinding(-7,"down");
  }
  
  int getType(){
    return type;
  }
  
  void addBinding(int i,String s){
    list.put(i,s);
  }
  
  void replaceBinding(int i,String s,int next){
    list.remove(i);
    list.put(next,s);
  }
  
  HashMap<Integer,String> getDefaultBindings(){
    return getBindings("enter","back","menu","change");
  }
  
  HashMap<Integer,String> getBindings(String... name){
    HashSet<String>names=new HashSet<>(Arrays.asList(name));
    HashMap<Integer,String>ret=new HashMap<>();
    list.forEach((k,v)->{
      if(names.contains(v))ret.put(k,v);
    });
    return ret;
  }
  
  ArrayList<String> getState(){
    ArrayList<String>ret=new ArrayList<>();
    if(type==1){
      for(int i:list.keySet()){
        if(ctrl_buttons.get(i).pressed())ret.add(list.get(i));
      }
      if(list.containsKey(-(int)ctrl_hat.getValue()-1))ret.add(list.get(-(int)ctrl_hat.getValue()-1));
    }else{
      for(String s:PressedKeyCode){
        ret.add(list.get(Integer.parseInt(s)));
      }
    }
    return ret;
  }
  
  String getKeyState(int i){
    return list.get(i);
  }
  
  String getButtonState(int i){
    return list.get(i);
  }
  
  boolean getControllerState(String s){
    int binding=getButtonBinding(s);
    if(type==1&&list.containsValue(s)){
      if(binding>=0){
        return ctrl_buttons.get(binding).pressed();
      }else{
        return ctrl_hat.getValue()==-binding-1;
      }
    }
    return false;
  }
  
  boolean getKeyInputState(String s){
    int binding=getButtonBinding(s);
    if(type==0&&list.containsValue(s)){
      return PressedKeyCode.contains(str(binding));
    }
    return false;
  }
  
  int getButtonBinding(String s){
    for(int i:list.keySet()){
      if(s.equals(list.get(i))){
        return i;
      }
    }
    return -1024;
  }
  
  String getButtonState(){
    if(type==0)return null;
    for(int i=0;i<ctrl_buttons.size();i++){
      if(ctrl_buttons.get(i).pressed()&&list.get(i)!=null)return list.get(i);
    }
    return null;
  }
  
  String getHatState(){
    return type==1?list.get(-(int)ctrl_hat.getValue()-1):null;
  }
  
  String getKeyState(){
    return type==0?(keyPressed?list.get(nowPressedKeyCode):null):null;
  }
}

boolean getInputState(String s){
  return (keyPress&&keyboardBinding.getKeyInputState(s))||(useController&&(ctrl_button_press||ctrl_hat_press)&&controllerBinding.getControllerState(s));
}

boolean isInput(){
  return keyPress||ctrl_button_press||ctrl_hat_press;
}

String getInputState(){
  if(useController){
    String btn=controllerBinding.getButtonState();
    if(btn!=null)return btn;
    String hat=controllerBinding.getHatState();
    if(hat!=null)return hat;
  }
  String Key=keyboardBinding.getKeyState();
  return Key==null?"":Key;
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
  public void display(PGraphics g){
    if(Debug)displayAABB(g);
    g.strokeWeight(2);
    g.stroke(255);
    g.line(pos.x,pos.y,pos.x+dist.x,pos.y+dist.y);
  }
  
  @Override
  public void update(){
    Center=new PVector(pos.x+dist.x*0.5,pos.y+dist.y*0.5);
    AxisSize=new PVector(max(1,abs(dist.x)),max(1,abs(dist.y)));
    putAABB();
    super.update();
  }
  
  public void Process(Entity e){
    
  }
  
  @Override
  public void Collision(Entity e){
    if(e instanceof Explosion){
      ExplosionCollision((Explosion)e);
    }else if(e instanceof Enemy){
      EnemyCollision((Enemy)e);
    }else if(e instanceof Bullet){
      BulletCollision((Bullet)e);
    }else if(e instanceof Myself){
      MyselfCollision((Myself)e);
    }else if(e instanceof WallEntity){
      WallCollision((WallEntity)e);
    }
    Process(e);
  }
  
  @Override
  public void ExplosionCollision(Explosion e){}
  
  @Override
  public void EnemyCollision(Enemy e){
    PVector copy=e.pos.copy();
    e.pos=CircleMovePosition(e.pos,e.size,pos,dist);
  }
  
  @Override
  public void BulletCollision(Bullet b){
    b.WallCollision(this);
  }
  
  @Override
  public void MyselfCollision(Myself m){
    PVector copy=m.pos.copy();
    m.pos=CircleMovePosition(m.pos,m.size,pos,dist);
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

interface Executable{
  public void exec(String s);
}
