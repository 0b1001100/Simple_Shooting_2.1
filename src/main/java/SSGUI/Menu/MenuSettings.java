package SSGUI.Menu;

import SSGUI.Component.ComponentEventType;
import SSGUI.Component.GameComponent;
import SSGUI.Component.Animator.VectorAnimator;
import SSGUI.Theme.MenuTheme;
import SSGUI.Theme.Theme;
import processing.core.PVector;

public enum MenuSettings {
  INSTANCE;

  private Theme theme;

  private Object eventObject;

  private MenuSettings(){
    theme=new MenuTheme();
  }

  public VectorAnimator getFocusAnimator(){
    VectorAnimator focusAnimator=new VectorAnimator(100f, false);
    focusAnimator.addKeyFrame(0f, new PVector(0f, 25f));
    focusAnimator.addKeyFrame(50f, new PVector(100f, 25f));
    focusAnimator.addKeyFrame(75f, new PVector(140f, 25f));
    focusAnimator.addKeyFrame(100f, new PVector(150f, 25f));
    return focusAnimator;
  }

  public void setEventObject(Object o){
    eventObject=o;
  }

  public Theme getTheme(){
    return theme;
  }

  public void setFocusAnimator(GameComponent c){
    c.setAnimator("foreground_animator", getFocusAnimator(), ComponentEventType.GetFocus, ComponentEventType.LostFocus);
  }

  public Object getEventObject(){
    return eventObject;
  }
}
