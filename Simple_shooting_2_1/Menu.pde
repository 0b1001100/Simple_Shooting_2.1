Canvas menu_op_canvas;
ShopItemList shopItemList=new ShopItemList();
ItemList backgroundList=new ItemList();

HashMap<String,LineManager>menu_animations=new HashMap<>();
HashMap<String,Consumer<String>>shop_selected_process=new HashMap<>();
LineManager menu_animation=new DefaultLineManager();

{
  menu_animations.put("default",new DefaultLineManager());
  menu_animations.put("hexagon",new HexagonLineManager());
  menu_animations.put("triangle",new TriangleLineManager());
}

public void initMenu(){
  soundManager.setMute(true);
  starts=new ComponentSetLayer();
  NormalButton New=new NormalButton(Language.getString("start_game"));
  New.setBounds(width*0.5-155,height-80,140,30);
  New.addListener(()-> {
    starts.toChild("main");
  });
  New.addWindowResizeEvent(()->{
    New.setBounds(width*0.5-155,height-80,140,30);
  });
  NormalButton Update_Check=new NormalButton(Language.getString("check_update"));
  Update_Check.setBounds(width*0.5+15,height-80,140,30);
  Update_Check.addListener(()-> {
    Update_Check.setLabel(Language.getString("checking"));
    exec.execute(()->{
      boolean latest=true;
      boolean fail=false;
      try{
        latest=checkUpdate();
      }catch(Exception e){
        e.printStackTrace();
        latest=false;
        fail=true;
      }
      Update_Check.setLabel(Language.getString(latest?"latest":fail?"fail_check":"update"));
    });
  });
  Update_Check.addWindowResizeEvent(()->{
    Update_Check.setBounds(width*0.5+15,height-80,140,30);
  });
  Canvas TitleCanvas=new Canvas(g);
  TitleCanvas.setContent((g)->{
    try{
      if(ShaderQuality==2){
        Title_HighShader.set("time",millis()/30000f);
        Title_HighShader.set("mouse",0,0);
        Title_HighShader.set("volsteps",10);
        filter(Title_HighShader);
      }else if(ShaderQuality==1){
        Title_HighShader.set("time",millis()/30000f);
        Title_HighShader.set("mouse",0,0);
        Title_HighShader.set("volsteps",5);
        filter(Title_HighShader);
      }else{
        for(int i=0;i<20;i++){
          titleLight[i*2+1]-=titleLightSpeed[i];
          if(titleLight[i*2+1]<0)titleLight[i*2+1]=height;
        }
        if(frameCount==1){
          preg.beginDraw();
          preg.background(0);
          preg.endDraw();
          preg.loadPixels();
          g.loadPixels();
          titleShader.set("tex",g);
          titleShader.set("position",titleLight,2);
          titleShader.set("resolution",width,height);
          preg.filter(titleShader);
          g.filter(titleShader);
        }else{
          preg.loadPixels();
          g.loadPixels();
          titleShader.set("tex",preg);
          titleShader.set("position",titleLight,2);
          titleShader.set("resolution",width,height);
          preg.filter(titleShader);
          g.filter(titleShader);
        }
      }
    }catch(Exception e){}
    g.fill(255);
    g.textFont(font_70);
    g.textAlign(CENTER);
    g.textSize(70);
    g.text("Simple_shooting_2.1",width*0.5,130);
    g.fill(200);
    g.textFont(font_15);
    g.textAlign(LEFT);
    g.textSize(15);
    g.text("["+VERSION+"]  Developed by 0x4C",10,height-10);
  });
  TitleCanvas.addWindowResizeEvent(()->{
    preg=createGraphics(width,height,P2D);
    for(int i=0;i<20;i++){
      titleLight[i*2]=width*0.05*i+random(-5,5);
      titleLight[i*2+1]=random(0,height);
    }
  });
  ComponentSet titleSet=toSet(TitleCanvas,New,Update_Check);
  Y_AxisLayout mainLayout=new Y_AxisLayout(100,120,120,25,15);
  MenuButton Select=new MenuButton(Language.getString("stage_select"));
  Select.addListener(()->{
    starts.toChild("stage");
  });
  //--
    stageList.setBounds(250,100,300,500);
    stageList.setSubBounds(width-320,100,300,500);
    stageList.addWindowResizeEvent(()->{
      stageList.setSubBounds(width-320,100,300,500);
    });
    stageList.addSelectListener((s)->{
      StageName=s;
      starts.toChild("mode");
    });
    MenuButton NormalMag=new MenuButton(Language.getString("normal"));
    NormalMag.addListener(()->{
      scene=1;
    });
    MenuButton AbsMag=new MenuButton(Language.getString("mag_set"));
    AbsMag.addListener(()->{
      absoluteMagnification=1.5;
      scene=1;
    });
  //--
  MenuButton Config=new MenuButton(Language.getString("config"));
  Config.addListener(()->{
    starts.toChild("confMenu");
  });
  MenuButton item=new MenuButton(Language.getString("item"));
  item.addListener(()->{
    starts.toChild("item");
  });
  MenuButton Archive=new MenuButton(Language.getString("Archive"));
  Archive.addListener(()->{
    starts.toChild("archive");
  });
    //---
    Y_AxisLayout arcLayout=new Y_AxisLayout(10,120,120,25,15);
    MenuButton arc_tolist=new MenuButton(Language.getString("enemy"));
    arc_tolist.addListener(()->{
      starts.toChild("arc_list");
      starts.getNowComponents().forEach(c->c.addSelect());
    });
    MenuButton arc_back=new MenuButton(Language.getString("back"));
    arc_back.addListener(()->{
      starts.toParent();
    });
    ComponentSet archiveSelect=toSet(arcLayout,arc_tolist,arc_back);
    //---
  //---
  MenuButton operationEx=new MenuButton(Language.getString("operation_ex"));
  operationEx.addListener(()->{
    starts.toChild("operation");
  });
  //---
  MenuButton credit=new MenuButton(Language.getString("credit"));
  credit.addListener(()->{
    starts.toChild("credit");
    credit_scroll=0;
  });
  //--
  menu_op_canvas=new Canvas(g);
    menu_op_canvas.setContent((pg)->{
      PGraphicsOpenGL glpg=(PGraphicsOpenGL)pg;
      glpg.blendMode(BLEND);
      glpg.rectMode(CORNER);
      glpg.noStroke();
      float v=grayScale(get(10,height-30));
      glpg.fill(int(255-round(v/255)*180));
      glpg.textSize(15);
      glpg.rect(10,15,textWidth(getLanguageText("ui_frag")+" : "+fragmentCount)+40,20);
      glpg.fill(int(255-round(v/255)*255));
      glpg.rect(10,height-30,width-20,1);
      glpg.textAlign(LEFT);
      glpg.textFont(font_15);
      glpg.text(getLanguageText("enter")+" : "+(main_input.getController().isAvailable()?"〇":"Enter"),30,height-10);
      glpg.text(getLanguageText("back")+" : "+(main_input.getController().isAvailable()?"×":"Shift"),150,height-10);
      glpg.fill(int(round(v/255)*255));
      glpg.text(getLanguageText("ui_frag")+" : "+fragmentCount,30,30);
    });
  //--
  starts.setSubChildDisplayType(1);
  starts.addLayer("root",titleSet);
  starts.addChild("root","main",toSet(mainLayout,Select,Config,item,Archive,operationEx,credit));
  starts.addSubChild("main","stage",toSet(stageList));
  starts.addSubChild("stage","mode",toSet(new Y_AxisLayout(570,120,120,25,10),NormalMag,AbsMag));
  confSet(starts);
  itemSet(starts);
  starts.addChild("main","archive",archiveSelect);
  starts.addSubChild("archive","arc_list",initArchive(archiveSelect));
  operationSet(starts);
  creditSet(starts);
  if(launched){
    starts.toChild("main");
  }else{
    launched=true;
  }
  soundManager.setMute(false);
}

