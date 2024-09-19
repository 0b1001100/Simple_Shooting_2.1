class GameProcess{
  private GameHUD mainHUD;
  HashMap<String,String>EventSet;
  HashMap<String,ArrayList<BiSwitchConsumer>>EventProcessSet;
  HashMap<String,Command>CommandQue=new HashMap<String,Command>();
  BackgroundShader backgroundShader;
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
  
  int main_cool_rainforce=0;
  int main_proj_rainforce=0;
  int main_atk_rainforce=0;
  
  final float maxDeadTime=3;
  
  GameProcess(){
    setup();
  }
  
   public void setup(){
    init();
  }
  
   public void init(){
     EventSet=new HashMap<String,String>();
     EventProcessSet=new HashMap<>();
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
     deadTimer=sumLevel=main_cool_rainforce=main_proj_rainforce=main_atk_rainforce=0;
     killCount.set(0);
     playerTable.clear();
     Arrays.asList(conf.getJSONArray("Weapons").toStringArray()).forEach(s->{
       playerTable.addTable(masterTable.get(s),masterTable.get(s).getWeight());
     });
     masterTable.getAll().forEach(i->{
       i.reset();
     });
     playerTable.getAll().forEach(i->{
       playerTable.addTable(i,i.weight);
     });
     player.attackWeapons.clear();
     JSONObject ex=loadJSONObject(StageConfPath+"Stage_ex.json");
     if(!StageName.equals("")){
       backgroundShader=backgrounds.get(ex.getJSONObject(StageName).getString("background","default"));
       Arrays.asList(ex.getJSONObject(StageName).getJSONArray("weapon").toStringArray()).forEach(s->player.attackWeapons.add(masterTable.getWeapon(s)));
     }
     if(StageName.equals("Tutorial"))initTutorial();
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
      if((mousePressed&&mouseButton==LEFT)||main_input.getAttackMag()>0){
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
      if((mousePressed&&mouseButton==LEFT)||main_input.getAttackMag()>0){
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
    if(StageName.equals("Stage9")||StageName.equals("Stage10")){
      if(floor((player.score_kill.get()+player.score_tech.get())/100f)>main_cool_rainforce){
        main_cool_rainforce++;
        player.weapons.forEach(w->w.coolTime=((PlayerWeapon)w).init_cooltime*max(0.1,1f-main_cool_rainforce*0.01));
      }
      if(floor((player.score_kill.get()+player.score_tech.get())/2500f)>main_proj_rainforce){
        main_proj_rainforce++;
        player.weapons.forEach(w->w.bulletNumber=((PlayerWeapon)w).init_projectile+min(3,main_proj_rainforce));
      }
      if(floor((player.score_kill.get()+player.score_tech.get())/200f)>main_atk_rainforce){
        main_atk_rainforce++;
        player.weapons.forEach(w->w.power=((PlayerWeapon)w).init_attack*min(1.5,1f+main_atk_rainforce*0.01));
      }
    }
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
      player.handleUpdate();
      EntityUpdateAndCollision(()->{},()->{});
    }
    EventProcess();
    EventSet.clear();
    HashMap<String,Command>nextQue=new HashMap<String,Command>();
    CommandQue.forEach((k,v)->{
      v.update();
      if(!v.isDead())nextQue.put(k,v);
    });
    CommandQue=nextQue;
  }
  
  public void EntityUpdateAndCollision(Runnable whileUpdate,Runnable whileCollision) throws RejectedExecutionException{
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
        return Float.valueOf(d1.getPos()).compareTo(d2.getPos())*((frameCount%2==0)?1:-1);
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
    backgroundShader.display();
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    Entities.forEach(e->{e.handleDisplay(g);});
    popMatrix();
  }
  
   public void keyProcess(){
    if(main_input.isMenuInput()){
      menu=!menu;
      if(!upgrade)pause=menu;
      if(menu){
        soundManager.fadeTo(current_bgm,0.9,0.1);
      }else{
        soundManager.amp(current_bgm,0.3);
      }
    }
  }
  
   public void EventProcess(){
    if(EventSet.containsKey("start_upgrade")){
      soundManager.fadeTo(current_bgm,0.9,0.1);
    }
    if(EventSet.containsKey("end_upgrade")){
      UpgradeSet.removeAll();
      if(player.levelupNumber<1){
        pause=false;
      }else{
        player.levelup=true;
      }
      soundManager.amp(current_bgm,0.3);
    }
    if(EventSet.containsKey("getNextWeapon")){
      String[] src=EventSet.get("getNextWeapon").split("_");
      for(String s:src){
        JSONArray a=nextDataMap.get(s);
        for(int i=0;i<a.size();i++){
          if(a.getJSONObject(i).getString("type").equals("use")){
            player.attackWeapons.remove(masterTable.get(a.getJSONObject(i).getString("name")).w);
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
    EventSet.forEach((k,v)->{
      if(EventProcessSet.containsKey(k)){
        EventProcessSet.get(k).forEach(p->{
          p.accept(k,v);
        });
      }
    });
  }
  
  ComponentSet getHUDComponentSet(){
    return HUDSet;
  }
  
   public void upgrade(){
    if(player.levelup){
      EventSet.put("start_upgrade","");
      upgrade=true;
      menu=false;
      ItemTable copy=playerTable.clone();
      java.util.List<String> weaponNames=player.attackWeapons.stream()
                                               .filter(w->masterTable.get(w.getClass().getName().replace("Weapon","").replace("Simple_shooting_2_1$",""))!=null
                                               ||w.level<masterTable.get(w.getClass().getName().replace("Weapon","").replace("Simple_shooting_2_1$","")).upgradeData.size()+1)
                                               .map(w->w.getClass().getName().replace("Weapon","").replace("Simple_shooting_2_1$",""))
                                               .collect(Collectors.toList());
      int num=min(14-(player.attackWeapons.size()-weaponNames.size()),min(playerTable.probSize(),round(random(3,3.55))));
      Item[]list=new Item[num];
      for(int i=0;i<num;i++){
        if(random(0,1)<0.2&&playerTable.hasNextWeapon()){
          list[i]=copy.getRandomNextWeapon();
        }else if(random(0,1)<0.35&&!weaponNames.isEmpty()){
          String target=weaponNames.get(round(random(0,weaponNames.size()-1)));
          list[i]=copy.get(target);
          weaponNames.remove(target);
        }else if(player.attackWeapons.size()<7){
          list[i]=copy.getRandomWeapon();
        }
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
        boolean hasWeapon=player.attackWeapons.contains(list[i].getWeapon())||player.itemWeapons.contains(list[i].getWeapon());
        buttons[i]=(UpgradeButton)new UpgradeButton(list[i].getName()+"  Level"+(hasWeapon?(list[i].level+1):1)).setBounds(width*0.45,100+(height-100)*0.25*i,width*0.5,(height-100)*0.225);
        if(hasWeapon){
          if(list[i].type.equals("item")){
            buttons[i].setExplanation(getLanguageText("ex_"+list[i].getName()));
          }else{
            String res="";
            for(String t:list[i].upgradeData.getJSONObject(list[i].level-1).getJSONArray("name").toStringArray()){
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
          SubWeapon w=item.getWeapon();
          if((w instanceof AttackWeapon)&&player.attackWeapons.contains(w)){
            ++item.level;
            item.update();
            ++sumLevel;
          }else if((w instanceof ItemWeapon)&&player.itemWeapons.contains(w)){
            ++item.level;
            item.update();
            w.update();
            ++sumLevel;
          }else{
            switch(item.getType()){
              case "weapon":{
                player.attackWeapons.add((AttackWeapon)w);
                ++sumLevel;
              }break;
              case "item":{
                player.itemWeapons.add((ItemWeapon)w);
                w.update();
              }break;
              case "next_weapon":{
                item.update();
                player.attackWeapons.add((AttackWeapon)w);
              }break;
            }
          }
          applyStatus();
          --player.levelupNumber;
          upgrade=false;
          EventSet.put("end_upgrade","");
        });
      }
      if(num==0){
        player.levelup=false;
        --player.levelupNumber;
        upgrade=false;
        EventSet.put("end_upgrade","");
        player.fragment+=20;
        return;
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
    java.util.List<java.util.List<Token>>ex_single_tokens=new ArrayList<java.util.List<Token>>();
    ex_single_tokens.add(new ArrayList<>());
    int index=0;
    for(Token t:tokens){
      if(!t.getText().matches(";")){
        ex_single_tokens.get(index).add(t);
      }else{
        index++;
        ex_single_tokens.add(new ArrayList<>());
      }
    }
    for(java.util.List<Token> token_list:ex_single_tokens){
      java.util.List<Token>ex_space_tokens=new ArrayList<Token>();
      token_list.forEach(t->{
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
        case "invincible":command_invincible(ex_space_tokens);break;
        case "summon":command_summon(ex_space_tokens);break;
        case "exit":command_exit();break;
      }
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
      int targetLevel=(int)setParameter((float)i.level,tokens.get(2).getText(),PApplet.parseFloat(tokens.get(3).getText()));
      if((w instanceof AttackWeapon)&&player.attackWeapons.contains(w)){
        try{
          if(i.level<targetLevel){
            while(i.level<targetLevel){
              ++i.level;
              i.update();
              ++sumLevel;
            }
          }else{
            i.reset();
            while(i.level<targetLevel){
              ++i.level;
              i.update();
              ++sumLevel;
            }
          }
        }catch(NullPointerException e){
          e.printStackTrace();
        }finally{
          i.level=constrain(i.level,1,i.upgradeData.size()+1);
          applyStatus();
          
          playerTable.table.forEach((k,v)->{
            v.checkNext();
          });
        }
      }else if((w instanceof ItemWeapon)&&player.itemWeapons.contains(w)){
        try{
          if(i.level<targetLevel){
            while(i.level<targetLevel){
              ++i.level;
              i.update();
              w.update();
              ++sumLevel;
            }
          }else{
            i.reset();
            while(i.level<targetLevel){
              ++i.level;
              i.update();
              w.update();
              ++sumLevel;
            }
          }
        }catch(NullPointerException e){
          e.printStackTrace();
        }finally{
          i.level=constrain(i.level,1,i.upgradeData.size()+1);
          applyStatus();
          playerTable.table.forEach((k,v)->{
            v.checkNext();
          });
        }
      }
    }
  }
  
   public void command_give(java.util.List<Token>tokens){
    String src=tokens.get(1).getText();
    if(tokens.get(1).getText().length()>2&&masterTable.contains(src.replace("\"",""))){
      SubWeapon w=masterTable.get(src.replace("\"","")).getWeapon();
      if((w instanceof AttackWeapon)&&!player.attackWeapons.contains(w)){
        player.attackWeapons.add((AttackWeapon)w);
        applyStatus();
        addDebugText("Added "+src,false);
      }else if((w instanceof ItemWeapon)&&!player.itemWeapons.contains(w)){
        player.itemWeapons.add((ItemWeapon)w);
        w.update();
        applyStatus();
        addDebugText("Added "+src,false);
      }else{
        addWarning("You already have "+src);
      }
    }else{
      addWarning(src+" doesn't exist");
    }
  }
  
   public void command_kill(java.util.List<Token>tokens){
    if(tokens.get(1).getText().equals("@p")){
      player.HP.set(0);
    }else{
      try{
        Class c=Class.forName("Simple_shooting_2_1$"+tokens.get(1).getText().replace("\"",""));
        Entities.forEach(e->{
          if(c.isInstance(e))e.destruct(e);
        });
      }catch(ClassNotFoundException e){
        addWarning("Class "+tokens.get(1).getText()+" doesn't exist");
      }
    }
  }
  
  public void command_parameter(java.util.List<Token>tokens){
    ItemWeapon w=(ItemWeapon)masterTable.get(tokens.get(1).getText()).getWeapon();
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
  
  public void command_invincible(java.util.List<Token>tokens){
    if(tokens.get(1).getText().equals("true")){
      player.invincibleTime=6000000;
    }else{
      player.invincibleTime=0;
    }
  }
  
  public void command_summon(java.util.List<Token>tokens){
    int type=1;//relative
    if(tokens.size()>4){
      type=tokens.get(4).getText().equals("relative")?1:0;
    }
    try{
      stage.addSpown(new PVector(Float.valueOf(tokens.get(2).getText()),Float.valueOf(tokens.get(3).getText())).add(type==1?player.pos:new PVector(0,0)),
                     (Enemy)Class.forName("Simple_shooting_2_1$"+tokens.get(1).getText().replace("\"","")).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet));
    }catch(Exception e){
      e.printStackTrace();
    }
  }
  
  public void command_exit(){
    StageFlag.add("Game_Over");
    scene=3;
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

abstract class BackgroundShader{
  PShader shader;
  
  abstract BackgroundShader load();
  
  abstract void display();
}

class DefaultBackgroundShader extends BackgroundShader{
  
  BackgroundShader load(){
    shader=Title_HighShader;
    return this;
  }
  
  void display(){
    if(ShaderQuality==2){
      shader.set("time",0);
      shader.set("mouse",-scroll.x/4096f,scroll.y/4096f);
      shader.set("volsteps",10);
      filter(shader);
    }else if(ShaderQuality==1){
      shader.set("time",0);
      shader.set("mouse",-scroll.x/4096f,scroll.y/4096f);
      shader.set("volsteps",5);
      filter(shader);
    }else{
      backgroundShader.set("offset",player.pos.x,-player.pos.y);
      filter(backgroundShader);
    }
  }
}

class PixelBackgroundShader extends BackgroundShader{
  
  BackgroundShader load(){
    shader=loadShader(ShaderPath+"Pixel_high.glsl");
    return this;
  }
  
  void display(){
    if(ShaderQuality==2){
      shader.set("offset",-scroll.x/512f,scroll.y/512f);
      shader.set("count",10f);
      filter(shader);
    }else if(ShaderQuality==1){
      shader.set("offset",-scroll.x/512f,scroll.y/512f);
      shader.set("count",3f);
      filter(shader);
    }else{
      backgroundShader.set("offset",player.pos.x,-player.pos.y);
      filter(backgroundShader);
    }
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
    g.strokeWeight(2);
    g.stroke(255);
    g.line(pos.x,pos.y,pos.x+dist.x,pos.y+dist.y);
  }
  
  @Override
  public void update(){
    Center=new PVector(pos.x+dist.x*0.5,pos.y+dist.y*0.5);
    AxisSize=new PVector(max(1,abs(dist.x)),max(1,abs(dist.y)));
    putAABB();
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

interface BiSwitchConsumer<T,U>{
  final Switcher switcher=new Switcher(true);
  
  void accept(T t,U u);
}

static class Switcher{
  boolean state=true;
  
  Switcher(boolean state){
    this.state=state;
  }
  
  void set(boolean state){
    this.state=state;
  }
}

class AchievementManager{
  AchievementText text=new AchievementText();
  TreeMap<String,JSONObject> achievement_map;
  ArrayList<String> achieved_list=new ArrayList<String>();
  ArrayList<String> achieved=new ArrayList<String>();
  String stage_a="";
  
  AchievementManager(){
    JSONObject achievement=loadJSONObject(SavePath+"achievement.json");
    String src=String.join("",loadStrings(SavePath+"achievement.json"));
    achievement_map=new TreeMap<String,JSONObject>(new Comparator<String>(){int compare(String a,String b){return src.indexOf(a)-src.indexOf(b);}});
    achievement.keys().forEach(k->{
      achievement_map.put((String)k,achievement.getJSONObject((String)k));
    });
    Arrays.asList(conf.getJSONArray("Achievement").toStringArray()).forEach(a->{
      achieved_list.add(a);
    });
  }
  
  void setStageAchievement(String a){
    stage_a=a;
  }
  
  void stageCleared(){
    complete(stage_a);
  }
  
  void complete(String a){
    if(isValid(a)){
      achieved.add(a);
      text.complete(a);
    }
  }
  
  boolean isValid(String a){
    return achievement_map.containsKey(a)&&!achieved_list.contains(a);
  }
  
  String[] getReward(String s){
    return achievement_map.get(s).getJSONArray("reward").toStringArray();
  }
  
  String[] getRewardText(String s){
    String[] rew=getReward(s);
    for(int i=0;i<rew.length;i++){
      String[] p=rew[i].split(":");
      rew[i]=getLanguageText("rew_"+p[0].toLowerCase()).replace("{}",p[1]);
    }
    return rew;
  }
  
  ArrayList<String> getAchieved(){
    return achieved_list;
  }
  
  boolean isAchieved(String s){
    return achieved_list.contains(s);
  }
  
  void display(){
    text.display();
  }
  
  void update(){
    if(!achieved.isEmpty()){
      achieved.forEach(a->{
        if(!isValid(a))return;
        achieved_list.add(a);
        Arrays.asList(getReward(a)).forEach(r->{
          processAchievement(r);
        });
      });
      achieved.clear();
      JSONArray temp=new JSONArray();
      achieved_list.forEach(a->{
        temp.append(a);
      });
      conf.setJSONArray("Achievement",temp);
      saveConfig save=new saveConfig();
      exec.submit(save);
    }
    text.update();
  }
  
  void processAchievement(String a){
    if(!conf.getJSONArray("Achievement").isNull(0)){
      java.util.List<String>list=Arrays.asList(conf.getJSONArray("Achievement").toStringArray());
      if(list.contains(a))return;
    }
    String type=a.split(":")[0];
    String target=a.split(":")[1];
    switch(type){
      case "Weapon":conf.getJSONArray("Weapons").append(target);break;
      case "Fragment":fragmentCount+=Integer.parseInt(target);break;
    }
  }
}
