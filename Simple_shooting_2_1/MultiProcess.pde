import java.util.concurrent.atomic.AtomicInteger;

import processing.sound.*;

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
  HashMap<String,SoundFile>sounds=new HashMap<>();
  
  boolean mute=false;
  
  SoundManager(){
  }
  
  void loadSound(){
    String[] names=loadJSONArray(SoundPath+"sounds.json").toStringArray();
    for(String s:names){
      sounds.put(s.split(".wav")[0].split(".mp3")[0],new SoundFile(CopyApplet,SoundPath+s));
    }
  }
  
  void setMute(boolean b){
    mute=b;
  }
  
  void play(String name){
    if(!sounds.containsKey(name)||mute)return;
    sounds.get(name).stop();
    sounds.get(name).play();
  }
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