void confSet(ComponentSetLayer layer){
  MenuTextBox confBox=new MenuTextBox(Language.getString("ex"));
  confBox.setBounds(width-320,100,300,500);
  confBox.addWindowResizeEvent(()->{
    confBox.setBounds(width-320,100,300,500);
  });
  //---
    Y_AxisLayout confLayout=new Y_AxisLayout(250,160,120,25,15);
    MenuButton Display=new MenuButton(Language.getString("display"));
    Display.addListener(()->{
      starts.toChild("dispMenu");
    });
    Display.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_display"));
      }
      
       public void lostFocus(){}
    });
    //--
      Y_AxisLayout dispLayout=new Y_AxisLayout(400,200,120,25,15);
      MenuCheckBox Colorinv=new MenuCheckBox(Language.getString("color_inverse"),colorInverse);
      Colorinv.addListener(()->{
        colorInverse=Colorinv.value;
      });
      Colorinv.addFocusListener(new FocusEvent(){
         public void getFocus(){
          confBox.setText(Language.getString("ex_color_inverse"));
        }
        
         public void lostFocus(){}
      });
      MenuCheckBox dispFPS=new MenuCheckBox(Language.getString("disp_FPS"),displayFPS);
      dispFPS.addListener(()->{
        displayFPS=dispFPS.value;
        conf.setBoolean("FPS",displayFPS);
        exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
      });
      dispFPS.addFocusListener(new FocusEvent(){
         public void getFocus(){
          confBox.setText(Language.getString("ex_disp_FPS"));
        }
        
         public void lostFocus(){}
      });
      MenuToggleBox Quality=new MenuToggleBox(Language.getString("Quality"),ShaderQuality,3);
      Quality.addCustomizeText(0,getLanguageText("ex_qu_low")).addCustomizeText(1,getLanguageText("ex_qu_high")).addCustomizeText(2,getLanguageText("ex_qu_ultra"));
      Quality.addListener(()->{
        ShaderQuality=Quality.value;
        conf.setInt("ShaderQuality",ShaderQuality);
        exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
      });
      Quality.addFocusListener(new FocusEvent(){
         public void getFocus(){
          confBox.setText(Language.getString("ex_Quality"));
        }
        
         public void lostFocus(){}
      });
      MenuCheckBox vsy=new MenuCheckBox(Language.getString("VSync"),vsync);
      vsy.addListener(()->{
        vsync=vsy.value;
        FrameRateConfig=vsync?RefleshRate:60;
        frameRate(FrameRateConfig);
        conf.setBoolean("vsync",vsync);
        exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
      });
      vsy.addFocusListener(new FocusEvent(){
         public void getFocus(){
          confBox.setText(Language.getString("ex_VSync"));
        }
        
         public void lostFocus(){}
      });
      MenuCheckBox fullsc=new MenuCheckBox(Language.getString("fullscreen"),fullscreen);
      fullsc.addListener(()->{
        fullscreen=fullsc.value;
        noLoop();
        ((GLWindow)surface.getNative()).setFullscreen(fullscreen);
        if(!fullscreen){
          surface.setLocation(0,0);
        }
        loop();
        conf.setBoolean("Fullscreen",fullscreen);
        exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
      });
      fullsc.addFocusListener(new FocusEvent(){
         public void getFocus(){
          confBox.setText(Language.getString("ex_fullscreen"));
        }
        
         public void lostFocus(){}
      });
      //--
    MenuButton Background=new MenuButton(Language.getString("background"));
    Background.addListener(()->{
      starts.toChild("bgMenu");
    });
    Background.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_background"));
      }
      
       public void lostFocus(){}
    });
      //--
      backgroundList=new ItemList();
      backgroundList.setBounds(400,100,300,500);
      backgroundList.showSub=false;
      backgroundList.addContent("default");
      backgroundList.addSelectListener((s)->{
        if(menu_animations.containsKey(s))menu_animation=menu_animations.get(s).get();
      });
      //--
    MenuButton Lang=new MenuButton(Language.getString("language"));
    Lang.addListener(()->{
      starts.toChild("Language");
    });
    Lang.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_language"));
      }
      
       public void lostFocus(){}
    });
    //--
      ItemList LangList=new ItemList();
      LangList.setBounds(400,100,300,500);
      LangList.showSub=false;
      for(int i=0;i<LanguageData.getJSONArray("Language").size();i++){
        LangList.addContent(LanguageData.getJSONArray("Language").getJSONObject(i).getString("name"));
      }
      LangList.addSelectListener((s)->{
        if(conf.getString("Language").equals(LanguageData.getString(s))){
          starts.toParent();
          return;
        }
        conf.setString("Language",LanguageData.getString(s));
        exec.submit(()->saveJSONObject(conf,SavePath+"config.json"));
        LoadLanguage();
        initMenu();
        starts.toParent();
      });
    //--
    MenuButton exit=new MenuButton(Language.getString("exit"));
    exit.addListener(()->{
      exit();
    });
    exit.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_exit"));
      }
      
       public void lostFocus(){}
    });
    //--
    MenuButton reset=new MenuButton(Language.getString("reset"));
    reset.setSelectForeground(toAWTColor(color(0xFF,0x50,0x50)));
    reset.setForeground(toAWTColor(color(0xFF,0x40,0x40)));
    reset.addListener(()->{
      layer.toChild("reset_dialog");
    });
    reset.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_reset"));
      }
      
       public void lostFocus(){}
    });
    //--
      Canvas DialogBG=new Canvas(g);
      DialogBG.setBounds(0,0,width,height);
      DialogBG.addWindowResizeEvent(()->{
        DialogBG.setBounds(0,0,width,height);
      });
      DialogBG.setContent(g->{
        g.noStroke();
        g.fill(0,100);
        g.rectMode(CORNER);
        g.rect(0,0,width,height);
        g.fill(230);
        g.rectMode(CENTER);
        g.rect(width*0.5,height*0.5,300,100);
        g.fill(0);
        g.textAlign(CENTER);
        g.text(getLanguageText("confirm_reset"),width*0.5,height*0.5);
      });
      MenuButton back_reset=new MenuButton(Language.getString("no"));
      back_reset.setBounds(width*0.5+15,height*0.5+20,120,25);
      back_reset.addWindowResizeEvent(()->{
        back_reset.setBounds(width*0.5+15,height*0.5+20,120,25);
      });
      back_reset.addListener(()->{
        layer.toParent();
      });
      MenuButton enter_reset=new MenuButton(Language.getString("yes"));
      enter_reset.setBounds(width*0.5-135,height*0.5+20,120,25);
      enter_reset.addWindowResizeEvent(()->{
        enter_reset.setBounds(width*0.5-135,height*0.5+20,120,25);
      });
      enter_reset.addListener(()->{
        conf=loadJSONObject(SavePath+"config_base.json");
        saveJSONObject(conf,SavePath+"config.json");
        LoadData();
        initMenu();
        starts.toParent();
      });
  //---
  layer.addSubChild("main","confMenu",toSet(confLayout,Display,Background,Lang,exit,reset),toSet(confBox));
  layer.addSubChild("confMenu","dispMenu",toSet(dispLayout,Colorinv,dispFPS,Quality,vsy,fullsc),toSet(confBox));
  layer.addSubChild("confMenu","bgMenu",toSet(backgroundList),toSet(confBox));
  layer.addSubChild("confMenu","Language",toSet(LangList));
  layer.addSubChild("confMenu","reset_dialog",toSet(DialogBG,back_reset,enter_reset));
}

