class Explosion extends Enemy{
  ExplosionParticle p;
  boolean myself=false;
  float power=10;
  
  Explosion(Entity e,float size){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size);
    HeapEntity.get(threadNum).add(p);
    myself=e instanceof Myself;
  }
  
  Explosion(Entity e,float size,float time){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size,time);
    HeapEntity.get(threadNum).add(p);
    myself=e instanceof Myself;
  }
  
  void display(){
    if(Debug){
      displayAABB();
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
  void Hit(Weapon w){
    return;
  }
}

class BulletExplosion extends Explosion{
  HashSet<Entity>HitEnemy;
  Weapon parent;
  
  BulletExplosion(Entity e,float size,float time,boolean my,Weapon w){
    super(e,size,time);
    HitEnemy=new HashSet<Entity>();
    myself=my;
    parent=w;
  }
  
  @Override
  void Collision(Entity e){
    if((e instanceof Enemy)&&!(e instanceof Explosion)&&!HitEnemy.contains(e)){
      HitEnemy.add(e);
      ((Enemy)e).Hit(parent);
    }
  }
}

void addExplosion(Entity e,float size){
  HeapEntity.get(0).add(new Explosion(e,size));
}

void addExplosion(Entity e,float size,float time){
  HeapEntity.get(0).add(new Explosion(e,size,time));
}
