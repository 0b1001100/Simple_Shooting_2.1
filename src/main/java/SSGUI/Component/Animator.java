package SSGUI.Component;

import java.util.HashMap;
import java.util.function.Supplier;

import processing.core.PVector;
import processing.data.JSONObject;

public class Animator implements Supplier<PVector>, ConstractibleFromJSON<Animator> {
  private HashMap<Float,PVector>keyFrame=new HashMap<>();

  protected PVector value=new PVector();

  private boolean isEnd=false;
  private boolean loop=false;
  private float millis=0f;
  private float end=0f;
  private int mag=1;

  Animator(float end,boolean loop){
    this.end=end;
    this.loop=loop;
  }

  public void update(){
    update(16f);
  }

  public void update(float millis){
    if(isEnd)return;
    this.millis+=millis*mag;
    if(this.millis>=end&&!loop){
      isEnd=true;
      int i=0;
      for(float f:keyFrame.keySet()){
        if(++i==keyFrame.size())value=keyFrame.get(f);
      }
    }else{
      boolean passage=true;
      float pre=0f;
      float targets[]=new float[]{0f,0f};
      for(float f:keyFrame.keySet()){
        if(f>this.millis&&passage){
          targets[0]=pre;
          targets[1]=f;
          passage=false;
        }else if(passage){
          pre=f;
        }
      }
      float offset=this.millis-targets[0];
      float length=targets[1]-targets[0];
      value=PVector.lerp(keyFrame.get(targets[0]),keyFrame.get(targets[1]),offset/length);
    }
  }

  @Override
  public PVector get() {
    return value;
  }

  public Animator buildFromJSON(JSONObject o){
    //add key frame
    return this;
  }
}
