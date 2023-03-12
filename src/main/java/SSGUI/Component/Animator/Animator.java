package SSGUI.Component.Animator;

import java.util.HashMap;
import java.util.function.Supplier;

import SSGUI.Component.ConstractibleFromJSON;

public abstract class Animator<T> implements Supplier<T>, ConstractibleFromJSON<Animator<T>> {
  protected HashMap<Float,T>keyFrame=new HashMap<>();

  protected T value;

  protected boolean animate=false;
  protected boolean isEnd=false;
  protected boolean loop=false;
  protected float millis=0f;
  protected float end=0f;
  protected float mag=1f;
  
  public Animator(float end,boolean loop){
    this.end=end;
    this.loop=loop;
    init();
  }

  protected abstract void init();

  public void update(){
    update(16f);
  }

  public void update(float deltaTime){
    if(isEnd||!animate)return;
    this.millis+=deltaTime*mag;
    if((mag<0?this.millis<=0f:this.millis>=end)&&!loop){
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
      apply(keyFrame.get(targets[0]),keyFrame.get(targets[1]),offset,length);
    }
  }

  protected abstract void apply(T value_0,T value_1,float offset,float length);

  public void setMagnification(float mag){
    this.mag=mag;
  }

  public void animate(){
    animate=true;
  }

  public void stop(){
    animate=false;
  }

  public void rewind(){
    isEnd=false;
    millis=0;
  }

  @Override
  public T get() {
    return value;
  }

  public void setPlayTime(float millis){
    end=millis;
  }

  public float getPlayTime(){
    return end;
  }

  public float getCurrentTime(){
    return millis;
  }
}
