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
    }else if(damage>0){
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
    }else if(damage>0){
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
  public void Collision(Entity e){
    if(e.co_type==CollisionType.Inside){
      e.EnemyCollision(this);
    }else{
      if(e instanceof Explosion){
        ExplosionCollision((Explosion)e);
      }else if(e instanceof Enemy){
        EnemyCollision((Enemy)e);
      }else if(e instanceof Bullet){
        BulletCollision((Bullet)e);
      }else if(e instanceof Myself){
        MyselfCollision((Myself)e);
      }else if(e instanceof WallEntity){
        WallCollision((WallEntity)e);
      }
    }
  }
  
  @Override
  void ExplosionCollision(Explosion e){
    e.EnemyCollision(this);
  }
  
  @Override
  void EnemyCollision(Enemy e){
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
  }
  
  @Override
  void BulletCollision(Bullet b){
    b.EnemyCollision(this);
  }
  
  @Override
  void MyselfCollision(Myself m){
    if(!m.isDead&&qDist(m.pos,pos,(m.size+size)*0.5)){
      float r=-atan2(pos.x-m.pos.x,pos.y-m.pos.y)-PI*0.5;
      float d=(m.size+size)*0.5-dist(m.pos,pos);
      vel=new PVector(-cos(r)*d,-sin(r)*d);
      addtionalVel=new PVector(0,0);
      pos.add(vel);
      m.Hit(1);
    }
  }
  
  @Override
  void WallCollision(WallEntity w){
    w.EnemyCollision(this);
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
    co_type=CollisionType.Inside;
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
  void ExplosionCollision(Explosion e){
    if(qDist(pos,e.pos,(e.size+size)*0.5)){
      isDead=true;
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
    if(StageName.equals("Stage1")){
      boss=new HUDText("BOSS");
      dead=(e)->{
        StageFlag.add("Survive_10_min");
        stage.addSchedule(StageName,new TimeSchedule(stage.time/60f+3,(s)->{if(!stageList.contains("Stage2"))stageList.addContent("Stage2");scene=3;}));
        boss.Dispose();
      };
    }
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
    if(StageName.equals("Stage1")){
      boss.setTarget(this);
      main.HUDSet.add(boss);
      boss.startDisplay();
    }
    return this;
  }
}

class Turret_S extends Enemy{
  Bullet b;
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
    if(StageName.equals("Stage2")){
      boss=new HUDText("BOSS");
      dead=(e)->{
        StageFlag.add("Survive_10_min");
        stage.addSchedule(StageName,new TimeSchedule(stage.time/60f+3,(s)->{if(!stageList.contains("Stage3"))stageList.addContent("Stage3");scene=3;}));
        boss.Dispose();
      };
    }
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
  
  @Override
  Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage2")){
      boss.setTarget(this);
      main.HUDSet.add(boss);
      boss.startDisplay();
    }
    return this;
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

class Poison extends Turret_S{
  
  @Override
  protected void init(){
    setHP(6);
    maxSpeed=0.8;
    rotateSpeed=3;
    setExpMag(0.85);
    setSize(28);
    setColor(new Color(120,200,30));
    addMultiplyer(AntiSkillWeapon.class,30);
    addMultiplyer(EnemyPoisonWeapon.class,30);
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new EnemyPoisonWeapon(this));
    return this;
  }
}

class AntiPlasmaField extends Enemy{
  
  @Override
  protected void init(){
    setHP(8);
    setExpMag(0.85);
    setSize(28);
    maxSpeed=1;
    rotateSpeed=3;
    setColor(new Color(255,250,70));
    addMultiplyer(PlasmaFieldWeapon.class,0);
  }
  
  void Process(){
  }
}

class Boost extends Enemy{
  float time=0;
  float edge;
  boolean boost=false;
  
  @Override
  protected void init(){
    edge=random(210,270);
    setHP(10);
    setExpMag(0.8);
    setSize(22);
    maxSpeed=0.5;
    rotateSpeed=2;
    setColor(new Color(255,220,220));
  }
  
  void Process(){
    time+=vectorMagnification;
    if(!boost&&time>edge){
      boost=true;
      time=0;
    }
    if(boost){
      if(time<60){
        maxSpeed=4;
      }else{
        boost=false;
        maxSpeed=0.5;
        time=0;
      }
    }
  }
}

class Teleport extends Enemy{
  float time=0;
  float edge;
  
  @Override
  protected void init(){
    edge=random(210,270);
    setHP(13);
    setExpMag(1);
    setSize(24);
    maxSpeed=0.7;
    rotateSpeed=2;
    setColor(new Color(235,110,255));
    addMultiplyer(G_ShotWeapon.class,1.2);
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
      g.stroke(c.getRed(),c.getGreen(),c.getBlue(),time>edge-60?255*(1-((edge-time)%20)/20):255);
    }
    g.rect(0,0,size*0.7071,size*0.7071);
    g.popMatrix();
  }
  
  void Process(){
    time+=vectorMagnification;
    if(time>edge){
      pos=player.pos.copy().add(new PVector(max(player.size*7.5,sqrt(playerDistsq)+random(-30,30)),0).rotate(random(0,TWO_PI)));
      setColor(new Color(235,110,255));
      time=0;
    }
  }
}

