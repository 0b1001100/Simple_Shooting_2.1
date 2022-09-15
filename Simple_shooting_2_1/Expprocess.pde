class Exp extends Entity{
  boolean inScreen=true;
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
  
  void setExp(float e){
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
  void display(PGraphics g){
    g.fill(toColor(c));
    g.noStroke();
    g.rect(pos.x,pos.y,size,size);
  }
  
  void update(){
    if(inScreen&&qDist(player.pos,pos,player.magnetDist)&&player.canMagnet){
      getProcess();
      player.exp+=this.exp;
      isDead=true;
    }
  }
  
  void getProcess(){
    
  }
  
  void setPos(PVector p){
    pos=p;
  }
  
  @Override
  void putAABB(){
  }
  
  @Override
  void Collision(Entity e){
  }
}
