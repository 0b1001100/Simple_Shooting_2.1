HashMap<String,Constructor>WeaponConstructor=new HashMap<String,Constructor>();
int addtionalProjectile=0;
float addtionalScale=1;
float addtionalPower=1;
float addtionalSpeed=1;
float addtionalDuration=1;
float reductionCoolTime=1;

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
  float heatUP=0.4;
  float coolDown=0.2;
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
  
  void setType(int t){
    type=t;
  }
  
  void setPower(float p){
    power=p;
  }
  
  void setSpeed(float s){
    speed=s;
  }
  
  void setColor(Color c){
    bulletColor=c;
  }
  
  void setColor(int r,int g,int b){
    bulletColor=new Color(r,g,b);
  }
  
  void setDiffuse(Float rad){
    diffuse=rad;
  }
  
  void setCoolTime(float t){
    coolTime=t;
  }
  
  void setName(String s){
    name=s;
  }
  
  void setAttribute(int a){
    Attribute=a;
  }
  
  void setAutoShot(boolean a){
    autoShot=a;
  }
  
  void setDuration(int i){
    duration=i;
  }
  
  void setBulletNumber(int n){
    bulletNumber=n;
  }
  
  void setHeatUP(float h){
    heatUP=h;
  }
  
  void setCoolDown(float c){
    coolDown=c;
  }
  
  void setLoadNumber(int i){
    loadNumber=i;
  }
  
  void setLoadedNumber(int i){
    loadedNumber=i;
  }
  
  void setReloadTime(int t){
    maxReloadTime=t;
  }
  
  String getName(){
    return name;
  }
  
  void reload(){
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
  
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
      if(parent instanceof Myself){
        NextEntities.add(new Bullet((Myself)parent,i));
      }else{
        HeapEntity.get(parent.threadNum).add(new Bullet(parent,this));
      }
    }
  }
  
  Weapon clone()throws CloneNotSupportedException{
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
  
  void init(JSONObject o){
    level=1;
    obj=o;
    name=o.getString(params[0]);
    bulletNumber=o.getInt(params[1])+addtionalProjectile;
    scale=o.getFloat(params[2])*addtionalScale;
    power=o.getFloat(params[3])*addtionalPower;
    speed=o.getFloat(params[4])*addtionalSpeed;
    duration=o.getFloat(params[5])*addtionalDuration;
    coolTime=o.getFloat(params[6])*reductionCoolTime;
    through=o.getInt(params[7]);
    upgradeStatus=new HashMap<String,Float>();
    for(String s:params)upgradeStatus.put(s,0f);
  }
  
  void upgrade(JSONArray a,int level){
    this.level=level;
    JSONObject add=a.getJSONObject(level-2);
    HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray(params[0]).getStringArray()));
    param.forEach(s->{if(upgradeStatus.containsKey(s))upgradeStatus.replace(s,upgradeStatus.get(s)+add.getFloat(s));});
    bulletNumber=obj.getInt(params[1])+upgradeStatus.get(params[1]).intValue()+addtionalProjectile;
    scale=(obj.getFloat(params[2])+upgradeStatus.get(params[2]))*addtionalScale;
    power=(obj.getFloat(params[3])+upgradeStatus.get(params[3]))*addtionalPower;
    speed=(obj.getFloat(params[4])+upgradeStatus.get(params[4]))*addtionalSpeed;
    duration=(obj.getFloat(params[5])+upgradeStatus.get(params[5]))*addtionalDuration;
    coolTime=(obj.getFloat(params[6])+upgradeStatus.get(params[6]))*reductionCoolTime;
    through=obj.getInt(params[7])+upgradeStatus.get(params[7]).intValue();
  }
  
  void reInit(){
    bulletNumber=obj.getInt(params[1])+upgradeStatus.get(params[1]).intValue()+addtionalProjectile;
    scale=(obj.getFloat(params[2])+upgradeStatus.get(params[2]))*addtionalScale;
    power=(obj.getFloat(params[3])+upgradeStatus.get(params[3]))*addtionalPower;
    speed=(obj.getFloat(params[4])+upgradeStatus.get(params[4]))*addtionalSpeed;
    duration=(obj.getFloat(params[5])+upgradeStatus.get(params[5]))*addtionalDuration;
    coolTime=(obj.getFloat(params[6])+upgradeStatus.get(params[6]))*reductionCoolTime;
    through=obj.getInt(params[7])+upgradeStatus.get(params[7]).intValue();
  }
  
  void update(){
    time+=vectorMagnification;
    if(time>=coolTime){
      shot();
      time=0;
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
    setName("クォークキャノン");
  }
}

class PulseBullet extends Weapon{
  
  PulseBullet(Entity e){
    super(e);
    setSpeed(20);
    setPower(1.3);
    setDuration(40);
    setAutoShot(true);
    setColor(new Color(0,255,255));
    setHeatUP(0.45);
    setDiffuse(0f);
    setCoolTime(15);
    setName("フォトンパルス");
  }
}

class G_ShotWeapon extends SubWeapon{
  
  G_ShotWeapon(){
    super();
  }
  
  G_ShotWeapon(JSONObject o){
    super(o);
  }
  
  @Override
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
  
  @Override
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new TurretBullet(this,i));
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
  
  @Override
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
  
  @Override
  void shot(){
    float offset=random(0,TWO_PI);
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new MirrorBullet(this,i,bulletNumber,offset));
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
  
  @Override
  void update(){
    if(bullet==null){
      bullet=new PlasmaFieldBullet();
      bullet.init(this);
      NextEntities.add(bullet);
    }
  }
  
  void upgrade(JSONArray a,int level){
    super.upgrade(a,level);
    bullet.init(this);
  }
  
  @Override
  void init(JSONObject o){
    super.init(o);
    bullet=null;
  }
}

class SatelliteWeapon extends SubWeapon{
  Satellite child;
  
  SatelliteWeapon(){
    super();
  }
  
  SatelliteWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  void update(){
    if(child==null){
      child=new Satellite(this);
      NextEntities.add(child);
    }
  }
}

class LaserWeapon extends SubWeapon{
  
  LaserWeapon(){
    super();
  }
  
  LaserWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new LaserBullet(this,i));
    }
  }
}

class LightningWeapon extends SubWeapon{
  int offset=0;
  
  LightningWeapon(JSONObject o){
    super(o);
  }
  
  @Override
  void shot(){
    for(int i=0;i<this.bulletNumber;i++){
        NextEntities.add(new LightningBullet(this,i,bulletNumber,offset));
    }
    offset++;
    offset%=12;
  }
}

interface Equipment{
  int ATTAK=1;
  int DIFENCE=2;
}
