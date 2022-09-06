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
  float expMag=0.5;
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
  
  void setExpMag(float m){
    expMag=e;
  }
  
  void Down(){
    isDead=true;
    NextEntities.add(new Particle(this,(int)(size*3),1));
    NextEntities.add(new Exp(this,ceil(((float)maxHP)*expMag)));
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
    addMultiplyer(TurretWeapon.class,1.2);
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
    addMultiplyer(EnergyBullet.class,1.1);
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
    addMultiplyer(ReflectorWeapon.class,1.2);
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
    addMultiplyer(LaserWeapon.class,1.2);
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
    addMultiplyer(MirrorWeapon.class,1.2);
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
    addMultiplyer(GrenadeWeapon.class,1.2);
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
    addMultiplyer(G_ShotWeapon.class,1.2);
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
    addMultiplyer(LightningWeapon.class,1.2);
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
      stage.addSchedule("Stage1",new TimeSchedule(stage.time/60f+3,(s)->{if(!stageList.contains("Stage2"))stageList.addContent("Stage2");scene=3;}));
      boss.Dispose();
    };
    addMultiplyer(PlasmaFieldWeapon.class,1.2);
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

class Turret_S extends Enemy{
  Entity target;
  float cooltime=0;
  
  @Override
  protected void init(){
    setHP(2);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
    target=player;
    setExpMag(1);
    addMultiplyer(TurretWeapon.class,1.2);
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new EnemyWeapon(this));
    return this;
  }
  
  void Process(){
    if(target!=player&&!EntitySet.contains(target))target=player;
    cooltime+=vectorMagnification;
    if(useWeapon.coolTime<cooltime){
      useWeapon.shot();
      cooltime=0;
    }
  }
  
  @Override
  void Rotate(){
    float rad=atan2(pos.x-target.pos.x,pos.y-target.pos.y);
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,radians(rotateSpeed)*vectorMagnification);
    protate=rotate;
    rotate+=rad;
    rotate=rotate%TWO_PI;
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
}

class Plus_S extends Turret_S{
  
  @Override
  protected void init(){
    setHP(5);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
    target=player;
    setColor(new Color(20,170,20));
    setExpMag(0.8);
    addMultiplyer(EnergyBullet.class,1.2);
  }
}

class Slime extends Enemy{
  protected int scale=2;
  
  @Override
  protected void init(){
    scale=2;
    setHP(3*scale);
    setSize(18*max(1,scale*0.85));
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(20,255,0));
    addMultiplyer(EnergyBullet.class,1.1);
  }
  
  @Override
  void Process(){
    if(isDead&&scale>1){
      float next=18*max(1,(scale-1)*0.85)*0.5;
      Slime s1=(Slime)new Slime().setPos(pos.copy().add(next*cos(-rotate),next*cos(-rotate)));
      s1.setScale(scale-1);
      Slime s2=(Slime)new Slime().setPos(pos.copy().sub(next*cos(-rotate),next*cos(-rotate)));
      s2.setScale(scale-1);
      NextEntities.addAll(Arrays.asList(s1,s2));
    }
  }
  
  @Override
  Slime clone()throws CloneNotSupportedException{
    Slime s=(Slime)super.clone();
    s.setScale(scale);
    return s;
  }
  
  void setScale(int i){
    scale=i;
    setSize(18*max(1,scale*0.85));
    setHP(3*scale);
  }
}

class Decay extends Enemy{
  
  @Override
  protected void init(){
    setHP(7);
    setSize(9+3*(float)HP);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(240,240,255));
    addMultiplyer(ReflectorWeapon.class,1.2);
  }
  
  @Override
  void Process(){
    setSize(9+3*(float)HP);
  }
}

class White_S extends Turret_S{
  
  @Override
  protected void init(){
    setHP(8);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
    target=player;
    setColor(new Color(255,255,255));
    setExpMag(0.8);
    addMultiplyer(ReflectorWeapon.class,1.2);
  }
}

class Division extends Enemy{
  
  Division(){
    super();
  }
  
  Division(float hp){
    init();
    maxHP=hp;
    HP=hp;
    setSize(10+2.5*(float)HP);
  }
  
  @Override
  protected void init(){
    setHP(10);
    setSize(10+2.5*(float)HP);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(255,0,20));
    addMultiplyer(LaserWeapon.class,1.2);
  }
  
  @Override
  void Hit(Weapon w){
    super.Hit(w);
    if(HP<2||w.getClass()==PlasmaFieldWeapon.class)return;
    HP*=0.5;
    setSize(10+2.5*(float)HP);
    NextEntities.add(new Division((float)HP).setPos(pos.copy().add(cos(-rotate+PI)*size*0.5,sin(-rotate+PI)*size*0.5)));
  }
}