class Amplification extends Enemy{
  
  @Override
  protected void init(){
    setHP(15);
    setExpMag(0.6);
    setSize(38-2*(float)HP);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(235,85,85));
    addMultiplyer(LaserWeapon.class,1.2);
  }
  
  @Override
  void Process(){
    setSize(38-2*(float)HP);
  }
}

class AntiBullet extends Enemy{
  
  @Override
  protected void init(){
    setExpMag(1);
    setHP(18);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(85,150,235));
    co_type=CollisionType.Inside;
  }
  
  @Override
  void BulletCollision(Bullet b){
    if(CircleCollision(pos,size,b.pos,b.vel)){
      b.isDead=true;
      addtionalVel=vel.copy().mult(-(vel.mag()/Mass));
      if(b instanceof GravityBullet||b instanceof GrenadeBullet||b instanceof FireBullet||b instanceof PlasmaFieldBullet)Hit(b.parent);
    }
  }
}

class AntiExplosion extends Enemy implements BlastResistant{
  
  @Override
  protected void init(){
    setExpMag(0.65);
    setHP(20);
    setSize(28);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(80,100,250));
    addMultiplyer(FireWeapon.class,0.7);
  }
}

class AntiSkill extends Turret_S{
  
  @Override
  protected void init(){
    setHP(23);
    maxSpeed=0.6;
    rotateSpeed=3;
    setExpMag(1);
    setSize(28);
    setColor(new Color(210,235,200));
    addMultiplyer(AntiSkillWeapon.class,30);
    addMultiplyer(EnemyPoisonWeapon.class,30);
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new AntiSkillWeapon(this));
    return this;
  }
}

class EnemyShield extends M_Boss_Y implements BossEnemy{
  ArrayList<EnemyShield_Child>child=new ArrayList<EnemyShield_Child>();
  boolean attack=false;
  boolean shot=false;
  float age=0;
  float rad=0;
  int attacknum=0;
  
  @Override
  void init(){
    setHP(1850);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(62);
    setMass(37);
    setColor(new Color(10,180,255));
    if(StageName.equals("Stage3")){
      boss=new HUDText("BOSS");
      dead=(e)->{
        StageFlag.add("Survive_10_min");
        stage.addSchedule(StageName,new TimeSchedule(stage.time/60f+3,(s)->{if(!stageList.contains("Stage4"))stageList.addContent("Stage4");scene=3;}));
        boss.Dispose();
      };
    }
    addMultiplyer(SatelliteWeapon.class,1.2);
  }
  