void itemSet(ComponentSetLayer layer){
  shopItemList.setBounds(250,100,300,500);
  shopItemList.setSubBounds(width-350,100,300,500);
  shopItemList.addWindowResizeEvent(()->{
    shopItemList.setSubBounds(width-350,100,300,500);
  });
  shopItemList.addSelectListener((s)->{
    fragmentCount-=shopItemList.Items.get(s).price;
    conf.setInt("Fragment",fragmentCount);
    if(s.equals("sale")){
      shopItemList.Items.forEach((k,v)->{
        fragmentCount+=v.stock*v.price;
        v.setStock(0);
        conf.getJSONObject("Items").remove(k);
        backgroundList.Contents.removeIf(st->!st.equals("default"));
        backgroundList.selectedNumber=0;
        menu_animation=menu_animations.get("default");
      });
    }else{
      shopItemList.Items.get(s).setStock(shopItemList.Items.get(s).stock+1);
      conf.getJSONObject("Items").setInt(s,shopItemList.Items.get(s).stock);
      if(shop_selected_process.containsKey(s))shop_selected_process.get(s).accept(s);
    }
    shopItemList.Items.forEach((k,v)->{
      if(k.contains("background_")&&v.stock>0&&!backgroundList.contains(k.split("background_")[1]))backgroundList.addContent(k.split("background_")[1]);
    });
  });
  shopItemList.addExplanation("_","Loading...");
  exec.execute(()->{
    JSONObject obj=loadJSONObject(ItemPath+"item.json");
    JSONObject belong=conf.getJSONObject("Items");
    JSONObject lang=obj.getJSONObject("lang").getJSONObject(conf.getString("Language"));
    JSONArray items=obj.getJSONArray("list");
    shopItemList.clearContent();
    shopItemList.clearExplanation();
    for(int i=0;i<items.size();i++){
      JSONObject item=items.getJSONObject(i);
      String name=lang.getString(item.getString("name"));
      shopItemList.addContent(new ShopItem(lang,item.getString("name"),item.getInt("price"),item.getInt("stock")).setStock(belong.getInt(item.getString("name"),0)).setProgress(item.getInt("progress",0)));
      shopItemList.addExplanation(item.getString("name"),lang.getString("ex_"+item.getString("name")));
    }
    shopItemList.Items.forEach((k,v)->{
      if(k.contains("background_")&&v.stock>0&&!backgroundList.contains(k.split("background_")[1]))backgroundList.addContent(k.split("background_")[1]);
    });
  });
  shopItemList.setPredicate(i->fragmentCount>=i);
  starts.addSubChild("main","item",toSet(shopItemList));
}

