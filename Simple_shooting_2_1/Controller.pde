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
      p.update();
      if(!p.isEnd())next.put(s,p);
    }
    statusMap=next;
    Enemy e=(Enemy)entity;
    Rotate(e);
    move(e);
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
    float s=applyStatus("Speed",e.accelSpeed);
    e.addVel(s,false);
    e.pos.add(e.vel.copy().mult(vectorMagnification));
  }
}
