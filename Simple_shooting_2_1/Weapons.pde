HashMap<String,Constructor>WeaponConstructor=new HashMap<String,Constructor>();

HashMap<String,HashMap<String,Float>>StatusList;
HashMap<String,Float>AddtionalStatus;

abstract class Weapon implements Equipment,Cloneable{
  Entity parent;
  boolean autoShot=true;
  boolean pHeat=false;
  boolean empty=false;
  String name="default";
  float power=1;
  float powerTemp=1;
  float speed=15;
  Float diffuse=0f;
  float coolTime=10;
  float heatUP=0.4f;
  float coolDown=0.2f;
  int bulletNumber=1;
  float duration=60;
  int Attribute=ENERGY;
  int itemNumber=INFINITY;
  int loadNumber=INFINITY;
  int loadedNumber=INFINITY;
  int reloadTime=0;
  int maxReloadTime=60;
  int type=ATTACK;
  Color bulletColor=new Color(36,224,125);
  
  static final int ENERGY=0;
  static final int LASER=1;
  static final int PHYSICS=2;
  static final int EXPLOSIVE=3;
  
  static final int INFINITY=-1;
  
  Weapon(){
  }
  
  Weapon(Entity e){
    parent=e;
  }
  
   public void setType(int t){
    type=t;
  }
  
   public Weapon setPower(float p){
    power=p;
    powerTemp=p;
    return this;
  }
  
   public void setSpeed(float s){
    speed=s;
  }
  
   public void setColor(Color c){
    bulletColor=c;
  }
  
   public void setColor(int r,int g,int b){
    bulletColor=new Color(r,g,b);
  }
  
   public void setDiffuse(Float rad){
    diffuse=rad;
  }
  
   public void setCoolTime(float t){
    coolTime=t;
  }
  
   public void setName(String s){
    name=s;
  }
  
   public void setAttribute(int a){
    Attribute=a;
  }
  
   public void setAutoShot(boolean a){
    autoShot=a;
  }
  
   public void setDuration(int i){
    duration=i;
  }
  
   public void setBulletNumber(int n){
    bulletNumber=n;
  }
  
   public void setHeatUP(float h){
    heatUP=h;
  }
  
   public void setCoolDown(float c){
    coolDown=c;
  }
  
   public void setLoadNumber(int i){
    loadNumber=i;
  }
  
   public void setLoadedNumber(int i){
    loadedNumber=i;
  }
  
   public void setReloadTime(int t){
    maxReloadTime=t;
  }
  
   public String getName(){
    return name;
  }
  
   public void reload(){
    reloadTime+=floor(vectorMagnification);
    empty=true;
    if(maxReloadTime<=reloadTime){
      loadedNumber=min(loadNumber,itemNumber!=INFINITY ? itemNumber:loadNumber);
      itemNumber-=itemNumber!=INFINITY ? loadedNumber:0;
      empty=false;
      if(itemNumber==0&&loadedNumber==0){
        empty=true;
      }
      reloadTime=0;
      pHeat=false;
    }
  }
  
  public void shot(){
    power=powerTemp;
    for(int i=0;i<this.bulletNumber;i++){
      addBullet(i);
    }
  }
  
  protected abstract void addBullet(int i);
  
   public Weapon clone()throws CloneNotSupportedException{
    return (Weapon)super.clone();
  }
}

class PlayerWeapon extends Weapon{
  float init_cooltime;
  float init_attack;
  int init_projectile;
  
  {
    init_cooltime=coolTime;
    init_attack=power;
    init_projectile=bulletNumber;
  }
  
  PlayerWeapon(Entity e){
    super(e);
  }
  
  @Override
  public void setCoolTime(float t){
    init_cooltime=coolTime=t;
  }
  
  @Override
  public void setBulletNumber(int n){
    init_projectile=bulletNumber=n;
  }
  
  @Override
  public Weapon setPower(float p){
    init_attack=power=p;
    powerTemp=p;
    return this;
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new PlayerBullet((Myself)parent,i));
  }
}

