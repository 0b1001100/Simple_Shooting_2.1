package SSGUI.input.controller;

import net.java.games.input.Component;

public class Controller_Event {
  private Controller_Event_Type type;
  private Component component;

  public Controller_Event(Component component,Controller_Event_Type type){
    this.component=component;
    this.type=type;
  }

  public Controller_Event_Type getType(){
    return type;
  }

  public Component getComponent(){
    return component;
  }
}
