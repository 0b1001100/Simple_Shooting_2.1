package SSGUI;

import java.util.ArrayList;
import java.util.HashSet;

import com.jogamp.newt.opengl.GLWindow;

import processing.core.PApplet;
import processing.event.Event;
import processing.event.KeyEvent;
import processing.event.MouseEvent;
import processing.opengl.PSurfaceJOGL;

public class Input {
  private ArrayList<Event>events;

  private PApplet applet;
  private PSurfaceJOGL surface;
  private GLWindow window;

  private HashSet<Integer>pressedKeys;

  private boolean keyPress=false;
  private boolean keyRelease=false;

  private boolean mousePress=false;
  private boolean mouseRelease=false;
  private boolean mouseMove=false;

  public Input(PApplet applet,PSurfaceJOGL surface){
    events=new ArrayList<>();
    pressedKeys=new HashSet<>();
    this.applet=applet;
    this.surface=surface;
    this.window=(GLWindow)surface.getNative();
  }

  public void update(){
    keyPress=keyRelease=false;
    mousePress=mouseRelease=mouseMove=false;
    events.forEach(e->{
      switch(e){
        case KeyEvent ke:
          switch(ke.getAction()){
            case KeyEvent.PRESS:keyPress=true;pressedKeys.add(ke.getKeyCode());break;
            case KeyEvent.RELEASE:keyRelease=true;pressedKeys.remove(ke.getKeyCode());break;
          }break;
        case MouseEvent me:
          switch(me.getAction()){
            case MouseEvent.PRESS:mousePress=true;
            case MouseEvent.RELEASE:mouseRelease=true;
            case MouseEvent.MOVE:mouseMove=true;
          }break;
        default:break;
      }
    });
  }

  public void addEvent(Event e){
    events.add(e);
  }

  public boolean keyPressed(){
    return applet.keyPressed;
  }

  public boolean keyPress(){
    return keyPress;
  }

  public boolean keyRelease(){
    return keyRelease;
  }

  public HashSet<Integer> getKeys(){
    return pressedKeys;
  }

  public boolean mousePressed(){
    return applet.mousePressed;
  }

  public boolean mousePress(){
    return mousePress;
  }

  public boolean mouseRelease(){
    return mouseRelease;
  }

  public boolean mouseMove(){
    return mouseMove;
  }
}