class EnemyWeapon extends Weapon{
  Enemy parentEnemy;
  
  EnemyWeapon(Enemy e){
    super(e);
    parent=parentEnemy=e;
    setPower(1);
    setSpeed(3.5f);
    setDuration(120);
    setDiffuse(radians(1));
    setColor(255,0,0);
    setCoolTime(250);
    setBulletNumber(1);
    setColor(new Color(255,0,0));
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new ThroughBullet(parentEnemy,this));
  }
}

class WallBounseWeapon extends BarrageWeapon{
  
  WallBounseWeapon(Enemy e){
    super(e);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new WallBounseBullet(parentEnemy,this,bulletNumber,i));
  }
}

class EnemyPoisonWeapon extends EnemyWeapon{
  
  EnemyPoisonWeapon(Enemy e){
    super(e);
    setPower(0.1);
    setDuration(180);
    setDiffuse(radians(1));
    setCoolTime(250);
    setBulletNumber(1);
    setColor(new Color(10,130,30));
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new EnemyPoisonBullet(parentEnemy,this));
  }
}

class AntiSkillWeapon extends EnemyWeapon{
  
  AntiSkillWeapon(Enemy e){
    super(e);
    setPower(0.1);
    setDuration(160);
    setDiffuse(radians(5));
    setCoolTime(350);
    setBulletNumber(1);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new AntiSkillBullet(parentEnemy,this));
  }
}

class BoundWeapon extends EnemyWeapon{
  
  BoundWeapon(Enemy e){
    super(e);
    setPower(0.1);
    setDuration(180);
    setDiffuse(radians(5));
    setCoolTime(240);
    setBulletNumber(1);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new BoundBullet(parentEnemy,this));
  }
}

class SnipeWeapon extends Weapon{
  Enemy parentEnemy;
  
  SnipeWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(2);
    setSpeed(17f);
    setDuration(170);
    setDiffuse(radians(1));
    setCoolTime(300);
    setBulletNumber(1);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new ThroughBullet(parentEnemy,this));
  }
}

class BlasterWeapon extends Weapon{
  Enemy parentEnemy;
  
  BlasterWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(0.6f);
    setSpeed(3f);
    setDuration(60);
    setDiffuse(radians(50));
    setCoolTime(290);
    setBulletNumber(5);
    setColor(230,230,10);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new AntiExplosionBullet(parentEnemy,this));
  }
}

class MissileWeapon extends Weapon{
  Enemy parentEnemy;
  
  MissileWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(0.6f);
    setSpeed(2f);
    setDuration(420);
    setDiffuse(radians(50));
    setCoolTime(420);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new MissileBullet(parentEnemy,this));
  }
}

class BindWeapon extends EnemyWeapon{
  BindEnemy parentEnemy;
  
  BindWeapon(BindEnemy e){
    super(e);
    parentEnemy=e;
    setPower(0.6f);
    setSpeed(6f);
    setDuration(120);
    setDiffuse(radians(50));
    setCoolTime(420);
  }
  
  @Override
  protected void addBullet(int i){
    if(!parentEnemy.bind)NextEntities.add(new BindBullet(parentEnemy,this));
  }
}

class EnemyMirrorWeapon extends Weapon{
  
  EnemyMirrorWeapon(Enemy e){
    super();
    parent=e;
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new EnemyMirrorBullet(this,i,bulletNumber));
  }
}

class FlashWeapon extends Weapon{
  Enemy parentEnemy;
  
  FlashWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(0.1);
    setSpeed(15f);
    setDuration(60);
    setDiffuse(radians(1));
    setCoolTime(300);
    setColor(new Color(255,25,0));
    setBulletNumber(1);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new ThroughBullet(parentEnemy,this));
  }
}

class BarrageWeapon extends Weapon{
  Enemy parentEnemy;
  
  BarrageWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(0.6f);
    setSpeed(2f);
    setDuration(420);
    setDiffuse(radians(50));
    setCoolTime(420);
  }
  
  public void shot(){
    power=powerTemp;
    for(int i=0;i<this.bulletNumber;i++){
      addBullet(i);
    }
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new Barrage(parentEnemy,this,bulletNumber,i));
  }
}

class EnemyLaserWeapon extends Weapon{
  Enemy parentEnemy;
  
  EnemyLaserWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(3);
    setSpeed(15f);
    setDuration(120);
    setDiffuse(0f);
    setCoolTime(180);
    setColor(new Color(255,25,0));
    setBulletNumber(1);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new EnemyLaserBullet(parentEnemy,this));
  }
}

class QuarkCanon extends PlayerWeapon{
  
  QuarkCanon(Entity e){
    super(e);
    setPower(1.2f+getItemCount("attack")*0.25);
    setSpeed(15);
    setDuration(40);
    setDiffuse(0f);
    setCoolTime(15);
    setBulletNumber(1);
  }
}

class TauBlaster extends PlayerWeapon{
  
  TauBlaster(Entity e){
    super(e);
    setPower(1.2f+getItemCount("attack")*0.25);
    setBulletNumber(4);
    setColor(new Color(255,105,20));
    setCoolTime(45);
    setDiffuse(radians(20));
  }
}

class PhotonPulse extends PlayerWeapon{
  
  PhotonPulse(Entity e){
    super(e);
    setSpeed(20);
    setPower(0.8f+getItemCount("attack")*0.25);
    setDuration(40);
    setAutoShot(true);
    setColor(new Color(0,255,255));
    setHeatUP(0.45f);
    setDiffuse(0f);
    setCoolTime(10);
  }
}

class Surge extends PlayerWeapon{
  int level;
  float charge_time;
  float charge=0;
  
  Surge(Entity e,int level){
    super(e);
    this.level=level;
    charge_time=60.0+20.0*(level-1);
    setSpeed(20);
    setPower(3f+level+getItemCount("attack")*0.25);
    setDuration(40);
    setAutoShot(false);
    setColor(new Color(255,128,0));
    setHeatUP(0.45f);
    setDiffuse(0f);
  }
  
  void charge(){
    charge+=vectorMagnification;
    charge=min(charge,charge_time);
  }
  
  float getChargePercent(){
    return charge/charge_time;
  }
  
  int getChargeLevel(){
    return floor(charge*level/charge_time);
  }
  
  void shot(){
    int c_level=getChargeLevel();
    if(c_level>0){
      addBullet(c_level);
    }
    charge=0;
  }
  
  @Override
  void addBullet(int l){
    int n=ceil(((float)l)/3.0);
    bulletNumber=n;
    setPower(3f+pow(l,1.5)+getItemCount("attack")*0.25);
    for(int i=0;i<n;i++)NextEntities.add(new SurgeBullet((Myself)parent,i,level));
  }
}

abstract class SubWeapon extends Weapon{
  String[] params=new String[]{"name","projectile","scale","power","velocity","duration","cooltime","through"};
  HashMap<String,Float>upgradeStatus;
  JSONObject obj;
  float scale=1;
  int through=0;
  int level=1;
  int maxLevel=1;
  
  protected float time=0;
  
  public abstract void init(JSONObject o);
  
  public abstract void upgrade(JSONArray a,int level);
  
  public abstract void reInit();
  
  public abstract void updateStatus();
  
  public abstract void update();
}

abstract class AttackWeapon extends SubWeapon{
  
  AttackWeapon(){
    super();
  }
  
  AttackWeapon(JSONObject o){
    init(o);
  }
  
