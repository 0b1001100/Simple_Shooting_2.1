TreeMap<Float,Enemy>EnemyX=new TreeMap<Float,Enemy>();
HashMap<Float,String>EnemyData=new HashMap<Float,String>();

class Enemy extends Entity implements Cloneable{
  HashMap<Class<? extends Weapon>,Float>MultiplyerMap=new HashMap<Class<? extends Weapon>,Float>();
  Weapon useWeapon=null;
  Weapon ShotWeapon=null;
  ItemTable dropTable;
  boolean Expl=false;
  boolean inScreen=true;
  boolean hit=false;
  double damage=0;
  float rotateSpeed=10;
  float protate=0;
  float playerDistsq=0;
  float hue=0;
  float exp=1;
  protected double maxHP=10d;
  protected double HP=10d;
  
  Enemy(){
    setColor(new Color(0,0,255));
  }
  
  protected void setTable(){
    
  }
  
  void display(){
    if(!inScreen)return;
    pushMatrix();
    translate(pos.x,pos.y);
    if(Debug){
      fill(255);
      textSize(15);
      text(pos.toString(),0,0);
    }
    rotate(-rotate);
    rectMode(CENTER);
    strokeWeight(1);
    noFill();
    if(Debug){
      colorMode(HSB);
      stroke(hue,255,255);
      colorMode(RGB);
    }else{
      stroke(toColor(c));
    }
    rect(0,0,size*0.7071,size*0.7071);
    popMatrix();
  }
  
  void update(){
    Expl=false;
    Rotate();
    move();
    Collision();
    float d=size*0.5;
    EnemyX.put(pos.x-d,this);
    EnemyX.put(pos.x+d,this);
    EnemyData.put(pos.x-d,"s");
    EnemyData.put(pos.x+d,"e");
    Process();
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
    pos.add(vel);
    inScreen=-scroll.x<pos.x+size/2&pos.x-size/2<-scroll.x+width&-scroll.y<pos.y+size/2&pos.y-size/2<-scroll.y+height;
    LeftUP=new PVector(pos.x-size,pos.y+size);
    LeftDown=new PVector(pos.x-size,pos.y-size);
    RightUP=new PVector(pos.x+size,pos.y+size);
    RightDown=new PVector(pos.x+size,pos.y-size);
  }
  
  private void addVel(float accel,boolean force){
    if(!force){
      Speed+=accel*vectorMagnification;
      Speed=min(maxSpeed,Speed);
    }else{
      Speed+=accel*vectorMagnification;
    }
    vel.add(cos(-rotate-HALF_PI)*Speed,sin(-rotate-HALF_PI)*Speed).mult(vectorMagnification);
    vel.mult(0.95);
    if(vel.magSq()>maxSpeed*maxSpeed*vectorMagnification){
      vel.normalize().mult(maxSpeed).mult(vectorMagnification);
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
  
  void updateVertex(){
    float s=size*0.5;
    float r=-rotate+PI*0.25;
    LeftUP=new PVector(pos.x-cos(r)*s,pos.y+sin(r)*s);
    LeftDown=new PVector(pos.x-cos(r)*s,pos.y-sin(r)*s);
    RightUP=new PVector(pos.x+cos(r)*s,pos.y+sin(r)*s);
    RightDown=new PVector(pos.x+cos(r)*s,pos.y-sin(r)*s);
  }
  
  void Hit(Weapon w){
    float mult=MultiplyerMap.containsKey(w.getClass())?MultiplyerMap.get(w.getClass()):1;
    HP-=w.power*mult;
    damage+=w.power*mult;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  void Hit(float f){
    HP-=f;
    damage+=f;
    hit=true;
    if(!isDead&&HP<=0){
      Down();
      return;
    }
  }
  
  void Down(){
    isDead=true;
    ParticleHeap.add(new Particle(this,(int)size*3,1));
    ExpHeap.add(new Exp(this,exp));
  }
  
  void Collision(){
    playerDistsq=sqDist(player.pos,pos);
    if(!player.isDead&&playerDistsq<=((player.size+size)*0.5)*((player.size+size)*0.5)){
      float r=-atan2(pos.x-player.pos.x,pos.y-player.pos.y)-PI*0.5;
      float d=(player.size+size)*0.5-dist(player.pos,pos);
      vel=new PVector(-cos(r)*d,-sin(r)*d);
      pos.add(vel);
      player.Hit(1);
    }
  }
  
  void Collision(Enemy e){
    if(e instanceof Explosion){
      if(!Expl){
        Hit(((Explosion)e).power*vectorMagnification);
        Expl=true;
      }
      return;
    }
    PVector c=pos.copy().sub(e.pos).normalize();
    PVector d=new PVector((size+e.size)*0.5-dist(pos,e.pos),0).rotate(-atan2(pos.x-e.pos.x,pos.y-e.pos.y)-PI*0.5);
    vel=c.copy().mult((-e.Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(vel);
    e.vel=c.copy().mult((Mass/(Mass+e.Mass))*(1+this.e*e.e)*dot(vel.copy().sub(e.vel),c.copy())).add(e.vel);
    pos.sub(d);
    e.pos.add(d);
    if(vel.magSq()>maxSpeed*maxSpeed){
      vel.normalize().mult(maxSpeed);
    }
    if(e.vel.magSq()>e.maxSpeed*e.maxSpeed){
      e.vel.normalize().mult(e.maxSpeed);
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

class Turret extends Enemy{
  
  Turret(){
    init();
  }
  
  Turret(PVector pos){
    init();
    this.pos=pos;
  }
  
  private void init(){
    setHP(1);
    setSize(28);
    useWeapon=new EnergyBullet(this);
    maxSpeed=0.7;
    rotateSpeed=3;
  }
  
  void display(){
    super.display();
  }
  
  void Process(){
  }
}

class Plus extends Enemy{
  
  Plus(){
    init();
  }
  
  Plus(PVector pos){
    init();
    this.pos=pos;
  }
  
  private void init(){
    setHP(2);
    setSize(28);
    useWeapon=new EnergyBullet(this);
    maxSpeed=0.7;
    rotateSpeed=3;
    setColor(new Color(20,170,20));
  }
  
  void display(){
    super.display();
  }
  
  void Process(){
  }
}

class White extends Enemy{
  
  White(){
    init();
  }
  
  White(PVector pos){
    init();
    this.pos=pos;
  }
  
  private void init(){
    exp=3;
    setHP(3);
    setSize(28);
    useWeapon=new EnergyBullet(this);
    maxSpeed=0.8;
    rotateSpeed=4;
    setColor(new Color(255,255,255));
  }
  
  void display(){
    super.display();
  }
  
  void Process(){
  }
}

class Normal extends Enemy{
  
  Normal(){
    init();
  }
  
  Normal(PVector pos){
    init();
    this.pos=pos;
  }
  
  private void init(){
    exp=2;
    setHP(1);
    useWeapon=new EnergyBullet(this);
    maxSpeed=1;
    rotateSpeed=3;
    setSize(42);
    setMass(100);
    setColor(new Color(255,20,20));
  }
  
  void display(){
    super.display();
  }
  
  void Process(){
  }
}
