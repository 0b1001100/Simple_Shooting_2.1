abstract class Controller{
  HashMap<String,StatusParameter>statusMap=new HashMap<>();
  
  public Controller(){
  }
  
  abstract void update(Entity e);
  
  public void addStatus(String s,StatusParameter p){
    statusMap.put(s,p);
  }
  
  public boolean statusContains(String s){
    return statusMap.containsKey(s);
  }
  
  public float applyStatus(String name,float f){
    float mag=1f;
    for(StatusParameter m:statusMap.values()){
      if(m.getName().equals(name)){
        mag+=m.getValue();
      }
    }
    mag=max(0f,mag);
    return f*mag;
  }
}

class VoidController extends Controller{
  public void update(Entity e){}
}

class SurvivorEnemyController extends Controller{
  
  public void update(Entity entity){
    HashMap<String,StatusParameter>next=new HashMap<>();
    for(String s:statusMap.keySet()){
      StatusParameter p=statusMap.get(s);
      if(p==null)continue;
      p.update();
      if(!p.isEnd())next.put(s,p);
    }
    statusMap=next;
    Enemy e=(Enemy)entity;
    Rotate(e);
    move(e);
    e.Center=e.pos.copy();
    e.AxisSize=new PVector(e.size,e.size);
    e.putAABB();
    if(e.inScreen){
      if(!nearEnemy.contains(e)){
        nearEnemy.add(e);
      }else{
        e.playerDistsq=sqDist(player.pos,e.pos);
      }
    }
  }
  
  void Rotate(Enemy e){
    float s=applyStatus("Speed",e.rotateSpeed);
    float rad=atan2(e.pos,player.pos);
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(s)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
  }
  
  void move(Enemy e){
    if(Float.isNaN(e.Speed)){
      e.Speed=0;
    }
    float s=applyStatus("Speed",0.9f);
    e.addVel(e.accelSpeed,false);
    e.vel.x=(abs(e.vel.x)<0.01?0f:e.vel.x)*s;
    e.vel.y=(abs(e.vel.y)<0.01?0f:e.vel.y)*s;
    e.Speed=(abs(e.Speed)<0.01?0f:e.Speed)*s;
    e.pos.add(e.vel.x*vectorMagnification,e.vel.y*vectorMagnification);
  }
}

class FixedTurretController extends Controller{
  
  public void update(Entity entity){
    HashMap<String,StatusParameter>next=new HashMap<>();
    for(String s:statusMap.keySet()){
      StatusParameter p=statusMap.get(s);
      if(p==null)continue;
      p.update();
      if(!p.isEnd())next.put(s,p);
    }
    statusMap=next;
    Enemy e=(Enemy)entity;
    Rotate(e);
    e.Center=e.pos.copy();
    e.AxisSize=new PVector(e.size,e.size);
    e.putAABB();
    if(e.inScreen){
      if(!nearEnemy.contains(e)){
        nearEnemy.add(e);
      }else{
        e.playerDistsq=sqDist(player.pos,e.pos);
      }
    }
  }
  
  void Rotate(Enemy e){
    float s=applyStatus("Speed",e.rotateSpeed);
    float rad=atan2(e.pos,player.pos);
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(s)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
  }
}

class AsteroidController extends Controller{
  float rotate_angle=radians(random(0.5,2));
  
  public void update(Entity entity){
    Enemy e=(Enemy)entity;
    move(e);
    e.Center=e.pos.copy();
    e.AxisSize=new PVector(e.size,e.size);
    e.putAABB();
    if(e.inScreen){
      if(!nearEnemy.contains(e)){
        nearEnemy.add(e);
      }else{
        e.playerDistsq=sqDist(player.pos,e.pos);
      }
    }
  }
  
  void Rotate(Enemy e){
    float s=applyStatus("Speed",e.rotateSpeed);
    float rad=e.rotate+rotate_angle;
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(s)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
  }
  
  void move(Enemy e){
    if(Float.isNaN(e.Speed)){
      e.Speed=0;
    }
    float s=applyStatus("Speed",0.9f);
    e.addVel(e.accelSpeed,false);
    e.vel.x=(abs(e.vel.x)<0.01?0f:e.vel.x)*s;
    e.vel.y=(abs(e.vel.y)<0.01?0f:e.vel.y)*s;
    e.Speed=(abs(e.Speed)<0.01?0f:e.Speed)*s;
    e.pos.add(e.vel.x*vectorMagnification,e.vel.y*vectorMagnification);
  }
}

class RotateTurretController extends Controller{
  