  @Override
  void Process(){
    super.Process();
    age+=vectorMagnification;
    rad+=radians(vectorMagnification*5);
    if(age>300&&child.size()<12&&!shot){
      age=0;
      EnemyShield_Child bullet=(EnemyShield_Child)new EnemyShield_Child(child.size()).setPos(pos.copy().add(new PVector(80,0).rotate(rad+TWO_PI*(child.size()+1)/12)));
      NextEntities.add(bullet);
      this.child.add(bullet);
    }else if(age>300&&(child.size()==12||shot)){
      shot=true;
      ArrayList<EnemyShield_Child>list=new ArrayList<EnemyShield_Child>();
      for(EnemyShield_Child c:child){
        if(abs(c.rotate-atan2(player.pos,c.pos))<radians(50)||abs(c.rotate+TWO_PI-atan2(player.pos,c.pos))<radians(50)||abs(c.rotate-TWO_PI-atan2(player.pos,c.pos))<radians(50)){
          list.add(c);
        }
      }
      if(list.size()>0){
        EnemyShield_Child b=list.get(round(random(0,list.size()-1)));
        b.shot();
        if(child.size()==0)shot=false;
        age=0;
      }
    }
    ArrayList<EnemyShield_Child>nextChild=new ArrayList<EnemyShield_Child>();
    for(EnemyShield_Child f:child){
      if(EntitySet.contains(f))nextChild.add(f);
    }
    child=nextChild;
  }
  
  @Override
  Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage3")){
      boss.setTarget(this);
      main.HUDSet.add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  private PVector getPos(){
    return pos;
  }
  
  class EnemyShield_Child extends Enemy{
    int num;
    boolean go=false;
    
    EnemyShield_Child(int n){
      super();
      num=n;
    }
  
    @Override
    void init(){
      setHP(15);
      maxSpeed=5;
      rotateSpeed=0.8;
      setSize(25);
      setMass(20);
      setColor(new Color(10,180,255));
      addMultiplyer(SatelliteWeapon.class,1.2);
    }
    
    @Override
    void Process(){
      if(!go){
        HP=min(15f,(float)HP+3);
        rotate=atan2(pos,getPos());
        pos=getPos().copy().add(new PVector(80,0).rotate(rad+TWO_PI*(num+1)/12));
        vel=new PVector(0,10).rotate(rad);
      }else{
        if(!inScreen)maxSpeed=2.5;
      }
    }
    
    void shot(){
      vel=player.pos.copy().sub(pos).normalize().mult(5);
      child.remove(this);
      go=true;
    }
  }
}

class Bound extends Turret_S{
  
  @Override
  protected void init(){
    setHP(8);
    setSize(28);
    setExpMag(1);
    setColor(new Color(255,100,170));
    maxSpeed=0.7;
    rotateSpeed=3;
    addMultiplyer(TurretWeapon.class,1.2);
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new BoundWeapon(this));
    return this;
  }
}

class AntiBulletField extends Enemy{
  AntiBulletFieldBullet child=null;
  
  @Override
  protected void init(){
    setHP(11);
    setSize(28);
    setExpMag(1);
    setColor(new Color(105,60,255));
    maxSpeed=0.7;
    rotateSpeed=3;
    addMultiplyer(TurretWeapon.class,1.2);
  }
  
  @Override
  void Process(){
    if(child==null){
      child=new AntiBulletFieldBullet(this);
      NextEntities.add(child);
    }
    child.pos=pos;
  }
}

class CollisionEnemy extends Enemy{
  float time=0;
  boolean hit=false;
  
  @Override
  protected void init(){
    setHP(14);
    setSize(28);
    setExpMag(1);
    setColor(new Color(30,255,180));
    maxSpeed=1.1;
    rotateSpeed=3;
    co_type=CollisionType.Inside;
  }
  
  @Override
  void Process(){
    if(hit){
      maxSpeed=0;
      time+=vectorMagnification;
      NextEntities.add(new Particle(this,1,1));
      if(time>180){
        isDead=true;
        NextEntities.add(new Explosion(this,size*2,0.5,5));
      }
    }
  }
  
  @Override
  void MyselfCollision(Myself m){
    if(!m.isDead&&qDist(m.pos,pos,(m.size+size)*0.5)){
      float r=-atan2(pos.x-m.pos.x,pos.y-m.pos.y)-PI*0.5;
      float d=(m.size+size)*0.5-dist(m.pos,pos);
      vel=new PVector(-cos(r)*d,-sin(r)*d);
      addtionalVel=new PVector(0,0);
      pos.add(vel);
      hit=true;
    }
  }
  
  @Override
  void BulletCollision(Bullet b){
    if(CircleCollision(pos,size,b.pos,b.vel)){
      b.isDead=true;
    }
  }
}

class Decoy extends Enemy{
  boolean stop=true;
  
