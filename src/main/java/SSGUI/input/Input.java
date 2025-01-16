package SSGUI.input;

import java.util.ArrayList;

import com.jogamp.newt.event.WindowEvent;
import com.jogamp.newt.event.WindowListener;
import com.jogamp.newt.event.WindowUpdateEvent;
import com.jogamp.newt.opengl.GLWindow;

import SSGUI.Component.Direction;
import processing.core.PApplet;
import processing.core.PVector;
import processing.opengl.PSurfaceJOGL;

public class Input {
  private PApplet applet;

  private ArrayList<Device>devices;

  private Mouse mouse;
  private KeyBoard keyBoard;
  private Controller controller;

  private boolean focus=true;

  public Input(PApplet applet,PSurfaceJOGL surface){
    this.applet=applet;
    devices=new ArrayList<>();
    mouse=new Mouse(applet, surface);
    devices.add(mouse);
    keyBoard=new KeyBoard(applet, surface);
    devices.add(keyBoard);
    controller=new Controller(applet, surface);
    devices.add(controller);
    ((GLWindow)surface.getNative()).addWindowListener(new WindowListener() {
      @Override
      public void windowDestroyed(WindowEvent e){}
      @Override
      public void windowMoved(WindowEvent e){}
      @Override
      public void windowResized(WindowEvent e){}
      @Override
      public void windowRepaint(WindowUpdateEvent e){}
      @Override
      public void windowDestroyNotify(WindowEvent e){}
      @Override
      public void windowLostFocus(WindowEvent e){
        focus=false;
      }
      @Override
      public void windowGainedFocus(WindowEvent e){
        focus=true;
      }
    });
  }

  public void update(){
    mouse.update();
    keyBoard.update();
    controller.update();
  }

  public boolean isWindowFocused(){
    return focus;
  }
  
  public Mouse getMouse(){
    return mouse;
  }

  public KeyBoard getKeyBoard(){
    return keyBoard;
  }

  public Controller getController(){
    return controller;
  }

  public boolean isInputDetected(){
    return controller.getControllerMove()||controller.getButtonPress()||keyBoard.keyPress();
  }

  public Direction getDirection(){
    Direction d=keyBoard.getDirection();
    if(!(controller.getDirection().equals(Direction.None))){
      d=controller.getDirection();
    }
    return d;
  }

  public boolean isEnterInput(){
    if(getMouse().getButtonPress(1)){
      return true;
    }
    if(getKeyBoard().keyPress()&&getKeyBoard().getBindedInput("Enter")){
      return true;
    }
    if(getController().getBindedInput("Enter")){
      return true;
    }
    return false;
  }

  public boolean isEnterButtonInput(){
    if(getKeyBoard().keyPress()&&getKeyBoard().getBindedInput("Enter")){
      return true;
    }
    if(getController().getBindedInput("Enter")){
      return true;
    }
    return false;
  }

  public boolean isBackInput(){
    if(getKeyBoard().keyPress()&&getKeyBoard().getBindedInput("Back")){
      return true;
    }
    if(getController().getBindedInput("Back")){
      return true;
    }
    return false;
  }

  public boolean isMenuInput(){
    if(getKeyBoard().keyPress()&&getKeyBoard().getBindedInput("Menu")){
      return true;
    }
    if(getController().getBindedInput("Menu")){
      return true;
    }
    return false;
  }

  public boolean isChangeInput(){
    if(getKeyBoard().keyPress()&&getKeyBoard().getBindedInput("Change")){
      return true;
    }
    if(getController().getBindedInput("Change")){
      return true;
    }
    return false;
  }

  public float getMoveAngle(){
    float angle=((float)Math.PI*2)-keyBoard.getAngle();
    if(controller.isAvailable()&&controller.getMoveMag()>0&&!Float.isNaN(controller.getMoveAngle())){
      angle=controller.getMoveAngle();
    }
    return angle;
  }

  public float getMoveMag(){
    float mag=keyBoard.getDirection()==Direction.None?0:1;
    if(controller.isAvailable()&&!Float.isNaN(controller.getMoveAngle())){
      mag=controller.getMoveMag();
    }
    return mag;
  }

  public PVector getMoveVector(){
    float mag=getMoveMag();
    float angle=keyBoard.getAngle();
    return new PVector((float)Math.cos(angle)*mag,(float)Math.sin(angle)*mag);
  }

  public float getAttackAngle(){
    float angle=(float)Math.atan2(mouse.getY()-applet.height*0.5f,mouse.getX()-applet.width*0.5f);
    if(controller.isAvailable()&&controller.getAttackMag()>0&&!Float.isNaN(controller.getAttackAngle())){
      angle=controller.getAttackAngle();
    }
    return angle;
  }

  public float getAttackMag(){
    float mag=mouse.mousePressed()?1:0;
    if(controller.isAvailable()&&!Float.isNaN(controller.getAttackAngle())){
      mag=controller.getAttackMag();
    }
    return mag;
  }
}
