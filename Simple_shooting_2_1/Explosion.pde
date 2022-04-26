class Explosion extends Enemy{
  ExplosionParticle p;
  boolean myself=false;
  float power=10;
  
  Explosion(Entity e,float size){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size);
    ParticleHeap.add(p);
  }
  
  void display(){
    p.display();
  }
  
  void update(){
    size=p.nowSize;
    isDead=p.isDead;
    float d=size*0.5;
    EnemyX.put(pos.x-d,this);
    EnemyX.put(pos.x+d,this);
    EnemyData.put(pos.x-d,"s");
    EnemyData.put(pos.x+d,"e");
  }
  
  @Override
  void Collision(Enemy e){
    if(!(e instanceof Explosion))e.Collision(this);
  }
  
  @Override
  void Collision(){
    
  }
}

void addExplosion(Entity e,float size){
  EnemyHeap.add(new Explosion(e,size));
}
