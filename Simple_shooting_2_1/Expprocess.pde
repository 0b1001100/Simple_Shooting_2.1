class Exp extends Entity{
  float exp;
  
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
    if(Debug)displayAABB(g);
    g.fill(toColor(c));
    g.noStroke();
    g.rect(pos.x,pos.y,size,size);
  }
  
  public void update(){
    Center=pos;
    AxisSize=new PVector(size+player.magnetDist,size+player.magnetDist);
    putAABB();
  }
  
  public void getProcess(){
    
  }
  
  public void setPos(PVector p){
    pos=p;
  }
  
  @Override
  public void Collision(Entity e){
    if(isDead)return;
    if(e instanceof Myself){
      Myself m=(Myself)e;
      if(qDist(m.pos,pos,m.magnetDist+1.5)&&m.canMagnet){
        getProcess();
        player.exp+=this.exp;
        isDead=true;
      }
    }else if(e instanceof Exp){
      if(e.isDead)return;
      Exp ex=(Exp)e;
      ex.setExp(ex.exp+exp);
      ex.pos=pos.add(ex.pos).mult(0.5);
      isDead=true;
    }
  }
}
