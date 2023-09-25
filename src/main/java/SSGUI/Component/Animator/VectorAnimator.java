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
    loop=o.getBoolean("loop",false);
    mag=o.getFloat("mag", 1f);
    end=o.getFloat("duration");
    float keyFrames[]=o.getJSONArray("keyFrames").toFloatArray();
    for(int i=0;i<keyFrames.length;i+=4){
      addKeyFrame(keyFrames[i], new PVector(keyFrames[i+1],keyFrames[i+2],keyFrames[i+3]));
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
 *     0  ,0  ,25,
 *     100,125,25,
 *     150,150,25
 *   ]
 * }
 */