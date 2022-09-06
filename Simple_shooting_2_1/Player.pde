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
  boolean canMagnet=true;
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
  float magnetDist=40;
  int selectedIndex=0;
  int weaponChangeTime=0;
  int Level=1;
  int levelupNumber=0;
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
      HeapEntity.get(0).add(new Explosion(this,250,1).Infinity(true));
      NextEntities.add(new Particle(this,(int)(size*3),1));
    });
  }
  
  @Override
  void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(-rotate);
    g.strokeWeight(1);
    g.noFill();
    g.stroke(c.getRed(),c.getGreen(),c.getBlue());
    g.ellipse(0,0,size,size);
    g.strokeWeight(3);
    g.arc(0,0,size*1.5,size*1.5,
        radians(-5)-PI/2-selectedWeapon.diffuse/2,radians(5)-PI/2+selectedWeapon.diffuse/2);
    g.popMatrix();
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
      nextLevel=10+(Level-1)*10*ceil(Level/10f);
      levelup=true;
      ++levelupNumber;
    }
    if(!camera.moveEvent){
      if(!Command){
        shot();
        Rotate();
        move();
      }
      if(HP.get().intValue()<=0){
        isDead=true;
        main.EventSet.put("player_dead","");
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
        Hit(((Explosion)e).power);
      }
    }else if((e instanceof Enemy)||e instanceof WallEntity){
      e.Collision(this);
    }else if(e instanceof Bullet){
      if(!((Bullet)e).isMine){
        e.Collision(this);
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
  PVector target;
  float rad=0;
  float cooltime=0;
  float maxCooltime=15;
  float attackTime=0;
  boolean attack=false;
  
  Satellite(SatelliteWeapon w){
    satellite=w;
    rad=random(0,TWO_PI);
    pos=player.pos.copy().add(new PVector(140,0).rotate(rad));
    init();
  }
  
  void init(){
    setColor(new Color(0,255,150));
    setSize(15);
  }
  
  @Override
  void display(PGraphics g){
    g.noFill();
    g.stroke(toColor(c));
    g.strokeWeight(1);
    g.triangle(pos.x+cos(rotate)*size,pos.y+sin(rotate)*size,pos.x+cos(rotate+TWO_PI/3)*size,pos.y+sin(rotate+TWO_PI/3)*size,pos.x+cos(rotate-TWO_PI/3)*size,pos.y+sin(rotate-TWO_PI/3)*size);
  }
  
  @Override
  void update(){
    cooltime+=vectorMagnification;
    if(attack){
      attackTime+=vectorMagnification;
      if(cooltime>maxCooltime){
        shot();
        cooltime=0;
        if(attackTime>=satellite.duration){
          attack=false;
          attackTime=0;
        }
      }
    }else{
      if(cooltime>satellite.coolTime){
        attack=true;
        cooltime=0;
      }
    }
    rotate+=radians(vectorMagnification)*2;
    rotate%=TWO_PI;
    rad=atan2(player.pos,pos);
    vel=new PVector(2,0).rotate(-rad);
    vel.add(new PVector(0.01*(dist(pos,player.pos)-140),0).rotate(-rad-HALF_PI));
    vel.normalize().mult(max(1.7,dist(pos,player.pos)/70));
    pos.add(vel);
  }
  
  void shot(){
    target=player.pos.copy().add(player.pos.copy().sub(pos));
    NextEntities.add(new SatelliteBullet(satellite,this,target.copy().add(random(-satellite.scale*8,satellite.scale*8),random(-satellite.scale*8,satellite.scale*8))));
  }
}
