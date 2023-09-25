package SSGUI.input.controller.configuration;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

import SSGUI.input.Controller;
import SSGUI.input.controller.Controller_Button;
import SSGUI.input.controller.Controller_Slider;

public class Xbox_Configuration extends Controller_Configuration{
  
  public Xbox_Configuration(Controller controller){
    super(controller);
  }

  @Override
  protected void setSliders(ArrayList<Controller_Slider>sliders){
    if(!isAvailable())return;
    synchronized(this){
      moveSliders[0]=sliders.get(1);
      moveSliders[1]=sliders.get(0);
      attackSliders[0]=sliders.get(3);
      attackSliders[1]=sliders.get(2);
    }
  }

  @Override
  protected void setButtons(ArrayList<Controller_Button>buttons){
    if(!isAvailable())return;
    synchronized(this){
      buttonBind.put("Enter",new HashSet<>(Arrays.asList(buttons.get(1))));
      buttonBind.put("Back",new HashSet<>(Arrays.asList(buttons.get(0))));
      buttonBind.put("Menu",new HashSet<>(Arrays.asList(buttons.get(3))));
      buttonBind.put("Change",new HashSet<>(Arrays.asList(buttons.get(2))));
    }
  }
}
