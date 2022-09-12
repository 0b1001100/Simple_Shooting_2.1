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
    pos=new PVector(m.pos.x+cos(rotate)*m.size*0.5f,m.pos.y+sin(rotate)*m.size*0.5f);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    duration=m.selectedWeapon.duration;
    try{
      parent=m.selectedWeapon.clone();
    }catch(Exception e){}
    isMine=true;
    setAABB();
  }
  
  Bullet(Myself m,int num){
    int n=m.selectedWeapon.bulletNumber;
    float r=n>1?radians(20)/(n/2):0;
    float rad=n>1?r*(n-1):0;
    rotate=-atan2(m.pos.x-localMouse.x,m.pos.y-localMouse.y)-PI/2+random(-m.diffuse/2,m.diffuse/2)+(n>1?+rad/2-num*r:0);
    speed=m.selectedWeapon.speed;
    bulletColor=cloneColor(m.selectedWeapon.bulletColor);
    parentColor=cloneColor(m.selectedWeapon.bulletColor);
    pos=new PVector(m.pos.x+cos(rotate)*m.size*0.5f,m.pos.y+sin(rotate)*m.size*0.5f);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    duration=m.selectedWeapon.duration;
    try{
      parent=m.selectedWeapon.clone();
    }catch(Exception e){}
    isMine=true;
    setAABB();
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
    pos=new PVector(e.pos.x+cos(rotate)*e.size*0.5f,e.pos.y+sin(rotate)*e.size*0.5f);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    duration=w.duration;
    isMine=e.getClass().getSimpleName().equals("Myself");
    if(!isMine)bulletColor=new Color(255,0,0);
    setAABB();
  }
  
   public void display(PGraphics g){
    g.strokeWeight(1);
    if(Debug){
      displayAABB(g);
    }
    g.stroke(toColor(bulletColor));
    g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    if(age/duration>0.9f)bulletColor=bulletColor.darker();
  }
  
   public void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>duration)isDead=true;
    age+=vectorMagnification;
    setAABB();
  }
  
   public void setAABB(){
    Center=pos.copy().add(vel.copy().mult(0.5f).mult(vectorMagnification));
    AxisSize=new PVector(abs(vel.x),abs(vel.y)).mult(vectorMagnification);
    putAABB();
  }
  
   public void setBounse(boolean b){
    bounse=b;
  }
  
  @Override
  public void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
        isDead=true;
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      isDead=true;
      NextEntities.add(new Particle(this,5));
    }else if(e instanceof MirrorBullet){
      e.Collision(this);
    }else if(!(e instanceof SubBullet)&&(e instanceof Bullet)){
      if(((Bullet)e).isMine!=isMine&&!(e instanceof AntiBulletFieldBullet)){
        e.isDead=true;
        isDead=true;
        NextEntities.add(new Particle(this,4));
        NextEntities.add(new Particle(((Bullet)e),4));
      }else if(e instanceof AntiBulletFieldBullet){
        e.Collision(this);
      }
    }else if(e instanceof Myself){
      if(!isMine&&CircleCollision(e.pos,e.size,pos,vel)){
        isDead=true;
        ((Myself)e).Hit(power);
      }
    }
  }
  
   public void invX(){
    float r=PI-abs(rotate);
    rotate=r*sign(rotate);
  }
  
   public void invY(){
    rotate=-rotate;
  }
  
   public void reflect(PVector c,float r){
    pos=getCrossPoint(pos,vel,c,r);
    reflectFromNormal(atan2(pos,c));
  }
  
   public void reflectFromNormal(PVector n){
    vel=vel.copy().add(n.copy().mult(dot(vel.copy().mult(-1),n)*2));
  }
  
   public void reflectFromNormal(float r){
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
  
   public void init(SubWeapon w){
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
  
   public void setNear(int num){
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
    screen=new PVector(pos.x-player.pos.x+width*0.5f,height-(pos.y-player.pos.y+height*0.5f));
    bulletColor=new Color(200,110,255);
  }
  
   public void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    if(stop){
      LensData.add(this);
    }else{
      g.stroke(toColor(bulletColor));
      g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    }
  }
  
   public void update(){
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
    screen=new PVector(pos.x-player.pos.x+width*0.5f,height-(pos.y-player.pos.y+height*0.5f));
    setAABB();
  }
  
   public void setAABB(){
    if(stop){
      Center=pos;
      AxisSize=new PVector(scale,scale).mult(1.5f);
    }else{
      Center=pos.copy().add(vel.copy().mult(0.5f).mult(vectorMagnification));
      AxisSize=new PVector(abs(vel.x),abs(vel.y)).mult(vectorMagnification);
    }
    putAABB();
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(stop){
        if(qDist(pos,e.pos,(e.size+scale)*0.75f)){
          float rad=-atan2(pos,e.pos)+HALF_PI;
          e.vel.add(new PVector(-dist(pos,e.pos)/((e.size+scale)*0.75f),0).rotate(rad));
        }
        if(count>=damageCoolTime&&qDist(pos,e.pos,(e.size+scale)*0.5f)){
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
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      age=0;
      stop=true;
      vel=new PVector(0,0);
      NextEntities.add(new Particle(this,5));
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

class MP5Bullet extends TurretBullet{
  
  MP5Bullet(SubWeapon w,int num){
    super(w,num);
    bulletColor=new Color(0,50,255);
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
  
   public void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(age>duration){
      isDead=true;
      HeapEntity.get(0).add(new BulletExplosion(this,scale,0.3f,true,parent));
      return;
    }
    age+=vectorMagnification;
    setAABB();
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        ((Enemy)e).Hit(parent.power*3);
        isDead=true;
        if(!hit){
          HeapEntity.get(0).add(new BulletExplosion(this,scale,0.3f,true,parent));
          hit=true;
        }
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      isDead=true;
      if(!hit){
        HeapEntity.get(0).add(new BulletExplosion(this,scale,0.3f,true,parent));
        hit=true;
      }
      NextEntities.add(new Particle(this,5));
    }
  }
}

class MirrorBullet extends SubBullet implements ExcludeGPGPU{
  HashSet<Entity>HitEnemy;
  HashSet<Entity>nextHitEnemy;
  float axis=0;
  float offset=0;
  float rad=0;
  float scaleMag=2;
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
    pos=player.pos.copy().add(new PVector(scale*scaleMag,0).rotate(offset));
    axis+=offset;
    this.offset=atan2(scale*0.5f,scale*0.125f)+offset;
    rad=dist(0,0,scale,scale*0.25f)+offset;
    vel=new PVector(0,0);
    LeftUP=new PVector(scale*4.875f,scale*0.5f);
    RightUP=new PVector(scale*5.125f,scale*0.5f);
    LeftDown=new PVector(scale*4.875f,-scale*0.5f);
    RightDown=new PVector(scale*5.125f,-scale*0.5f);
    vector=new PVector(0,scale);
    bulletColor=new Color(0,255,220);
  }
  
  @Override public 
  void display(PGraphics g){
    g.noFill();
    g.rectMode(CENTER);
    if(Debug){
      displayAABB(g);
    }
    g.stroke(toColor(bulletColor));
    g.strokeWeight(1);
    g.pushMatrix();
    g.translate(pos.x,pos.y);
    g.rotate(axis);
    g.rect(0,0,scale*0.25f,scale);
    g.popMatrix();
    pos=player.pos.copy().add(new PVector(scale*scaleMag,0).rotate(axis));
  }
  
  @Override public 
  void update(){
    LeftUP=new PVector(-scale*0.125f,scale*0.5f).rotate(axis).add(pos);
    RightUP=new PVector(scale*0.125f,scale*0.5f).rotate(axis).add(pos);
    LeftDown=new PVector(-scale*0.125f,-scale*0.5f).rotate(axis).add(pos);
    RightDown=new PVector(scale*0.125f,-scale*0.5f).rotate(axis).add(pos);
    Center=new PVector(0,0).rotate(axis).add(pos);
    vector=new PVector(0,scale).rotate(axis);
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
  
  @Override public 
  void Collision(Entity e){
    if((e instanceof Enemy)&&!(e instanceof Explosion)&&!(e instanceof ExcludeBullet)){
      if(circleOrientedRectangleCollision(e.pos,e.size,LeftDown,new PVector(scale*0.25f,scale),axis)){
        nextHitEnemy.add(e);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20/e.Mass));
        if(!HitEnemy.contains(e)){
          ((Enemy)e).Hit(this.parent);
        }
      }
    }else if(e instanceof Bullet){
      if(!((Bullet)e).isMine){
        if(SegmentOrientedRectangleCollision(e.pos,e.vel,LeftDown,new PVector(scale*0.25f,scale),axis)){
          ((Bullet)e).reflectFromNormal(axis);
          if(e instanceof ThroughBullet){
            ((Bullet)e).isMine=true;
            ((Bullet)e).parent.parent=player;
          }
        }
      }
    }
  }
}

class InfinityShieldBullet extends MirrorBullet{
  
  InfinityShieldBullet(SubWeapon w,int num,int sum,float offset){
    super(w,num,sum,offset);
    bulletColor=new Color(230,0,100);
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
  
  @Override public 
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
      int num=(int)random(4+scale*0.02f,8+scale*0.02f);
      v.sub(pos).div(num);
      PVector p=pos.copy();
      for(int i=0;i<num;i++){
        PVector e=pos.copy().add(v.copy().mult(i+1).add(i==num-1?0:random(scale*0.05f),i==num-1?0:random(scale*0.05f)));
        g.line(p.x,p.y,e.x,e.y);
        p=e;
      }
    }
    hitPosition.clear();
  }
  
   public void update(){
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
  
  @Override public 
  void Collision(Entity e){
    if((e instanceof Enemy)&&!(e instanceof Explosion)&&!(e instanceof ExcludeBullet)){
      if(qDist(pos,e.pos,(scale+e.size)*0.5f)){
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
  
  @Override public 
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
  
   public void update(){
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
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(!HitEnemy.contains(e)){
          ((Enemy)e).Hit(parent);
          ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20f/e.Mass));
        }
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      nextHitEnemy.add(e);
      reflectFromNormal(((WallEntity)e).norm);
      vertex.put(pos.copy(),0);
      NextEntities.add(new Particle(this,5));
    }
  }
  
  @Override public 
  void reflect(PVector c,float r){
    super.reflect(c,r);
    vertex.put(pos.copy(),0);
  }
}

class ElectronBullet extends LaserBullet{
  
  ElectronBullet(SubWeapon w,int num){
    super(w,num);
    bulletColor=new Color(20,20,255);
  }
}

class LightningBullet extends SubBullet implements ExcludeGPGPU{
  HashSet<Entity>HitEnemy;
  HashSet<Entity>nextHitEnemy;
  float time=0;
  float rad=0;
  
  LightningBullet(SubWeapon w,int num,int sum,int offset){
    super(w);
    pos=player.pos;
    if(nearEnemy.size()>num){
      rad=-atan2(pos,nearEnemy.get(num).pos)+HALF_PI+radians(random(-10.10f));
    }else{
      rad=-HALF_PI+HALF_PI/3*offset+TWO_PI/(float)sum*num;
    }
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
    HitEnemy=new HashSet<Entity>();
    nextHitEnemy=new HashSet<Entity>();
  }
  
  @Override
  public void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    g.strokeWeight(scale);
    g.stroke(255,255,240);
    g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
  }
  
  @Override
  public void update(){
    if(duration<time)isDead=true;
    time+=vectorMagnification;
    HitEnemy.clear();
    nextHitEnemy.forEach(e->{HitEnemy.add(e);});
    nextHitEnemy.clear();
    setAABB();
  }
  
  @Override
  public void Collision(Entity e){
    if(!(e instanceof Explosion)&&(e instanceof Enemy)&&!(e instanceof ExcludeBullet)){
      if(CircleCollision(e.pos,(e.size+size+4)*0.5f,pos,vel)){
        nextHitEnemy.add(e);
        if(!HitEnemy.contains(e)){
          ((Enemy)e).Hit(parent);
          ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20f/e.Mass));
        }
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
  
  @Override public 
  void update(){
    HitEnemy.clear();
    nextHitEnemy.forEach(e->{HitEnemy.add(e);});
    nextHitEnemy.clear();
    super.update();
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if(CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(!HitEnemy.contains(e)){
          reflectFromNormal(atan2(pos,e.pos));
          ((Enemy)e).Hit(parent);
          ((Enemy)e).addtionalVel=e.vel.copy().mult(-(20f/e.Mass));
          age-=30;
        }
      }
    }else if(e instanceof WallEntity){
      if(!(SegmentCollision(pos,vel,e.pos,((WallEntity)e).dist)
       &&SegmentCollision(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)))return;
      nextHitEnemy.add(e);
      reflectFromNormal(((WallEntity)e).norm);
      NextEntities.add(new Particle(this,5));
    }
  }
}

