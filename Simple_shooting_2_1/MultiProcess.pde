import java.util.concurrent.atomic.AtomicInteger;

class EntityProcess implements Callable<String>{
  long pTime=0;
  byte number;
  int s;
  int l;
  
  EntityProcess(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
  }
  
  String call(){
    pTime=System.nanoTime();
    ArrayList<Entity>next=HeapEntity.get(number);
    for(int i=s;i<l;i++){
      Entity e=Entities.get(i);
      e.threadNum=number;
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
        next.add(e);
      }
    }
    EntityTime=(System.nanoTime()-pTime)/1000000f;
    return "";
  }
  
  void setData(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
  }
}

class EntityCollision implements Callable<String>{
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
    for(int i=s;i<l;i++){
      Entity E=EntityX.get(SortedX[i]);
      if((E instanceof Enemy)&&Debug)((Enemy)E).hue=hue;
      switch(EntityDataX.get(SortedX[i])){
        case "s":Collision(E,i);break;
        case "e":break;
      }
    }
    return "";
  }
  
  void Collision(Entity E,int i){
    ++i;
    for(int j=i,s=EntityX.size();j<s;j++){
      Entity e=EntityX.get(SortedX[j]);
      if(E==e)break;
      if(EntityDataX.get(SortedX[j]).equals("e")){
        continue;
      }
      if(abs(e.Center.y-E.Center.y)<=abs((e.AxisSize.y+E.AxisSize.y)*0.5)){
        E.Collision(e);
      }
    }
  }
  
  void setData(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
    hue=s==0?0:255*(s/(float)EntityX.size());
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
      Entities.get(i).display(g);
    }
    g.endDraw();
    return g;
  }
  
  void setData(int s,int l){
    this.s=s;
    this.l=l;
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
