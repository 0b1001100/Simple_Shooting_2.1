package SSGUI.input.controller.configuration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

import SSGUI.input.Controller;
import SSGUI.input.controller.Controller_Button;
import SSGUI.input.controller.Controller_Slider;

public abstract class Controller_Configuration {
  private Controller parent;

  protected HashMap<String,HashSet<Controller_Button>>buttonBind;

  /**
   * This variable keeps both X axis slider and Y axis slider which used to move.<br>
   * [0] : X<br>
   * [1] : Y
   */
  protected Controller_Slider moveSliders[]=new Controller_Slider[2];
  /**
   * This variable keeps both X axis slider and Y axis slider which used to attack.<br>
   * [0] : X<br>
   * [1] : Y
   */
  protected Controller_Slider attackSliders[]=new Controller_Slider[2];

  /**
   * This variable defines edge values which is used to detect slider input.
   */
  protected float edge=0.1f;
  
  protected boolean pAttack=false;
  protected boolean Attack=false;
  protected boolean beginAttack=false;
  protected boolean endAttack=false;
  protected boolean pMove=false;
  protected boolean Move=false;
  protected boolean beginMove=false;
  protected boolean endMove=false;

  public Controller_Configuration(Controller controller){
    parent=controller;
    init();
  }

  public final void init(){
    buttonBind=new HashMap<>();
    setSliders(parent.getSliders());
    setButtons(parent.getButtons());
  }

  protected abstract void setSliders(ArrayList<Controller_Slider>sliders);

  protected abstract void setButtons(ArrayList<Controller_Button>buttons);

  public void update(){
    synchronized(this){
      Attack=!(Math.abs(attackSliders[0].getRawValue())<edge&&Math.abs(attackSliders[1].getRawValue())<edge);
      Move=!(Math.abs(moveSliders[0].getRawValue())<edge&&Math.abs(moveSliders[1].getRawValue())<edge);
      beginAttack=!pAttack&&Attack;
      beginMove=!pMove&&Move;
      beginAttack=pAttack&&!Attack;
      beginMove=pMove&&!Move;
      pAttack=Attack;
      pMove=Move;
    }
  }

  public float getAttackAngle() {
    if(!isAvailable()||(attackSliders[0]==null||attackSliders[1]==null))return Float.NaN;
    float x=Math.abs(attackSliders[0].getRawValue())>edge?attackSliders[0].getRawValue():0;
    float y=Math.abs(attackSliders[1].getRawValue())>edge?attackSliders[1].getRawValue():0;
    double radians=Math.atan2(y, x);
    return (float)(radians<0?radians+Math.PI*2:radians);
  }

  public float getAttackMag(){
    if(!isAvailable()||(attackSliders[0]==null||attackSliders[1]==null))return 0;
    float x=Math.abs(attackSliders[0].getRawValue())>edge?attackSliders[0].getRawValue():0;
    float y=Math.abs(attackSliders[1].getRawValue())>edge?attackSliders[1].getRawValue():0;
    return (float) Math.sqrt(x*x+y*y);
  }

  public float getMoveAngle() {
    if(!isAvailable()||(moveSliders[0]==null||moveSliders[1]==null))return Float.NaN;
    float x=Math.abs(moveSliders[0].getRawValue())>edge?moveSliders[0].getRawValue():0;
    float y=Math.abs(moveSliders[1].getRawValue())>edge?moveSliders[1].getRawValue():0;
    if(x==0&&y==0)return Float.NaN;
    double radians=Math.atan2(y, x);
    return (float)(radians<0?radians+Math.PI*2:radians);
  }

  public float getMoveMag(){
    if(!isAvailable()||(moveSliders[0]==null||moveSliders[1]==null))return 0;
    float x=Math.abs(moveSliders[0].getRawValue())>edge?moveSliders[0].getRawValue():0;
    float y=Math.abs(moveSliders[1].getRawValue())>edge?moveSliders[1].getRawValue():0;
    return (float) Math.sqrt(x*x+y*y);
  }

  public boolean getBeginAttack(){
    return beginAttack;
  }

  public boolean getBeginMove(){
    return beginMove;
  }

  public boolean getEndAttack(){
    return endAttack;
  }

  public boolean getEndMove(){
    return endMove;
  }

  public boolean getBindedInput(String bind){
    if(!isAvailable())return false;
    synchronized(this){
      if(!buttonBind.containsKey(bind))return false;
      boolean b=false;
      for(Controller_Button button:buttonBind.get(bind)){
        if(button.press()){
          b=true;
          break;
        }
      }
      return b;
    }
  }

  public HashSet<Controller_Button> getButton(String name){
    return buttonBind.get(name);
  }

  protected boolean isAvailable(){
    return parent.isAvailable();
  }

  public void setEdge(float e){
    edge=e;
  }
}
