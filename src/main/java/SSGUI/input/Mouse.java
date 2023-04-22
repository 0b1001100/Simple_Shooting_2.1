package SSGUI.input;

import java.util.HashMap;
import java.util.function.Consumer;

import com.jogamp.newt.event.MouseAdapter;
import com.jogamp.newt.event.MouseEvent;
import com.jogamp.newt.opengl.GLWindow;

import processing.core.PApplet;
import processing.opengl.PSurfaceJOGL;

public class Mouse extends Device {
  private HashMap<String,HashMap<String,Consumer<MouseEvent>>>eventMap;
  
  private boolean mousePress=false;
  private boolean mouseRelease=false;
  private boolean mouseClick=false;
  private boolean mouseMove=false;

  private int latestButton;

  public static final String eventNames[]=new String[]{"pressed","released","clicked","dragged","moved","wheelMoved","entered","exited"};
  
  public Mouse(PApplet applet,PSurfaceJOGL surface){
    super(applet,surface);
  }

  protected void init(){
    eventMap=new HashMap<>();
    for(String s:eventNames){
      eventMap.put(s,new HashMap<>());
    }
    ((GLWindow)surface.getNative()).addMouseListener(new MouseAdapter(){
      @Override
      public void mousePressed(com.jogamp.newt.event.MouseEvent e) {
        mousePress=true;
        eventMap.get(eventNames[0]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseReleased(com.jogamp.newt.event.MouseEvent e) {
        mouseRelease=true;
        eventMap.get(eventNames[1]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseClicked(com.jogamp.newt.event.MouseEvent e) {
        mouseClick=true;
        eventMap.get(eventNames[2]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseDragged(com.jogamp.newt.event.MouseEvent e) {
        mouseMove=true;
        eventMap.get(eventNames[3]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseMoved(com.jogamp.newt.event.MouseEvent e) {
        mouseMove=true;
        eventMap.get(eventNames[4]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseWheelMoved(com.jogamp.newt.event.MouseEvent e) {
        eventMap.get(eventNames[5]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseEntered(com.jogamp.newt.event.MouseEvent e) {
        eventMap.get(eventNames[6]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
      @Override
      public void mouseExited(com.jogamp.newt.event.MouseEvent e) {
        eventMap.get(eventNames[7]).forEach((k,v)->v.accept(e));
        latestButton=e.getButton();
      }
    });
  }

  /**
   * This method updates inner variable state.
   * This method should call after processing the input.
   */
  public void update(){
    mousePress=mouseRelease=false;
    mouseClick=mouseMove=false;
  }

  public void addProcess(String eventName,String name,Consumer<MouseEvent> process){
    eventMap.get(eventName).put(name,process);
  }

  public Consumer<MouseEvent> getProcess(String eventName,String name){
    return eventMap.get(eventName).get(name);
  }

  public void removeProcess(String eventName,String name){
    eventMap.get(eventName).remove(name);
  }

  /**
   * This method returns true if the mouse had pressed.
   * @return whether the mouse had pressed.
   */
  public boolean mousePress(){
    return mousePress;
  }

  /**
   * This method returns true if the left button had pressed.
   * @return whether the left button had pressed.
   */
  public boolean getButtonPress(int button){
    return mousePress&&latestButton==button;
  }

  /**
   * This method returns true while the mouse is pressed.
   * @return whether the mouse is pressed.
   */
  public boolean mousePressed(){
    return applet.mousePressed;
  }

  public boolean mouseRelease(){
    return mouseRelease;
  }

  public boolean mouseClicked(){
    return mouseClick;
  }

  public boolean mouseMoved(){
    return mouseMove;
  }

  public int mouseButton(){
    return applet.mouseButton;
  }

  public int getX(){
    return applet.mouseX;
  }

  public int getY(){
    return applet.mouseY;
  }
}
