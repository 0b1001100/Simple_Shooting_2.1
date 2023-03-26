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

  public abstract float getMoveAngle();

  public abstract float getAttackAngle();

  public HashSet<Controller_Button> getButton(String name){
    return buttonBind.get(name);
  }

  protected boolean isAvariable(){
    return parent.isAvariable();
  }
}
