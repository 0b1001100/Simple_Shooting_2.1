ArrayList<AABBData>EntityDataX=new ArrayList<AABBData>();
ArrayList<ArrayList<AABBData>>HeapEntityDataX=new ArrayList<ArrayList<AABBData>>();
AABBData[]SortedDataX;

class Enemy extends Entity implements Cloneable{
  HashMap<Class<? extends Weapon>,Float>MultiplyerMap=new HashMap<Class<? extends Weapon>,Float>();
  PVector addtionalVel=new PVector();
  Weapon useWeapon=null;
  Weapon ShotWeapon=null;
  ItemTable dropTable;
  boolean inScreen=true;
  boolean hit=false;
  double damage=0;
  float maxAddtionalSpeed=35;
  float rotateSpeed=10;
  float protate=0;
  float playerDistsq=0;
  float hue=0;
  protected double maxHP=10d;
  protected double HP=10d;
  
  Enemy(){
    setColor(new Color(0,0,255));
    init();
  }
  
  Enemy(PVector pos){
    init();
    this.pos=pos;
  }
  
  protected void init(){
  }
  
  protected void setTable(){
    
  }
  
  @Override
  void display(PGraphics g){
    if(!inScreen)return;
    if(Debug){
      displayAABB(g);
    }
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(-rotate);
    g.rectMode(CENTER);
    g.strokeWeight(1);
    g.noFill();
    if(Debug){
      g.colorMode(HSB);
      g.stroke(hue,255,255);
      g.colorMode(RGB);
    }else{
      g.stroke(toColor(c));
    }
    g.rect(0,0,size*0.7071,size*0.7071);
    g.popMatrix();
  }
  
  void update(){
    Process();
    Rotate();
    move();
    Center=pos;
    AxisSize=new PVector(size,size);
    putAABB();
    if(inScreen){
      if(!nearEnemy.contains(this)){
        nearEnemy.add(this);
      }else{
        playerDistsq=sqDist(player.pos,pos);
      }
    }
    super.update();
  }
  
