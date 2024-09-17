java.util.List<Enemy>nearEnemy=Collections.synchronizedList(new ArrayList<Enemy>());

class Myself extends Entity{
  HashMap<String,StatusManage>effects=new HashMap<String,StatusManage>();
  ArrayList<AttackWeapon>attackWeapons=new ArrayList<AttackWeapon>();
  ArrayList<ItemWeapon>itemWeapons=new ArrayList<ItemWeapon>();
  ArrayList<Weapon>weapons=new ArrayList<Weapon>();
  Weapon selectedWeapon;
  Weapon ShotWeapon;
  Camera camera;
  Status HP;
  Status Attak;
  Status Defence;
  boolean useSub=true;
  boolean autoShot=true;
  boolean levelup=false;
  boolean hit=false;
  boolean canMagnet=true;
  double damage=0;
  double absHP;
  double absAttak;
  double absDefence;
  volatile float exp=0;
  float nextLevel=10;
  float diffuse=0;
  float rotateSpeed=10;
  float bulletSpeed=15;
  float coolingTime=0;
  float invincibleTime=0;
  float initMagnetDist=40;
  float magnetDist=40;
  float speedMag=1;
  volatile int fragment=0;
  int selectedIndex=0;
  int weaponChangeTime=0;
  int Level=1;
  int levelupNumber=0;
  int remain=3;
  AtomicInteger score_kill=new AtomicInteger(0);
  AtomicInteger score_tech=new AtomicInteger(0);
  
  Myself(){
    setMaxSpeed(3);
    accelSpeed=0.4;
    pos=new PVector(0,0);
    vel=new PVector(0,0);
    remain=3+getItemCount("revive");
    HP=new Status(1+getItemCount("hp"));
    Attak=new Status(1);
    Defence=new Status(getItemCount("defence")*0.05);
    absHP=HP.getMax().doubleValue();
    absAttak=Attak.getMax().doubleValue();
    absDefence=Defence.getMax().doubleValue();
    weapons.add(new QuarkCanon(this));
    weapons.add(new PhotonPulse(this));
    weapons.add(new TauBlaster(this));
    resetWeapon();
    camera=new Camera();
    camera.setTarget(this);
    addDeadListener((e)->{
      HeapEntity.get(0).add(new Explosion(this,250,1).Infinity(true));
      NextEntities.add(new Particle(this,(int)(size*3),1));
    });
  }
  
  @Override
  public void display(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(rotate);
    g.strokeWeight(1);
    g.noFill();
    g.stroke(skins.get());
    g.ellipse(0,0,size,size);
    g.strokeWeight(3);
    g.arc(0,0,size*1.5,size*1.5,
        radians(-5)-selectedWeapon.diffuse/2,radians(5)+selectedWeapon.diffuse/2);
    g.popMatrix();
    if(!camera.moveEvent){
      drawUI(g);
    }
  }
  
  public void drawUI(PGraphics g){
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rectMode(CORNER);
    g.noStroke();
    g.fill(255,0,0);
    g.rect(-size*0.5,size,size,4);
    g.fill(0,255,0);
    g.rect(-size*0.5,size,size*HP.getPercentage(),4);
    g.popMatrix();
  }
  