class Duplication extends Enemy{
  float time=0;
  
  Duplication(){
    super();
  }
  
  Duplication(float hp,float size){
    init();
    maxHP=hp;
    HP=hp;
    setSize(size);
  }
  
  @Override
  protected void init(){
    setHP(13);
    setSize(35);
    maxSpeed=3;
    rotateSpeed=0.5;
    setMass(20);
    setColor(new Color(20,225,255));
    addMultiplyer(MirrorWeapon.class,1.2);
  }
  
  @Override
  void update(){
    time+=vectorMagnification;
    if(time>600){
      time=0;
      if(HP>2){
      HP*=0.5;
      setSize(size*0.5);
      NextEntities.add(new Duplication((float)HP,size).setPos(pos.copy().add(cos(-rotate+PI)*size*0.5,sin(-rotate+PI)*size*0.5)));
      }
    }
    super.update();
  }
}

class ExplosionEnemy_Micro extends ExplosionEnemy{
  
  @Override
  protected void init(){
    setHP(16);
    maxSpeed=0.8;
    rotateSpeed=3;
    setSize(20);
    setMass(8);
    setColor(new Color(255,128,0));
    addMultiplyer(GrenadeWeapon.class,1.2);
  }
}

class Micro_Y extends Enemy{
  
  @Override
  protected void init(){
    setHP(18);
    maxSpeed=0.8;
    rotateSpeed=3;
    setSize(16);
    setMass(4);
    setColor(new Color(255,255,0));
    addMultiplyer(G_ShotWeapon.class,1.2);
  }
}

class Ghoast extends Enemy{
  
  @Override
  protected void init(){
    setHP(15);
    maxSpeed=2;
    rotateSpeed=0.85;
    setSize(25);
    setMass(12);
    setExpMag(1);
    setColor(new Color(10,255,255));
    addMultiplyer(LightningWeapon.class,1.2);
  }
  
  @Override
  void Process(){
    if(inScreen){
      if(abs(player.rotate-atan2(pos,player.pos))<radians(50)||abs(player.rotate+TWO_PI-atan2(pos,player.pos))<radians(50)||abs(player.rotate-TWO_PI-atan2(pos,player.pos))<radians(50)){
        if(c.getAlpha()==40)setColor(new Color(10,255,255,255));
      }else{
        if(c.getAlpha()==255)setColor(new Color(10,255,255,40));
      }
    }else{
      if(c.getAlpha()==40)setColor(new Color(10,255,255,255));
    }
  }
}

class Formation extends M_Boss_Y implements BossEnemy{
  ArrayList<Formation_Copy>child=new ArrayList<Formation_Copy>();
  float age=0;
  
  @Override
  void init(){
    setHP(1400);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(58);
    setMass(37);
    setColor(new Color(150,95,255));
    boss=new HUDText("BOSS");
    dead=(e)->{
      StageFlag.add("Survive_10_min");
      stage.addSchedule("Stage2",new TimeSchedule(stage.time/60f+3,(s)->{scene=3;}));
      boss.Dispose();
    };
    addMultiplyer(G_ShotWeapon.class,1.2);
  }
  
  @Override
  void Process(){
    super.Process();
    age+=vectorMagnification;
    if(HP<700&&age>1800&&child.size()<2){
      age=0;
      Formation_Copy copy=new Formation_Copy(HP*0.5);
      stage.addSpown(pos.copy().add(new PVector(size,0).rotate(random(TWO_PI))),copy);
      child.add(copy);
    }
    ArrayList<Formation_Copy>nextChild=new ArrayList<Formation_Copy>();
    for(Formation_Copy f:child){
      if(EntitySet.contains(child))nextChild.add(f);
    }
    child=nextChild;
  }

  private class Formation_Copy extends M_Boss_Y implements BossEnemy{
    
    Formation_Copy(double hp){
      setHP(hp);
      init();
    }
    
    @Override
    void init(){
      maxSpeed=1.85;
      rotateSpeed=1.2;
      setSize(50);
      setMass(37);
      setColor(new Color(150,95,255));
      addMultiplyer(G_ShotWeapon.class,1.2);
    }
    
    @Override
    Formation_Copy setPos(PVector p){
      pos=p;
      return this;
    }
  }
}

interface BossEnemy{
}

interface BlastResistant{
}
