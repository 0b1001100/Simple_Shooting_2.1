HashMap<String,Constructor>WeaponConstructor=new HashMap<String,Constructor>();
int addtionalProjectile=0;
float addtionalScale=1;
float addtionalPower=1;
float addtionalSpeed=1;
float addtionalDuration=1;
float reductionCoolTime=1;

HashMap<String,HashMap<String,Float>>StatusList;
HashMap<String,Float>AddtionalStatus;

class Weapon implements Equipment,Cloneable{
  Entity parent;
  boolean autoShot=true;
  boolean pHeat=false;
  boolean empty=false;
  String name="default";
  float power=1;
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
  int type=ATTAK;
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
  
   public void setPower(float p){
    power=p;
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
    for(int i=0;i<this.bulletNumber;i++){
      if(parent instanceof Myself){
        NextEntities.add(new Bullet((Myself)parent,i));
      }else{
        NextEntities.add(new Bullet(parent,this));
      }
    }
  }
  
   public Weapon clone()throws CloneNotSupportedException{
    return (Weapon)super.clone();
  }
}

class SubWeapon extends Weapon{
  String[] params=new String[]{"name","projectile","scale","power","velocity","duration","cooltime","through"};
  HashMap<String,Float>upgradeStatus;
  JSONObject obj;
  float scale=1;
  int through=0;
  int level=1;
  
  protected float time=0;
  
  SubWeapon(){
    super();
  }
  
  SubWeapon(JSONObject o){
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
    upgradeStatus=new HashMap<String,Float>();
    for(String s:params)upgradeStatus.put(s,0f);
  }
  
   public void upgrade(JSONArray a,int level) throws NullPointerException{
    this.level=level;
    if(level-2>=a.size())throw new NullPointerException();
    JSONObject add=a.getJSONObject(level-2);
    HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray(params[0]).getStringArray()));
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
      shot();
      time=0;
    }
  }
}

class EnemyWeapon extends Weapon{
  Enemy parentEnemy;
  
  EnemyWeapon(Enemy e){
    super(e);
    parentEnemy=e;
    setPower(1);
    setSpeed(3.5f);
    setDuration(120);
    setDiffuse(radians(1));
    setCoolTime(250);
    setBulletNumber(1);
  }
  
  @Override
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
      NextEntities.add(new ThroughBullet(parentEnemy,this));
    }
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
  }
  
  @Override
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
      NextEntities.add(new EnemyPoisonBullet(parentEnemy,this));
    }
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
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
      NextEntities.add(new AntiSkillBullet(parentEnemy,this));
    }
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
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
      NextEntities.add(new BoundBullet(parentEnemy,this));
    }
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
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
      NextEntities.add(new ThroughBullet(parentEnemy,this));
    }
  }
}

class EnergyBullet extends Weapon{
  
  EnergyBullet(Entity e){
    super(e);
    setPower(1);
    setSpeed(15);
    setDuration(40);
    setDiffuse(0f);
    setCoolTime(15);
    setBulletNumber(1);
  }
}

class PulseBullet extends Weapon{
  
  PulseBullet(Entity e){
    super(e);
    setSpeed(20);
    setPower(1.3f);
    setDuration(40);
    setAutoShot(true);
    setColor(new Color(0,255,255));
    setHeatUP(0.45f);
    setDiffuse(0f);
    setCoolTime(15);
  }
}

class G_ShotWeapon extends SubWeapon{
  
  G_ShotWeapon(){
    super();
  }
  
  G_ShotWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new GravityBullet(this,i));
    }
  }
}

class TurretWeapon extends SubWeapon{
  
  TurretWeapon(){
    super();
  }
  
  TurretWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new TurretBullet(this,i));
    }
  }
}

class MP5Weapon extends TurretWeapon{
  
  MP5Weapon(){
    super();
  }
  
  MP5Weapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new MP5Bullet(this,i));
    }
  }
}

class GrenadeWeapon extends SubWeapon{
  
  GrenadeWeapon(){
    super();
  }
  
  GrenadeWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new GrenadeBullet(this,i));
    }
  }
}

class MirrorWeapon extends SubWeapon{
  
  MirrorWeapon(){
    super();
  }
  
  MirrorWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    float offset=random(0,TWO_PI);
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new MirrorBullet(this,i,bulletNumber,offset));
    }
  }
}

class InfinityShieldWeapon extends MirrorWeapon{
  
  InfinityShieldWeapon(){
    super();
  }
  
  InfinityShieldWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    float offset=random(0,TWO_PI);
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new InfinityShieldBullet(this,i,bulletNumber,offset));
    }
  }
}

class PlasmaFieldWeapon extends SubWeapon{
  PlasmaFieldBullet bullet;
  
  PlasmaFieldWeapon(){
    super();
  }
  
  PlasmaFieldWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    if(bullet==null){
      bullet=new PlasmaFieldBullet();
      bullet.init(this);
      NextEntities.add(bullet);
    }else if(!EntitySet.contains(bullet)){
      bullet=new PlasmaFieldBullet();
      bullet.init(this);
      NextEntities.add(bullet);
    }
  }
  
   public void upgrade(JSONArray a,int level){
    super.upgrade(a,level);
    if(bullet!=null)bullet.init(this);
  }
  
  @Override public 
  void init(JSONObject o){
    super.init(o);
    bullet=null;
  }
}

class LaserWeapon extends SubWeapon{
  
  LaserWeapon(){
    super();
  }
  
  LaserWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new LaserBullet(this,i));
    }
  }
}

class ElectronWeapon extends LaserWeapon{
  
