import java.util.concurrent.atomic.AtomicInteger;

import ddf.minim.*;

import java.net.*;
import java.net.http.*;

class EntityProcess implements Callable<String>{
  long pProcessTime;
  byte number;
  int s;
  int l;
  
  EntityProcess(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
  }
  
  String call(){
    pProcessTime=System.nanoTime();
    ArrayList<Entity>next=HeapEntity.get(number);
    for(int i=s;i<l;i++){
      Entity e=Entities.get(i);
      e.threadNum=number;
      if(player.isDead){
        if((e instanceof Explosion)||(e instanceof Particle)){
          e.handleUpdate();
        }else{
          e.putAABB();
        }
      }else{
        e.handleUpdate();
      }
      if(!e.pDead){
        next.add(e);
      }else if(e instanceof Enemy&&!ArchiveEntity.contains(e.getClass().getName())&&e.getClass().getName().indexOf("$")==e.getClass().getName().lastIndexOf("$")){
        synchronized(ArchiveEntity){
          if(!ArchiveEntity.contains(e.getClass().getName())&&!(e instanceof ExcludeArchive)){
            ArchiveEntity.add(e.getClass().getName());
            Collections.sort(ArchiveEntity);
          }
        }
      }
    }
    EntityTime=(System.nanoTime()-pProcessTime)/1000000f;
    return "";
  }
  
  public void setData(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
  }
}

class EntityCollision implements Callable<String>{
  long pProcessTime;
  float hue;
  byte number;
  int s;
  int l;
  
  EntityCollision(int s,int l,byte num){
    this.s=s;
    this.l=l;
    hue=s==0?0:255*(s/(float)EntityDataX.size());
    number=num;
  }
  
  String call(){
    pProcessTime=System.nanoTime();
    for(int i=s;i<l;i++){
      Entity E=SortedDataX[i].getEntity();
      if((E instanceof Enemy)&&Debug)((Enemy)E).hue=hue;
      switch(SortedDataX[i].getType()){
        case "s":if(frameCount%2==0)Collision(E,i);break;
        case "e":if(frameCount%2==1)Collision(E,i);break;
      }
    }
    CollisionTime=(System.nanoTime()-pProcessTime)/1000000f;
    return "";
  }
  
  public void Collision(Entity E,int i){
    ++i;
    for(int j=i,s=EntityDataX.size();j<s;j++){
      Entity e=SortedDataX[j].getEntity();
      if(E==e)break;
      if(SortedDataX[j].getType().equals((frameCount%2==0)?"e":"s")){
        continue;
      }
      if(abs(e.Center.y-E.Center.y)<=(e.AxisSize.y+E.AxisSize.y)*0.5){
        E.Collision(e);
      }
    }
  }
  
  public void setData(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
    hue=s==0?0:255*(s/(float)EntityDataX.size());
  }
}

class EntityDraw implements Callable<PGraphics>{
  PGraphics g;
  int s;
  int l;
  
  EntityDraw(int s,int l){
    this.s=s;
    this.l=l;
    this.g=createGraphics(width,height);
  }
  
  PGraphics call(){
    g.beginDraw();
    g.translate(scroll.x,scroll.y);
    g.background(0,0);
    for(int i=s;i<l;i++){
      Entities.get(i).handleDisplay(g);
    }
    g.endDraw();
    return g;
  }
  
  public void setData(int s,int l){
    this.s=s;
    this.l=l;
  }
}

class saveConfig implements Runnable{
  
  public void run(){
    conf.setInt("Fragment",fragmentCount);
    if(!StageFlag.contains("Game_Over")){
      conf.setJSONArray("Stage",parseJSONArray(Arrays.toString(stageList.Contents.toArray(new String[0]))));
      conf.setJSONArray("Enemy",parseJSONArray(Arrays.toString(ArchiveEntity.toArray(new String[0]))));
      saveJSONObject(conf,SavePath+"config.json");
    }
  }
}

class CollisionData{
  byte number;
  byte end;
  Entity e;
  CollisionData(Entity e,byte num){
    number=num;
    this.e=e;
  }
  
  Entity getEntity(){
    return e;
  }
  
  byte getNumber(){
    return number;
  }
  
  public void setEnd(byte b){
    end=b;
  }
  
  byte getEnd(){
    return end;
  }
  
  @Override
  public String toString(){
    return number+":"+e;
  }
}

class AABBData{
  private float pos;
  private String type="";
  private Entity e;
  
  AABBData(float pos,String type,Entity e){
    this.pos=pos;
    this.type=type;
    this.e=e;
  }
  
  final float getPos(){
    return pos;
  }
  
  final String getType(){
    return type;
  }
  
  final Entity getEntity(){
    return e;
  }
}

class SoundManager{
  HashMap<String,AudioPlayer>sounds=new HashMap<>();
  HashMap<String,SoundData>soundData=new HashMap<>();
  
  HashMap<String,Runnable>loadQueue=new HashMap<>();
  
  boolean mute=false;
  float vol_SE=1;
  float vol_BGM=1;
  
  SoundManager(){
  }
  
