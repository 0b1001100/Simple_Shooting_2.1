ArrayList<AABBData>EntityDataX=new ArrayList<AABBData>();
ArrayList<ArrayList<AABBData>>HeapEntityDataX=new ArrayList<ArrayList<AABBData>>();
AABBData[]SortedDataX;

abstract class Enemy extends Entity implements Cloneable{
  HashMap<Class<? extends Weapon>,Float>MultiplyerMap=new HashMap<Class<? extends Weapon>,Float>();
  Weapon useWeapon=null;
  Weapon ShotWeapon=null;
  ItemTable dropTable;
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
  
  {
    setController(new SurvivorEnemyController());
  }
  
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
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
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
  
  public final void update(){
    Process();
    getController().update(this);
    if(!(HP<=0)&&damage>0){
      NextEntities.add(new Particle(this,(int)(damage*0.5),1));
      damage=0;
    }
  }
  
  protected void addVel(float accel,boolean force){
    Speed*=0.95f;
    vel.mult(0.95f);
    if(!force){
      Speed+=accel*vectorMagnification;
      Speed=min(maxSpeed,Speed);
    }else{
      Speed+=accel*vectorMagnification;
    }
    vel.x=abs(cos(rotate)*Speed)>abs(vel.x)?cos(rotate)*Speed:vel.x;
    vel.y=abs(sin(rotate)*Speed)>abs(vel.y)?sin(rotate)*Speed:vel.y;
  }
  
  public void addMultiplyer(Class<? extends Weapon> c,float f){
    MultiplyerMap.put(c,f);
  }
  
  public void setHP(double h){
    maxHP=h;
    HP=h;
  }
  
  public void setWeapon(Weapon w){
    useWeapon=w;
  }
  
  Enemy setPos(PVector p){
    pos=p;
    return this;
  }
  
  PVector getPos(){
    return pos;
  }
  
