class Myself extends Entity{
  HashMap<String,StatusManage>effects=new HashMap<String,StatusManage>();
  ArrayList<Weapon>weapons=new ArrayList<Weapon>();
  ItemTable Items;
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
  float exp=0;
  float protate=0;
  float diffuse=0;
  float rotateSpeed=10;
  float bulletSpeed=15;
  float coolingTime=0;
  int selectedIndex=0;
  int weaponChangeTime=0;
  int Level=1;
  
  Myself(){
    setMaxSpeed(3);
    Items=new ItemTable();
    Items.addStorage(new Item("回復薬(小)").setRecovoryPercent(0.25),10);
    Items.addStorage(new Item("回復薬(中)").setRecovoryPercent(0.45),3);
    Items.addStorage(new Item("回復薬(大)").setRecovoryPercent(0.75),1);
    pos=new PVector(0,0);
    vel=new PVector(0,0);
    HP=new Status(1);
    Attak=new Status(1);
    Defence=new Status(0);
    absHP=HP.getMax().doubleValue();
    absAttak=Attak.getMax().doubleValue();
    absDefence=Defence.getMax().doubleValue();
    weapons.add(new EnergyBullet(this));
    weapons.add(new DiffuseBullet(this));
    weapons.add(new PulseBullet(this));
    resetWeapon();
    camera=new Camera();
    camera.setTarget(this);
    //effects.put("test",new StatusManage(this).setHP(32768));
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
    if(isDead)return;
    while(exp>=10+(Level-1)*10){
      exp-=10+(Level-1)*10;
      ++Level;
      levelup=true;
    }
    if(!camera.moveEvent){
      Rotate();
      move();
      shot();
      BulletCollision();
      if(HP.get().intValue()<=0){isDead=true;return;}
      keyEvent();
      HashMap<String,StatusManage>nextEffects=new HashMap<String,StatusManage>();
      for(String s:effects.keySet()){
        effects.get(s).update();
        if(!effects.get(s).isEnd)nextEffects.put(s,effects.get(s));
      }
      effects=nextEffects;
    }
    camera.update();
    weaponChangeTime+=4;
    weaponChangeTime=constrain(weaponChangeTime,0,255);
    prePos=new PVector(pos.x,pos.y);
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
    if(PressedKey.contains("w")){
      ++i;
    }
    if(PressedKey.contains("s")){
      --i;
    }
    if(PressedKey.contains("d")){
      ++r;
    }
    if(PressedKey.contains("a")){
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
    if(keyPressed&&move&&(nowPressedKey.equals("w")||nowPressedKey.equals("s")||nowPressedKey.equals("a")||nowPressedKey.equals("d"))){
      addVel(accelSpeed,false);
    }else{
      Speed=Speed>0?Speed-min(Speed,accelSpeed*2*vectorMagnification):
      Speed-max(Speed,-accelSpeed*2*vectorMagnification);
    }
    vel=new PVector(0,0);
    vel.y=-Speed;
    vel=unProject(vel.x,vel.y);
    pos.add(vel.mult(vectorMagnification));
    LeftUP=new PVector(pos.x-size,pos.y+size);
    LeftDown=new PVector(pos.x-size,pos.y-size);
    RightUP=new PVector(pos.x+size,pos.y+size);
    RightDown=new PVector(pos.x+size,pos.y-size);
  }
  
  void move(PVector v){
    vel.add(v);
    pos.add(v.mult(vectorMagnification));
    LeftUP=new PVector(pos.x-size,pos.y+size);
    LeftDown=new PVector(pos.x-size,pos.y-size);
    RightUP=new PVector(pos.x+size,pos.y+size);
    RightDown=new PVector(pos.x+size,pos.y-size);
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
    if(keyPress&&PressedKey.contains("q")){
      for(Enemy e:Enemies){
        if(qDist(pos,e.pos,600)){
          e.Hit(100);
        }
      }
      synchronized(Particles){
        Particles.add(new ExplosionParticle(this,600));
      }
    }
  }
  
  void keyEvent(){
    if(keyPress&&ModifierKey==TAB){
      changeWeapon();
    }
  }
  
  boolean hit(PVector pos){
    if(this.pos.dist(pos)<=size){
      return true;
    }else{
      return false;
    }
  }
  
  void Collision(PVector pos){
  }
  
  void resetSpeed(){
    Speed=dist(0,0,vel.x,vel.y)*sign(Speed);
    Speed=min(abs(Speed),maxSpeed)/vectorMagnification*sign(Speed);
  }
  
  void BulletCollision(){
    hit=false;
    damage=0;
    COLLISION:for(Bullet b:eneBullets){
      if(b.isDead)continue COLLISION;
      PVector bulletVel=b.vel.copy().mult(vectorMagnification);
      PVector vecAP=createVector(b.pos,pos);
      PVector normalAB=normalize(bulletVel);//vecAB->b.vel
      float lenAX=dot(normalAB,vecAP);
      float dist;
      if(lenAX<0){
        dist=dist(b.pos.x,b.pos.y,pos.x,pos.y);
      }else if(lenAX>dist(0,0,bulletVel.x,bulletVel.y)){
        dist=dist(b.pos.x+bulletVel.x,b.pos.y+bulletVel.y,pos.x,pos.y);
      }else{
        dist=abs(cross(normalAB,vecAP));
      }
      if(dist<size/2){
        b.isDead=true;
        
        Hit(b.power);
        continue COLLISION;
      }
    }
    if(hit){
      Particles.add(new Particle(this,str((int)damage)));
    }
  }
  
  protected void Hit(float d){
    HP.sub(d);
    damage+=d;
    hit=true;
  }
}
