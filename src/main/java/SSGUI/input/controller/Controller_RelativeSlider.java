package SSGUI.input.controller;

import net.java.games.input.Component;

public class Controller_RelativeSlider extends Controller_Slider {
  private float pollValue;
  
  public Controller_RelativeSlider(Component component){
    super(component);
  }

  public void update(){
		if(Math.abs(rawValue) >= component.getDeadZone()){
			pollValue += component.getPollData();
		}
  }

  @Override
  public float getTotalValue(){
    return pollValue;
  }
}
