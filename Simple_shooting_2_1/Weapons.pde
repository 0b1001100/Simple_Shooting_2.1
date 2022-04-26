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
  int bulletMaxAge=60;
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
  
  void setMaxAge(int i){
    bulletMaxAge=i;
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
    switch(Attribute){
    case ENERGY:
    case PHYSICS:synchronized(Bullets){
                   for(int i=0;i<this.bulletNumber;i++){
                     if(parent instanceof Myself){
                       BulletHeap.add(new Bullet((Myself)parent,i));
                     }else{
                       BulletHeap.add(new Bullet(parent,this));
                     }
                   }
                 }
                 break;
    case LASER:break;
    }
  }
  
  Weapon clone()throws CloneNotSupportedException{
    return (Weapon)super.clone();
  }
}

class EnergyBullet extends Weapon{
  
  EnergyBullet(Entity e){
    super(e);
    setPower(1);
    setSpeed(15);
    setMaxAge(40);
    setDiffuse(0f);
    setCoolTime(15);
    setBulletNumber(1);
    setName("クォークキャノン");
  }
}

class DiffuseBullet extends Weapon{
  
  DiffuseBullet(Entity e){
    super(e);
    setPower(0.06);
    setSpeed(6);
    setAutoShot(true);
    setBulletNumber(3);
    setColor(new Color(255,105,20));
    setCoolTime(0);
    setHeatUP(20);
    setCoolDown(0.5);
    setDiffuse(radians(2));
    setName("タウブラスター");
  }
}

class PulseBullet extends Weapon{
  
  PulseBullet(Entity e){
    super(e);
    setSpeed(20);
    setPower(1.3);
    setMaxAge(40);
    setAutoShot(true);
    setColor(new Color(0,255,255));
    setHeatUP(0.45);
    setDiffuse(0f);
    setCoolTime(15);
    setName("フォトンパルス");
  }
}

interface Equipment{
  int ATTAK=1;
  int DIFENCE=2;
}
