class Exp extends Entity{
  volatile float exp;
  boolean magnet=false;
  
  Exp(){
    size=3;
    setExp(1);
  }
  
  Exp(Entity e){
    pos=e.pos.copy();
    size=3;
    setExp(1);
  }
  
  Exp(Entity e,float exp){
    pos=e.pos.copy();
    size=3;
    setExp(exp);
  }
  
  public void setExp(float e){
    exp=e;
    if(exp<=4){
      c=new Color(0,150,255);
    }else if(exp<=49){
      c=new Color(0,240,125);
    }else if(exp<=99){
      c=new Color(255,55,55);
    }else{
      c=new Color(200,190,20);
    }
  }
  
  @Override
  public void display(PGraphics g){
    g.fill(toColor(c));
    g.noStroke();
    g.rect(pos.x,pos.y,size,size);
  }
  
  public void update(){
    if(magnet){
      if(qDist(pos,player.pos,player.size)){
        getProcess();
        destruct(player);
        return;
      }
      vel.set(PVector.sub(player.pos,pos).normalize().mult(min(5f,dist(pos,player.pos))));
      pos.add(vel);
    }else{
      Center=pos;
      AxisSize.set(size+player.magnetDist*2,size+player.magnetDist*2);
      putAABB();
    }
  }
  
  public void getProcess(){
    player.exp+=this.exp;
  }
  
  public void setPos(PVector p){
    pos=p;
  }
  
  @Override
  public void Collision(Entity e){
    if(isDead)return;
    if(!magnet&&e instanceof Myself){
      Myself m=(Myself)e;
      if(qDist(m.pos,pos,m.magnetDist+1.5)&&m.canMagnet){
        magnet=true;
      }
    }else if(e.getClass().getName().equals(Exp.class.getName())&&getClass().getName().equals(Exp.class.getName())&&qDist(e.pos,pos,20f)){
      if(e.isDead)return;
      Exp ex=(Exp)e;
      ex.setExp(ex.exp+exp);
      ex.pos=pos.add(ex.pos).mult(0.5);
      destruct(e);
    }
  }
}

class LargeExp extends Exp{
  
  LargeExp(){
    super();
    size=6;
  }
  
  LargeExp(Entity e){
    super(e);
    size=6;
  }
  
  LargeExp(Entity e,float exp){
    super(e,exp);
    size=6;
  }
  
  public void getProcess(){
    player.exp+=this.exp;
    Entities.forEach(e->{if(e.getClass().getName().equals(Exp.class.getName()))((Exp)e).magnet=true;});
  }
  
  @Override
  public void display(PGraphics g){
    g.fill(toColor(c));
    g.noStroke();
    g.colorMode(HSB,360,100,100);
    g.beginShape();
    g.fill(45,100,100);
    g.vertex(pos.x-size*0.5,pos.y-size*0.5);
    g.fill(135,100,100);
    g.vertex(pos.x+size*0.5,pos.y-size*0.5);
    g.fill(225,100,100);
    g.vertex(pos.x+size*0.5,pos.y+size*0.5);
    g.fill(315,100,100);
    g.vertex(pos.x-size*0.5,pos.y+size*0.5);
    g.endShape(CLOSE);
    g.colorMode(RGB,255,255,255);
  }
  
  @Override
  public void Collision(Entity e){
    if(isDead)return;
    if(!magnet&&e instanceof Myself){
      Myself m=(Myself)e;
      if(qDist(m.pos,pos,m.magnetDist+1.5)&&m.canMagnet){
        magnet=true;
      }
    }
  }
}

class Fragment extends Exp{
  
  Fragment(){
    super();
  }
  
  Fragment(Entity e){
    super(e);
  }
  
  Fragment(Entity e,float exp){
    super(e,exp);
  }
  
  public void setExp(float e){
    exp=e;
    if(exp<=1){
      c=new Color(200,190,20);
    }else if(exp<=10){
      c=new Color(255,55,55);
    }else if(exp<=100){
      c=new Color(205,0,255);
    }else{
      c=new Color(0,255,255);
    }
  }
  
  @Override
  public void display(PGraphics g){
    g.fill(toColor(c));
    g.noStroke();
    g.beginShape();
    for(int i=0;i<3;i++)g.vertex(pos.x+size*cos(TWO_PI*(i/3f)),pos.y+size*sin(TWO_PI*(i/3f)));
    g.endShape(CLOSE);
  }
  
  public void getProcess(){
    player.fragment+=(int)this.exp;
  }
}
