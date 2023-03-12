package SSGUI.Component.Animator;

import SSGUI.Theme.Color;
import processing.data.JSONObject;

public class ColorAnimator extends Animator<Color> {
  
  public ColorAnimator(float end,boolean loop){
    super(end,loop);
  }

  @Override
  protected void init(){
    value=new Color(0,0,0,0);
  }

  @Override
  protected void apply(Color value_0,Color value_1,float offset,float length){
    value=Color.lerp(value_0,value_1,offset/length);
  }

  @Override
  public ColorAnimator buildFromJSON(JSONObject o){
    //add key frame
    return this;
  }
}