  public void update(){
    if(isDead)return;
    while(exp>=nextLevel){
      exp-=nextLevel;
      ++Level;
      nextLevel=10+(Level-1)*5*ceil(Level/10f);
      levelup=true;
      ++levelupNumber;
    }
    if(!camera.moveEvent){
      if(!Command){
        shot();
        Rotate();
        move();
      }
      if(HP.get().floatValue()<=0){
        destruct(this);
        main_game.EventSet.put("player_dead","");
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
    HP.add(HP.getReset().floatValue()*getItemCount("auto_recover")*0.02/60*vectorMagnification);
    if(useSub)attackWeapons.forEach(w->{w.update();});
    itemWeapons.forEach(w->{w.update();});
    weaponChangeTime+=4;
    weaponChangeTime=constrain(weaponChangeTime,0,255);
    invincibleTime=max(0,invincibleTime-0.016*vectorMagnification);
    setAABB();
  }
  
  public void setAABB(){
    Center=pos;
    AxisSize=new PVector(size,size);
    putAABB();
  }
  
  @Deprecated
  public void setpos(PVector pos){
    vel=new PVector(pos.x,pos.y).sub(this.pos);
    this.pos=pos;
  }
  
  @Deprecated
  public void setpos(float x,float y){
    vel=new PVector(x,y).sub(this.pos);
    pos=new PVector(x,y);
  }
  
  public void addWeapon(Weapon w){
    weapons.add(w);
  }
  
  public void changeWeapon(){
    selectedIndex++;
    if(selectedIndex>=weapons.size()){
      selectedIndex=0;
    }
    selectedWeapon=weapons.get(selectedIndex);
    setParameta();
  }
  
  public void resetWeapon(){
    selectedIndex=0;
    selectedWeapon=weapons.get(selectedIndex);
    setParameta();
  }
  
  public void setParameta(){
    diffuse=selectedWeapon.diffuse;
    autoShot=selectedWeapon.autoShot;
    weaponChangeTime=0;
  }
  
  public void Rotate(){
    float rad=0;
    rad=main_input.getMoveMag()>0?(TWO_PI-main_input.getMoveAngle()):rotate;
    if(Float.isNaN(rad))rad=rotate;
    PVector dir=new PVector(cos(rotate),sin(rotate));
    PVector t_dir=new PVector(cos(rad),sin(rad));
    rad=constrain(PVector.angleBetween(dir,t_dir),0,radians(rotateSpeed*main_input.getMoveMag()))*sign(cross(dir,t_dir))*vectorMagnification;
    rotate+=rad;
    rotate=rotate%TWO_PI;
  }
  
  public void move(){
    if(Float.isNaN(Speed)){
      Speed=0;
    }
    addVel(accelSpeed*main_input.getMoveMag(),false);
    vel.x=abs(vel.x)<0.01?0f:vel.x;
    vel.y=abs(vel.y)<0.01?0f:vel.y;
    Speed=abs(Speed)<0.01?0f:Speed;
    pos.add(vel.x*vectorMagnification,vel.y*vectorMagnification);
  }
  
  public void move(PVector v){
    vel.add(v);
    pos.add(v.mult(vectorMagnification));
    camera.reset();
  }
  
  private void addVel(float accel,boolean force){
    float mag=pow(0.9f,vectorMagnification);
    Speed*=mag;
    vel.mult(mag);
    if(!force){
      Speed+=accel*vectorMagnification;
      Speed=min(maxSpeed*speedMag,Speed);
    }else{
      Speed+=accel*vectorMagnification;
    }
    vel.x=abs(cos(rotate)*Speed)>abs(vel.x)?cos(rotate)*Speed:vel.x;
    vel.y=abs(sin(rotate)*Speed)>abs(vel.y)?sin(rotate)*Speed:vel.y;
  }
  
  private void subVel(float accel,boolean force){
    float mag=pow(0.9f,vectorMagnification);
    Speed*=mag;
    vel.mult(mag);
    if(!force){
      Speed-=accel*vectorMagnification;
      Speed=max(-maxSpeed,Speed);
    }else{
      Speed-=accel*vectorMagnification;
    }
    vel.x=abs(cos(rotate)*Speed)<abs(vel.x)?vel.x:cos(rotate)*Speed;
    vel.y=abs(sin(rotate)*Speed)<abs(vel.y)?vel.y:sin(rotate)*Speed;
  }
  
  public void shot(){
    if(coolingTime>selectedWeapon.coolTime&&((((mousePressed&&autoShot)||(main_input.getMouse().mousePress()&&!autoShot))&&mouseButton==LEFT)||main_input.getAttackMag()>0
      )&&!selectedWeapon.empty){
      soundManager.play("shot");
      selectedWeapon.shot();
      coolingTime=0;
    }else if(selectedWeapon.empty){
      selectedWeapon.reload();
    }
    coolingTime+=vectorMagnification;
  }
  
  public void keyEvent(){
    if(main_input.isChangeInput()){
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
  
  public void resetSpeed(){
    Speed=dist(0,0,vel.x,vel.y)*sign(Speed);
    Speed=min(abs(Speed),maxSpeed*speedMag)/vectorMagnification*sign(Speed);
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
    }else if(e instanceof Exp){
      ((Exp)e).Collision(this);
    }
  }
  
  @Override
  public void ExplosionHit(Explosion e,boolean b){
    if(!e.myself){
      Hit(e.power,this);
    }
  }
  
  @Override
  public void EnemyCollision(Enemy e){
    e.MyselfCollision(this);
  }
  
  @Override
  public void BulletCollision(Bullet b){
    if(!(b.parent.parent instanceof Myself))b.MyselfCollision(this);
  }
  
  @Override
  public void WallCollision(WallEntity w){
    w.MyselfCollision(this);
  }
  
  protected void Hit(float d,Entity e){
    if(invincibleTime<=0.0){
      if(!LensData.isEmpty()&&(e instanceof Enemy))d*=0.01;
      HP.sub(d-Defence.get().floatValue());
      damage+=d-Defence.get().floatValue();
    }
    hit=true;
  }
}

class Player_Skin{
  HashMap<String,Integer>colors=new HashMap<>();
  String current="default";
  
  Player_Skin(){
    colors.put("default",color(0,255,0));
    colors.put("red",color(255,0,0));
    colors.put("orange",color(255,128,0));
    colors.put("yellow",color(255,255,0));
    colors.put("light_blue",color(0,200,255));
    colors.put("blue",color(0,50,255));
    colors.put("purple",color(255,0,255));
    colors.put("rainbow",color(0,255,0));
  }
  
  int get(){
    if(current.equals("rainbow"))return Color.HSBtoRGB(millis()*0.0005,1,1);
    return colors.get(current);
  }
  
  void set(String s){
    if(colors.containsKey(s))current=s;
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
  
  public void init(){
    setColor(new Color(0,255,150));
    setSize(15);
  }
  
  @Override
  public void display(PGraphics g){
    g.noFill();
    g.stroke(toColor(c));
    g.strokeWeight(1);
    g.triangle(pos.x+cos(rotate)*size,pos.y+sin(rotate)*size,pos.x+cos(rotate+TWO_PI/3)*size,pos.y+sin(rotate+TWO_PI/3)*size,pos.x+cos(rotate-TWO_PI/3)*size,pos.y+sin(rotate-TWO_PI/3)*size);
  }
  
  @Override
  public void update(){
    if(!player.attackWeapons.contains(satellite))main_game.CommandQue.put(getClass().getName(),new Command(0,0,0,(e)->Entities.remove(this)));
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
    rad=atan2(pos,player.pos);
    vel.set(cos(rad-HALF_PI),sin(rad-HALF_PI));
    float dist=0.01*(dist(pos,player.pos)-140);
    vel.add(dist*cos(rad),dist*sin(rad));
    vel.normalize().mult(max(0.9,dist(pos,player.pos)/140)*vectorMagnification);
    pos.add(vel);
    Center=pos;
    AxisSize=new PVector(size*2,size*2);
    putAABB();
  }
  
  public void shot(){
    satellite.parent=player;
    target=player.pos.copy().add(player.pos.copy().sub(pos));
    NextEntities.add(new SatelliteBullet(satellite,this,target.copy().add(random(-satellite.scale*8,satellite.scale*8),random(-satellite.scale*8,satellite.scale*8))));
  }
}

class Hexite extends Satellite{
  
  Hexite(HexiteWeapon w){
    super(w);
  }
  
  public void init(){
    setColor(new Color(255,128,0));
    setSize(15);
  }
  
  @Override
  public void display(PGraphics g){
    g.noFill();
    g.stroke(toColor(c));
    g.strokeWeight(1);
    g.beginShape();
    for(int i=0;i<6;i++){
      g.vertex(pos.x+cos(rotate+TWO_PI*(i/6f))*size,pos.y+sin(rotate+TWO_PI*(i/6f))*size);
    }
    g.endShape(CLOSE);
  }
  
  public void shot(){
    satellite.parent=player;
    target=player.pos.copy().add(player.pos.copy().sub(pos));
    NextEntities.add(new HexiteBullet((HexiteWeapon)satellite,this,target.copy().add(random(-satellite.scale*8,satellite.scale*8),random(-satellite.scale*8,satellite.scale*8))));
  }
}

int[] ten_keys=new int[]{LogiLED.NUM_ZERO,LogiLED.NUM_ONE,LogiLED.NUM_TWO,LogiLED.NUM_THREE,LogiLED.NUM_FOUR,LogiLED.NUM_FIVE,LogiLED.NUM_SIX,LogiLED.NUM_SEVEN,LogiLED.NUM_EIGHT,LogiLED.NUM_NINE};
int[] num_keys=new int[]{LogiLED.ZERO,LogiLED.ONE,LogiLED.TWO,LogiLED.THREE,LogiLED.FOUR,LogiLED.FIVE,LogiLED.SIX,LogiLED.SEVEN,LogiLED.EIGHT,LogiLED.NINE};

void applyPlayerColor(){
  int i=skins.get();
  int r=int(red(i));
  int g=int(green(i));
  int b=int(blue(i));
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.W,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.S,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.A,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.D,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.ARROW_UP,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.ARROW_DOWN,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.ARROW_LEFT,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.ARROW_RIGHT,r,g,b);
  LogiLED.LogiLedSetLightingForKeyWithKeyName(LogiLED.G_LOGO,r,g,b);
  int life=min(player.remain,9);
  for(int j=0;j<10;j++){
    boolean current=life==j;
    LogiLED.LogiLedSetLightingForKeyWithKeyName(ten_keys[j],current?255:0,0,0);
    LogiLED.LogiLedSetLightingForKeyWithKeyName(num_keys[j],current?255:0,0,0);
  }
}