void operationSet(ComponentSetLayer layer){
  MenuButton back_op=new MenuButton(Language.getString("back"));
  back_op.setBounds(width*0.5f-60,height*0.9f,120,25);
  back_op.addListener(()->{
    starts.toParent();
  });
  back_op.addWindowResizeEvent(()->{
    back_op.setBounds(width*0.5f-60,height*0.9f,120,25);
  });
  Canvas op_canvas=new Canvas(g);
  op_canvas.setContent((g)->{
    g.blendMode(BLEND);
    g.rectMode(CENTER);
    g.textSize(30);
    g.textFont(font_30);
    for(int i=0;i<4;i++){
      String s="";
      switch(i){
        case 0:s="w";break;
        case 1:s="a";break;
        case 2:s="s";break;
        case 3:s="d";break;
      }
      if(PressedKey.contains(s))s+="_p";
      image(confImage.get(s),55f+45*i,40f);
    }
    for(int i=0;i<4;i++){
      String s="";
      int code=-1;
      switch(i){
        case 0:s="up";code=38;break;
        case 1:s="left";code=37;break;
        case 2:s="down";code=40;break;
        case 3:s="right";code=39;break;
      }
      if(PressedKeyCode.contains(str(code)))s+="_p";
      image(confImage.get(s),55f+45*i,95f);
    }
    g.image(confImage.get("ctrl"+(PressedKeyCode.contains("17")?"_p":"")),55,155);
    g.image(confImage.get("tab"+(PressedKeyCode.contains("9")?"_p":"")),55,215);
    g.image(confImage.get("enter"+(PressedKeyCode.contains("10")?"_p":"")),55,275);
    g.image(confImage.get("mouse"),55,355);
    g.fill(0);
    g.textAlign(LEFT);
    g.text(": "+Language.getString("move"),245,110f);
    g.text(": "+Language.getString("menu"),150,200);
    g.text(": "+Language.getString("change_weapon"),150,260);
    g.text(": "+Language.getString("enter"),150,320);
    g.text(": "+Language.getString("shot"),150,400);
  });
  layer.addChild("main","operation",toSet(back_op,op_canvas));
}