  @Override
  protected void init(){
    setHP(25);
    setSize(23);
    setExpMag(1);
    setColor(new Color(205,200,255));
    maxSpeed=0;
    rotateSpeed=0;
    co_type=CollisionType.Inside;
  }
  
  @Override
  void Process(){
    if(!stop){
      maxSpeed=1.5;
      rotateSpeed=2;
    }
  }
  
  @Override
  void BulletCollision(Bullet b){
    if(CircleCollision(pos,size,b.pos,b.vel)){
      if(stop)stop=false;
      Hit(b.parent);
      addtionalVel=vel.copy().mult(-(b.vel.mag()/Mass));
      b.isDead=true;
    }
  }
}

class Recover extends Enemy implements BossEnemy{
  float moveCoolTime=0;
  
  @Override
  protected void init(){
    setHP(500);
    maxSpeed=1.85;
    rotateSpeed=2;
    setSize(40);
    setMass(35);
    setColor(new Color(255,150,225));
    co_type=CollisionType.Inside;
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
  void BulletCollision(Bullet b){
    super.BulletCollision(b);
    if(isDead)NextEntities.add(new RecoverItem(this));
  }
  
  private final class RecoverItem extends Exp{
    
    RecoverItem(){
      size=5;
      setExp(0);
    }
    
    RecoverItem(Entity e){
      pos=e.pos.copy();
      size=5;
      setExp(0);
    }
    
    @Override
    void display(PGraphics g){
      g.stroke(60,255,230);
      g.noFill();
      g.strokeWeight(2);
      g.ellipse(pos.x,pos.y,size,size);
    }
    
    @Override
    void update(){
      if(inScreen&&qDist(player.pos,pos,player.magnetDist)&&player.canMagnet){
        ++player.remain;
        player.exp+=250;
        isDead=true;
      }
    }
  }
}

class AntiG_Shot extends Enemy{
  
  @Override
  protected void init(){
    setHP(25);
    setExpMag(1);
    maxSpeed=1.85;
    rotateSpeed=2;
    setSize(25);
    setMass(3);
    setColor(new Color(0,255,0));
    co_type=CollisionType.Inside;
  }
  
  @Override
  void BulletCollision(Bullet b){
    if(b instanceof GravityBullet)return;
    super.BulletCollision(b);
  }
}

class Barrier extends M_Boss_Y implements BossEnemy{
  float age=0;
  float edge;
  boolean barrier=false;
  
  @Override
  protected void init(){
    setHP(2500);
    maxSpeed=1.85;
    rotateSpeed=2;
    setSize(53);
    setMass(53);
    setColor(new Color(0,200,255));
    edge=random(1500,1800);
    if(StageName.equals("Stage4")){
      boss=new HUDText("BOSS");
      dead=(e)->{
        StageFlag.add("Survive_10_min");
        stage.addSchedule(StageName,new TimeSchedule(stage.time/60f+3,(s)->{if(!stageList.contains("Stage5"))stageList.addContent("Stage5");scene=3;}));
        boss.Dispose();
      };
    }
    co_type=CollisionType.Inside;
  }
  
  @Override
  void display(PGraphics g){
    if(!inScreen)return;
    if(Debug){
      displayAABB(g);
    }
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.strokeWeight(2);
    g.stroke(0,255,255);
    g.noFill();
    if(barrier)g.ellipse(0,0,size,size);
    g.rotate(-rotate);
    g.rectMode(CENTER);
    g.strokeWeight(1);
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
  
  @Override
  void Process(){
    super.Process();
    age+=vectorMagnification;
    if(age>edge){
      age=0;
      barrier=!barrier;
    }
  }
  
  @Override
  Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage4")){
      boss.setTarget(this);
      main.HUDSet.add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  @Override
  void BulletCollision(Bullet b){
    if(barrier){
      if(CircleCollision(pos,size,b.pos,b.vel)){
        if(b instanceof GravityBullet){
          Hit(b.parent);
          addtionalVel=vel.copy().mult(-(b.vel.mag()/Mass));
        }
        b.isDead=true;
      }
    }else{
      super.BulletCollision(b);
    }
  }
}

class GoldEnemy extends Enemy implements BossEnemy{
  