class ThroughBullet extends Bullet{
  HashSet<Entity>HitEnemy;
  HashSet<Entity>nextHitEnemy;
  
  {
    isMine=false;
    HitEnemy=new HashSet<Entity>();
    nextHitEnemy=new HashSet<Entity>();
  }
  
  ThroughBullet(Enemy e,Weapon w){
    super(e,w);
  }
  
  @Override public 
  void display(PGraphics g){
    g.strokeWeight(2);
    if(Debug){
      displayAABB(g);
    }
    g.stroke(toColor(bulletColor));
    g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    if(age/duration>0.9f)bulletColor=bulletColor.darker();
  }
  
  @Override public 
  void update(){
    HitEnemy.clear();
    nextHitEnemy.forEach(e->{HitEnemy.add(e);});
    nextHitEnemy.clear();
    super.update();
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if((isMine||parent.parent!=e)&&CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(HitEnemy.contains(e))return;
        if(e instanceof Explosion)isDead=true;
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
        if(e instanceof Turret_S)((Turret_S)e).target=parent.parent;
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      isDead=true;
      NextEntities.add(new Particle(this,5));
    }else if(e instanceof MirrorBullet){
      e.Collision(this);
    }else if(e instanceof Myself){
      if(!isMine&&CircleCollision(e.pos,e.size,pos,vel)){
        ((Myself)e).Hit(parent.power);
        isDead=true;
      }
    }
  }
}

