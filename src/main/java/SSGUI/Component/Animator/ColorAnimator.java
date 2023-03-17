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
    loop=o.getBoolean("loop",false);
    mag=o.getFloat("mag", 1f);
    end=o.getFloat("duration");
    float keyFrames[]=o.getJSONArray("keyFrames").toFloatArray();
    for(int i=0;i<keyFrames.length;i+=5){
      addKeyFrame(keyFrames[i], new Color((int)keyFrames[i+1],(int)keyFrames[i+2],(int)keyFrames[i+3],(int)keyFrames[i+4]));
    }
    return this;
  }
}

/*
 * JSON example
 * {
 *   "loop":false,
 *   "mag":1,
 *   "duration":150,
 *   "keyFrames":[
 *     0  ,0  ,25,255,
 *     100,125,25,255,
 *     150,150,25,255
 *   ]
 * }
 */