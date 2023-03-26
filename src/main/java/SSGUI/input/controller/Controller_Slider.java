package SSGUI.input.controller;

import net.java.games.input.Component;

public class Controller_Slider extends Controller_Input {
  protected float totalValue;

  public Controller_Slider(Component component){
    super(component);
  }

  @Override
  public float getRawValue(){
    return component.getPollData();
  }

  public float getTotalValue(){
    return totalValue;
  }

  public void reset(){
    totalValue=0;
  }

  public boolean isRelative(){
    return component.isRelative();
  }

  @Override
  public void update(){
    if(Math.abs(rawValue)<component.getDeadZone()){
      rawValue=0f;
    }else{
      rawValue=component.getPollData();
    }
    totalValue+=rawValue;
  }
}
