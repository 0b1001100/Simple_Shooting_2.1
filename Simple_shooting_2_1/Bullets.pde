TreeMap<Float,Bullet>BulletX=new TreeMap<Float,Bullet>();
TreeMap<Float,Object>BulletEnemyX=new TreeMap<Float,Object>();
HashMap<Float,String>BulletData=new HashMap<Float,String>();

class Bullet extends Entity{
  Weapon parent;
  PVector bVel;
  PVector tPos;
  boolean isMine=false;
  boolean isDead=false;
  boolean bounse=false;
  Color bulletColor;
  Color parentColor;
  float rotate=0;
  float speed=7;
  float power;
  float age=0;
  int maxAge=0;
  
  Bullet(Myself m){
    rotate=-atan2(m.pos.x-localMouse.x,m.pos.y-localMouse.y)-PI/2+random(-m.diffuse/2,m.diffuse/2);
    speed=m.selectedWeapon.speed;
    bulletColor=cloneColor(m.selectedWeapon.bulletColor);
    parentColor=cloneColor(m.selectedWeapon.bulletColor);
    pos=new PVector(m.pos.x+cos(rotate)*m.size,m.pos.y+sin(rotate)*m.size);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=m.selectedWeapon.bulletMaxAge;
    try{
      parent=m.selectedWeapon.clone();
    }catch(Exception e){}
    prePos=pos.copy();
    tPos=pos.copy();
    isMine=true;
  }
  
  Bullet(Myself m,int num){
    int n=m.selectedWeapon.bulletNumber;
    float r=n>1?radians(20)/(n/2):0;
    float rad=n>1?r*(n-1):0;
    rotate=-atan2(m.pos.x-localMouse.x,m.pos.y-localMouse.y)-PI/2+random(-m.diffuse/2,m.diffuse/2)+(n>1?+rad/2-num*r:0);
    speed=m.selectedWeapon.speed;
    bulletColor=cloneColor(m.selectedWeapon.bulletColor);
    parentColor=cloneColor(m.selectedWeapon.bulletColor);
    pos=new PVector(m.pos.x+cos(rotate)*m.size,m.pos.y+sin(rotate)*m.size);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=m.selectedWeapon.bulletMaxAge;
    try{
      parent=m.selectedWeapon.clone();
    }catch(Exception e){}
    prePos=pos.copy();
    tPos=pos.copy();
    isMine=true;
  }
  
  Bullet(Entity e,Weapon w){
    isMine=e instanceof Myself;
    try{
      parent=w.clone();
    }catch(Exception E){}
    if(w.loadedNumber>1){
      w.loadedNumber--;
    }else if(w.loadedNumber>0){
      w.loadedNumber--;
      w.reload();
    }
    rotate=-e.rotate-PI/2+random(-w.diffuse/2,w.diffuse/2);
    speed=w.speed;
    bulletColor=cloneColor(w.bulletColor);
    parentColor=cloneColor(w.bulletColor);
    pos=new PVector(e.pos.x-(isMine?0:cos(rotate)*e.size),e.pos.y-(isMine?0:sin(rotate)*e.size));
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=w.bulletMaxAge;
    isMine=e.getClass().getSimpleName().equals("Myself");
    prePos=pos.copy();
    tPos=pos.copy();
    if(!isMine)bulletColor=new Color(255,0,0);
  }
  
  void display(){
    strokeWeight(1);
    stroke(toColor(bulletColor));
    line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    if(age/maxAge>0.9)bulletColor=bulletColor.darker();
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>maxAge)isDead=true;
    age+=vectorMagnification;
    tPos=prePos.copy();
    prePos=pos.copy();println("aaa");synchronized(Enemies){for(Enemy e:Enemies)Collision(e);}
    float min=min(pos.x+vel.x,pos.x)*vectorMagnification;
    float max=max(pos.x+vel.x,pos.x)*vectorMagnification;
    BulletX.put(min,this);
    BulletX.put(max,this);
    BulletData.put(min,"s");
    BulletData.put(max,"e");
  }
  
  void setBounse(boolean b){
    bounse=b;
  }
  
  void Collision(Enemy e){
    if(CircleCollision(e.pos,e.size,pos,vel)){
      isDead=true;
      e.Hit(parent);
    }
  }
  
  void invX(){
    float r=PI-abs(rotate);
    rotate=r*sign(rotate);
  }
  
  void invY(){
    rotate=-rotate;
  }
  
  void refrectFromNormal(PVector n){
    vel=vel.copy().add(n.mult(dot(vel.copy().mult(-1),n)*2));
  }
}

class HomingBullet extends Bullet{
  Entity target=null;
  float mag=0.0005;
  
  HomingBullet(Myself m,Entity e){
    super(m);
    target=e;
  }
  
  HomingBullet(Entity e,Weapon w,Entity t){
    super(e,w);
    target=t;
  }
  
  @Override
  void display(){
    super.display();
  }
  
  @Override
  void update(){
    super.update();
    float rad=atan2(target.pos.x-pos.x,target.pos.y-pos.y)-PI*0.5;
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,PI*mag*vectorMagnification);
    rotate+=rad;
    rotate%=TWO_PI;
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
  }
}