class EnemyPoisonBullet extends ThroughBullet{
  
  EnemyPoisonBullet(Enemy e,Weapon w){
    super(e,w);
    setColor(new Color(5,200,70));
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if((isMine||parent.parent!=e)&&CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(HitEnemy.contains(e))return;
        if(e instanceof Explosion)isDead=true;
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
        if(e instanceof Turret_S)((Turret_S)e).target=parent.parent;
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      isDead=true;
      NextEntities.add(new Particle(this,5));
    }else if(e instanceof MirrorBullet){
      e.Collision(this);
    }else if(e instanceof Myself){
      if(!isMine&&CircleCollision(e.pos,e.size,pos,vel)){
        main.CommandQue.put("Poison",new Command(0,90,0,(s)->{
          if(s.equals("exec"))player.speedMag=0.5;
          if(s.equals("shutdown"))player.speedMag=1;
        }));
        ((Myself)e).Hit(parent.power);
        isDead=true;
      }
    }
  }
}

class AntiSkillBullet extends ThroughBullet{
  
  AntiSkillBullet(Enemy e,Weapon w){
    super(e,w);
    setColor(new Color(235,200,200));
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if((isMine||parent.parent!=e)&&CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(HitEnemy.contains(e))return;
        if(e instanceof Explosion)isDead=true;
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
        if(e instanceof Turret_S)((Turret_S)e).target=parent.parent;
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      isDead=true;
      NextEntities.add(new Particle(this,5));
    }else if(e instanceof MirrorBullet){
      e.Collision(this);
    }else if(e instanceof Myself){
      if(!isMine&&CircleCollision(e.pos,e.size,pos,vel)){
        main.CommandQue.put("Poison",new Command(0,90,0,(s)->{
          if(s.equals("exec"))player.useSub=false;
          if(s.equals("shutdown"))player.useSub=true;
        }));
        ((Myself)e).Hit(parent.power);
        isDead=true;
      }
    }
  }
}

