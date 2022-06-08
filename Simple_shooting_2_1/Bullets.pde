class Bullet extends Entity{
  Weapon parent;
  boolean isMine=false;
  boolean bounse=false;
  Color bulletColor;
  Color parentColor;
  float rotate=0;
  float speed=7;
  float power;
  float age=0;
  int maxAge=0;
  
  Bullet(){
  }
  
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
    if(!isMine)bulletColor=new Color(255,0,0);
  }
  
  void display(){
    strokeWeight(1);
    if(Debug){
      noFill();
      stroke(255);
      rectMode(CENTER);
      rect(Center.x,Center.y,AxisSize.x,AxisSize.y);
    }
    stroke(toColor(bulletColor));
    line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    if(age/maxAge>0.9)bulletColor=bulletColor.darker();
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>maxAge)isDead=true;
    age+=vectorMagnification;
    setAABB();
  }
  
  void setAABB(){
    Center=pos.copy().add(vel.copy().mult(0.5).mult(vectorMagnification));
    AxisSize=new PVector(abs(vel.x),abs(vel.y)).mult(vectorMagnification);
    putAABB();
  }
  
  void setBounse(boolean b){
    bounse=b;
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        ((Enemy)e).Hit(parent);
        isDead=true;
      }
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

class SubBullet extends Bullet{
  float scale=0;
  int duration=0;
  int through=0;
  
  SubBullet(SubWeapon w){
    parent=w;
    scale=w.scale;
    power=w.power;
    speed=w.speed;
    maxAge=w.bulletMaxAge;
    duration=w.duration;
    through=w.through;
    isMine=true;
    pos=player.pos.copy();
    rotate=random(0,TWO_PI);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
  }
  
  void setNear(int num){
    if(nearEnemy.size()>0){
      float rad=-atan2(pos,nearEnemy.get(num).pos)+HALF_PI+random(radians(-2),radians(2));
      vel=new PVector(cos(rad)*speed,sin(rad)*speed);
    }
  }
}

class GravityBullet extends SubBullet{
  PVector screen;
  boolean stop=false;
  float count=0;
  final float damageCoolTime=30;
  
  GravityBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    screen=new PVector(pos.x-player.pos.x+width*0.5,height-(pos.y-player.pos.y+height*0.5));
  }
  
  void display(){
    if(stop){
      LensData.add(this);
    }else{
      stroke(200,110,255);
      line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    }
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(!stop&&age>maxAge){
      age=0;
      stop=true;
      vel=new PVector(0,0);
    }
    if(count>damageCoolTime){
      count=0;
    }
    if(duration<0)isDead=true;
    if(stop){
      duration-=vectorMagnification;
      count+=vectorMagnification;
    }else{
      age+=vectorMagnification;
    }
    screen=new PVector(pos.x-player.pos.x+width*0.5,height-(pos.y-player.pos.y+height*0.5));
    setAABB();
  }
  
  void setAABB(){
    if(stop){
      Center=pos;
      AxisSize=new PVector(scale,scale).mult(1.5);
    }else{
      Center=pos.copy().add(vel.copy().mult(0.5).mult(vectorMagnification));
      AxisSize=new PVector(abs(vel.x),abs(vel.y)).mult(vectorMagnification);
    }
    putAABB();
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(stop){
        if(qDist(pos,e.pos,(e.size+scale)*0.75)){
          float rad=-atan2(pos,e.pos)+HALF_PI;
          e.vel.add(new PVector(-dist(pos,e.pos)/((e.size+scale)*0.75),0).rotate(rad));
        }
        if(count>=damageCoolTime&&qDist(pos,e.pos,(e.size+scale)*0.5)){
          ((Enemy)e).Hit(parent);
        }
      }else{
        if(CircleCollision(e.pos,e.size,pos,vel)){
          ((Enemy)e).Hit(parent.power*3);
          age=0;
          stop=true;
          vel=new PVector(0,0);
        }
      }
    }
  }
}

class TurretBullet extends SubBullet{
  
  TurretBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    bulletColor=new Color(0,150,255);
  }
}

class GrenadeBullet extends SubBullet{
  
  GrenadeBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    bulletColor=new Color(0,150,255);
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>maxAge){
      isDead=true;
      addExplosion(this,scale,0.3);
    }
    age+=vectorMagnification;
    setAABB();
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        ((Enemy)e).Hit(parent.power*3);
        isDead=true;
        addExplosion(this,scale,0.3);
      }
    }
  }
}

class HomingBullet extends SubBullet{
  float mag=0.0005;
  int num;
  
  HomingBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    bulletColor=new Color(0,0,255);
    this.num=num;
  }
  
  @Override
  void display(){
    super.display();
  }
  
  @Override
  void update(){
    super.update();
    float rad=atan2(nearEnemy.get(num).pos.x-pos.x,nearEnemy.get(num).pos.y-pos.y)-PI*0.5;
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,PI*mag*vectorMagnification);
    rotate+=rad;
    rotate%=TWO_PI;
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    setAABB();
  }
}