  void loadSound(){
    String[] names=loadJSONArray(SoundPath+"sounds.json").toStringArray();
    for(String s:names){
      String name=s.split(".wav")[0].split(".mp3")[0];
      if(name.contains("*")){
        String[]n={name.replace("*","")};
        loadQueue.put(n[0],()->{
          sounds.put(n[0],minim.loadFile(SoundPath+s.replace("*","")));
          soundData.put(n[0],new SoundData().setCategory(SoundCat.BGM));
          setVolume(vol_BGM,vol_SE);
        });
        continue;
      }
      sounds.put(name,minim.loadFile(SoundPath+s));
      soundData.put(name,new SoundData());
    }
    setVolume((conf.getJSONObject("volume").getInt("bgm")-1)/5.0,(conf.getJSONObject("volume").getInt("SE")-1)/5.0);
  }
  
  void loadQeuedData(String name,Runnable end){
    if(sounds.containsKey(name)){
      end.run();
      return;
    }
    exec.execute(()->{
      loadQueue.get(name).run();
      end.run();
    });
  }
  
  void setMute(boolean b){
    mute=b;
  }
  
  void play(String name){
    if(!sounds.containsKey(name)||mute||soundData.get(name).isMute())return;
    sounds.get(name).rewind();
    sounds.get(name).play();
    soundData.get(name).setLoop(false);
  }
  
  void loop(String name){
    if(!sounds.containsKey(name)||mute||soundData.get(name).isMute())return;
    sounds.get(name).rewind();
    sounds.get(name).loop();
    soundData.get(name).setLoop(true);
  }
  
  void amp(String name,float a){
    if(!sounds.containsKey(name))return;
    soundData.get(name).setAmp(a);
    if(soundData.get(name).isMute())return;
    sounds.get(name).setGain(10*log(soundData.get(name).getAmp()));
  }
  
  void setVolume(float bgm,float se){
    vol_BGM=bgm;
    vol_SE=se;
    sounds.forEach((n,s)->{
      SoundData data=soundData.get(n);
      switch(soundData.get(n).category){
        case BGM:data.vol=vol_BGM;break;
        case SE:data.vol=vol_SE;break;
      }
      if(data.isMute())return;
      sounds.get(n).setGain(10*log(data.getAmp()));
    });
  }
  
  void stop(String name){
    if(!sounds.containsKey(name))return;
    sounds.get(name).pause();
    sounds.get(name).rewind();
  }
  
  void fadeout(String name,float mag){
    if(!sounds.containsKey(name)||mute||soundData.get(name).isMute())return;
    float amp[]={soundData.get(name).amp};
    exec.execute(()->{
      while(amp[0]>0.001){
        sounds.get(name).setGain(10*log(amp[0]*soundData.get(name).vol));
        amp[0]*=min(1,mag);
        try{
          Thread.sleep(16);
        }catch(Exception e){
          e.printStackTrace();
        }
      }
      stop(name);
    });
  }
  
  void fadeTo(String name,float mag,float target){
    if(!sounds.containsKey(name)||mute||soundData.get(name).isMute())return;
    float amp[]={soundData.get(name).amp};
    exec.execute(()->{
      while(amp[0]>target){
        sounds.get(name).setGain(10*log(amp[0]*soundData.get(name).vol));
        amp[0]*=min(1,mag);
        try{
          Thread.sleep(16);
        }catch(Exception e){
          e.printStackTrace();
        }
      }
      amp(name,target);
    });
  }
  
  class SoundData{
    float amp;
    float vol;
    boolean loop;
    boolean mute;
    SoundCat category;
    
    SoundData(){
      amp=1;
      vol=1;
      loop=false;
      mute=false;
      category=SoundCat.SE;
    }
    
    void setAmp(float amp){
      this.amp=amp;
    }
    
    float getAmp(){
      return amp*vol;
    }
    
    boolean isMute(){
      return getAmp()<1e-5||mute;
    }
    
    void setVolume(float vol){
      this.vol=vol;
    }
    
    void setLoop(boolean loop){
      this.loop=loop;
    }
    
    void setMute(boolean mute){
      this.mute=mute;
    }
    
    SoundData setCategory(SoundCat cat){
      this.category=cat;
      return this;
    }
  }
}

enum SoundCat{
  BGM,
  SE
}

boolean checkUpdate() throws Exception{
  HttpClient cli = HttpClient.newHttpClient();
  HttpRequest req = HttpRequest.newBuilder()
      .uri(URI.create("https://api.github.com/repos/Asynchronous-0x4C/Simple_Shooting_2.1/releases"))
      .GET()
      .build();
  HttpResponse<String> ress = cli.send(req, HttpResponse.BodyHandlers.ofString());
  JSONObject info=parseJSONArray(ress.body()).getJSONObject(0);
  boolean latest=true;
  String[] repo_version=info.getString("tag_name").split(".");
  String[] current_version=VERSION.split(".");
  for(int i=0;i<repo_version.length;i++){
    if(Integer.valueOf(repo_version[i])>Integer.valueOf(current_version[i])){
      latest=false;
      break;
    }
  }
  return latest;
}