  public void update(Entity entity){
    HashMap<String,StatusParameter>next=new HashMap<>();
    for(String s:statusMap.keySet()){
      StatusParameter p=statusMap.get(s);
      if(p==null)continue;
      p.update();
      if(!p.isEnd())next.put(s,p);
    }
    statusMap=next;
    Enemy e=(Enemy)entity;
    Rotate(e);
    e.Center=e.pos.copy();
    e.AxisSize=new PVector(e.size,e.size);
    e.putAABB();
    if(e.inScreen){
      if(!nearEnemy.contains(e)){
        nearEnemy.add(e);
      }else{
        e.playerDistsq=sqDist(player.pos,e.pos);
      }
    }
  }
  
  void Rotate(Enemy e){
    e.rotate+=e.rotateSpeed;
    e.rotate=e.rotate%TWO_PI;
  }
}

class TornadeController extends SurvivorEnemyController{
  
  void Rotate(Enemy e){
    float s=applyStatus("Speed",e.rotateSpeed);
    float rad=atan2(e.pos,player.pos)+HALF_PI*0.25;
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(s)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
  }
}

class WormController extends SurvivorEnemyController{
  
  void Rotate(Enemy e){
    Worm.Worm_body w=(Worm.Worm_body)e;
    float s=applyStatus("Speed",e.rotateSpeed);
    PVector target=player.pos;
    if(w.num!=0){
      target=w.parent.body.get(w.num-1).pos;
    }
    float rad=atan2(e.pos,target);
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(s)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
  }
  
  void move(Enemy e){
    if(Float.isNaN(e.Speed)){
      e.Speed=0;
    }
    Worm.Worm_body w=(Worm.Worm_body)e;
    float s=applyStatus("Speed",0.9f);
    e.addVel(e.accelSpeed,false);
    if(w.num!=0){
      PVector dist=PVector.sub(w.parent.body.get(w.num-1).pos,w.pos).add(w.parent.body.get(w.num-1).vel.copy().normalize().mult(-10));
      float mag=dist.mag()-10;
      e.vel.add(dist.normalize().mult(mag*0.1));
    }
    e.vel.x=(abs(e.vel.x)<0.01?0f:e.vel.x)*s;
    e.vel.y=(abs(e.vel.y)<0.01?0f:e.vel.y)*s;
    e.Speed=(abs(e.Speed)<0.01?0f:e.Speed)*s;
    e.pos.add(e.vel.x*vectorMagnification,e.vel.y*vectorMagnification);
  }
}

class ArchiveEnemyController extends Controller{
  PVector point=new PVector();
  boolean onPoint=true;
  float stopTime=0;
  float maxStopTime=300;
  float minStopTime=180;
  int state=0;
  
  public void update(Entity entity){
    HashMap<String,StatusParameter>next=new HashMap<>();
    for(String s:statusMap.keySet()){
      StatusParameter p=statusMap.get(s);
      p.update();
      if(!p.isEnd())next.put(s,p);
    }
    statusMap=next;
    Enemy e=(Enemy)entity;
    switch(state){
      case 0:Rotate(e);break;
      case 1:Rotate(e);move(e);break;
      case 2:stop(e);break;
    }
    e.Center=e.pos;
    e.AxisSize=new PVector(e.size,e.size);
    e.putAABB();
    if(e.inScreen){
      if(!nearEnemy.contains(e)){
        nearEnemy.add(e);
      }else{
        e.playerDistsq=sqDist(player.pos,e.pos);
      }
    }
  }
  
  void Rotate(Enemy e){
    float s=applyStatus("Speed",e.rotateSpeed);
    float rad=atan2(e.pos,point);
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(s)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
    if(abs(rad)<radians(0.01))state=1;
  }
  
  void move(Enemy e){
    if(Float.isNaN(e.Speed)){
      e.Speed=0;
    }
    float s=applyStatus("Speed",e.accelSpeed);
    e.addVel(s,false);
    e.vel.x=abs(e.vel.x)<0.01?0f:e.vel.x;
    e.vel.y=abs(e.vel.y)<0.01?0f:e.vel.y;
    e.Speed=abs(e.Speed)<0.01?0f:e.Speed;
    e.pos.add(e.vel.x*vectorMagnification,e.vel.y*vectorMagnification);
    if(qDist(point,e.pos,e.size*0.5)){
      onPoint=true;
      state=2;
    }
  }
  
  void stop(Enemy e){
    if(stopTime<=0){
      stopTime=random(minStopTime,maxStopTime);
      onPoint=false;
      state=0;
      point.set(random(-width*0.5,width*0.5),random(-height*0.5,height*0.5));
    }else{
      stopTime-=vectorMagnification;
    }
  }
}
