package SSGUI.input.controller;

public interface Controller_Listener {
  public void buttonPressed(Controller_Event e);
  
  public void buttonPressing(Controller_Event e);
  
  public void buttonReleased(Controller_Event e);
}
