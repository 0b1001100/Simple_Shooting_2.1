class Particle{
  ArrayList<particleFragment>particles=new ArrayList<particleFragment>();
  boolean isDead=false;
  Color pColor;
  float min=1;
  float max=5;
  float time=0;
  
  Particle(){
    
  }
  
  Particle(Bullet b,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(b.bulletColor.getRed(),b.bulletColor.getGreen(),b.bulletColor.getBlue(),(int)random(16,255));
      particles.add(new LineFragment(b.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Entity e,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(e.c.getRed(),e.c.getGreen(),e.c.getBlue(),(int)random(16,255));
      particles.add(new particleFragment(e.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Entity e,String s){
    particles.add(new StringFragment(e.pos,new PVector(0,-1),
                      e instanceof Myself?new Color(255,0,0):new Color(255,255,255),15,s));
  }
  
  Particle(Entity e,int num,float speed){
    for(int i=0;i<num;i++){
      float scala=random(0,speed);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(e.c.getRed(),e.c.getGreen(),e.c.getBlue(),(int)random(16,255));
      particles.add(new particleFragment(e.pos,vec,c,random(min,max)));
    }
  }
  
  Particle setSize(float min,float max){
    this.min=min;
    this.max=max;
    for(particleFragment p:particles){
      p.setSize(random(min,max));
    }
    return this;
  }
  
  void display(){
    for(particleFragment p:particles){
      p.display();
    }
  }
  
  void update(){
    ArrayList<particleFragment>nextParticles=new ArrayList<particleFragment>();
    for(particleFragment p:particles){
      p.setAlpha(p.alpha-(p instanceof StringFragment?1000f/p.alpha:2)*vectorMagnification);
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    particles=nextParticles;
    time+=2*vectorMagnification;
    if(time>255){
      isDead=true;
    }
  }
}

class ExplosionParticle extends Particle{
  PVector pos;
  float nowSize=0;
  float size=0;
  float time=0;
  
  float maxTime=0.4;
  
  ExplosionParticle(Entity e,float size){
    this.pos=e.pos.copy();
    this.size=size;
    pColor=new Color(255,60,0);
  }
  
  ExplosionParticle(Entity e,float size,float time){
    this.pos=e.pos.copy();
    this.size=size;
    pColor=new Color(255,60,0);
    maxTime=time;
  }
  
  void display(){
    nowSize=size*(time/maxTime)*2;
    noFill();
    stroke(toColor(pColor));
    strokeWeight(1);
    ellipse(pos.x,pos.y,nowSize,nowSize);
  }
  
  void update(){
    time+=0.016*vectorMagnification;
    if(time>=maxTime)isDead=true;
  }
}

class StringFragment extends particleFragment{
  String text="0";
  
  final float diffuse=5.5;
  
  StringFragment(PVector pos,PVector vel,Color c,float size,String s){
    super(pos,vel,c,size);
    this.pos.add(random(-diffuse,diffuse),random(-diffuse,diffuse));
    setText(s);
  }
  
  void setText(String s){
    text=s;
  }
  
  void display(){
    blendMode(BLEND);
    textAlign(CENTER);
    textSize(size+1);
    fill(128,128,128,pColor.getAlpha());
    text(text,pos.x,pos.y);
    textSize(size);
    fill(toColor(pColor));
    text(text,pos.x,pos.y);
  }
  
  void update(){
    vel=vel.copy().div(1.1);
    super.update();
  }
}

class LineFragment extends particleFragment{
  
  LineFragment(PVector pos,PVector vel,Color c,float size){
    super(pos,vel,c,size);
  }
  
  void display(){
    if(!inScreen)return;
    if(alpha<=0){
      isDead=true;
      return;
    }
    strokeWeight(1);
    stroke(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),pColor.getAlpha());
    line(pos.x,pos.y,pos.x+vel.x*size*3,pos.y+vel.y*size*3);
  }
  
  void update(){
    super.update();
  }
}

class particleFragment{
  PVector pos;
  PVector vel;
  boolean inScreen=true;
  boolean isDead=false;
  Color pColor;
  float alpha;
  float size;
  
  particleFragment(PVector pos,PVector vel,Color c,float size){
    this.pos=new PVector(pos.x,pos.y);
    this.vel=new PVector(vel.x,vel.y);
    this.pColor=new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
    alpha=c.getAlpha();
    this.size=size;
  }
  
  particleFragment setSize(float f){
    size=f;
    return this;
  }
  
  particleFragment setColor(Color c){
    this.pColor=new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
    return this;
  }
  
  particleFragment setAlpha(float a){
    alpha=constrain(a,0,255);
    pColor=new Color(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),round(max(0,alpha)));
    return this;
  }
  
  void display(){
    if(!inScreen)return;
    if(alpha<=0){
      isDead=true;
      return;
    }
    noStroke();
    fill(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),pColor.getAlpha());
    rectMode(CENTER);
    rect(pos.x,pos.y,size,size);
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    inScreen=-scroll.x<pos.x-size/2&&pos.x+size/2<-scroll.x+width&&-scroll.y<pos.y-size/2&&pos.y+size/2<-scroll.y+height;
  }
}
