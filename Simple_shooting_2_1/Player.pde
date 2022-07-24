java.util.List<Enemy>nearEnemy=Collections.synchronizedList(new ArrayList<Enemy>());

class Myself extends Entity{
  HashMap<String,StatusManage>effects=new HashMap<String,StatusManage>();
  ArrayList<SubWeapon>subWeapons=new ArrayList<SubWeapon>();
  ArrayList<Weapon>weapons=new ArrayList<Weapon>();
  Weapon selectedWeapon;
  Weapon ShotWeapon;
  Camera camera;
  Status HP;
  Status Attak;
  Status Defence;
  boolean autoShot=true;
  boolean levelup=false;
  boolean shield=false;
  boolean hit=false;
  boolean move=false;
  double damage=0;
  double absHP;
  double absAttak;
  double absDefence;
  float nextLevel=10;
  float exp=0;
  float protate=0;
  float diffuse=0;
  float rotateSpeed=10;
  float bulletSpeed=15;
  float coolingTime=0;
  float invincibleTime=0;
  int selectedIndex=0;
  int weaponChangeTime=0;
  int Level=1;
  int remain=3;
  
  Myself(){
    setMaxSpeed(3);
    pos=new PVector(0,0);
    vel=new PVector(0,0);
    HP=new Status(1);
    Attak=new Status(1);
    Defence=new Status(0);
    absHP=HP.getMax().doubleValue();
    absAttak=Attak.getMax().doubleValue();
    absDefence=Defence.getMax().doubleValue();
    weapons.add(new EnergyBullet(this));
    weapons.add(new PulseBullet(this));
    resetWeapon();
    camera=new Camera();
    camera.setTarget(this);
    addDeadListener((e)->{
      addExplosion(this,250,1);
      NextEntities.add(new Particle(this,(int)size*3,1));
    });
  }
  
