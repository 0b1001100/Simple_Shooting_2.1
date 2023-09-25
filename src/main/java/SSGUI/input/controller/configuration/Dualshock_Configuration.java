package SSGUI.input.controller.configuration;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

import SSGUI.input.Controller;
import SSGUI.input.controller.Controller_Button;
import SSGUI.input.controller.Controller_Slider;

public class Dualshock_Configuration extends Controller_Configuration {
  
  public Dualshock_Configuration(Controller controller){
    super(controller);
  }

  @Override
  protected void setSliders(ArrayList<Controller_Slider>sliders){
    if(!isAvailable())return;
    synchronized(this){
      moveSliders[0]=sliders.get(3);
      moveSliders[1]=sliders.get(2);
      attackSliders[0]=sliders.get(1);
      attackSliders[1]=sliders.get(0);
    }
  }

  @Override
  protected void setButtons(ArrayList<Controller_Button>buttons){
    if(!isAvailable())return;
    synchronized(this){
      buttonBind.put("Enter",new HashSet<>(Arrays.asList(buttons.get(2))));
      buttonBind.put("Back",new HashSet<>(Arrays.asList(buttons.get(1))));
      buttonBind.put("Menu",new HashSet<>(Arrays.asList(buttons.get(3))));
      buttonBind.put("Change",new HashSet<>(Arrays.asList(buttons.get(0))));
    }
  }
}
