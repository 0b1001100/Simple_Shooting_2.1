package SSGUI.input.controller;

import java.util.ArrayList;

import net.java.games.input.Component;

public class Controller_Button extends Controller_Input {
  protected ArrayList<Controller_Listener>listeners=new ArrayList<>();

  protected boolean initialized=true;

  protected boolean press=false;
  protected boolean pressed=false;
  protected boolean oldPressed=true;
  protected boolean release=false;

  protected float rawValue=0;
  
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
    rawValue=getRawValue();
    pressed=rawValue>0;
    if(pressed&&!oldPressed){
      press=true;
    }else if(!initialized&&!pressed&&oldPressed){
      release=true;
    }
    listeners.forEach(l->{
      if(pressed&&!oldPressed){
        l.buttonPressed(new Controller_Event(component, Controller_Event_Type.Pressed));
      }else if(pressed&&oldPressed){
        l.buttonPressing(new Controller_Event(component, Controller_Event_Type.Pressing));
      }else if(!pressed&&oldPressed){
        l.buttonReleased(new Controller_Event(component, Controller_Event_Type.Released));
      }
    });
    oldPressed=pressed;
    initialized=false;
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
