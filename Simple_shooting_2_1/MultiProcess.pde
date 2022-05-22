import java.util.concurrent.atomic.AtomicInteger;

Future<?> CollisionFuture1;
Future<?> CollisionFuture2;
Future<?> CollisionFuture3;

EntityCollision p1;
EntityCollision p2;
EntityCollision p3;

Future<?> BulletCollision1;
Future<?> BulletCollision2;

BulletCollision b1;
BulletCollision b2;

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
    /*BulletEnemyX=new TreeMap<Float,Object>(BulletX);
    BulletEnemyX.putAll(EnemyX);
    if(BulletEnemyX.size()!=0){
      int size=BulletEnemyX.size();
      b1=new BulletCollision(0,(int)(size*0.5));
      b2=new BulletCollision((int)(size*0.5),size);
      try{
        BulletCollision1=exec.submit(b1);
        BulletCollision2=exec.submit(b2);
      }
      catch(Exception e) {
      }
      try {
        BulletCollision1.get();
        BulletCollision2.get();
      }
      catch(ConcurrentModificationException e) {
        e.printStackTrace();
      }
      catch(InterruptedException|ExecutionException f) {f.printStackTrace();println(EnemyData,EnemyData.size(),BulletData,BulletData.size());exit();
      }
      catch(NullPointerException g) {g.printStackTrace();exit();
      }
    }*/
    BulletTime=(System.nanoTime()-pTime)/1000000f;
    return "";
  }
}

class EntityCollision implements Callable<String>{
  ArrayList<Float>arrayX;
  ArrayList<Entity>entity;
  TreeMap<Float,Enemy>overEntity;
  float hue;
  int s;
  int l;
  
  EntityCollision(int s,int l){
    this.s=s;
    this.l=l;
    hue=s==0?0:255*(s/(float)EntityX.size());
  }
  
  String call(){
    arrayX=new ArrayList<Float>(EntityX.keySet());
    entity=new ArrayList<Entity>(EntityX.values());
    HashSet<Entity>CollisionList=new HashSet<Entity>();
    HashSet<Entity>CollisionedList=new HashSet<Entity>();
    for(int i=s;s<l;i++){
      Entity E=entity.get(i);
      float f=arrayX.get(i);
      if((E instanceof Enemy)&&Debug)((Enemy)E).hue=hue;
      switch(EntityDataX.get(f)){
        case "s":CollisionList.forEach(e->{
                   if(abs(e.Center.y-E.Center.y)<=abs((e.AxisSize.y+E.AxisSize.y)*0.5)){println(e,E);
                     E.Collision(e);
                     e.Collision(E);
                   }
                 });
                 CollisionedList.add(E);
                 CollisionList.add(E);break;
        case "e":if(CollisionList.contains(E)){
                   CollisionList.remove(E);
                 }else{
                   CollisionedList.forEach(e->{
                     if(abs(e.Center.y-E.Center.y)<=abs((e.AxisSize.y+E.AxisSize.y)*0.5)){
                       E.Collision(e);
                       e.Collision(E);
                     }
                   });
                   CollisionedList.add(E);
                 }break;
      }
      ++s;
    }
    return "";
  }
}

class BulletCollision implements Callable<String>{
  ArrayList<Float>arrayX;
  ArrayList<Object>obj;
  int s;
  int l;
  
  BulletCollision(int s,int l){
    this.s=s;
    this.l=l;
  }
  
  String call(){
    arrayX=new ArrayList<Float>(BulletEnemyX.keySet());
    obj=new ArrayList<Object>(BulletEnemyX.values());
    HashSet<Bullet>bul=new HashSet<Bullet>();
    HashSet<Enemy>ene=new HashSet<Enemy>();
    for(int i=s;s<l;i++){
      float f=arrayX.get(i);
      if(obj.get(i) instanceof Enemy){
        Enemy E=(Enemy)obj.get(i);
        switch(EntityDataX.get(f)){
          case "s":ene.add(E);break;
          case "e":if(ene.contains(E)){
                     ene.remove(E);
                   }else{
                     bul.forEach(b->{
                       if(abs(b.pos.y-E.pos.y)<E.size*1.4142+abs(b.vel.mag())){b.Collision(E);}
                     });
                   }break;
        }
      }else if(obj.get(i) instanceof Bullet){
        Bullet B=(Bullet)obj.get(i);
        switch(BulletData.get(f)){
          case "s":bul.add(B);
                   ene.forEach(e->{
                     if(abs(e.pos.y-B.pos.y)<e.size*1.4142+abs(B.vel.mag())){B.Collision(e);}
                   });break;
          case "e":if(bul.contains(B)){
                     bul.remove(B);
                   }else{
                     ene.forEach(e->{
                       if(abs(e.pos.y-B.pos.y)<e.size*1.4142+abs(B.vel.mag())){B.Collision(e);}
                     });
                   }break;
        }
      }
      ++s;
    }
    return "";
  }
}