  ElectronWeapon(){
    super();
  }
  
  ElectronWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new ElectronBullet(this,i));
    }
  }
}

class LightningWeapon extends SubWeapon{
  int offset=0;
  
  LightningWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new LightningBullet(this,i,bulletNumber,offset));
    }
    offset++;
    offset%=12;
  }
}

class ReflectorWeapon extends SubWeapon{
  
  ReflectorWeapon(){
    super();
  }
  
  ReflectorWeapon(JSONObject o){
    super(o);
  }
  
  @Override 
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new ReflectorBullet(this,i));
    }
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
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new ShadowReflectorBullet(this,i));
    }
  }
}

class AbsorptionWeapon extends SubWeapon{
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
}

class FireWeapon extends SubWeapon{
  
  FireWeapon(){
    super();
  }
  
  FireWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new FireBullet(this,i));
    }
  }
}

class IceWeapon extends SubWeapon{
  
  IceWeapon(){
    super();
  }
  
  IceWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new IceBullet(this,i));
    }
  }
}

class InfernoWeapon extends SubWeapon{
  
  InfernoWeapon(){
    super();
  }
  
  InfernoWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  public void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new InfernoBullet(this,i));
    }
  }
}

class SatelliteWeapon extends SubWeapon{
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
    }else if(child!=null&&!NextEntities.contains(child)&&!EntitySet.contains(child)){
      child=new Satellite(this);
      NextEntities.add(child);
    }
  }
  
  @Override
  void reInit(){
    super.reInit();
    if(child==null)update();
    child.maxCooltime=max(15/bulletNumber,15-bulletNumber*2);
  }
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
    }else if(child!=null&&!NextEntities.contains(child)&&!EntitySet.contains(child)){
      child=new Hexite(this);
      NextEntities.add(child);
    }
  }
}

class itemWeapon extends SubWeapon{
  
  itemWeapon(){
    super();
  }
  
  itemWeapon(JSONObject o){
    init(o);
  }
  
  @Override public 
  void init(JSONObject o){
    level=1;
    obj=o;
    name=o.getString(params[0]);
    switch(name){
      case "projectile":bulletNumber=o.getInt("value");break;
      case "scale":scale=o.getFloat("value");break;
      case "power":power=o.getFloat("value");break;
      case "speed":speed=o.getFloat("value");break;
      case "duration":duration=o.getFloat("value");break;
      case "cooltime":coolTime=o.getFloat("value");break;
    }
    upgradeStatus=new HashMap<String,Float>();
    for(String s:params)upgradeStatus.put(s,0f);
  }
  
  @Override public 
  void upgrade(JSONArray a,int level) throws NullPointerException{
    this.level=level;
    if(level-2>=a.size())throw new NullPointerException();
    JSONObject add=a.getJSONObject(level-2);
    HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray(params[0]).getStringArray()));
    param.forEach(s->{if(upgradeStatus.containsKey(s))upgradeStatus.replace(s,upgradeStatus.get(s)+add.getFloat(s));});
    switch(name){
      case "projectile":bulletNumber=obj.getInt("value")+upgradeStatus.get(params[1]).intValue();break;
      case "scale":scale=obj.getFloat("value")+upgradeStatus.get(params[2]);break;
      case "power":power=obj.getFloat("value")+upgradeStatus.get(params[3]);break;
      case "speed":speed=obj.getFloat("value")+upgradeStatus.get(params[4]);break;
      case "duration":duration=obj.getFloat("value")+upgradeStatus.get(params[5]);break;
      case "cooltime":coolTime=obj.getFloat("value")+upgradeStatus.get(params[6]);break;
    }
  }
  
  @Override public 
  void reInit(){
    switch(name){
      case "projectile":bulletNumber=obj.getInt("value")+upgradeStatus.get(params[1]).intValue();break;
      case "scale":scale=obj.getFloat("value")+upgradeStatus.get(params[2]);break;
      case "power":power=obj.getFloat("value")+upgradeStatus.get(params[3]);break;
      case "speed":speed=obj.getFloat("value")+upgradeStatus.get(params[4]);break;
      case "duration":duration=obj.getFloat("value")+upgradeStatus.get(params[5]);break;
      case "cooltime":coolTime=obj.getFloat("value")+upgradeStatus.get(params[6]);break;
    }
  }
}

final class projectileWeapon extends itemWeapon{
  
  projectileWeapon(){
    super();
  }
  
  projectileWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    StatusList.get("projectile").put("item",(float)bulletNumber);
  }
}

final class scaleWeapon extends itemWeapon{
  
  scaleWeapon(){
    super();
  }
  
  scaleWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    StatusList.get("scale").put("item",scale*0.01f);
  }
}

final class powerWeapon extends itemWeapon{
  
  powerWeapon(){
    super();
  }
  
  powerWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    StatusList.get("power").put("item",power*0.01f);
  }
}

class speedWeapon extends itemWeapon{
  
  speedWeapon(){
    super();
  }
  
  speedWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    StatusList.get("velocity").put("item",speed*0.01f);
  }
}

class durationWeapon extends itemWeapon{
  
  durationWeapon(){
    super();
  }
  
  durationWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    StatusList.get("duration").put("item",duration*0.01f);
  }
}

class cooltimeWeapon extends itemWeapon{
  
  cooltimeWeapon(){
    super();
  }
  
  cooltimeWeapon(JSONObject o){
    super(o);
  }
  
  @Override public 
  void update(){
    StatusList.get("cooltime").put("item",-coolTime*0.01f);
  }
}

interface Equipment{
  int ATTAK=1;
  int DIFENCE=2;
}
