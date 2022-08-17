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
  float duration=0;
  
  Bullet(){
  }
  
  Bullet(Myself m){
    rotate=-atan2(m.pos.x-localMouse.x,m.pos.y-localMouse.y)-PI/2+random(-m.diffuse/2,m.diffuse/2);
    speed=m.selectedWeapon.speed;
    bulletColor=cloneColor(m.selectedWeapon.bulletColor);
    parentColor=cloneColor(m.selectedWeapon.bulletColor);
    pos=new PVector(m.pos.x+cos(rotate)*m.size,m.pos.y+sin(rotate)*m.size);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    duration=m.selectedWeapon.duration;
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
    duration=m.selectedWeapon.duration;
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
    duration=w.duration;
    isMine=e.getClass().getSimpleName().equals("Myself");
    if(!isMine)bulletColor=new Color(255,0,0);
  }
  
  void display(PGraphics g){
    g.strokeWeight(1);
    if(Debug){
      displayAABB(g);
    }
    g.stroke(toColor(bulletColor));
    g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    if(age/duration>0.9)bulletColor=bulletColor.darker();
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>duration)isDead=true;
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
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
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
  
  void reflect(PVector c,float r){
    pos=getCrossPoint(pos,vel,c,r);
    reflectFromNormal(atan2(pos,c));
  }
  
  void reflectFromNormal(PVector n){
    vel=vel.copy().add(n.mult(dot(vel.copy().mult(-1),n)*2));
  }
  
  void reflectFromNormal(float r){
    PVector n=new PVector(1,0).rotate(r);
    vel=vel.copy().add(n.mult(dot(vel.copy().mult(-1),n)*2));
  }
}

class SubBullet extends Bullet{
  float scale=0;
  int through=0;
  
  SubBullet(){}
  
  SubBullet(SubWeapon w){
    parent=w;
    scale=w.scale;
    power=w.power;
    speed=w.speed;
    duration=w.duration;
    through=w.through;
    isMine=true;
    pos=player.pos.copy();
    rotate=random(0,TWO_PI);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
  }
  
  void init(SubWeapon w){
    parent=w;
    scale=w.scale;
    power=w.power;
    speed=w.speed;
    duration=w.duration;
    through=w.through;
    isMine=true;
    pos=player.pos.copy();
    rotate=random(0,TWO_PI);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
  }
  
  void setNear(int num){
    if(nearEnemy.size()>num){
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
  
  void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    if(stop){
      LensData.add(this);
    }else{
      g.stroke(200,110,255);
      g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    }
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(!stop&&age>60){
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
  volatile boolean hit=false;
  
  GrenadeBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    bulletColor=new Color(0,150,255);
    duration=60;
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>duration){
      isDead=true;
      HeapEntity.get(0).add(new BulletExplosion(this,scale,0.3,true,parent));
      return;
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
        if(!hit){
          HeapEntity.get(0).add(new BulletExplosion(this,scale,0.3,true,parent));
          hit=true;
        }
      }
    }
  }
}

class MirrorBullet extends SubBullet implements ExcludeGPGPU{
  HashSet<Entity>HitEnemy;
  HashSet<Entity>nextHitEnemy;
  float axis=0;
  float offset=0;
  float rad=0;
  PVector LeftUP;
  PVector RightUP;
  PVector LeftDown;
  PVector RightDown;
  PVector vector;
  
  MirrorBullet(SubWeapon w,int num,int sum,float offset){
    super(w);
    HitEnemy=new HashSet<Entity>();
    nextHitEnemy=new HashSet<Entity>();
    offset+=(num==0?0:(float)num/(float)sum)*TWO_PI;
    pos=player.pos.copy().add(new PVector(scale*5,0).rotate(offset));
    axis+=offset;
    this.offset=atan2(scale*0.5,scale*0.125)+offset;
    rad=dist(0,0,scale,scale*0.25)+offset;
    vel=new PVector(0,0);
    LeftUP=new PVector(scale*4.875,scale*0.5);
    RightUP=new PVector(scale*5.125,scale*0.5);
    LeftDown=new PVector(scale*4.875,-scale*0.5);
    RightDown=new PVector(scale*5.125,-scale*0.5);
    vector=new PVector(0,scale);
    bulletColor=new Color(0,255,220);
  }
  
