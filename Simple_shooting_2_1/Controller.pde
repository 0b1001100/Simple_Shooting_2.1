abstract class Controller{
  
  public Controller(){
  }
  
  abstract void update(Entity e);
}

class VoidController extends Controller{
  public void update(Entity e){}
}

class SurvivorEnemyController extends Controller{
  
  public void update(Entity entity){
    Enemy e=(Enemy)entity;
    Rotate(e);
    move(e);
    e.Center=e.pos;
    e.AxisSize=new PVector(e.size,e.size);
    e.putAABB();
    if(e.inScreen){
      if(!nearEnemy.contains(e)){
        nearEnemy.add(e);
      }else{
        e.playerDistsq=sqDist(player.pos,e.pos);
      }
    }
  }
  
  void Rotate(Enemy e){
    float rad=atan2(e.pos.x-player.pos.x,e.pos.y-player.pos.y);
    float nRad=0<e.rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(e.rotate-rad)<abs(e.rotate-nRad)?rad:nRad;
    rad=sign(rad-e.rotate)*constrain(abs(rad-e.rotate),0,radians(e.rotateSpeed)*vectorMagnification);
    e.protate=e.rotate;
    e.rotate+=rad;
    e.rotate=e.rotate%TWO_PI;
  }
  
  void move(Enemy e){
    rotate(e.rotate);
    if(Float.isNaN(e.Speed)){
      e.Speed=0;
    }
    e.addVel(e.accelSpeed,false);
    e.pos.add(e.vel.copy().mult(vectorMagnification));
  }
}