  public void init(JSONObject o){
    level=1;
    obj=o;
    name=o.getString(params[0]);
    bulletNumber=o.getInt(params[1])+AddtionalStatus.get(params[1]).intValue();
    scale=o.getFloat(params[2])*AddtionalStatus.get(params[2]);
    power=o.getFloat(params[3])*AddtionalStatus.get(params[3]);
    speed=o.getFloat(params[4])*AddtionalStatus.get(params[4]);
    duration=o.getFloat(params[5])*AddtionalStatus.get(params[5]);
    coolTime=o.getFloat(params[6])*AddtionalStatus.get(params[6]);
    through=o.getInt(params[7]);
    maxLevel=o.getInt("maxLevel");
    upgradeStatus=new HashMap<String,Float>();
    for(String s:params)upgradeStatus.put(s,0f);
    time=coolTime;
  }
  
  public void upgrade(JSONArray a,int level) throws NullPointerException{
    this.level=level;
    if(level>maxLevel)throw new NullPointerException();
    JSONObject add=a.getJSONObject(level-2);
    HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray(params[0]).toStringArray()));
    param.forEach(s->{if(upgradeStatus.containsKey(s))upgradeStatus.replace(s,upgradeStatus.get(s)+add.getFloat(s));});
    bulletNumber=obj.getInt(params[1])+upgradeStatus.get(params[1]).intValue()+AddtionalStatus.get(params[1]).intValue();
    scale=(obj.getFloat(params[2])+upgradeStatus.get(params[2]))*AddtionalStatus.get(params[2]);
    power=(obj.getFloat(params[3])+upgradeStatus.get(params[3]))*AddtionalStatus.get(params[3]);
    speed=(obj.getFloat(params[4])+upgradeStatus.get(params[4]))*AddtionalStatus.get(params[4]);
    duration=(obj.getFloat(params[5])+upgradeStatus.get(params[5]))*AddtionalStatus.get(params[5]);
    coolTime=(obj.getFloat(params[6])-upgradeStatus.get(params[6]))*AddtionalStatus.get(params[6]);
    through=obj.getInt(params[7])+upgradeStatus.get(params[7]).intValue();
  }
  
  public void reInit(){
    if(coolTime!=(obj.getFloat(params[6])-upgradeStatus.get(params[6]))*AddtionalStatus.get(params[6]))time=coolTime;
    updateStatus();
  }
  
  public void updateStatus(){
    bulletNumber=obj.getInt(params[1])+upgradeStatus.get(params[1]).intValue()+AddtionalStatus.get(params[1]).intValue();
    scale=(obj.getFloat(params[2])+upgradeStatus.get(params[2]))*AddtionalStatus.get(params[2]);
    power=(obj.getFloat(params[3])+upgradeStatus.get(params[3]))*AddtionalStatus.get(params[3]);
    speed=(obj.getFloat(params[4])+upgradeStatus.get(params[4]))*AddtionalStatus.get(params[4]);
    duration=(obj.getFloat(params[5])+upgradeStatus.get(params[5]))*AddtionalStatus.get(params[5]);
    coolTime=(obj.getFloat(params[6])-upgradeStatus.get(params[6]))*AddtionalStatus.get(params[6]);
    through=obj.getInt(params[7])+upgradeStatus.get(params[7]).intValue();
  }
  
  public void update(){
    time+=vectorMagnification;
    if(time>=coolTime){
      updateStatus();
      shot();
      time=0;
    }
  }
  
  void shot(){
    parent=player;
    super.shot();
  }
}

class G_ShotWeapon extends AttackWeapon{
  
  G_ShotWeapon(){
    super();
  }
  
  G_ShotWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new GravityBullet(this,i));
  }
}

class TurretWeapon extends AttackWeapon{
  
  TurretWeapon(){
    super();
  }
  
  TurretWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new TurretBullet(this,i));
  }
}

class MP5Weapon extends TurretWeapon{
  
  MP5Weapon(){
    super();
  }
  
  MP5Weapon(JSONObject o){
    super(o);
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new MP5Bullet(this,i));
  }
}

class GrenadeWeapon extends AttackWeapon{
  
  GrenadeWeapon(){
    super();
  }
  
  GrenadeWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new GrenadeBullet(this,i));
  }
}

class MirrorWeapon extends AttackWeapon{
  float offset=0;
  
  MirrorWeapon(){
    super();
  }
  
  MirrorWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void shot(){
    offset=random(0,TWO_PI);
    parent=player;
    super.shot();
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new MirrorBullet(this,i,bulletNumber,offset));
  }
}

class InfinityShieldWeapon extends MirrorWeapon{
  
  InfinityShieldWeapon(){
    super();
  }
  
  InfinityShieldWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new InfinityShieldBullet(this,i,bulletNumber,offset));
  }
}

class PlasmaFieldWeapon extends AttackWeapon{
  PlasmaFieldBullet bullet;
  
  PlasmaFieldWeapon(){
    super();
  }
  
  PlasmaFieldWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    if(bullet==null){
      bullet=new PlasmaFieldBullet();
      bullet.init(this);
      NextEntities.add(bullet);
    }else if(!EntitySet.contains(bullet)){
      bullet.init(this);
      NextEntities.add(bullet);
    }
  }
  
   public void upgrade(JSONArray a,int level){
    super.upgrade(a,level);
    if(bullet!=null)bullet.init(this);
  }
  
  @Override 
  public void init(JSONObject o){
    super.init(o);
    bullet=null;
  }
  
  @Override
  public void reInit(){
    super.reInit();
    if(bullet!=null)bullet.init(this);
  }
  
  @Override
  protected void addBullet(int i){}
}

class AbsorptionWeapon extends AttackWeapon{
  AbsorptionBullet bullet;
  
  AbsorptionWeapon(){
    super();
  }
  
  AbsorptionWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void update(){
    if(bullet==null){
      bullet=new AbsorptionBullet();
      bullet.init(this);
      NextEntities.add(bullet);
    }else if(!EntitySet.contains(bullet)){
      bullet.init(this);
      NextEntities.add(bullet);
    }
  }
  
   public void upgrade(JSONArray a,int level){
    super.upgrade(a,level);
    if(bullet!=null)bullet.init(this);
  }
  
  @Override
  public void init(JSONObject o){
    super.init(o);
    bullet=null;
  }
  
  @Override
  public void reInit(){
    super.reInit();
    if(bullet!=null)bullet.init(this);
  }
  
  @Override
  protected void addBullet(int i){}
}

class LaserWeapon extends AttackWeapon{
  
  LaserWeapon(){
    super();
  }
  
  LaserWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new LaserBullet(this,i));
  }
}

class ElectronWeapon extends LaserWeapon{
  
  ElectronWeapon(){
    super();
  }
  
  ElectronWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new ElectronBullet(this,i));
  }
}

class LightningWeapon extends AttackWeapon{
  int offset=0;
  
  LightningWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void shot(){
    super.shot();
    parent=player;
    ++offset;
    offset%=12;
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new LightningBullet(this,i,bulletNumber,offset));
  }
}

class ReflectorWeapon extends AttackWeapon{
  
  ReflectorWeapon(){
    super();
  }
  
  ReflectorWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new ReflectorBullet(this,i));
  }
}

class ShadowReflectorWeapon extends ReflectorWeapon{
  
  ShadowReflectorWeapon(){
    super();
  }
  
  ShadowReflectorWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new ShadowReflectorBullet(this,i));
  }
}

class FireWeapon extends AttackWeapon{
  
  FireWeapon(){
    super();
  }
  
  FireWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new FireBullet(this,i));
  }
}

class IceWeapon extends AttackWeapon{
  
  IceWeapon(){
    super();
  }
  
  IceWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new IceBullet(this,i));
  }
}

class InfernoWeapon extends AttackWeapon{
  
  InfernoWeapon(){
    super();
  }
  
  InfernoWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new InfernoBullet(this,i));
  }
}

class SatelliteWeapon extends AttackWeapon{
  Satellite child=null;
  