  void display(PGraphics g){
    g.noFill();
    g.rectMode(CENTER);
    if(Debug){
      displayAABB(g);
    }
    g.stroke(toColor(bulletColor));
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(axis);
    g.rect(0,0,scale*0.25,scale);
    g.popMatrix();
    pos=player.pos.copy().add(new PVector(scale*5,0).rotate(axis));
  }
  
  void update(){
    pushMatrix();
    resetMatrix();
    translate(pos.x,pos.y);
    rotate(axis);
    LeftUP=Project(-scale*0.125,scale*0.5,g);
    RightUP=Project(scale*0.125,scale*0.5,g);
    LeftDown=Project(-scale*0.125,-scale*0.5,g);
    RightDown=Project(scale*0.125,-scale*0.5,g);
    Center=Project(0,0,g);
    resetMatrix();
    rotate(axis);
    vector=Project(0,scale,g);
    popMatrix();
    HitEnemy.clear();
    nextHitEnemy.forEach(e->{HitEnemy.add(e);});
    nextHitEnemy.clear();
    if(duration<0){
      isDead=true;
      return;
    }
    axis+=TWO_PI/(scale*10*PI/(speed*vectorMagnification));
    AxisSize=new PVector(max(abs(LeftUP.x-RightDown.x),abs(RightUP.x-LeftDown.x)),max(abs(LeftUP.y-RightDown.y),abs(RightUP.y-LeftDown.y)));
    putAABB();
    duration-=vectorMagnification;
  }
  
  @Override
  void Collision(Entity e){
    if((e instanceof Enemy)&&!(e instanceof Explosion)){
      if(CircleCollision(e.pos,e.size,LeftDown,vector)||
         CircleCollision(e.pos,e.size,RightDown,vector)){
        nextHitEnemy.add(e);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20/e.Mass));
        if(!HitEnemy.contains(e)){
          ((Enemy)e).Hit(this.parent);
        }
      }
    }
  }
}

class PlasmaFieldBullet extends SubBullet implements ExcludeGPGPU{
  HashMap<Entity,Float>cooltimes;
  HashSet<Entity>outEntity;
  HashSet<PVector>hitPosition;
  
  private PlasmaFieldBullet(){
    cooltimes=new HashMap<Entity,Float>();
    outEntity=new HashSet<Entity>();
    hitPosition=new HashSet<PVector>();
  }
  
  @Override
  void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    g.fill(195,255,0,10);
    g.stroke(255,50);
    g.strokeWeight(1);
    g.ellipse(pos.x,pos.y,scale,scale);
    g.stroke(255);
    for(PVector v:hitPosition){
      int num=(int)random(4+scale*0.02,8+scale*0.02);
      v.sub(pos).div(num);
      PVector p=pos.copy();
      for(int i=0;i<num;i++){
        PVector e=pos.copy().add(v.copy().mult(i+1).add(i==num-1?0:random(scale*0.05),i==num-1?0:random(scale*0.05)));
        g.line(p.x,p.y,e.x,e.y);
        p=e;
      }
    }
    hitPosition.clear();
  }
  
  void update(){
    HashMap<Entity,Float>nextCooltimes=new HashMap<Entity,Float>();
    cooltimes.forEach((k,v)->{
      cooltimes.replace(k,v-vectorMagnification);
      if(Entities.contains(k)&&!(outEntity.contains(k)&&cooltimes.get(k)<=0)){
        nextCooltimes.put(k,cooltimes.get(k));
        outEntity.add(k);
      }
    });
    cooltimes=nextCooltimes;
    pos=player.pos;
    Center=pos;
    AxisSize=new PVector(scale,scale);
    putAABB();
  }
  
  @Override
  void Collision(Entity e){
    if((e instanceof Enemy)&&!(e instanceof Explosion)){
      if(qDist(pos,e.pos,(scale+e.size)*0.5)){
        outEntity.remove(e);
        if(!cooltimes.containsKey(e)){
          ((Enemy)e).Hit(this.parent);
          cooltimes.put(e,parent.coolTime);
          hitPosition.add(e.pos.copy());
        }else{
          if(cooltimes.get(e)<=0){
            ((Enemy)e).Hit(this.parent);
            cooltimes.replace(e,parent.coolTime);
            hitPosition.add(e.pos.copy());
          }
        }
      }
    }
  }
}

