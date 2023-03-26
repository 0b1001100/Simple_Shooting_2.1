package SSGUI.input;

import java.util.ArrayList;

import processing.core.PApplet;
import processing.opengl.PSurfaceJOGL;

public class Input {
  private PApplet applet;

  private ArrayList<Device>devices;

  private Mouse mouse;
  private KeyBoard keyBoard;
  private Controller controller;

  public Input(PApplet applet,PSurfaceJOGL surface){
    this.applet=applet;
    devices=new ArrayList<>();
    mouse=new Mouse(applet, surface);
    devices.add(mouse);
    keyBoard=new KeyBoard(applet, surface);
    devices.add(keyBoard);
    controller=new Controller(applet, surface);
    devices.add(controller);
  }

  public void update(){
    mouse.update();
    keyBoard.update();
    controller.update();
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

  public float getMoveAngle(){
    float angle=keyBoard.getAngle();
    if(controller.isAvariable()&&!Float.isNaN(controller.getMoveAngle())){
      if(Float.isNaN(angle)){
        angle=controller.getMoveAngle();
      }else{
        angle=(angle+controller.getMoveAngle())*0.5f;
      }
    }
    return angle;
  }

  public float getAttackAngle(){
    float angle=(float)Math.atan2(mouse.getY()-applet.height*0.5f,mouse.getX()-applet.width*0.5f);
    if(controller.isAvariable()&&!Float.isNaN(controller.getAttackAngle())){
      angle=(angle+controller.getAttackAngle())*0.5f;
    }
    return angle;
  }
}