class BoundBullet extends ThroughBullet{
  
  BoundBullet(Enemy e,Weapon w){
    super(e,w);
    setColor(new Color(255,220,100));
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if((isMine||parent.parent!=e)&&CircleCollision(e.pos,e.size,pos,vel)){
        nextHitEnemy.add(e);
        if(HitEnemy.contains(e))return;
        if(e instanceof Explosion)isDead=true;
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
        if(e instanceof Turret_S)((Turret_S)e).target=parent.parent;
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      isDead=true;
      NextEntities.add(new Particle(this,5));
    }else if(e instanceof MirrorBullet){
      e.Collision(this);
    }else if(e instanceof Myself){
      if(!isMine&&CircleCollision(e.pos,e.size,pos,vel)){
        e.Speed=e.maxSpeed*-3;
        ((Myself)e).Hit(parent.power);
        isDead=true;
      }
    }
  }
}

class AntiBulletFieldBullet extends Bullet{
  float scale=50;
  AntiBulletField parentEnemy;
  
  AntiBulletFieldBullet(AntiBulletField p){
    super();
    parentEnemy=p;
    bulletColor=new Color(60,115,255);
    vel=new PVector(0,0);
    scale=80;
    isMine=false;
  }
  
  @Override
  void display(PGraphics g){
    g.fill(60,115,255,10);
    g.stroke(60,115,255,50);
    g.ellipse(pos.x,pos.y,scale,scale);
  }
  