  public void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  public void Hit(float f){
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  public void setExpMag(float e){
    expMag=e;
  }
  
  public void Down(){
    HP=0;
    killCount.incrementAndGet();
    player.score_kill.addAndGet(round((float)maxHP));
    destruct(this);
    spownEntity();
    dead.deadEvent(this);
    dead=(e)->{};
  }
  
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    NextEntities.add(random(0,1)<0.0005?new LargeExp(this,ceil(((float)maxHP)*expMag)):new Exp(this,ceil(((float)maxHP)*expMag)));
    if(random(1f)<maxHP*0.01f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.001?random(1)<maxHP*0.0001?100:10:1));
  }
  
  @Override
  public void Collision(Entity e){
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
  
  @Override
  public void ExplosionCollision(Explosion e){
    e.EnemyCollision(this);
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    if(e.inf){
      Down();
    }else{
      Hit(e.power);
    }
  }
  
  @Override
  public void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      EnemyHit(e,false);
    }
  }
  
  @Override
  public void EnemyHit(Enemy e,boolean b){
    PVector c=pos.copy().sub(e.pos).normalize();
    PVector d=new PVector((size+e.size)*0.5-dist(pos,e.pos),0).rotate(atan2(pos,e.pos));
    vel=c.copy().mult((-e.Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(vel);
    e.vel=c.copy().mult((Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(e.vel);
    vel.sub(d.mult((e.Mass/(Mass+e.Mass))*(1f/0.9)));
    e.vel.sub(d.mult((-Mass/(Mass+e.Mass))*(1f/0.9)));
  }
  
  @Override
  public void BulletCollision(Bullet b){
    b.EnemyCollision(this);
  }
  
  @Override
  public void MyselfCollision(Myself m){
    if(!m.isDead&&qDist(m.pos,pos,(m.size+size)*0.5)){
      MyselfHit(m,true);
    }
  }
  
  @Override
  public void MyselfHit(Myself m,boolean b){
    float r=atan2(m.pos,pos);
    float d=(m.size+size)*0.5-dist(m.pos,pos);
    pos.add(new PVector(cos(r)*d,sin(r)*d));
    m.Hit(1*vectorMagnification,this);
  }
  
  @Override
  public void WallCollision(WallEntity w){
    w.EnemyCollision(this);
  }
  
  Enemy clone()throws CloneNotSupportedException{
    Enemy clone=(Enemy)super.clone();
    clone.dropTable=dropTable==null?null:dropTable.clone();
    try{
      clone.setController(this.getController().getClass().getDeclaredConstructor(Simple_shooting_2_1.class).newInstance(CopyApplet));
    }catch(NoSuchMethodException|InstantiationException|IllegalAccessException|InvocationTargetException me){
      me.printStackTrace();
    }
    return clone;
  }
  
  public void Process(){
    
  }
}

class DummyEnemy extends Enemy implements BlastResistant{
  Exp exp;
  
  {
    exp=new Exp();
    dead=(e)->{
      ((HUDText)main_game.getHUDComponentSet().components.get(3)).endDisplay();
      ((HUDText)main_game.getHUDComponentSet().components.get(4)).setTarget(exp);
    };
  }
  
  @Override
  public void init(){
    setHP(20);
    setSize(28);
    setMass(200);
    maxSpeed=0;
    rotateSpeed=0;
  }
  
  @Override
  public void Down(){
    killCount.incrementAndGet();
    destruct(this);
    NextEntities.add(new Particle(this,(int)(size*3),1));
    NextEntities.add(exp);
  }
  
  @Override
  public Enemy setPos(PVector p){
    Enemy e=super.setPos(p);
    exp.setPos(this.pos);
    exp.setExp(10);
    return e;
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){}
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
  
  public void Process(){
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
    addMultiplyer(QuarkCanon.class,1.1);
  }
  
  public void Process(){
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
  
  public void Process(){
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
  
  public void Process(){
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
  
  public void Process(){
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
  public void ExplosionHit(Explosion e,boolean b){
    Down();
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
  public void Process(){
    if(inScreen){
      if(abs(player.rotate-atan2(player.pos,pos))<radians(50)||abs(player.rotate+TWO_PI-atan2(player.pos,pos))<radians(50)||abs(player.rotate-TWO_PI-atan2(player.pos,pos))<radians(50)){
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
    maxSpeed=1;
    rotateSpeed=1.2;
    setSize(52);
    setMass(35);
    setColor(new Color(255,255,10));
    setBossData("Stage1");
    addMultiplyer(PlasmaFieldWeapon.class,1.2);
  }
  
  void setBossData(String stage_name){
    if(StageName.equals(stage_name)){
      boss=new HUDText("BOSS");
      dead=(e)->{
        StageFlag.add("Survive_10_min");
        stage.addSchedule(StageName,new TimeSchedule(stage.time/60f+3,(s)->scene=3));
        boss.Dispose();
      };
    }
  }
  
  void backToScreen(){
    if(!inScreen&&moveCoolTime<=0){
      pos.x=player.pos.x+sign(player.pos.x-pos.x)*min(abs(player.pos.x-pos.x),width*0.5);
      pos.y=player.pos.y+sign(player.pos.y-pos.y)*min(abs(player.pos.y-pos.y),height*0.5);
      rotate=(rotate+PI)%TWO_PI;
      moveCoolTime=180;
    }
    moveCoolTime-=vectorMagnification;
  }
  
  @Override
  public void Process(){
    backToScreen();
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    if(StageName.equals("Stage1")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
}

class Turret_S extends Enemy{
  Bullet b;
  Entity target;
  float cooltime=random(-30,30);
  
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
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new EnemyWeapon(this));
    return this;
  }
  
  public void Process(){
    if(target!=player&&!EntitySet.contains(target))target=player;
    cooltime+=vectorMagnification;
    if(useWeapon.coolTime<cooltime){
      useWeapon.shot();
      cooltime=random(-2,2);
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
    addMultiplyer(QuarkCanon.class,1.2);
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
    addMultiplyer(QuarkCanon.class,1.1);
  }
  
  @Override
  public void Process(){
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
  public Slime clone()throws CloneNotSupportedException{
    Slime s=(Slime)super.clone();
    s.setScale(scale);
    return s;
  }
  
  public void setScale(int i){
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
  public void Process(){
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
  public void Hit(Weapon w){
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
  public void Process(){
    time+=vectorMagnification;
    if(time>600){
      time=0;
      if(HP>2){
      HP*=0.5;
      setSize(size*0.5);
      NextEntities.add(new Duplication((float)HP,size).setPos(pos.copy().add(cos(-rotate+PI)*size*0.5,sin(-rotate+PI)*size*0.5)));
      }
    }
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

class Ghost extends Enemy{
  
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
  public void Process(){
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

class Formation extends M_Boss_Y{
  ArrayList<Formation_Copy>child=new ArrayList<Formation_Copy>();
  float age=0;
  
  @Override
  public void init(){
    setHP(1400);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(58);
    setMass(37);
    setColor(new Color(150,95,255));
    setBossData("Stage2");
    addMultiplyer(G_ShotWeapon.class,1.2);
  }
  
  @Override
  public void Process(){
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
  public Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage2")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
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
    public void init(){
      maxSpeed=1.85;
      rotateSpeed=1.2;
      setSize(50);
      setMass(37);
      setColor(new Color(150,95,255));
      addMultiplyer(G_ShotWeapon.class,1.2);
    }
    
    @Override
    public Formation_Copy setPos(PVector p){
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
  public Enemy setPos(PVector p){
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
  
  public void Process(){
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
  
  public void Process(){
    time+=vectorMagnification;
    if(!boost&&time>edge){
      boost=true;
      time=0;
    }
    if(boost){
      if(time<60){
        maxSpeed=3.5;
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
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
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
  
  public void Process(){
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
  public void Process(){
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
  }
  
  @Override
  public void BulletCollision(Bullet b){
    if(CircleCollision(pos,size,b.pos,b.vel)){
      b.destruct(this);
      vel.add(b.vel.copy().mult(b.Mass/Mass));
      if(b instanceof GravityBullet||b instanceof GrenadeBullet||b instanceof FireBullet||b instanceof PlasmaFieldBullet)Hit(b.parent);
    }
  }
  
  public void HitBullet(Weapon w){
    vel.add(vel.copy().mult(-1/Mass));
    if(w instanceof G_ShotWeapon||w instanceof GrenadeWeapon||w instanceof FireWeapon||w instanceof IceWeapon||w instanceof PlasmaFieldWeapon)super.Hit(w);
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
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){}
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
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new AntiSkillWeapon(this));
    return this;
  }
}

class EnemyShield extends M_Boss_Y{
  ArrayList<EnemyShield_Child>child=new ArrayList<EnemyShield_Child>();
  boolean attack=false;
  boolean shot=false;
  float age=0;
  float rad=0;
  int attacknum=0;
  int sum=0;
  
  @Override
  public void init(){
    setHP(1850);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(62);
    setMass(37);
    setColor(new Color(10,180,255));
    setBossData("Stage3");
    addMultiplyer(SatelliteWeapon.class,1.2);
  }
  
  @Override
  public void Process(){
    super.Process();
    age+=vectorMagnification;
    rad+=radians(vectorMagnification*5);
    ArrayList<EnemyShield_Child>nextChild=new ArrayList<EnemyShield_Child>();
    for(EnemyShield_Child f:child){
      if(EntitySet.contains(f))nextChild.add(f);
    }
    child=nextChild;
    int i=0;
    for(EnemyShield_Child c:child){
      c.setPos(pos.copy().add(new PVector(80,0).rotate(rad+TWO_PI*((i%12)/12f))));
      c.rotate=atan2(c.pos,pos);
      ++i;
    }
    if(age>300&&child.size()<12&&!shot){
      age=0;
      EnemyShield_Child bullet=(EnemyShield_Child)new EnemyShield_Child(child.size()).setPos(pos.copy().add(new PVector(80,0).rotate(rad+TWO_PI*((sum%12)/12f))));
      NextEntities.add(bullet);
      child.add(bullet);
      ++sum;
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
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage3")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  class EnemyShield_Child extends Enemy{
    int num;
    boolean go=false;
    
    EnemyShield_Child(int n){
      super();
      num=n;
    }
  
    @Override
    public void init(){
      setHP(15);
      maxSpeed=0;
      rotateSpeed=0;
      setSize(25);
      setMass(20);
      setColor(new Color(10,180,255));
      addMultiplyer(SatelliteWeapon.class,1.2);
    }
    
    @Override
    public void Process(){
      if(!go){
        HP=min(15f,(float)HP+3);
      }else{
        maxSpeed=5;
        rotateSpeed=0.2;
        if(!inScreen)maxSpeed=2.5;
      }
    }
    
    public void shot(){
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
  public Enemy setPos(PVector p){
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
  public void Process(){
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
  }
  
  @Override
  public void Process(){
    if(hit){
      maxSpeed=0;
      time+=vectorMagnification;
      NextEntities.add(new Particle(this,1,1));
      if(time>180){
        destruct(this);
        NextEntities.add(new Explosion(this,size*2,0.5,5));
      }
    }
  }
  
  @Override
  public void MyselfCollision(Myself m){
    if(!m.isDead&&qDist(m.pos,pos,(m.size+size)*0.5)){
      MyselfHit(m,true);
    }
  }
  
  @Override
  public void MyselfHit(Myself m,boolean b){
    float r=atan2(m.pos,pos);
    float d=(m.size+size)*0.5-dist(m.pos,pos);
    pos.add(new PVector(cos(r)*d,sin(r)*d));
    hit=true;
  }
  
  @Override
  public void Hit(Weapon w){
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
  }
  
  @Override
  public void Process(){
    if(!stop){
      maxSpeed=1.5;
      rotateSpeed=2;
    }
  }
  
  @Override
  public void Hit(Weapon w){
    super.Hit(w);
    stop=false;
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
    dead=(e)->{
      NextEntities.add(new RecoverItem(this));
    };
  }
  
  @Override
  public void Process(){
    if(!inScreen&&moveCoolTime<=0){
      pos.x=player.pos.x+sign(player.pos.x-pos.x)*min(abs(player.pos.x-pos.x),width*0.5);
      pos.y=player.pos.y+sign(player.pos.y-pos.y)*min(abs(player.pos.y-pos.y),height*0.5);
      rotate=(rotate+PI)%TWO_PI;
      moveCoolTime=180;
    }
    moveCoolTime-=vectorMagnification;
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
  
  public final class RecoverItem extends Exp{
    boolean recover=true;
    
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
    public void display(PGraphics g){
      g.stroke(60,255,230);
      g.noFill();
      g.strokeWeight(2);
      g.ellipse(pos.x,pos.y,size,size);
    }
    
    @Override
    public void getProcess(){
      if(recover){
        recover=false;
        ++player.remain;
        player.exp+=250;
        destruct(player);
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
  }
  
  @Override
  public void BulletCollision(Bullet b){
    if(b instanceof GravityBullet)return;
    super.BulletCollision(b);
  }
  
  @Override
  public void BulletHit(Bullet b,boolean p){
    if(b instanceof GravityBullet)return;
    super.BulletHit(b,p);
  }
}

class Barrier extends M_Boss_Y{
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
    setBossData("Stage4");
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.strokeWeight(2);
    g.stroke(0,255,255);
    g.noFill();
    if(barrier)g.ellipse(0,0,size,size);
    g.rotate(rotate);
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
  public void Process(){
    super.Process();
    age+=vectorMagnification;
    if(age>edge){
      age=0;
      barrier=!barrier;
    }
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage4")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  @Override
  public void BulletCollision(Bullet b){
    if(barrier){
      if(CircleCollision(pos,size,b.pos,b.vel)){
        b.EnemyHit(this,true);
      }
    }else{
      super.BulletCollision(b);
    }
  }
  
  @Override
  public void BulletHit(Bullet b,boolean p){
    if(b instanceof GravityBullet){
      vel.add(b.vel.copy().mult(b.Mass/Mass));
    }
  }
  
  @Override
  public void Hit(Weapon w){
    if(barrier&&!(w instanceof G_ShotWeapon))return;
    super.Hit(w);
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
  
  public void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass())*0.5:0.5;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  public void Hit(float f){
    f*=0.5;
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
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
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new SnipeWeapon(this));
    return this;
  }
  
  @Override
  public void Process(){
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
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
    g.strokeWeight(1);
    g.stroke(255,0,0,150);
    g.line(0,0,150,0);
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
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
}

class Sealed extends M_Boss_Y{
  ArrayList<SealedFrag>Frags;
  boolean release=false;
  
  @Override
  protected void init(){
    setHP(2750);
    maxSpeed=2;
    rotateSpeed=2;
    setSize(54);
    setMass(35);
    setColor(new Color(255,40,40));
    setBossData("Stage5");
  }
  
  @Override
  public void Process(){
    super.Process();
    if(!release){
      ArrayList<SealedFrag>next=new ArrayList<SealedFrag>();
      for(SealedFrag f:Frags){
        if(EntitySet.contains(f)){
          next.add(f);
          f.rotate=rotate;
          f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+HALF_PI*f.num));
        }
      }
      Frags=next;
      if(Frags.size()==0)release=true;
    }
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage5")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    Frags=new ArrayList<SealedFrag>();
    for(int i=0;i<4;i++){
      SealedFrag f=new SealedFrag(i);
      f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+HALF_PI*f.num));
      Frags.add(f);
      NextEntities.add(f);
    }
    return this;
  }
  
  @Override
  public void Hit(Weapon w){
    if(!release)return;
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  @Override
  public void Hit(float f){
    if(!release)return;
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  @Override
  public void EnemyHit(Enemy e,boolean b){
    if(!(e instanceof SealedFrag))super.EnemyHit(e,b);
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
    }
    
    @Override
    public void EnemyCollision(Enemy e){}
    
    @Override
    public void ExplosionHit(Explosion e,boolean b){
      Hit(10);
    }
  }
}

class Rare extends Enemy{
  
  @Override
  protected void init(){
    setHP(4);
    setSize(27);
    setExpMag(1.3);
    maxSpeed=0.8;
    rotateSpeed=4;
    setColor(new Color(203,152,224));
  }
}

class Zero extends Turret_S{
  float bullet_speed=1f;
  
  @Override
  protected void init(){
    setHP(8);
    setSize(28);
    maxSpeed=0.8;
    rotateSpeed=4;
    target=player;
    setExpMag(1.1);
    setColor(new Color(105,60,255));
    addMultiplyer(ReflectorWeapon.class,2);
  }
  
  public void Process(){
    bullet_speed+=vectorMagnification*0.02;
    useWeapon.setSpeed(bullet_speed);
    bullet_speed%=10f;
    super.Process();
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new EnemyWeapon(this));
    useWeapon.setPower(0.4f);
    useWeapon.setColor(210,210,0);
    return this;
  }
}

class Blaster extends Turret_S{
  
  @Override
  protected void init(){
    setHP(12);
    setSize(28);
    maxSpeed=0.8;
    rotateSpeed=3;
    target=player;
    setExpMag(0.8);
    setColor(new Color(250,120,0));
    addMultiplyer(FireWeapon.class,2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new BlasterWeapon(this));
    return this;
  }
}

class Metal extends Turret_S{
  
  @Override
  protected void init(){
    setHP(16);
    setSize(25);
    maxSpeed=0.8;
    rotateSpeed=2.5;
    target=player;
    setExpMag(1.1);
    setColor(new Color(125,125,150));
    addMultiplyer(PlasmaFieldWeapon.class,2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    EnemyWeapon w=new EnemyWeapon(this);
    w.setBulletNumber(3);
    w.setPower(0.1f);
    w.setDiffuse(radians(45f));
    setWeapon(w);
    return this;
  }
}

class Explosion_B extends Enemy{
  
  @Override
  protected void init(){
    setHP(20);
    setSize(25);
    maxSpeed=0.8;
    rotateSpeed=2.5;
    setExpMag(1.4);
    setColor(new Color(255,128,0));
    addMultiplyer(IceWeapon.class,2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    BlasterWeapon w=new BlasterWeapon(this);
    w.setPower(0.3f);
    w.setBulletNumber(6);
    w.setDiffuse(TWO_PI);
    setWeapon(w);
    dead=(e)->{
      useWeapon.shot();
      NextEntities.add(new Explosion(e,size*2,0.5,5));
    };
    return this;
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Down();
  }
}

class Rotate extends EnemyShield implements BossEnemy{
  
  @Override
  public void init(){
    setHP(510);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(30);
    setMass(30);
    setColor(new Color(0,150,60));
    addMultiplyer(SatelliteWeapon.class,1.2);
  }
  
  @Override
  public void Process(){
    backToScreen();
    age+=vectorMagnification;
    rad+=radians(vectorMagnification*5);
    ArrayList<EnemyShield_Child>nextChild=new ArrayList<EnemyShield_Child>();
    for(EnemyShield_Child f:child){
      if(EntitySet.contains(f))nextChild.add(f);
    }
    child=nextChild;
    int i=0;
    for(EnemyShield_Child c:child){
      c.setPos(pos.copy().add(new PVector(40,0).rotate(rad+TWO_PI*((i%12)/12f))));
      c.rotate=atan2(c.pos,pos);
      ++i;
    }
    if(age>300&&child.size()<12&&!shot){
      age=0;
      EnemyShield_Child bullet=(EnemyShield_Child)new Rotate_Child(child.size()).setPos(pos.copy().add(new PVector(80,0).rotate(rad+TWO_PI*((sum%12)/12f))));
      NextEntities.add(bullet);
      child.add(bullet);
      ++sum;
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
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    return this;
  }
  
  class Rotate_Child extends EnemyShield.EnemyShield_Child{
    
    Rotate_Child(int n){
      super(n);
      num=n;
    }
  
    @Override
    public void init(){
      setHP(15);
      maxSpeed=0;
      rotateSpeed=0;
      setSize(10);
      setMass(15);
      setColor(new Color(0,150,60));
      addMultiplyer(SatelliteWeapon.class,1.2);
    }
  }
}

class Missile extends Turret_S{
  
  @Override
  protected void init(){
    setHP(24);
    setSize(25);
    maxSpeed=0.8;
    rotateSpeed=2.5;
    target=player;
    setExpMag(1.3);
    setColor(new Color(200,0,0));
    addMultiplyer(BLASWeapon.class,2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new MissileWeapon(this));
    useWeapon.setPower(0.35f);
    return this;
  }
}

class MirrorEnemy extends Enemy{
  
  @Override
  protected void init(){
    setHP(28);
    setSize(25);
    maxSpeed=0.6;
    rotateSpeed=0.5;
    setExpMag(1);
    setColor(new Color(40,230,230));
    addMultiplyer(LightningWeapon.class,2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new EnemyMirrorWeapon(this));
    useWeapon.shot();
    return this;
  }
}

class Defence extends Enemy{
  
  @Override
  protected void init(){
    setHP(32);
    setSize(30);
    maxSpeed=0.5;
    rotateSpeed=1.5;
    setExpMag(1.1);
    setColor(new Color(155,120,120));
    addMultiplyer(IceWeapon.class,2);
  }
  
  public void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=max(0,w.power*mult-5f);
    damage+=max(0,w.power*mult-5f);
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  public void Hit(float f){
    HP-=min(0,f-5f);
    damage+=min(0,f-5f);
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
}

class Flash extends Turret_S{
  
  @Override
  protected void init(){
    setHP(36);
    setSize(23);
    maxSpeed=0.7;
    rotateSpeed=0.5;
    target=player;
    setExpMag(1.1);
    setColor(new Color(255,240,110));
    addMultiplyer(G_ShotWeapon.class,2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new FlashWeapon(this));
    return this;
  }
}

class Missile_B extends M_Boss_Y{
  float maxcool=30;
  float cooltime=30;
  int state=0;
  float stateCooltime=600;
  
  @Override
  public void init(){
    setHP(3000);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(58);
    setMass(37);
    setColor(new Color(170,0,70));
    setBossData("Stage6");
    addMultiplyer(IceWeapon.class,2);
  }
  
  @Override
  public void Process(){
    super.Process();
    if(stateCooltime<0){
      maxSpeed=0.8;
      cooltime-=vectorMagnification;
      if(cooltime<0){
        useWeapon.shot();
        cooltime=maxcool;
        state++;
        if(state>=4){
          stateCooltime=600;
          state=0;
        }
      }
    }else{
      maxSpeed=1.85;
      stateCooltime-=vectorMagnification;
    }
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    setWeapon(new MissileWeapon(this));
    useWeapon.setBulletNumber(6);
    useWeapon.setDiffuse(TWO_PI);
    if(StageName.equals("Stage6")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
}

class Slide extends Turret_S{
  float slideTime=0f;
  
  @Override
  protected void init(){
    setHP(4);
    setSize(23);
    maxSpeed=1;
    rotateSpeed=1;
    target=player;
    setExpMag(1.1);
    setColor(new Color(0,190,255));
    addMultiplyer(G_ShotWeapon.class,2);
  }
  
  @Override
  public void Process(){
    super.Process();
    slideTime+=vectorMagnification;
    if(slideTime>300f){
      slideTime=0f;
      float r=random(0,TWO_PI);
      vel.add(Speed*10*cos(r),10*sin(r));
    }
  }
}

class Slime_F extends Enemy{
  
  @Override
  protected void init(){
    setHP(8);
    setSize(18);
    maxSpeed=random(0.5,0.9);
    rotateSpeed=3;
    setColor(new Color(0,125,255));
    addMultiplyer(QuarkCanon.class,1.1);
  }
  
  @Override
  public void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      if(e instanceof Slime_F){
        if(!isDead){
          e.destruct(this);
          setSize(size+50f/size);
          setHP(HP+e.HP*0.5);
        }
      }else{
        EnemyHit(e,false);
      }
    }
  }
}

class Magnet extends Enemy{
  float magnet_cooltime=0;
  boolean magnet=true;
  
  @Override
  protected void init(){
    setHP(12);
    setSize(23);
    maxSpeed=random(1,1.4);
    rotateSpeed=1;
    setExpMag(1.1);
    setColor(new Color(200,170,170));
    addMultiplyer(G_ShotWeapon.class,2);
  }
  
  @Override
  public void Process(){
    super.Process();
    magnet_cooltime+=vectorMagnification;
    if(magnet_cooltime>300f){
      magnet=true;
    }
  }
  
  @Override
  public void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      if(!(e instanceof BossEnemy)&&magnet){
        if(!isDead){
          e.destruct(this);
          float eh_size=e.size*0.5;
          setColor(mixColor(c,e.c,eh_size/(size+eh_size)));
          setSize(sqrt(size*size+eh_size*eh_size));
          setHP(HP+e.HP*0.5);
          magnet=false;
          magnet_cooltime=0;
        }
      }else{
        EnemyHit(e,false);
      }
    }
  }
}

class Boid extends Enemy{
  float life=1800;
  
  @Override
  protected void init(){
    setHP(14);
    setSize(25);
    maxSpeed=6;
    rotateSpeed=0;
    setExpMag(1.1);
    setColor(new Color(190,170,200));
    addMultiplyer(G_ShotWeapon.class,2);
  }
  
  @Override
  public void Process(){
    super.Process();
    life-=vectorMagnification;
    if(life<0)destruct(this);
  }
  
  Enemy setPos(PVector p){
    pos=p;
    rotate=atan2(pos,player.pos);
    int num=round(sq(random(1.4,3.2)));
    for(int i=0;i<num;i++){
      BoidChild c=new BoidChild(this);//send direction
      NextEntities.add(c);
    }
    return this;
  }
  
  class BoidChild extends Enemy{
    float life=1800;
    
    BoidChild(Boid parent){
      pos=parent.pos.copy().add(random(-25,25),random(-25,25));
      setHP(7);
      setSize(15);
      maxSpeed=6;
      rotateSpeed=0;
      setExpMag(1.2);
      rotate=parent.rotate;
      setColor(new Color(190,170,200));
    }
    
    @Override
    public void Process(){
      super.Process();
      life-=vectorMagnification;
      if(life<0)destruct(this);
    }
  }
}

class Random extends Turret_S{
  
  @Override
  protected void init(){
    setHP(random(16,22));
    setSize(random(20,35));
    maxSpeed=random(0.5,1.1);
    rotateSpeed=random(0.8,3);
    target=player;
    setExpMag(random(1,2));
    setColor(new Color((int)random(128,255),(int)random(128,255),(int)random(128,255)));
  }
}

class Tornade extends Enemy{
  
  @Override
  protected void init(){
    setHP(24);
    setSize(26);
    maxSpeed=2;
    rotateSpeed=3;
    setExpMag(1.2);
    setController(new TornadeController());
    setColor(new Color(0,255,120));
  }
}

class Micro_C extends Enemy{
  
  @Override
  protected void init(){
    setHP(26);
    maxSpeed=0.9;
    rotateSpeed=3;
    setSize(18);
    setMass(5);
    setExpMag(1.2);
    setColor(new Color(0,255,255));
  }
}

class LinkEnemy extends Enemy{
  HashSet<LinkEnemy>link=new HashSet<>();
  HashSet<LinkEnemy>nextLink=new HashSet<>();
  
  @Override
  protected void init(){
    setHP(28);
    maxSpeed=0.8;
    rotateSpeed=3;
    setSize(25);
    setExpMag(1.2);
    setColor(new Color(150,180,210));
  }
  
  @Override
  public void display(PGraphics g){
    super.display(g);
    g.strokeWeight(2);
    g.stroke(255,120);
    for(LinkEnemy m:link)g.line(pos.x,pos.y,m.pos.x,m.pos.y);
    if(!link.isEmpty())g.ellipse(pos.x,pos.y,size,size);
  }
  
  @Override
  public void Process(){
    link=nextLink;
    nextLink=new HashSet<>();
  }
  
  @Override
  public void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      if(e instanceof LinkEnemy){
        nextLink.add((LinkEnemy)e);
      }
      EnemyHit(e,false);
    }
  }
  
  public void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=max(0.5,w.power*mult-link.size());
    damage+=max(0.5,w.power*mult-link.size());
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  public void Hit(float f){
    HP-=max(0.5,f-link.size());
    damage+=max(0.5,f-link.size());
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
}

class BindEnemy extends Turret_S{
  boolean bind=false;
  
  @Override
  protected void init(){
    setHP(31);
    maxSpeed=0.5;
    rotateSpeed=1;
    setSize(24);
    setExpMag(1.2);
    setColor(new Color(240,240,255));
  }
  
  public void Process(){
    if(target!=player&&!EntitySet.contains(target))target=player;
    cooltime+=vectorMagnification;
    if(useWeapon.coolTime<cooltime&&!bind){
      useWeapon.shot();
      cooltime=0;
    }
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new BindWeapon(this));
    return this;
  }
}

class Absorb extends M_Boss_Y{
  HashSet<Enemy>link=new HashSet<>();
  HashSet<Enemy>nextLink=new HashSet<>();
  
  Entity target;
  float cooltime=random(-30,30);
  
  float bodySize=58;
  float colliderSize=400;
  int pSize=0;
  
  @Override
  public void init(){
    setHP(3250);
    maxSpeed=1.5;
    rotateSpeed=1.3;
    setSize(400);
    setMass(37);
    target=player;
    setColor(new Color(150,255,160));
    setBossData("Stage7");
    addMultiplyer(IceWeapon.class,2);
  }
  
  @Override
  public void display(PGraphics g){
    size=bodySize;
    super.display(g);
    size=colliderSize;
    g.strokeWeight(2);
    g.stroke(255,120);
    for(Enemy e:link)g.line(pos.x,pos.y,e.pos.x,e.pos.y);
    if(!link.isEmpty())g.ellipse(pos.x,pos.y,bodySize,bodySize);
  }
  
  @Override
  public void Process(){
    size=bodySize;
    super.Process();
    if(target!=player&&!EntitySet.contains(target))target=player;
    cooltime+=vectorMagnification;
    if(useWeapon.coolTime<cooltime){
      useWeapon.shot();
      cooltime=0;
    }
    size=colliderSize;
    link=nextLink;
    nextLink=new HashSet<>();
    if(link.size()>=30&&floor(pSize*0.1)!=3){
      setWeapon(getMissile());
    }else if(link.size()>=20&&floor(pSize*0.1)!=2){
      setWeapon(getFlash());
    }else if(link.size()>=10&&floor(pSize*0.1)!=1){
      setWeapon(getPoison());
    }else if(floor(pSize*0.1)!=0){
      setWeapon(getBlaster());
    }
    pSize=link.size();
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    setWeapon(getBlaster());
    if(StageName.equals("Stage7")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  BlasterWeapon getBlaster(){
    BlasterWeapon b=new BlasterWeapon(this);
    b.setCoolTime(90);
    b.setBulletNumber(8);
    b.setDiffuse(30f);
    return b;
  }
  
  EnemyPoisonWeapon getPoison(){
    EnemyPoisonWeapon b=new EnemyPoisonWeapon(this);
    b.setCoolTime(60);
    b.setBulletNumber(8);
    b.setDiffuse(30f);
    return b;
  }
  
  FlashWeapon getFlash(){
    FlashWeapon b=new FlashWeapon(this);
    b.setDiffuse(15f);
    b.setCoolTime(120);
    b.setBulletNumber(6);
    return b;
  }
  
  MissileWeapon getMissile(){
    MissileWeapon b=new MissileWeapon(this);
    b.setDiffuse(15f);
    b.setCoolTime(90);
    b.setBulletNumber(6);
    return b;
  }
  
  @Override
  public void Collision(Entity e){
    size=bodySize;
    if(e instanceof Explosion){
      ExplosionCollision((Explosion)e);
    }else if(e instanceof Enemy){
      size=colliderSize;
      EnemyCollision((Enemy)e);
      size=bodySize;
    }else if(e instanceof Bullet){
      BulletCollision((Bullet)e);
    }else if(e instanceof Myself){
      MyselfCollision((Myself)e);
    }else if(e instanceof WallEntity){
      WallCollision((WallEntity)e);
    }
    size=colliderSize;
  }
  
  @Override
  public void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      nextLink.add(e);
      if(qDist(pos,e.pos,(bodySize+e.size)*0.5)){
        size=bodySize;
        EnemyHit(e,false);
      }
    }
  }
  
  public void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=max(0.5,w.power*mult-link.size());
    damage+=max(0.5,w.power*mult-link.size());
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  public void Hit(float f){
    HP-=max(0.5,f-link.size());
    damage+=max(0.5,f-link.size());
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
}

class Sealed_Base extends M_Boss_Y{
  ArrayList<SealedFrag_Base>Frags;
  boolean release=false;
  
  void init(){
    setHP(100);
    maxSpeed=2;
    rotateSpeed=0.5;
    setSize(54);
    setMass(35);
    setColor(new Color(0,230,230));
  }
  
  @Override
  public void display(PGraphics g){
    super.display(g);
    if(release)return;
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
    g.noFill();
    g.strokeWeight(1);
    g.stroke(0,255,255,100);
    g.circle(0,0,size);
    g.popMatrix();
  }
  
  @Override
  public void Process(){
    super.Process();
    if(!release){
      ArrayList<SealedFrag_Base>next=new ArrayList<>();
      for(SealedFrag_Base f:Frags){
        if(EntitySet.contains(f)){
          next.add(f);
          f.rotate=rotate;
          f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+HALF_PI*f.num));
        }
      }
      Frags=next;
      if(Frags.size()==0)release=true;
    }
  }
  
  Enemy setPos(PVector p){
    pos=p;
    Frags=new ArrayList<>();
    for(int i=0;i<4;i++){
      SealedFrag_Base f=new SealedFrag_Base(i);
      f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+HALF_PI*f.num));
      Frags.add(f);
      NextEntities.add(f);
    }
    return this;
  }
  
  @Override
  public void Hit(Weapon w){
    if(!release)return;
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  @Override
  public void Hit(float f){
    if(!release)return;
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  @Override
  public void EnemyHit(Enemy e,boolean b){
    if(!(e instanceof SealedFrag_Base))super.EnemyHit(e,b);
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    if(random(1f)<maxHP*0.01f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.001?random(1)<maxHP*0.0001?100:10:1));
  }
}

class SealedFrag_Base extends Enemy implements ExcludeArchive{
  int num=0;
  
  SealedFrag_Base(int i){
    num=i;
    init();
  }
  
  @Override
  protected void init(){
    setHP(50);
    setExpMag(0.8);
    maxSpeed=0;
    rotateSpeed=0;
    setSize(16);
    setMass(1000);
    setColor(new Color(10,75,230));
  }
  
  @Override
  public void EnemyCollision(Enemy e){}
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
  }
}

class Sealed_Shot extends Sealed_Base{
  
  void init(){
    super.init();
    maxSpeed=1.5;
    rotateSpeed=0.45;
    setColor(new Color(60,200,100));
  }
  
  Enemy setPos(PVector p){
    pos=p;
    Frags=new ArrayList<>();
    for(int i=0;i<4;i++){
      SealedFrag_Base f=new SealedFrag_Shot(this,i);
      f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+HALF_PI*f.num));
      Frags.add(f);
      NextEntities.add(f);
    }
    return this;
  }
}

class SealedFrag_Shot extends SealedFrag_Base{
  Sealed_Base parent;
  int num=0;
  float cooltime=random(-30,30);
  
  void init(){
    super.init();
    setColor(new Color(0,150,40));
  }
  
  SealedFrag_Shot(Sealed_Base parent,int i){
    super(i);
    this.parent=parent;
    useWeapon=new EnemyWeapon(this);
  }
  
  void Process(){
    cooltime+=vectorMagnification;
    if(useWeapon.coolTime<cooltime){
      float temp=rotate;
      rotate=atan2(parent.pos,pos);
      useWeapon.shot();
      rotate=temp;
      cooltime=0;
    }
  }
}

class Sealed_Defence extends Sealed_Base{
  float angle=0;
  
  void init(){
    super.init();
    maxSpeed=1.7;
    rotateSpeed=0.5;
    setColor(new Color(170,170,170));
  }
  
  Enemy setPos(PVector p){
    pos=p;
    Frags=new ArrayList<>();
    for(int i=0;i<7;i++){
      SealedFrag_Base f=new SealedFrag_Defence(this,i);
      f.pos=pos.copy().add(new PVector(32,0).rotate(rotate+QUARTER_PI+radians(360/7f)*f.num));
      Frags.add(f);
      NextEntities.add(f);
    }
    release=true;
    return this;
  }
  
  @Override
  public void Process(){
    super.Process();
    ArrayList<SealedFrag_Base>next=new ArrayList<>();
    for(SealedFrag_Base f:Frags){
      if(EntitySet.contains(f)){
        next.add(f);
        f.rotate=rotate;
        f.pos=pos.copy().add(new PVector(32,0).rotate(rotate+QUARTER_PI+radians(360/7f)*f.num+radians(angle)));
      }
    }
    Frags=next;
    angle+=5*vectorMagnification;
  }
  
  public void Down(){
    super.Down();
    for(SealedFrag_Base f:Frags)f.Down();
  }
}

class SealedFrag_Defence extends SealedFrag_Base{
  Sealed_Base parent;
  int num=0;
  boolean defence=true;
  Bullet pHit=null;
  
  void init(){
    super.init();
    setColor(new Color(255,0,0));
  }
  
  SealedFrag_Defence(Sealed_Base parent,int i){
    super(i);
    this.parent=parent;
    useWeapon=new EnemyWeapon(this);
  }
  
  @Override
  void BulletHit(Bullet b,boolean bl){
    if(pHit!=b){
      b.isDead=false;
      b.parent.parent=this;
      b.reflectFromNormal(PVector.sub(b.pos,pos).normalize());
      pHit=b;
    }
  }
  
  @Override
  public void Hit(Weapon w){
  }
}

class Sealed_Stun extends Sealed_Base{
  boolean stun=false;
  float cooltime=600;
  float angle=0;
  
  void init(){
    super.init();
    maxSpeed=1.8;
    rotateSpeed=0.3;
    setColor(new Color(255,200,0));
  }
  
  Enemy setPos(PVector p){
    pos=p;
    Frags=new ArrayList<>();
    for(int i=0;i<8;i++){
      SealedFrag_Base f=new SealedFrag_Stun(i);
      f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+radians(45)*f.num));
      Frags.add(f);
      NextEntities.add(f);
    }
    release=true;
    return this;
  }
  
  void Process(){
    super.Process();
    ArrayList<SealedFrag_Base>next=new ArrayList<>();
    for(SealedFrag_Base f:Frags){
      if(EntitySet.contains(f)){
        next.add(f);
        f.rotate=rotate;
        f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+radians(45)*f.num+radians(angle)));
      }
    }
    angle+=5*vectorMagnification;
    Frags=next;
    if(stun){
      cooltime-=vectorMagnification;
      if(cooltime<0){
        cooltime=600;
        stun=false;
        release=true;
        maxSpeed=2;
        rotateSpeed=0.5;
        setHP(100);
      }
    }
  }
  
  @Override
  void destruct(Entity e){
    isDead=false;
    stun=true;
    release=false;
    maxSpeed=0;
    rotateSpeed=0;
  }
}

class SealedFrag_Stun extends SealedFrag_Base{
  Bullet pHit=null;
  
  void init(){
    super.init();
    setColor(new Color(0,255,150));
  }
  
  SealedFrag_Stun(int i){
    super(i);
  }
  
  @Override
  void BulletHit(Bullet b,boolean bl){
    if(pHit!=b){
      b.isDead=false;
      b.parent.parent=this;
      b.reflectFromNormal(PVector.sub(b.pos,pos).normalize());
      pHit=b;
    }
  }
  
  @Override
  public void Hit(Weapon w){
  }
}

class Sealed_Multi extends Sealed_Base{
  float angle=0;
  
  void init(){
    super.init();
    maxSpeed=1.9;
    rotateSpeed=0.5;
    setHP(200);
    setColor(new Color(255,200,0));
    setBossData("Stage8");
  }
  
  Enemy setPos(PVector p){
    pos=p;
    Frags=new ArrayList<>();
    for(int i=0;i<8;i++){
      SealedFrag_Base f=new SealedFrag_Shot(this,i);
      f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+radians(45)*f.num));
      Frags.add(f);
      NextEntities.add(f);
    }
    if(StageName.equals("Stage8")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  @Override
  public void Process(){
    super.Process();
    ArrayList<SealedFrag_Base>next=new ArrayList<>();
    for(SealedFrag_Base f:Frags){
      if(EntitySet.contains(f)){
        next.add(f);
        f.rotate=rotate;
        f.pos=pos.copy().add(new PVector(27,0).rotate(rotate+QUARTER_PI+radians(45)*f.num+radians(angle)));
      }
    }
    Frags=next;
    angle+=5*vectorMagnification;
  }
}

class Crystal extends Enemy{
  
  @Override
  protected void init(){
    setHP(3);
    maxSpeed=1;
    setColor(new Color(255,10,10));
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
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
    g.beginShape();
    for(int i=0;i<5;i++){
      g.vertex(cos(TWO_PI/5f*i)*size*0.5,sin(TWO_PI/5f*i)*size*0.5);
    }
    g.endShape(CLOSE);
    g.popMatrix();
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    if(random(1f)<maxHP*0.05f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.005?random(1f)<maxHP*0.0005?100:10:1));
  }
}

class Crystal_W extends Crystal{
  
  @Override
  protected void init(){
    setHP(5);
    maxSpeed=1.2;
    setColor(new Color(255,255,255));
  }
}

class Worm extends Enemy{
  ArrayList<Worm_body>body;
  int length=3;
  
  double sum_HP=15;
  
  Enemy setPos(PVector v){
    body=new ArrayList<>();
    super.setPos(v);
    for(int i=0;i<length;i++){
      body.add(new Worm_body(this,i));
    }
    NextEntities.addAll(body);
    setController(new VoidController());
    return this;
  }
  
  @Override
  void display(PGraphics g){
    for(int i=1;i<length;i++){
      g.stroke(255,100);
      g.strokeWeight(2);
      g.line(body.get(i-1).pos.x,body.get(i-1).pos.y,body.get(i).pos.x,body.get(i).pos.y);
    }
  }
  
  @Override
  void Process(){
    double hp=0;
    for(Worm_body w:body)hp+=w.HP;
    if(hp<body.get(0).maxHP*length-sum_HP){
      Down();
      for(Worm_body w:body)if(!w.isDead)w.Down();
    }
  }
  
  @Override
  void putAABB(){}
  
  @Override
  public void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      EnemyHit(e,false);
    }
  }
  
  @Override
  public void EnemyHit(Enemy e,boolean b){
    if(!body.contains(e))super.EnemyHit(e,b);
  }
  
  @Override
  public void MyselfHit(Myself m,boolean b){
  }
  
  @Override
  public void BulletHit(Bullet b,boolean bl){
  }
  
  @Override
  protected void spownEntity(){}
  
  public void Down(){
    HP=0;
    killCount.incrementAndGet();
    player.score_kill.addAndGet(round((float)sum_HP));
    destruct(this);
    spownEntity();
    dead.deadEvent(this);
    dead=(e)->{};
  }
  
  class Worm_body extends Enemy{
    Worm parent;
    int num;
    
    Worm_body(Worm parent,int num){
      super();
      this.parent=parent;
      this.num=num;
      setPos(parent.pos.copy().add(cos(parent.rotate)*size*num,sin(parent.rotate)*size*num));
    }
    
    void init(){
      setSize(20);
      setHP(100);
      setMaxSpeed(1.2);
      setMass(1000f/((num+1)*(num+1)));
      rotateSpeed=1.0;
      setColor(new Color(0,200,0));
      setController(new WormController());
      setExpMag(0.1);
    }
    
    void Process(){
    }
    
    @Override
    public void EnemyHit(Enemy e,boolean b){
      super.EnemyHit(e,b);
    }
    
    @Override
    protected void spownEntity(){
      NextEntities.add(new Particle(this,(int)(size*3),1));
      if(random(1f)<maxHP*0.05f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.005?random(1f)<maxHP*0.0005?100:10:1));
    }
  
    public void Down(){
      HP=0;
      destruct(this);
      spownEntity();
      dead.deadEvent(this);
      dead=(e)->{};
    }
  }
}

class Worm_R extends Worm{
  
  Enemy setPos(PVector v){
    pos=v;
    sum_HP=20;
    body=new ArrayList<>();
    for(int i=0;i<length;i++){
      body.add(new Worm_body_R(this,i));
    }
    NextEntities.addAll(body);
    return this;
  }
  
  class Worm_body_R extends Worm_body{
    
    Worm_body_R(Worm parent,int num){
      super(parent,num);
    }
    
    void init(){
      super.init();
      setColor(new Color(200,10,10));
    }
  }
}

class IceDust extends Crystal{
  
  @Override
  protected void init(){
    setHP(1);
    setSize(15);
    maxSpeed=0.9;
    setColor(new Color(0,255,255));
  }
}

class Asteroid extends Enemy{
  
  {
    size=70;
  }
  
  @Override
  protected void init(){
    maxSpeed=0.9;
    setSize(random(25,70));
    setColor(new Color(130,115,110));
    setController(new AsteroidController());
    setExpMag(0);
    dead=(e)->{
      if(size<20)return;
      int num=round(random(1,4));
      for(int i=0;i<num;i++){
        Asteroid a=0.1<random(0,1)?(Asteroid)new Asteroid().setPos(e.pos.copy().add(cos(TWO_PI/num*i)*size*0.5,sin(TWO_PI/num*i)*size*0.5)):(Asteroid)new Asteroid_Core().setPos(e.pos.copy().add(cos(TWO_PI/num*i)*size*0.5,sin(TWO_PI/num*i)*size*0.5));
        a.rotate=a.protate=TWO_PI/num*i;
        a.init();
        a.setSize(size*0.5);
        NextEntities.add(a);
      }
    };
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
    g.rectMode(CENTER);
    g.strokeWeight(2);
    g.noFill();
    if(Debug){
      g.colorMode(HSB);
      g.stroke(hue,255,255);
      g.colorMode(RGB);
    }else{
      g.stroke(toColor(c));
    }
    g.beginShape();
    for(int i=0;i<8;i++){
      g.vertex(cos(TWO_PI/8f*i)*size*0.5,sin(TWO_PI/8f*i)*size*0.5);
    }
    g.endShape(CLOSE);
    g.popMatrix();
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    if(random(1f)<maxHP*0.05f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.005?random(1f)<maxHP*0.0005?100:10:1));
  }
  
  @Override
  public void EnemyHit(Enemy e,boolean b){
    super.EnemyHit(e,b);
    if(!(e instanceof BossEnemy))e.Hit(1);
    Hit(0.032/(size/20f));
  }
  
  public void Down(){
    HP=0;
    killCount.incrementAndGet();
    player.score_kill.addAndGet(round((float)HP*(size/70)));
    destruct(this);
    spownEntity();
    dead.deadEvent(this);
    dead=(e)->{};
  }
}

class Asteroid_Core extends Asteroid{
  
  @Override
  protected void init(){
    maxSpeed=0.9;
    setColor(new Color(75,215,75,100));
    setController(new AsteroidController());
    dead=(e)->{
      NextEntities.add(new AsteroidExplosion(this));
    };
  }
}

class Gear extends Crystal{
  boolean active=false;
  
  float cool=0f;
  float duration;
  
  float angle=0;
  
  void init(){
    maxSpeed=1.1;
    setSize(30);
    setHP(12);
    setColor(new Color(205,165,165));
    cool=random(180,480);
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
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
    g.beginShape();
    for(int i=0;i<5;i++){
      g.vertex(cos(TWO_PI/5f*i)*size*0.5,sin(TWO_PI/5f*i)*size*0.5);
    }
    g.endShape(CLOSE);
    g.beginShape();
    for(int i=0;i<5;i++){
      g.vertex(cos(TWO_PI/5f*i+angle)*size*0.5,sin(TWO_PI/5f*i+angle)*size*0.5);
    }
    g.endShape(CLOSE);
    g.popMatrix();
  }
  
  void Process(){
    if(!active){
      cool-=vectorMagnification;
    }else{
      duration-=vectorMagnification;
      angle+=radians(vectorMagnification*8);
    }
    if(cool<=0&&!active){
      active=true;
      duration=random(120,300);
    }
    if(duration<=0&&active){
      active=false;
      cool=random(180,480);
    }
  }
  
  @Override
  public void EnemyHit(Enemy e,boolean b){
    super.EnemyHit(e,b);
    if(active&&!((e instanceof Gear)||(e instanceof BossEnemy)))e.Hit(1);
  }
}

class IceChunk extends IceDust{
  
  void init(){
    setHP(6);
    setSize(35);
    maxSpeed=0.7;
    setColor(new Color(0,255,255));
    dead=(e)->{
      for(int i=0;i<6;i++){
        IceDust ice=(IceDust)new IceDust().setPos(e.pos.copy().add(cos(TWO_PI/6.0*i)*size*0.5,sin(TWO_PI/6.0*i)*size*0.5));
        ice.rotate=ice.protate=TWO_PI/6.0*i;
        ice.init();
        NextEntities.add(ice);
      }
    };
  }
}

class ARM extends M_Boss_Y{
  MissileWeapon weapon;
  boolean active=false;
  
  float cool=0f;
  float duration;
  float shot_cool=0f;
  
  float angle=0;
  
  @Override
  public void init(){
    weapon=new MissileWeapon(this);
    weapon.setBulletNumber(10);
    weapon.setSpeed(5f);
    weapon.setDiffuse(TWO_PI);
    setHP(500);
    maxSpeed=1.1;
    rotateSpeed=1.3;
    setSize(55);
    setMass(37);
    setColor(new Color(205,165,165));
    cool=random(180,480);
    shot_cool=random(240,420);
    setBossData("Stage9");
    addMultiplyer(IceWeapon.class,2);
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
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
    g.beginShape();
    for(int i=0;i<5;i++){
      g.vertex(cos(TWO_PI/5f*i)*size*0.5,sin(TWO_PI/5f*i)*size*0.5);
    }
    g.endShape(CLOSE);
    g.beginShape();
    for(int i=0;i<5;i++){
      g.vertex(cos(TWO_PI/5f*i+angle)*size*0.5,sin(TWO_PI/5f*i+angle)*size*0.5);
    }
    g.endShape(CLOSE);
    g.popMatrix();
  }
  
  @Override
  void Process(){
    super.Process();
    shot_cool-=vectorMagnification;
    if(shot_cool<0){
      weapon.shot();
      shot_cool=random(240,420);
    }
    if(!active){
      cool-=vectorMagnification;
    }else{
      duration-=vectorMagnification;
      angle+=radians(vectorMagnification*8);
    }
    if(cool<=0&&!active){
      active=true;
      duration=random(360,660);
      maxSpeed=1.4;
    }
    if(duration<=0&&active){
      active=false;
      cool=random(300,600);
      maxSpeed=1.1;
    }
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage9")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    if(random(1f)<maxHP*0.05f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.005?random(1f)<maxHP*0.0005?100:10:1));
  }
  
  public void Hit(Weapon w){
    float mult=(MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1)*(active?0.5:1);
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
}

class Fixed_Turret extends Turret_S{
  
  void init(){
    setController(new FixedTurretController());
    setHP(20);
    setSize(25);
    setColor(new Color(255,0,170));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    useWeapon.duration=600;
    useWeapon.coolTime=random(180,270);
    return this;
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Hit(10);
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    if(random(1f)<maxHP*0.05f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.005?random(1f)<maxHP*0.0005?100:10:1));
  }
}

class Rotate_Turret_D extends Fixed_Turret{
  
  void init(){
    setController(new RotateTurretController());
    setHP(10);
    setSize(25);
    rotateSpeed=radians(3);
    setColor(new Color(255,0,170));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new BarrageWeapon(this));
    useWeapon.duration=600;
    useWeapon.coolTime=random(15,20);
    useWeapon.bulletNumber=2;
    return this;
  }
}

class Rotate_Turret_Q extends Fixed_Turret{
  
  void init(){
    setController(new RotateTurretController());
    setHP(12);
    setSize(25);
    rotateSpeed=radians(3);
    setColor(new Color(255,0,170));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new BarrageWeapon(this));
    useWeapon.duration=600;
    useWeapon.coolTime=random(20,30);
    useWeapon.bulletNumber=4;
    return this;
  }
}

class Bound_Turret extends Fixed_Turret{
  
  void init(){
    super.init();
    setHP(12);
    setColor(new Color(0,110,255));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    useWeapon=new WallBounseWeapon(this);
    useWeapon.duration=600;
    useWeapon.coolTime=random(180,270);
    return this;
  }
}

class Bound_Turret_D extends Fixed_Turret{
  
  void init(){
    super.init();
    setHP(14);
    setColor(new Color(0,110,255));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    useWeapon=new WallBounseWeapon(this);
    useWeapon.duration=500;
    useWeapon.coolTime=random(30,60);
    useWeapon.bulletNumber=2;
    return this;
  }
}

class Self_Explosion extends Fixed_Turret{
  boolean fire=false;
  float timer=180;
  
  {
    dead=(e)->{
      NextEntities.add(new Explosion(e,size*2,0.5,5));
    };
  }
  
  @Override
  void init(){
    super.init();
    setHP(8);
    maxSpeed=0;
    rotateSpeed=3;
    setColor(new Color(255,128,0));
  }
  
  void Process(){
    if(fire){
      timer-=vectorMagnification;
      NextEntities.add(new Particle(this,1,1));
    }
    if(timer<0)Down();
  }
  
  @Override
  protected void putAABB(){
    inScreen=-scroll.x<Center.x+AxisSize.x/2&&Center.x-AxisSize.x/2<-scroll.x+width&&-scroll.y<Center.y+AxisSize.y/2&&Center.y-AxisSize.y/2<-scroll.y+height;
    float x=AxisSize.x*4.0;
    float min=Center.x-x;
    float max=Center.x+x;
    HeapEntityDataX.get(threadNum).add(new AABBData(min,"s",this));
    HeapEntityDataX.get(threadNum).add(new AABBData(max,"e",this));
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    Down();
  }
  
  @Override
  public void MyselfCollision(Myself m){
    if(!m.isDead&&qDist(m.pos,pos,(m.size+size)*0.5)){
      MyselfHit(m,true);
    }else if(!m.isDead&&qDist(m.pos,pos,(m.size+size)*4.0)){
      fire=true;
    }
  }
}

class Circle_Turret extends Fixed_Turret{
  
  void init(){
    setController(new RotateTurretController());
    setHP(16);
    setSize(25);
    rotateSpeed=radians(3);
    setColor(new Color(0,255,170));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new BarrageWeapon(this));
    useWeapon.duration=600;
    useWeapon.coolTime=random(25,40);
    useWeapon.bulletNumber=12;
    return this;
  }
}

class Homing_Turret extends Fixed_Turret{
  
  void init(){
    super.init();
    setHP(18);
    setSize(25);
    setColor(new Color(255,0,100));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new MissileWeapon(this));
    useWeapon.duration=400;
    useWeapon.coolTime=random(60,90);
    useWeapon.bulletNumber=1;
    return this;
  }
}

class Turret_Fast extends Fixed_Turret{
  
  void init(){
    super.init();
    setHP(20);
    setSize(25);
    setColor(new Color(235,255,0));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new FlashWeapon(this));
    useWeapon.power*=2;
    useWeapon.duration=400;
    useWeapon.coolTime=random(60,90);
    useWeapon.bulletNumber=1;
    return this;
  }
}

class Turret_Laser extends Fixed_Turret{
  
  void init(){
    super.init();
    setHP(25);
    setSize(25);
    setColor(new Color(255,0,0));
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    setWeapon(new EnemyLaserWeapon(this));
    useWeapon.coolTime=random(130,180);
    useWeapon.bulletNumber=1;
    return this;
  }
}

class Disk_Turret extends M_Boss_Y{
  BarrageWeapon weapon;
  
  boolean barrage=false;
  
  float time=0;
  float cooltime=0;
  
  float cool=random(400,700);
  
  float defenceDamage=0;
  
  @Override
  public void init(){
    useWeapon=new BarrageWeapon(this);
    useWeapon.setBulletNumber(6);
    useWeapon.setSpeed(5f);
    useWeapon.setCoolTime(15f);
    setHP(500);
    maxSpeed=0.5;
    rotateSpeed=1;
    setSize(55);
    setMass(37);
    setColor(new Color(210,210,210));
    setBossData("Stage10");
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
    g.rectMode(CENTER);
    g.strokeWeight(1);
    g.noFill();
    if(Debug){
      g.colorMode(HSB);
      g.stroke(hue,255,255);
      g.colorMode(RGB);
    }else{
      g.stroke(barrage?color(105,160,200):toColor(c));
    }
    g.beginShape();
    for(int i=0;i<8;i++){
      g.vertex(cos(TWO_PI/8f*i)*size*0.5,sin(TWO_PI/8f*i)*size*0.5);
    }
    g.endShape(CLOSE);
    g.popMatrix();
  }
  
  @Override
  void Process(){
    time+=vectorMagnification;
    if(time>cool||defenceDamage>30){
      cool=random(400,700);
      time=0;
      defenceDamage=0;
      barrage=!barrage;
      if(barrage){
        setController(new RotateTurretController());
        rotateSpeed=1;
      }else{
        setController(new SurvivorEnemyController());
        rotateSpeed=1;
      }
    }
    cooltime+=vectorMagnification;
    if(useWeapon.coolTime*(barrage?1.0:4.0)<cooltime){
      useWeapon.shot();
      cooltime=random(-2,2);
    }
  }
  
  @Override
  public Enemy setPos(PVector p){
    pos=p;
    if(StageName.equals("Stage10")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
  
  public void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    if(barrage){
      defenceDamage+=w.power*mult;
      return;
    }
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  @Override
  protected void spownEntity(){
    NextEntities.add(new Particle(this,(int)(size*3),1));
    if(random(1f)<maxHP*0.05f)NextEntities.add(new Fragment(this,random(1f)<maxHP*0.005?random(1f)<maxHP*0.0005?100:10:1));
  }
}

class S_Boss_Y extends M_Boss_Y{
  
  @Override
  protected void init(){
    setHP(300);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    setSize(52);
    setMass(35);
    setColor(new Color(255,255,10));
    setBossData("StageE1");
    addMultiplyer(PlasmaFieldWeapon.class,1.2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    if(StageName.equals("StageE1")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
}

class S_Boss_O extends Missile_B{
  
  @Override
  void init(){
    setHP(8000);
    maxSpeed=1.85;
    rotateSpeed=1.2;
    maxcool=cooltime=10;
    setSize(52);
    setMass(35);
    setColor(new Color(255,128,10));
    setBossData("StageE2");
    addMultiplyer(PlasmaFieldWeapon.class,1.2);
  }
  
  @Override
  public Enemy setPos(PVector p){
    super.setPos(p);
    if(StageName.equals("StageE2")){
      boss.setTarget(this);
      main_game.getHUDComponentSet().add(boss);
      boss.startDisplay();
    }
    return this;
  }
}

interface BossEnemy{}

interface BlastResistant{}

interface ExcludeArchive{}
