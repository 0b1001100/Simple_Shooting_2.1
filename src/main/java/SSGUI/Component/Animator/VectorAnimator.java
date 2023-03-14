package SSGUI.Component.Animator;

import processing.core.PVector;
import processing.data.JSONObject;

public class VectorAnimator extends Animator<PVector> {

  public VectorAnimator(float end,boolean loop){
    super(end,loop);
  }

  @Override
  protected void init(){
    value=new PVector();
  }

  @Override
  protected void apply(PVector value_0,PVector value_1,float offset,float length){
    value=PVector.lerp(value_0,value_1,offset/length);
  }

  @Override
  public VectorAnimator buildFromJSON(JSONObject o){
    //add key frame
    return this;
  }
}
