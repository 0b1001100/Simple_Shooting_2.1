package SSGUI.input.controller;

import java.util.ArrayList;

import net.java.games.input.Component;

public class Controller_Button extends Controller_Input {
  protected ArrayList<Controller_Listener>listeners;

  protected boolean press=false;
  protected boolean pressed=false;
  protected boolean oldPressed=false;
  protected boolean release=false;
  
  public Controller_Button(Component component){
    super(component);
  }

  @Override
  public float getRawValue(){
    return component.getPollData()*8f;
  }

  @Override
  public void update(){
    press=release=false;
    pressed=getRawValue()>0;
    listeners.forEach(l->{
      if(pressed&&!oldPressed){
        press=true;
        l.buttonPressed(new Controller_Event(component, Controller_Event_Type.Pressed));
      }else if(pressed&&oldPressed){
        l.buttonPressing(new Controller_Event(component, Controller_Event_Type.Pressing));
      }else if(!pressed&&oldPressed){
        release=true;
        l.buttonReleased(new Controller_Event(component, Controller_Event_Type.Released));
      }
    });
    oldPressed=pressed;
  }

  public boolean press(){
    return press;
  }

  public boolean pressed(){
    return pressed;
  }

  public boolean release(){
    return release;
  }
}