  SatelliteWeapon(){
    super();
  }
  
  SatelliteWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void update(){
    if(child==null){
      child=new Satellite(this);
      NextEntities.add(child);
    }else if(child!=null&&!EntitySet.contains(child)){
      NextEntities.add(child);
    }
  }
  
  @Override
  public void reInit(){
    super.reInit();
    if(child==null)update();
    child.maxCooltime=max(15/bulletNumber,15-bulletNumber*2);
  }
  
  @Override
  protected void addBullet(int i){}
}

class HexiteWeapon extends SatelliteWeapon{
  
  HexiteWeapon(){
    super();
  }
  
  HexiteWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void update(){
    if(child==null){
      child=new Hexite(this);
      NextEntities.add(child);
    }else if(child!=null&&!EntitySet.contains(child)){
      NextEntities.add(child);
    }
  }
}

class BLASWeapon extends AttackWeapon{
  
  BLASWeapon(){
    super();
    setName("B.L.A.S.");
  }
  
  BLASWeapon(JSONObject o){
    super(o);
    setName("B.L.A.S.");
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new BLASBullet(this,i));
  }
}

class VoidWeapon extends AttackWeapon{
  
  VoidWeapon(){
    super();
  }
  
  VoidWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  protected void addBullet(int i){
    NextEntities.add(new VoidBullet(this,0));
  }
}

class TLASWeapon extends AttackWeapon{
  
  TLASWeapon(){
    super();
    setName("T.L.A.S.");
  }
  
  TLASWeapon(JSONObject o){
    super(o);
    setName("T.L.A.S.");
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new TLASBullet(this,i));
  }
}

class LinearWeapon extends AttackWeapon{
  
  LinearWeapon(){
    super();
  }
  
  LinearWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new LinearBullet(this,i));
  }
}

class BiLinearWeapon extends LinearWeapon{
  
  BiLinearWeapon(){
    super();
  }
  
  BiLinearWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new BiLinearBullet(this,i));
  }
}

class TriLinearWeapon extends BiLinearWeapon{
  
  TriLinearWeapon(){
    super();
  }
  
  TriLinearWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new TriLinearBullet(this,i));
  }
}

class SanctuaryWeapon extends PlasmaFieldWeapon{
  
  SanctuaryWeapon(){
    super();
  }
  
  SanctuaryWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    if(bullet==null){
      bullet=new SanctuaryBullet();
      bullet.init(this);
      NextEntities.add(bullet);
    }else if(!EntitySet.contains(bullet)){
      bullet.init(this);
      NextEntities.add(bullet);
    }
  }
}

class AnomalyWeapon extends AttackWeapon{
  
  AnomalyWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  protected void addBullet(int i){
    NextEntities.add(new AnomalyBullet(this));
  }
}

abstract class ItemWeapon extends SubWeapon{
  
  ItemWeapon(){
    super();
  }
  
  ItemWeapon(JSONObject o){
    init(o);
  }
  
  @Override 
  public void init(JSONObject o){
    level=1;
    obj=o;
    name=o.getString(params[0]);
    switch(name){
      case "projectile":bulletNumber=o.getInt("value");break;
      case "magnet":
      case "scale":scale=o.getFloat("value");break;
      case "power":power=o.getFloat("value");break;
      case "speed":speed=o.getFloat("value");break;
      case "duration":duration=o.getFloat("value");break;
      case "cooltime":coolTime=o.getFloat("value");break;
    }
    upgradeStatus=new HashMap<String,Float>();
    for(String s:params)upgradeStatus.put(s,0f);
  }
  
