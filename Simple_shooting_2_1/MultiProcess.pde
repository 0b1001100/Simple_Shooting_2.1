import java.util.concurrent.atomic.AtomicInteger;

Future<?> CollisionFuture1;
Future<?> CollisionFuture2;
Future<?> CollisionFuture3;

EnemyCollision p1;
EnemyCollision p2;
EnemyCollision p3;

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
      e.update();
      if(!e.isDead)nextEnemies.add(e);
    }
    Enemies.clear();
    Enemies.addAll(nextEnemies);
    synchronized(EnemyHeap){
      Enemies.addAll(EnemyHeap);
      EnemyHeap.clear();
    }
    p1=new EnemyCollision(0,(int)(EnemyX.size()*0.33));
    p2=new EnemyCollision((int)(EnemyX.size()*0.33), (int)(EnemyX.size()*0.66));
    p3=new EnemyCollision((int)(EnemyX.size()*0.66), EnemyX.size());
    try{
      CollisionFuture1=exec.submit(p1);
      CollisionFuture2=exec.submit(p2);
      CollisionFuture3=exec.submit(p3);
    }
    catch(Exception e) {
    }
    try {
      CollisionFuture1.get();
      CollisionFuture2.get();
      CollisionFuture3.get();
    }
    catch(ConcurrentModificationException e){
      e.printStackTrace();
    }
    catch(InterruptedException|ExecutionException f){
    }
    catch(NullPointerException g){
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
      b.update();
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

class EnemyCollision implements Callable<String>{
  ArrayList<Float>arrayX;
  ArrayList<Enemy>enemy;
  TreeMap<Float,Enemy>overEnemy;
  float hue;
  int s;
  int l;
  
  EnemyCollision(int s,int l){
    this.s=s;
    this.l=l;
    hue=s==0?0:255*(s/(float)EnemyX.size());
  }
  
  String call(){
    arrayX=new ArrayList<Float>(EnemyX.keySet());
    enemy=new ArrayList<Enemy>(EnemyX.values());
    HashSet<Enemy>CollisionList=new HashSet<Enemy>();
    HashSet<Enemy>CollisionedList=new HashSet<Enemy>();
    for(int i=s;s<l;i++){
      Enemy E=enemy.get(i);
      float f=arrayX.get(i);
      if(Debug)E.hue=hue;
      switch(EnemyData.get(f)){
        case "s":CollisionList.forEach(e->{
                   if(qDist(e.pos,E.pos,(e.size+E.size)*0.5))E.Collision(e);
                 });
                 CollisionedList.add(E);
                 CollisionList.add(E);break;
        case "e":if(CollisionList.contains(E)){
                   CollisionList.remove(E);
                 }else{
                   CollisionedList.forEach(e->{
                     if(qDist(e.pos,E.pos,(e.size+E.size)*0.5))E.Collision(e);
                   });
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
        switch(EnemyData.get(f)){
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
