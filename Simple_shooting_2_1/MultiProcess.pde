import java.util.concurrent.atomic.AtomicInteger;

class EntityProcess implements Callable<String>{
  long pTime=0;
  int s;
  int l;
  
  EntityProcess(int s,int l){
    this.s=s;
    this.l=l;
  }
  
  String call(){
    pTime=System.nanoTime();
    for(int i=s;i<l;i++){
      Entity e=Entities.get(i);
      if(player.isDead){
        if((e instanceof Explosion)||(e instanceof Particle)){
          e.update();
        }else{
          e.putAABB();
        }
      }else{
        e.update();
      }
      if(!e.isDead){
        NextEntities.add(e);
      }
    }
    EnemyTime=(System.nanoTime()-pTime)/1000000f;
    return "";
  }
}

class EntityCollision implements Callable<String>{
  ArrayList<Float>arrayX;
  ArrayList<Entity>entity;
  TreeMap<Float,Enemy>overEntity;
  float hue;
  byte number;
  int s;
  int l;
  
  EntityCollision(int s,int l,byte num){
    this.s=s;
    this.l=l;
    hue=s==0?0:255*(s/(float)EntityX.size());
    number=num;
  }
  
  String call(){
    arrayX=new ArrayList<Float>(EntityX.keySet());
    entity=new ArrayList<Entity>(EntityX.values());
    for(int i=s;i<l;i++){
      Entity E=entity.get(i);
      if((E instanceof Enemy)&&Debug)((Enemy)E).hue=hue;
      switch(EntityDataX.get(arrayX.get(i))){
        case "s":Collision(E,i);break;//kore
        case "e":break;
      }
    }
    return "";
  }
  
  void Collision(Entity E,int i){
    ++i;
    for(int j=i;j<EntityX.size();j++){
      Entity e=entity.get(j);
      if(E==e)break;
      if(EntityDataX.get(arrayX.get(j)).equals("e")){
        continue;
      }
      if(abs(e.Center.y-E.Center.y)<=abs((e.AxisSize.y+E.AxisSize.y)*0.5)){
        E.Collision(e);
      }
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
  
  void setEnd(byte b){
    end=b;
  }
  
  byte getEnd(){
    return end;
  }
  
  @Override
  String toString(){
    return number+":"+e;
  }
}
