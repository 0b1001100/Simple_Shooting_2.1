class Explosion extends Enemy{
  ExplosionParticle p;
  float power=10;
  
  Explosion(Entity e,float size){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size);
  }
  
  void display(){
    p.display();
  }
  
  void update(){
    p.update();
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
    if(!e.Expl&&qDist(e.pos,pos,(e.size+size)*0.5)){
        e.HP-=power*vectorMagnification;
        e.Expl=true;
    }
  }
  
  @Override
  void Collision(){
    
  }
}

void addExplosion(Entity e,float size){
  Enemies.add(new Explosion(e,size));
}
