package SSGUI.input.controller.configuration;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

import SSGUI.input.Controller;
import SSGUI.input.controller.Controller_Button;
import SSGUI.input.controller.Controller_Slider;

public class Dualshock_Configuration extends Controller_Configuration {
  private boolean pAttack=false;
  private boolean Attack=false;
  private boolean beginAttack=false;
  private boolean endAttack=false;
  private boolean pMove=false;
  private boolean Move=false;
  private boolean beginMove=false;
  private boolean endMove=false;
  
  public Dualshock_Configuration(Controller controller){
    super(controller);
  }

  @Override
  protected void setSliders(ArrayList<Controller_Slider>sliders){
    if(!isAvariable())return;
    synchronized(this){
      moveSliders[0]=sliders.get(3);
      moveSliders[1]=sliders.get(2);
      attackSliders[0]=sliders.get(1);
      attackSliders[1]=sliders.get(0);
    }
  }

  @Override
  protected void setButtons(ArrayList<Controller_Button>buttons){
    if(!isAvariable())return;
    synchronized(this){
      buttonBind.put("Enter",new HashSet<>(Arrays.asList(buttons.get(2))));
      buttonBind.put("Back",new HashSet<>(Arrays.asList(buttons.get(1))));
      buttonBind.put("Menu",new HashSet<>(Arrays.asList(buttons.get(3))));
      buttonBind.put("Change",new HashSet<>(Arrays.asList(buttons.get(0))));
    }
  }

  @Override
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

  @Override
  public boolean getBindedInput(String bind){
    if(!isAvariable())return false;
    synchronized(this){
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

  @Override
  public float getAttackAngle() {
    if(!isAvariable()||(attackSliders[0]==null||attackSliders[1]==null))return Float.NaN;
    float x=Math.abs(attackSliders[0].getRawValue())>edge?attackSliders[0].getRawValue():0;
    float y=Math.abs(attackSliders[1].getRawValue())>edge?attackSliders[1].getRawValue():0;
    double radians=-Math.atan2(y, x);
    return (float)(radians<0?radians+Math.PI*2:radians);
  }

  @Override
  public float getMoveAngle() {
    if(!isAvariable()||(moveSliders[0]==null||moveSliders[1]==null))return Float.NaN;
    float x=Math.abs(moveSliders[0].getRawValue())>edge?moveSliders[0].getRawValue():0;
    float y=Math.abs(moveSliders[1].getRawValue())>edge?moveSliders[1].getRawValue():0;
    if(x==0&&y==0)return Float.NaN;
    double radians=-Math.atan2(y, x);
    return (float)(radians<0?radians+Math.PI*2:radians);
  }

  @Override
  public boolean getBeginAttack(){
    return beginAttack;
  }

  @Override
  public boolean getBeginMove(){
    return beginMove;
  }

  @Override
  public boolean getEndAttack(){
    return endAttack;
  }

  @Override
  public boolean getEndMove(){
    return endMove;
  }
}