  @Override 
  public void upgrade(JSONArray a,int level) throws NullPointerException{
    this.level=level;
    if(level-2>=a.size())throw new NullPointerException();
    JSONObject add=a.getJSONObject(level-2);
    HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray(params[0]).toStringArray()));
    param.forEach(s->{if(upgradeStatus.containsKey(s))upgradeStatus.replace(s,upgradeStatus.get(s)+add.getFloat(s));});
    switch(name){
      case "projectile":bulletNumber=obj.getInt("value")+upgradeStatus.get(params[1]).intValue();break;
      case "magnet":
      case "scale":scale=obj.getFloat("value")+upgradeStatus.get(params[2]);break;
      case "power":power=obj.getFloat("value")+upgradeStatus.get(params[3]);break;
      case "speed":speed=obj.getFloat("value")+upgradeStatus.get(params[4]);break;
      case "duration":duration=obj.getFloat("value")+upgradeStatus.get(params[5]);break;
      case "cooltime":coolTime=obj.getFloat("value")+upgradeStatus.get(params[6]);break;
    }
  }
  
  @Override 
  public void reInit(){
    switch(name){
      case "projectile":bulletNumber=obj.getInt("value")+upgradeStatus.get(params[1]).intValue();break;
      case "magnet":
      case "scale":scale=obj.getFloat("value")+upgradeStatus.get(params[2]);break;
      case "power":power=obj.getFloat("value")+upgradeStatus.get(params[3]);break;
      case "speed":speed=obj.getFloat("value")+upgradeStatus.get(params[4]);break;
      case "duration":duration=obj.getFloat("value")+upgradeStatus.get(params[5]);break;
      case "cooltime":coolTime=obj.getFloat("value")+upgradeStatus.get(params[6]);break;
    }
  }
  
  @Override
  public void updateStatus(){
    bulletNumber=obj.getInt(params[1])+upgradeStatus.get(params[1]).intValue()+AddtionalStatus.get(params[1]).intValue();
    scale=(obj.getFloat(params[2])+upgradeStatus.get(params[2]))*AddtionalStatus.get(params[2]);
    power=(obj.getFloat(params[3])+upgradeStatus.get(params[3]))*AddtionalStatus.get(params[3]);
    speed=(obj.getFloat(params[4])+upgradeStatus.get(params[4]))*AddtionalStatus.get(params[4]);
    duration=(obj.getFloat(params[5])+upgradeStatus.get(params[5]))*AddtionalStatus.get(params[5]);
    coolTime=(obj.getFloat(params[6])-upgradeStatus.get(params[6]))*AddtionalStatus.get(params[6]);
    through=obj.getInt(params[7])+upgradeStatus.get(params[7]).intValue();
  }
  
  @Override
  public void update(){
  }
  
  @Override
  protected void addBullet(int i){}
}

final class projectileWeapon extends ItemWeapon{
  
  projectileWeapon(){
    super();
  }
  
  projectileWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    StatusList.get("projectile").put("item",(float)bulletNumber);
  }
}

final class scaleWeapon extends ItemWeapon{
  
  scaleWeapon(){
    super();
  }
  
  scaleWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    StatusList.get("scale").put("item",scale*0.01f);
  }
}

final class powerWeapon extends ItemWeapon{
  
  powerWeapon(){
    super();
  }
  
  powerWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    StatusList.get("power").put("item",power*0.01f);
  }
}

class speedWeapon extends ItemWeapon{
  
  speedWeapon(){
    super();
  }
  
  speedWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    StatusList.get("velocity").put("item",speed*0.01f);
  }
}

class durationWeapon extends ItemWeapon{
  
  durationWeapon(){
    super();
  }
  
  durationWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    StatusList.get("duration").put("item",duration*0.01f);
  }
}

class cooltimeWeapon extends ItemWeapon{
  
  cooltimeWeapon(){
    super();
  }
  
  cooltimeWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    StatusList.get("cooltime").put("item",-coolTime*0.01f);
  }
}

final class magnetWeapon extends ItemWeapon{
  
  magnetWeapon(){
    super();
  }
  
  magnetWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void update(){
    player.magnetDist=player.initMagnetDist*(1f+scale*0.01f);
  }
}

interface Equipment{
  int ATTACK=1;
  int DIFENCE=2;
}