  void display(){
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-rotate);
    strokeWeight(1);
    noFill();
    stroke(c.getRed(),c.getGreen(),c.getBlue());
    ellipse(0,0,size,size);
    strokeWeight(3);
    arc(0,0,size*1.5,size*1.5,
        radians(-5)-PI/2-selectedWeapon.diffuse/2,radians(5)-PI/2+selectedWeapon.diffuse/2);
    popMatrix();
    if(!camera.moveEvent){
      drawUI();
    }
  }
  
  void drawUI(){
    
  }
  
  void update(){
    super.update();
    if(isDead)return;
    while(exp>=nextLevel){
      exp-=nextLevel;
      ++Level;
      nextLevel=10+(Level-1)*10*ceil(Level/7f);
      levelup=true;
    }
    if(!camera.moveEvent){
      Rotate();
      move();
      shot();
      if(HP.get().intValue()<=0){
        isDead=true;
        return;
      }
      keyEvent();
      HashMap<String,StatusManage>nextEffects=new HashMap<String,StatusManage>();
      for(String s:effects.keySet()){
        effects.get(s).update();
        if(!effects.get(s).isEnd)nextEffects.put(s,effects.get(s));
      }
      effects=nextEffects;
    }
    camera.update();
    subWeapons.forEach(w->{w.update();});
    weaponChangeTime+=4;
    weaponChangeTime=constrain(weaponChangeTime,0,255);
    invincibleTime=max(0,invincibleTime-0.016*vectorMagnification);
    setAABB();
  }
  
  void setAABB(){
    Center=pos;
    AxisSize=new PVector(size,size);
    putAABB();
  }
  
  @Deprecated
  void setpos(PVector pos){
    vel=new PVector(pos.x,pos.y).sub(this.pos);
    this.pos=pos;
  }
  
  @Deprecated
  void setpos(float x,float y){
    vel=new PVector(x,y).sub(this.pos);
    pos=new PVector(x,y);
  }
  
  void addWeapon(Weapon w){
    weapons.add(w);
  }
  
  void changeWeapon(){
    selectedIndex++;
    if(selectedIndex>=weapons.size()){
      selectedIndex=0;
    }
    selectedWeapon=weapons.get(selectedIndex);
    setParameta();
  }
  
  void resetWeapon(){
    selectedIndex=0;
    selectedWeapon=weapons.get(selectedIndex);
    setParameta();
  }
  
  void setParameta(){
    diffuse=selectedWeapon.diffuse;
    autoShot=selectedWeapon.autoShot;
    weaponChangeTime=0;
  }
  
  void Rotate(){
    float rad=0;
    float r=0;
    float i=0;
    if(PressedKey.contains("w")||PressedKeyCode.contains(str(UP))){
      ++i;
    }
    if(PressedKey.contains("s")||PressedKeyCode.contains(str(DOWN))){
      --i;
    }
    if(PressedKey.contains("d")||PressedKeyCode.contains(str(RIGHT))){
      ++r;
    }
    if(PressedKey.contains("a")||PressedKeyCode.contains(str(LEFT))){
      --r;
    }
    move=abs(i)+abs(r)!=0;
    rad=move?atan2(-r,i):rotate;
    if(Float.isNaN(rad))rad=0;
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
    if(keyPressed&&move&&containsList(moveKeyCode,PressedKeyCode)){
      addVel(accelSpeed,false);
    }else{
      Speed=Speed>0?Speed-min(Speed,accelSpeed*2*vectorMagnification):
      Speed-max(Speed,-accelSpeed*2*vectorMagnification);
    }
    vel=new PVector(0,0);
    vel.y=-Speed;
    vel=unProject(vel.x,vel.y);
    pos.add(vel.mult(vectorMagnification));
  }
  
  void move(PVector v){
    vel.add(v);
    pos.add(v.mult(vectorMagnification));
    camera.reset();
  }
  
  private void addVel(float accel,boolean force){
    if(!force){
      Speed+=accel*vectorMagnification;
      Speed=min(maxSpeed,Speed);
    }else{
      Speed+=accel*vectorMagnification;
    }
  }
  
  private void subVel(float accel,boolean force){
    if(!force){
      Speed-=accel*vectorMagnification;
      Speed=max(-maxSpeed,Speed);
    }else{
      Speed-=accel*vectorMagnification;
    }
  }
  
  void shot(){
    if(coolingTime>selectedWeapon.coolTime&&((mousePressed&&autoShot)||(mousePress&&!autoShot))&&mouseButton==LEFT
      &&!selectedWeapon.empty){
      selectedWeapon.shot();
      coolingTime=0;
    }else if(selectedWeapon.empty){
      selectedWeapon.reload();
    }
    coolingTime+=vectorMagnification;
  }
  
  void keyEvent(){
    if(keyPress&&ModifierKey==TAB){
      changeWeapon();
    }
    if(keyPress&&PressedKey.contains("q")){
      addExplosion(this,600);
    }
  }
  
  boolean hit(PVector pos){
    if(this.pos.dist(pos)<=size){
      return true;
    }else{
      return false;
    }
  }
  
  void resetSpeed(){
    Speed=dist(0,0,vel.x,vel.y)*sign(Speed);
    Speed=min(abs(Speed),maxSpeed)/vectorMagnification*sign(Speed);
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Explosion){
      if(!((Explosion)e).myself&&qDist(pos,e.pos,(e.size+size)*0.5)){
        Hit(((Explosion)e).power*vectorMagnification);
      }
    }else if(e instanceof Enemy){
      e.Collision(this);
    }else if(e instanceof Bullet){
      if(!((Bullet)e).isMine){
        if(CircleCollision(pos,size,e.pos,e.vel)){
          e.isDead=true;
          Hit(((Bullet)e).power);
        }
      }
    }
  }
  
  protected void Hit(float d){
    if(invincibleTime<=0.0){
      HP.sub(d);
      damage+=d;
    }
    hit=true;
  }
}

class Satellite extends Entity{
  SatelliteWeapon satellite;
  
  Satellite(SatelliteWeapon w){
    satellite=w;
  }
  
  void init(){
    
  }
  
  void display(){
    
  }
  
  void update(){
    
  }
  
  void shot(){
    
  }
}