float credit_scroll=0;
float credit_scroll_limit=1500;

void creditSet(ComponentSetLayer layer){
  MenuButton back_cr=new MenuButton(Language.getString("back"));
  back_cr.setBounds(20,height*0.9f,120,25);
  back_cr.addListener(()->{
    starts.toParent();
  });
  back_cr.addWindowResizeEvent(()->{
    back_cr.setBounds(20,height*0.9f,120,25);
  });
  PFont[] f={createFont("SansSerif.plain",height*0.03)};
  boolean[] cr_res={true};
  Canvas cr_canvas=new Canvas(g);
  cr_canvas.addWindowResizeEvent(()->{
    cr_res[0]=true;
  });
  cr_canvas.setContent((g)->{
    if(cr_res[0]){
      f[0]=createFont("SansSerif.plain",height*0.03);
      cr_res[0]=false;
    }
    g.pushMatrix();
    g.translate(0,750-credit_scroll);
    g.fill(0);
    g.rectMode(CORNER);
    g.textAlign(CENTER,TOP);
    g.textLeading(30);
    g.textSize(height*0.03);
    g.textFont(f[0]);
    g.text(getLanguageText("credit_co"),0,30,width,height*0.9-30);
    g.textAlign(CENTER,BOTTOM);
    g.textLeading(30);
    if(conf.getBoolean("clear"))g.text(getLanguageText("credit_co_2"),0,0,width*0.9,height*0.9-30);
    g.popMatrix();
    if(credit_scroll>=credit_scroll_limit){
      credit_scroll=0;
    }else{
      credit_scroll+=vectorMagnification;
    }
  });
  layer.addChild("main","credit",toSet(back_cr,cr_canvas));
}