  void Rotate(){
    float rad=atan2(pos.x-player.pos.x,pos.y-player.pos.y);
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,radians(rotateSpeed)*vectorMagnification);
    protate=rotate;
    rotate+=rad;
    rotate=rotate%TWO_PI;
  }
  
  void move(){
    rotate(rotate);
    if(Float.isNaN(Speed)){
      Speed=0;
    }
    addVel(accelSpeed,false);
    pos.add(vel).add(addtionalVel);
    inScreen=-scroll.x<pos.x+size/2&&pos.x-size/2<-scroll.x+width&&-scroll.y<pos.y+size/2&&pos.y-size/2<-scroll.y+height;
  }
  
  private void addVel(float accel,boolean force){
    if(!force){
      Speed+=accel*vectorMagnification;
      Speed=min(maxSpeed,Speed);
    }else{
      Speed+=accel*vectorMagnification;
    }
    vel.add(cos(-rotate-HALF_PI)*Speed,sin(-rotate-HALF_PI)*Speed).mult(vectorMagnification);
    addtionalVel.mult(0.95);
    if(vel.magSq()>maxSpeed*maxSpeed*vectorMagnification){
      vel.normalize().mult(maxSpeed).mult(vectorMagnification);
    }
    if(addtionalVel.magSq()>maxAddtionalSpeed*maxAddtionalSpeed*vectorMagnification){
      addtionalVel.normalize().mult(maxAddtionalSpeed).mult(vectorMagnification);
    }
  }
  
  void addMultiplyer(Class<? extends Weapon> c,float f){
    MultiplyerMap.put(c,f);
  }
  
  void setSize(float s){
    size=s;
  }
  
  void setHP(double h){
    maxHP=h;
    HP=h;
  }
  
  void setWeapon(Weapon w){
    useWeapon=w;
  }
  
  Enemy setPos(PVector p){
    pos=p;
    return this;
  }
  
  void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }else{
      NextEntities.add(new Particle(this,(int)(size*0.5),1));
    }
  }
  
  void Hit(float f){
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }else{
      NextEntities.add(new Particle(this,(int)(size*0.5),1));
    }
  }
  
  void Down(){
    isDead=true;
    NextEntities.add(new Particle(this,(int)(size*3),1));
    NextEntities.add(new Exp(this,ceil(((float)maxHP)*0.5)));
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Explosion){
      e.Collision(this);
    }else if(e instanceof Enemy){
      if(qDist(pos,e.pos,(size+e.size)*0.5)){
        PVector c=pos.copy().sub(e.pos).normalize();
        PVector d=new PVector((size+e.size)*0.5-dist(pos,e.pos),0).rotate(-atan2(pos.x-e.pos.x,pos.y-e.pos.y)-PI*0.5);
        vel=c.copy().mult((-e.Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(vel);
        e.vel=c.copy().mult((Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(e.vel);
        pos.sub(d);
        if(vel.magSq()>maxSpeed*maxSpeed){
          PVector v=vel.copy().normalize().mult(maxSpeed);
          addtionalVel=vel.copy().sub(v);
          vel=v;
        }
      }
    }else if(e instanceof Bullet){
      e.Collision(this);
    }else if(e instanceof Myself){
      if(!player.isDead&&qDist(player.pos,pos,(player.size+size)*0.5)){
        float r=-atan2(pos.x-player.pos.x,pos.y-player.pos.y)-PI*0.5;
        float d=(player.size+size)*0.5-dist(player.pos,pos);
        vel=new PVector(-cos(r)*d,-sin(r)*d);
        addtionalVel=new PVector(0,0);
        pos.add(vel);
        player.Hit(1);
      }
    }
  }
  
  Enemy clone()throws CloneNotSupportedException{
    Enemy clone=(Enemy)super.clone();
    clone.dropTable=dropTable==null?null:dropTable.clone();
    return clone;
  }
  
  void Process(){
    
  }
}

class DummyEnemy extends Enemy implements BlastResistant{
  Exp exp;
  
  {
    exp=new Exp();
    dead=(e)->{
      ((HUDText)main.HUDSet.components.get(3)).endDisplay();
      ((HUDText)main.HUDSet.components.get(4)).setTarget(exp);
    };
  }
  
  @Override
  void init(){
    setHP(20);
    setSize(28);
    maxSpeed=0;
    rotateSpeed=0;
  }
  
  @Override
  void Down(){
    isDead=true;
    NextEntities.add(new Particle(this,(int)(size*3),1));
    NextEntities.add(exp);
  }
  
  @Override
  Enemy setPos(PVector p){
    Enemy e=super.setPos(p);
    exp.setPos(this.pos);
    exp.setExp(10);
    return e;
  }
}

class Turret extends Enemy{
  
  @Override
  protected void init(){
    setHP(2);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
  }
  
  void Process(){
  }
}

class Plus extends Enemy{
  
  @Override
  protected void init(){
    setHP(5);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(20,170,20));
  }
  
  void Process(){
  }
}

class White extends Enemy{
  
  @Override
  protected void init(){
    setHP(7);
    setSize(28);
    maxSpeed=0.8;
    rotateSpeed=4;
    setColor(new Color(255,255,255));
  }
  
  void Process(){
  }
}

class Large_R extends Enemy{
  
  @Override
  protected void init(){
    setHP(10);
    maxSpeed=1;
    rotateSpeed=3;
    setSize(42);
    setMass(50);
    setColor(new Color(255,20,20));
  }
  
  void Process(){
  }
}

class Large_C extends Enemy{
  
  @Override
  protected void init(){
    setHP(12);
    maxSpeed=3;
    rotateSpeed=0.5;
    setSize(35);
    setMass(20);
    setColor(new Color(20,255,255));
  }
  
  void Process(){
  }
}

class ExplosionEnemy extends Enemy{
  {
    dead=(e)->{
      NextEntities.add(new Explosion(e,size*2,0.5,5));
    };
  }
  
  @Override
  protected void init(){
    setHP(14);
    maxSpeed=0.85;
    rotateSpeed=3;
    setSize(24);
    setMass(9);
    setColor(new Color(255,128,0));
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Explosion){
      if(qDist(pos,e.pos,(e.size+size)*0.5)){
        isDead=true;
      }
    }else if(e instanceof Enemy){
      if(qDist(pos,e.pos,(size+e.size)*0.5)){
        PVector c=pos.copy().sub(e.pos).normalize();
        PVector d=new PVector((size+e.size)*0.5-dist(pos,e.pos),0).rotate(-atan2(pos.x-e.pos.x,pos.y-e.pos.y)-PI*0.5);
        vel=c.copy().mult((-e.Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(vel);
        e.vel=c.copy().mult((Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(e.vel);
        pos.sub(d);
        if(vel.magSq()>maxSpeed*maxSpeed){
          PVector v=vel.copy().normalize().mult(maxSpeed);
          addtionalVel=vel.copy().sub(v);
          vel=v;
        }
      }
    }else if(e instanceof Bullet){
      e.Collision(this);
    }else if(e instanceof Myself){
      if(!player.isDead&&qDist(player.pos,pos,(player.size+size)*0.5)){
        float r=-atan2(pos.x-player.pos.x,pos.y-player.pos.y)-PI*0.5;
        float d=(player.size+size)*0.5-dist(player.pos,pos);
        vel=new PVector(-cos(r)*d,-sin(r)*d);
        addtionalVel=new PVector(0,0);
        pos.add(vel);
        player.Hit(1);
      }
    }
  }
}

class Micro_M extends Enemy{
  
  @Override
  protected void init(){
    setHP(16);
    maxSpeed=0.85;
    rotateSpeed=3;
    setSize(20);
    setMass(5);
    setColor(new Color(255,0,255));
  }
}

class Slow_G extends Enemy{
  
  @Override
  protected void init(){
    setHP(18);
    maxSpeed=2;
    rotateSpeed=0.85;
    setSize(25);
    setMass(12);
    setColor(new Color(160,160,160));
  }
  
  @Override
  void Process(){
    if(inScreen){
      if(abs(player.rotate-atan2(pos,player.pos))<radians(50)||abs(player.rotate+TWO_PI-atan2(pos,player.pos))<radians(50)||abs(player.rotate-TWO_PI-atan2(pos,player.pos))<radians(50)){
        maxSpeed=1;
      }else{
        maxSpeed=3;
      }
    }else{
      maxSpeed=2;
    }
  }
}

class M_Boss_Y extends Enemy implements BossEnemy{
  float moveCoolTime=180;
  HUDText boss;
  
  @Override
  protected void init(){
    setHP(1000);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(52);
    setMass(35);
    setColor(new Color(255,255,10));
    boss=new HUDText("BOSS");
    dead=(e)->{
      StageFlag.add("Survive_10_min");
      stage.addSchedule("Stage1",new TimeSchedule(stage.time/60f+3,(s)->{scene=3;}));
      boss.Dispose();
    };
  }
  
  @Override
  void Process(){
    if(!inScreen&&moveCoolTime<=0){
      pos.x=player.pos.x+sign(player.pos.x-pos.x)*min(abs(player.pos.x-pos.x),width*0.5);
      pos.y=player.pos.y+sign(player.pos.y-pos.y)*min(abs(player.pos.y-pos.y),height*0.5);
      rotate=(rotate+PI)%TWO_PI;
      moveCoolTime=180;
    }
    moveCoolTime-=vectorMagnification;
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    boss.setTarget(this);
    main.HUDSet.add(boss);
    boss.startDisplay();
    return this;
  }
}

interface BossEnemy{
}

interface BlastResistant{
}
