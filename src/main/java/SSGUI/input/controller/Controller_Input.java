package SSGUI.input.controller;

import net.java.games.input.Component;

public abstract class Controller_Input {
  protected Component component;

  protected float rawValue;

  protected Controller_Input(Component component){
    this.component=component;
  }

  public abstract float getRawValue();

  public abstract void update();
}
