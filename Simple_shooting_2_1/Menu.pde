Canvas menu_op_canvas;

public void initMenu(){
  starts=new ComponentSetLayer();
  NormalButton New=new NormalButton(Language.getString("start_game"));
  New.setBounds(width*0.5-60,height-80,120,30);
  New.addListener(()-> {
    starts.toChild("main");
  });
  New.addWindowResizeEvent(()->{
    New.setBounds(width*0.5-60,height-80,120,30);
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
  ComponentSet titleSet=toSet(TitleCanvas,New);
  Y_AxisLayout mainLayout=new Y_AxisLayout(100,120,120,25,15);
  MenuButton Select=new MenuButton(Language.getString("stage_select"));
  Select.addListener(()->{
    starts.toChild("stage");
  });
  //--
    stageList.setBounds(250,100,300,500);
    stageList.showSub=false;
    stageList.addSelectListener((s)->{
      scene=1;
      StageName=s;
    });
  //--
  MenuButton Config=new MenuButton(Language.getString("config"));
  Config.addListener(()->{
    starts.toChild("confMenu");
  });
  MenuTextBox confBox=new MenuTextBox(Language.getString("ex"));
  confBox.setBounds(width-320,100,300,500);
  confBox.addWindowResizeEvent(()->{
    confBox.setBounds(width-320,100,300,500);
  });
  //---
    Y_AxisLayout confLayout=new Y_AxisLayout(250,160,120,25,15);
    MenuCheckBox AbsMag=new MenuCheckBox(Language.getString("mag_set"),absoluteMagnification==1.5);
    AbsMag.addListener(()->{
      absoluteMagnification=AbsMag.value?1.5:1;
    });
    AbsMag.addFocusListener(new FocusEvent(){
       public void getFocus(){
        confBox.setText(Language.getString("ex_mag_set"));
      }
      
       public void lostFocus(){}
    });
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
  //---
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
    //---
  //---
  MenuButton operationEx=new MenuButton(Language.getString("operation_ex"));
  operationEx.addListener(()->{
    starts.toChild("operation");
  });
  //--
    MenuButton back_op=new MenuButton(Language.getString("back"));
    back_op.setBounds(width*0.5f-60,height*0.9f,120,25);
    back_op.addListener(()->{
      starts.toParent();
    });
    back_op.addWindowResizeEvent(()->{
      back_op.setBounds(width*0.5f-60,height*0.9f,120,25);
    });
    Canvas op_canvas=new Canvas(g);
    op_canvas.setContent((pg)->{
      pg.beginDraw();
      pg.blendMode(BLEND);
      pg.rectMode(CENTER);
      pg.fill(20);
      pg.noStroke();
      for(int i=0;i<4;i++)pg.rect(87.5f+45*i,70,35,35,3);
      pg.textSize(30);
      pg.textFont(font_30);
      pg.textAlign(CENTER);
      pg.fill(255);
      for(int i=0;i<4;i++)pg.text(i==0?"W":i==1?"A":i==2?"S":i==3?"D":"",87.5f+45*i,82.5f);
      pg.fill(0);
      pg.textAlign(LEFT);
      text(": "+Language.getString("move"),245,82.5f);
      image(mouseImage,70,85);
      text(": "+Language.getString("shot"),150,130);
      pg.endDraw();
    });
  //--
  MenuButton credit=new MenuButton(Language.getString("credit"));
  credit.addListener(()->{
    starts.toChild("credit");
  });
  //--
    MenuButton back_cr=new MenuButton(Language.getString("back"));
    back_cr.setBounds(width*0.5f-60,height*0.9f,120,25);
    back_cr.addListener(()->{
      starts.toParent();
    });
    back_cr.addWindowResizeEvent(()->{
      back_cr.setBounds(width*0.5f-60,height*0.9f,120,25);
    });
    PFont[] f={createFont("SansSerif.plain",height*0.03)};
    boolean[] cr_res={true};
    Canvas cr_canvas=new Canvas(g);
    cr_canvas.addWindowResizeEvent(()->{
      cr_res[0]=true;
    });
    cr_canvas.setContent((pg)->{
      pg.beginDraw();
      if(cr_res[0]){
        f[0]=createFont("SansSerif.plain",height*0.03);
        cr_res[0]=false;
      }
      pg.fill(0);
      pg.rectMode(CORNER);
      pg.textAlign(CENTER,TOP);
      pg.textLeading(30);
      pg.textSize(height*0.03);
      pg.textFont(f[0]);
      pg.text(getLanguageText("credit_co"),0,30,width,height*0.9-30);
      pg.textAlign(CENTER,BOTTOM);
      pg.textLeading(30);
      if(conf.getBoolean("clear"))pg.text(getLanguageText("credit_co_2"),0,0,width,height*0.9-30);
      pg.endDraw();
    });
  //--
  menu_op_canvas=new Canvas(g);
    menu_op_canvas.setContent((pg)->{
      PGraphicsOpenGL glpg=(PGraphicsOpenGL)pg;
      glpg.blendMode(BLEND);
      glpg.rectMode(CORNER);
      glpg.noStroke();
      float v=grayScale(get(10,height-30));
      glpg.fill(int(255-round(v/255)*255));
      glpg.rect(10,height-30,width-20,1);
      glpg.textSize(20);
      glpg.textFont(font_20);
      glpg.text("Enter : "+(useController?"〇":"Enter"),50,height-7.5);
      glpg.text("Back : "+(useController?"×":"Shift"),200,height-7.5);
    });
  //--
  starts.setSubChildDisplayType(1);
  starts.addLayer("root",titleSet);
  starts.addChild("root","main",toSet(mainLayout,Select,Config,Archive,operationEx,credit));
  starts.addSubChild("main","stage",toSet(stageList));
  starts.addSubChild("main","confMenu",toSet(confLayout,AbsMag,Display,Lang,exit),toSet(confBox));
  starts.addSubChild("confMenu","dispMenu",toSet(dispLayout,Colorinv,dispFPS,Quality,vsy,fullsc),toSet(confBox));
  starts.addSubChild("confMenu","Language",toSet(LangList));
  starts.addChild("main","archive",toSet(arcLayout,arc_tolist,arc_back));
  starts.addSubChild("archive","arc_list",initArchive(arc_tolist,arc_back));
  starts.addChild("main","operation",toSet(back_op,op_canvas));
  starts.addChild("main","credit",toSet(back_cr,cr_canvas));
  if(launched){
    starts.toChild("main");
  }else{
    launched=true;
  }
}

ComponentSet initArchive(MenuButton... parent){
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
      for(MenuButton m:parent)m.active=false;
    }
    
    void lostFocus(){
      for(MenuButton m:parent)m.active=true;
    }
  });
  for(String s:conf.getJSONArray("Enemy").getStringArray())list.addContent(s.replace("Simple_shooting_2_1$",""));
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