class SatelliteBullet extends SubBullet{
  
  SatelliteBullet(SubWeapon w,int num,int sum,float offset){
    super(w);
    pos=((SatelliteWeapon)w).child.pos.copy();
    bulletColor=new Color(0,255,220);
  }
}

class LaserBullet extends SubBullet implements ExcludeGPGPU{
  HashSet<Entity>HitEnemy;
  HashSet<Entity>nextHitEnemy;
  ArrayList<PVector>points;
  LinkedHashMap<PVector,Integer>vertex;
  
  final int memory;
  
  LaserBullet(SubWeapon w,int num){
    super(w);
    memory=(int)(90/vectorMagnification);
    setNear(num);
    bulletColor=new Color(255,20,20);
    HitEnemy=new HashSet<Entity>();
    nextHitEnemy=new HashSet<Entity>();
    points=new ArrayList<PVector>(memory);
    vertex=new LinkedHashMap<PVector,Integer>();
  }
  
  @Override
  void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    g.strokeWeight(2);
    if(!pause){
      points.add(pos.copy());
      while(points.size()>memory){
        points.remove(0);
      }
    }
    g.stroke(toColor(bulletColor),100);
    if(vertex.size()>0&&!pause){
      ArrayList<PVector>vertexArray=new ArrayList<PVector>(vertex.keySet());
      for(int i=0;i<=vertex.size();i++){
        switch(i){
          case 0:g.line(points.get(0).x,points.get(0).y,vertexArray.get(0).x,vertexArray.get(0).y);break;
          default:if(i==vertex.size()){
                    g.line(points.get(points.size()-1).x,points.get(points.size()-1).y,vertexArray.get(i-1).x,vertexArray.get(i-1).y);
                  }else{
                    g.line(vertexArray.get(i-1).x,vertexArray.get(i-1).y,vertexArray.get(i).x,vertexArray.get(i).y);
                  }break;
        }
      }
    }else if(points.size()>0){
      g.line(points.get(0).x,points.get(0).y,points.get(points.size()-1).x,points.get(points.size()-1).y);
    }
    g.stroke(toColor(bulletColor));
    g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
  }
  
  void update(){
    if(age>duration){
      isDead=true;
      return;
    }
    age+=vectorMagnification;
    HitEnemy.clear();
    nextHitEnemy.forEach(e->{HitEnemy.add(e);});
    nextHitEnemy.clear();
    LinkedHashMap<PVector,Integer>nextVertex=new LinkedHashMap<PVector,Integer>();
    vertex.forEach((k,v)->{
      if(++v<memory)nextVertex.put(k,v);
    });
    vertex=nextVertex;
    if(pos.x<-scroll.x){
      pos.x=-scroll.x;
      if(vel.x>0)vel.x=-vel.x;
    }else if(-scroll.x+width<pos.x){
      pos.x=-scroll.x+width;
      if(vel.x<0)vel.x=-vel.x;
    }
    if(pos.y<-scroll.y){
      pos.y=-scroll.y;
      if(vel.y>0)vel.y=-vel.y;
    }else if(-scroll.y+height<pos.y){
      pos.y=-scroll.y+height;
      if(vel.y<0)vel.y=-vel.y;
    }
    PVector cross=null;
    PVector lvel=vel.copy();
    int dir=0;
    for(int i=0;i<4;i++){
      switch(i){
        case 0:cross=SegmentCrossPoint(scroll.copy().mult(-1),new PVector(width,0),pos,lvel);break;
        case 1:cross=SegmentCrossPoint(scroll.copy().mult(-1).add(0,height),new PVector(width,0),pos,lvel);break;
        case 2:cross=SegmentCrossPoint(scroll.copy().mult(-1),new PVector(0,height),pos,vel);break;
        case 3:cross=SegmentCrossPoint(scroll.copy().mult(-1).add(width,0),new PVector(0,height),pos,lvel);break;
      }
      if(cross!=null){
        vertex.put(cross,0);
        dir=i;
        lvel=vel.copy().sub(cross.copy().sub(pos));
        if(dir<2){
          vel.y=-vel.y;
          lvel.y=-lvel.y;
        }else{
          vel.x=-vel.x;
          lvel.x=-lvel.x;
        }
        break;
      }
    }
    pos.add(lvel.copy().mult(vectorMagnification));
    setAABB();
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(!HitEnemy.contains(e)){
          ((Enemy)e).Hit(parent);
          ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20f/e.Mass));
        }
      }
    }
  }
  
  @Override
  void reflect(PVector c,float r){
    super.reflect(c,r);
    vertex.put(pos.copy(),0);
  }
}

