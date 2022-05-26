import java.util.concurrent.atomic.AtomicInteger;

Future<?> CollisionFuture1;
Future<?> CollisionFuture2;
Future<?> CollisionFuture3;

EntityCollision p1;
EntityCollision p2;
EntityCollision p3;

Future<?> BulletCollision1;
Future<?> BulletCollision2;

class ParticleProcess implements Callable<String>{
  long pTime=0;
  
  ParticleProcess(){
    
  }
  
  String call(){
    pTime=System.nanoTime();
    ArrayList<Particle>nextParticles=new ArrayList<Particle>();
    for(Particle p:Particles){
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    Particles=nextParticles;
    synchronized(ParticleHeap){
    Particles.addAll(ParticleHeap);
    ParticleHeap.clear();
    }
    ArrayList<Exp>nextExp=new ArrayList<Exp>();
    for(Exp e:Exps){
      e.update();
      if(!e.isDead)nextExp.add(e);
    }
    Exps=nextExp;
    synchronized(ExpHeap){
      Exps.addAll(ExpHeap);
      ExpHeap.clear();
    }
    ParticleTime=(System.nanoTime()-pTime)/1000000f;
    return "";
  }
}

class EnemyProcess implements Callable<String>{
  long pTime=0;
  
  EnemyProcess(){
  }
  
  String call(){
    pTime=System.nanoTime();
    player.update();
    ArrayList<Enemy>nextEnemies=new ArrayList<Enemy>();
    for(Enemy e:Enemies){
      if(player.isDead){
        if(e instanceof Explosion){
          e.update();
        }else{
          e.putAABB();
        }
      }else{
        e.update();
      }
      if(!e.isDead)nextEnemies.add(e);
    }
    Enemies.clear();
    Enemies.addAll(nextEnemies);
    synchronized(EnemyHeap){
      Enemies.addAll(EnemyHeap);
      EnemyHeap.clear();
    }
    EnemyTime=(System.nanoTime()-pTime)/1000000f;
    return "";
  }
}

class BulletProcess implements Callable<String>{
  long pTime=0;
  
  BulletProcess(){
    
  }
  
  String call(){
    pTime=System.nanoTime();
    ArrayList<Bullet>nextBullets=new ArrayList<Bullet>();
    for(Bullet b:Bullets){
      if(b.isDead)continue;
      b.update();
      if(!b.isDead)nextBullets.add(b);
    }
    Bullets=nextBullets;
    synchronized(BulletHeap){
      Bullets.addAll(BulletHeap);
      BulletHeap.clear();
    }
    ArrayList<Bullet>nextEneBullets=new ArrayList<Bullet>();
    for(Bullet b:eneBullets){
      if(b.isDead)continue;
      if(player.isDead){
        synchronized(Enemies){
          for(Enemy e:Enemies)b.Collision(e);
        }
        b.putAABB();
      }else{
        b.update();
      }
      if(!b.isDead)nextEneBullets.add(b);
    }
    eneBullets=nextEneBullets;
    synchronized(eneBulletHeap){
      eneBullets.addAll(eneBulletHeap);
      eneBulletHeap.clear();
    }
    BulletTime=(System.nanoTime()-pTime)/1000000f;
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
      float f=arrayX.get(i);
      if((E instanceof Enemy)&&Debug)((Enemy)E).hue=hue;
      switch(EntityDataX.get(f)){
        case "s":Collision(E,i);break;
        case "e":continue;
      }
    }
    return "";
  }
  
  void Collision(Entity E,int i){
    ++i;
    for(int j=i;j<EntityX.size();j++){
      Entity e=entity.get(j);
      float f=arrayX.get(j);
      if(EntityDataX.get(f).equals("e")){
        if(E==e)break;
        continue;
      }
      if(abs(e.Center.y-E.Center.y)<=abs((e.AxisSize.y+E.AxisSize.y)*0.5)){
        E.Collision(e);
        e.Collision(E);
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