  @Override
  public void update(){
    if(!EntitySet.contains(parentEnemy)){
      isDead=true;
      return;
    }
    Center=pos;
    AxisSize=new PVector(scale,scale);
    putAABB();
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Bullet){
      if(!((e instanceof PlasmaFieldBullet)||(e instanceof FireBullet)||
         (e instanceof GrenadeBullet)||(e instanceof GravityBullet)||
         (e instanceof AbsorptionBullet))){
        if(((Bullet)e).isMine)e.isDead=true;
      }
    }
  }
}

class AbsorptionBullet extends SubBullet implements ExcludeGPGPU{
  ArrayList<Enemy>Source;
  
  {
    Source=new ArrayList<Enemy>();
  }
  
  private AbsorptionBullet(){
    Source=new ArrayList<Enemy>();
  }
  
  @Override public 
  void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    g.noFill();
    g.stroke(255,50+205*min(1,Source.size()*0.125f));
    g.strokeWeight(1);
    g.ellipse(pos.x,pos.y,scale,scale);
    g.stroke(255);
    Source.forEach(e->{
      g.line(pos.x,pos.y,e.pos.x,e.pos.y);
    });
  }
  
   public void update(){
    StatusList.get("power").put(this.getClass().getName(),power*min(1,Source.size()*0.125f)*0.01f);
    Source.clear();
    pos=player.pos;
    Center=pos;
    AxisSize=new PVector(scale,scale);
    putAABB();
  }
  
  @Override public 
  void Collision(Entity e){
    if((e instanceof Enemy)&&!(e instanceof Explosion)){
      if(qDist(pos,e.pos,(scale+e.size)*0.5f)){
        Source.add(((Enemy)e));
      }
    }
  }
}

class FireBullet extends SubBullet{
  HashMap<Entity,Float>cooltimes;
  HashSet<Entity>outEntity;
  PVector screen;
  boolean stop=false;
  float count=0;
  final float damageCoolTime=30;
  
  FireBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    screen=new PVector(pos.x-player.pos.x+width*0.5f,height-(pos.y-player.pos.y+height*0.5f));
    bulletColor=new Color(255,30,0);
    cooltimes=new HashMap<Entity,Float>();
    outEntity=new HashSet<Entity>();
  }
  
   public void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
    if(stop){
      g.stroke(255,100,0,100);
      g.fill(255,30,0,50);
      g.ellipse(pos.x,pos.y,scale,scale);
    }else{
      g.stroke(toColor(bulletColor));
      g.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
    }
  }
  
   public void update(){
    HashMap<Entity,Float>nextCooltimes=new HashMap<Entity,Float>();
    cooltimes.forEach((k,v)->{
      cooltimes.replace(k,v-vectorMagnification);
      if(Entities.contains(k)&&!(outEntity.contains(k)&&cooltimes.get(k)<=0)){
        nextCooltimes.put(k,cooltimes.get(k));
        outEntity.add(k);
      }
    });
    cooltimes=nextCooltimes;
    pos.add(vel.copy().mult(vectorMagnification));
    if(stop&&age%10<vectorMagnification)NextEntities.add(new Particle(pos.copy().add(new PVector(random(0,scale*0.5),0).rotate(random(TWO_PI))),new Color(255,30,0),1));
    if(!stop&&age>150){
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
    screen=new PVector(pos.x-player.pos.x+width*0.5f,height-(pos.y-player.pos.y+height*0.5f));
    setAABB();
  }
  
   public void setAABB(){
    if(stop){
      Center=pos;
      AxisSize=new PVector(scale,scale);
    }else{
      Center=pos.copy().add(vel.copy().mult(0.5f).mult(vectorMagnification));
      AxisSize=new PVector(abs(vel.x),abs(vel.y)).mult(vectorMagnification);
    }
    putAABB();
  }
  
  @Override public 
  void Collision(Entity e){
    if(e instanceof Enemy){
      if(stop){
        if(qDist(pos,e.pos,(e.size+scale)*0.5)){
          outEntity.remove(e);
          if(!cooltimes.containsKey(e)){
            ((Enemy)e).Hit(this.parent);
            cooltimes.put(e,20f);
          }else{
            if(cooltimes.get(e)<=0){
              ((Enemy)e).Hit(this.parent);
              cooltimes.replace(e,20f);
            }
          }
        }
      }else{
        if(CircleCollision(e.pos,e.size,pos,vel)){
          ((Enemy)e).Hit(parent.power*3);
          age=0;
          stop=true;
          vel=new PVector(0,0);
        }
      }
    }else if(e instanceof WallEntity){
      if(SegmentCrossPoint(pos,vel,e.pos,((WallEntity)e).dist)==null
       &&SegmentCrossPoint(pos,vel.copy().mult(-1),e.pos,((WallEntity)e).dist)==null)return;
      age=0;
      stop=true;
      vel=new PVector(0,0);
      NextEntities.add(new Particle(this,5));
    }
  }
}

class SatelliteBullet extends SubBullet{
  PVector t;
  Satellite satellite;
  float weight=3;
  boolean doRotate=true;
  
  SatelliteBullet(SatelliteWeapon w,Satellite s,PVector target){
    super(w);
    pos=w.child.pos.copy();
    bulletColor=new Color(0,255,150);
    satellite=s;
    t=target;
    vel=new PVector(random(2,4),0).rotate(-s.rad).mult(random(0,1)>0.5?1:-1);
  }
  
  @Override
  void display(PGraphics g){
    if(Debug)displayAABB(g);
    g.noFill();
    g.stroke(toColor(c));
    g.strokeWeight(1);
    g.triangle(pos.x+cos(rotate)*scale,pos.y+sin(rotate)*scale,pos.x+cos(rotate+TWO_PI/3)*scale,pos.y+sin(rotate+TWO_PI/3)*scale,pos.x+cos(rotate-TWO_PI/3)*scale,pos.y+sin(rotate-TWO_PI/3)*scale);
  }
  
  @Override
  void update(){
    if(doRotate){
      float protate=rotate;
      float rad=atan2(pos,t);
      doRotate=abs(rad)<2;
      float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
      rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
      rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,radians(weight)*vectorMagnification);
      rotate+=rad;
      vel=new PVector(speed,0).rotate(-rotate+HALF_PI);
    }
    super.update();
  }
  
  @Override
  public void setAABB(){
    Center=pos.copy();
    AxisSize=new PVector(scale*2,scale*2);
    putAABB();
  }
  
  @Override
  public void Collision(Entity e){
    if(e instanceof Enemy&&!(e instanceof ExcludeBullet)){
      if(qDist(pos,e.pos,e.size*0.5+scale)){
        ((Enemy)e).Hit(parent);
        ((Enemy)e).addtionalVel=e.vel.copy().mult(-(vel.mag()/e.Mass));
        isDead=true;
      }
    }else if(e instanceof WallEntity){
      if(!CircleCollision(pos,scale*2,e.pos,e.vel))return;
      isDead=true;
      NextEntities.add(new Particle(this,5));
    }
  }
}

class HomingBullet extends SubBullet{
  float mag=0.0005f;
  int num;
  
  HomingBullet(SubWeapon w,int num){
    super(w);
    setNear(num);
    bulletColor=new Color(0,0,255);
    this.num=num;
  }
  
  @Override public 
  void update(){
    super.update();
    float rad=atan2(nearEnemy.get(num).pos.x-pos.x,nearEnemy.get(num).pos.y-pos.y)-PI*0.5f;
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,PI*mag*vectorMagnification);
    rotate+=rad;
    rotate%=TWO_PI;
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    setAABB();
  }
}

interface ExcludeBullet{
}
