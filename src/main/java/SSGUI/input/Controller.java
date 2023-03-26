package SSGUI.input;

import java.util.ArrayList;
import java.util.Arrays;

import SSGUI.input.controller.Controller_Button;
import SSGUI.input.controller.Controller_Hat;
import SSGUI.input.controller.Controller_RelativeSlider;
import SSGUI.input.controller.Controller_Slider;
import SSGUI.input.controller.configuration.Controller_Configuration;
import SSGUI.input.controller.configuration.Dualshock_Configuration;
import net.java.games.input.Component;
import net.java.games.input.DirectAndRawInputEnvironmentPlugin;
import processing.core.PApplet;
import processing.opengl.PSurfaceJOGL;

public class Controller extends Device {
  private Controller_Configuration config;

  private net.java.games.input.Controller gamePad;

  private ArrayList<Controller_Slider>sliders;
  private ArrayList<Controller_Button>buttons;
  private Controller_Hat hat;

  private boolean avariable=false;
  
  public Controller(PApplet applet,PSurfaceJOGL surface){
    super(applet,surface);
  }

  protected void init(){
    sliders=new ArrayList<>();
    buttons=new ArrayList<>();
    config=new Dualshock_Configuration(this);
    Thread.ofVirtual().start(()->{
      while(true){System.out.println("detecting");
        ArrayList<net.java.games.input.Controller>controllers=new ArrayList<>(Arrays.asList(new DirectAndRawInputEnvironmentPlugin().getControllers()));
        synchronized(gamePad){
          gamePad=null;
          controllers.forEach(c->{
            if(c.getType().toString().equals("Gamepad")||c.getType().toString().equals("Stick"))gamePad=c;
          });
          avariable=gamePad!=null;
        }
        if(avariable){
          sliders.clear();
          buttons.clear();
          for(Component c:gamePad.getComponents()){
            if(c.isAnalog()){
              if(c.isRelative()){
                sliders.add(new Controller_RelativeSlider(c));
              }else{
                sliders.add(new Controller_Slider(c));
              }
            }else{
              if(c.getIdentifier()==Component.Identifier.Axis.POV){
                hat=new Controller_Hat(c);
              }else{
                buttons.add(new Controller_Button(c));
              }
            }
          }
        }
        config.init();
        try {
          Thread.sleep(500);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
    });
  }

  public void update(){
    hat.update();
    buttons.forEach(b->b.update());
    sliders.forEach(s->s.update());
  }

  public boolean isAvariable(){
    return avariable;
  }

  public ArrayList<Controller_Button> getButtons(){
    if(!avariable)return null;
    return buttons;
  }

  public Controller_Button getButton(int index){
    if(!avariable)return null;
    return buttons.get(index);
  }

  public Controller_Hat getHat(){
    if(!avariable)return null;
    return hat;
  }

  public ArrayList<Controller_Slider> getSliders(){
    return sliders;
  }

  public float getMoveAngle(){
    if(!avariable)return Float.NaN;
    return config.getMoveAngle();
  }

  public float getAttackAngle(){
    if(!avariable)return Float.NaN;
    return config.getAttackAngle();
  }
}