  @Override
  protected void init(){
    setHP(100);
    setExpMag(2);
    maxSpeed=2.2;
    rotateSpeed=2;
    setSize(25);
    setMass(30);
    setColor(new Color(230,180,34));
  }
  
  void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass())*0.5:0.5;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }else if(damage>0){
      NextEntities.add(new Particle(this,(int)(size*0.5),1));
    }
  }
  
  void Hit(float f){
    f*=0.5;
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }else if(damage>0){
      NextEntities.add(new Particle(this,(int)(size*0.5),1));
    }
  }
}

class SnipeEnemy extends Turret_S implements BossEnemy{
  boolean stop=false;
  
  @Override
  protected void init(){
    setHP(200);
    setExpMag(0.8);
    maxSpeed=1.2;
    rotateSpeed=3.5;
    setSize(40);
    setMass(30);
    setColor(new Color(230,180,34));
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new SnipeWeapon(this));
    return this;
  }
  
  @Override
  void Process(){
    if(stop&&!(useWeapon.coolTime*0.9<cooltime)){
      stop=false;
      rotateSpeed=3.5;
      maxSpeed=1.2;
    }
    if(useWeapon.coolTime*0.9<cooltime){
      stop=true;
      rotateSpeed=maxSpeed=0;
    }
    super.Process();
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
    g.strokeWeight(1);
    g.stroke(255,0,0,150);
    g.line(0,0,0,-150);
    g.noStroke();
    g.fill(255,0,0,150);
    g.ellipse(0,0,3,3);
    g.rectMode(CENTER);
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
}

class Sealed extends M_Boss_Y implements BossEnemy{
  ArrayList<SealedFrag>Frags=new ArrayList<SealedFrag>();
  boolean release=false;
  
  @Override
  protected void init(){
    setHP(2750);
    maxSpeed=2;
    rotateSpeed=2;
    setSize(54);
    setMass(35);
    setColor(new Color(255,40,40));
    if(StageName.equals("Stage5")){
      boss=new HUDText("BOSS");
      dead=(e)->{
        StageFlag.add("Survive_10_min");
        stage.addSchedule(StageName,new TimeSchedule(stage.time/60f+3,(s)->{scene=3;}));
        boss.Dispose();
      };
    }
    for(int i=0;i<4;i++){
      SealedFrag f=new SealedFrag(i);
      Frags.add(f);
      NextEntities.add(f);
    }
  }
  
  @Override
  void Process(){
    super.Process();
    if(!release){
      ArrayList<SealedFrag>next=new ArrayList<SealedFrag>();
      for(SealedFrag f:Frags){
        if(EntitySet.contains(f)){
          next.add(f);
          switch(f.num){
            case 0:f.pos=pos.copy().add(new PVector(27,0).rotate(QUARTER_PI));break;
            case 1:f.pos=pos.copy().add(new PVector(27,0).rotate(HALF_PI+QUARTER_PI));break;
            case 2:f.pos=pos.copy().add(new PVector(27,0).rotate(PI+QUARTER_PI));break;
            case 3:f.pos=pos.copy().add(new PVector(27,0).rotate(QUARTER_PI-HALF_PI));break;
          }
        }
      }
      Frags=next;
      if(Frags.size()==0)release=true;
    }
  }
  
  @Override
  void ExplosionCollision(Explosion e){
    if(release)super.ExplosionCollision(e);
  }
  
  @Override
  void BulletCollision(Bullet b){
    if(release)super.BulletCollision(b);
  }
  
  @Override
  Enemy setPos(PVector p){
    super.setPos(p);
    if(StageName.equals("Stage5")){
      boss.setTarget(this);
      main.HUDSet.add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  final private class SealedFrag extends Enemy implements BossEnemy{
    int num=0;
    
    SealedFrag(int i){
      setColor(new Color(0,255,255));
      num=i;
      init();
    }
    
    @Override
    protected void init(){
      setHP(200);
      setExpMag(0.8);
      maxSpeed=0;
      rotateSpeed=0;
      setSize(16);
      setMass(1000);
      setColor(new Color(230,180,34));
      co_type=CollisionType.Inside;
    }
    
    @Override
    void EnemyCollision(Enemy e){}
  }
}

interface BossEnemy{
}

interface BlastResistant{
}
