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
  
  Explosion(Entity e,float size,float time){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size,time);
    ParticleHeap.add(p);
  }
  
  void display(){
    if(Debug){
      rectMode(CENTER);
      strokeWeight(1);
      stroke(255);
      noFill();
      rect(Center.x,Center.y,AxisSize.x,AxisSize.y);
    }
  }
  
  void update(){
    size=p.nowSize;
    isDead=p.isDead;
    Center=pos;
    AxisSize=new PVector(size,size);
    putAABB();
  }
  
  @Override
  void Collision(Entity e){
    if(!(e instanceof Explosion))e.Collision(this);
  }
  
  @Override
  void Collision(){
    
  }
  
  @Override
  void Hit(Weapon w){
    return;
  }
}

void addExplosion(Entity e,float size){
  EnemyHeap.add(new Explosion(e,size));
}

void addExplosion(Entity e,float size,float time){
  EnemyHeap.add(new Explosion(e,size,time));
}