ComponentSet initArchive(ComponentSet parent){
  main_game.backgroundShader=backgrounds.get("default");
  Entities=new ArrayList<Entity>();
  ComponentSet archive=new ComponentSet();
  Canvas view=new Canvas(g);
  view.setContent((g)->{
    scroll=new PVector(width/2,height/2);
    pushMatrix();
    main_game.EntityUpdateAndCollision(()->{},()->{});
    main_game.drawMain();
    popMatrix();
  });
  ItemList list=new ItemList();
  list.setAlpha(200);
  list.setBounds(10,100,300,height-200);
  list.setSubBounds(width-310,100,300,height-200);
  list.addWindowResizeEvent(()->{
    list.setBounds(10,100,300,height-200);
    list.setSubBounds(width-310,100,300,height-200);
  });
  list.addFocusListener(new FocusEvent(){
    void getFocus(){
      parent.Active=false;
    }
    
    void lostFocus(){
     parent.Active=true;
    }
  });
  for(String s:conf.getJSONArray("Enemy").toStringArray())list.addContent(s.replace("Simple_shooting_2_1$",""));
  list.addExplanation("_","Loading...");
  exec.execute(()->{
    JSONObject data=loadJSONObject(EnemyPath+"explanation.json").getJSONObject(conf.getString("Language"));
    for(String s:list.getContents())if(data.getString(s)!=null)list.addExplanation(s,data.getString(s));
    list.removeExplanation("_");
  });
  list.addSelectListener((s)->{
    Entities.clear();
    try{
      Enemy New=((Enemy)Class.forName("Simple_shooting_2_1$"+s).getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet)).setPos(new PVector(0,0));
      New.setController(new ArchiveEnemyController());
      Entities.add(New);
    }catch(ClassNotFoundException|NoSuchMethodException|InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
    Entities.addAll(NextEntities);
  });
  archive=toSet(view,list);
  return archive;
}