class LightningBullet extends SubBullet implements ExcludeGPGPU{
  int frame=0;
  float rad=0;
  
  LightningBullet(SubWeapon w,int num,int sum,int offset){
    super(w);
    rad=-HALF_PI+HALF_PI/3*offset+TWO_PI/(float)sum*num;
    int len=width+height;
    for(int i=0;i<4;i++){
      switch(i){
        case 0:vel=SegmentCrossPoint(scroll.copy().mult(-1),new PVector(width,0),pos,new PVector(len,0).rotate(rad));break;
        case 1:vel=SegmentCrossPoint(scroll.copy().mult(-1).add(0,height),new PVector(width,0),pos,new PVector(len,0).rotate(rad));break;
        case 2:vel=SegmentCrossPoint(scroll.copy().mult(-1),new PVector(0,height),pos,new PVector(len,0).rotate(rad));break;
        case 3:vel=SegmentCrossPoint(scroll.copy().mult(-1).add(width,0),new PVector(0,height),pos,new PVector(len,0).rotate(rad));break;
      }
      if(vel!=null){
        vel.sub(pos);
        break;
      }
    }
  }
  
  @Override
  void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    g.strokeWeight(scale);
    g.stroke(255,255,240);
    g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
  }
  
  void update(){
    if(frame>3)isDead=true;
    setAABB();
    frame++;
  }
  
  @Override
  void Collision(Entity e){
    if(!(e instanceof Explosion)&&(e instanceof Enemy)){
      if(frame==1&&(CircleCollision(e.pos,e.size,pos.copy().add(new PVector(scale/2,0).rotate(rad-HALF_PI)),vel)
                  ||CircleCollision(e.pos,e.size,pos.copy().add(new PVector(scale/2,0).rotate(rad+HALF_PI)),vel))){
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20f/e.Mass));
      }
    }
  }
}

class ReflectorBullet extends SubBullet{
  HashSet<Entity>HitEnemy;
  HashSet<Entity>nextHitEnemy;
  
  ReflectorBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    bulletColor=new Color(230,230,230);
    HitEnemy=new HashSet<Entity>();
    nextHitEnemy=new HashSet<Entity>();
  }
  
  @Override
  void update(){
    HitEnemy.clear();
    nextHitEnemy.forEach(e->{HitEnemy.add(e);});
    nextHitEnemy.clear();
    super.update();
  }
  
  @Override
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(!HitEnemy.contains(e)){
          reflectFromNormal(atan2(pos,e.pos));
          ((Enemy)e).Hit(parent);
          ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20f/e.Mass));
        }
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
