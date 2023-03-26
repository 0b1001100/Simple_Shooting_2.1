package Simple_shooting_2_1;

import SSGUI.Menu.MenuButton;
import SSGUI.input.Input;
import processing.core.PApplet;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;
import processing.opengl.PSurfaceJOGL;

public class Simple_shooting_2_1 extends PApplet{
  PGraphicsOpenGL glpg;

  Input input;

  MenuButton button;

  public static void main(String args[]){
    PApplet.main("Simple_shooting_2_1.Simple_shooting_2_1");
  }

  @Override
  public void settings(){
    size(1280,720,P2D);
    button=new MenuButton();
    button.setBounds(()->new PVector(100f,100f), ()->new PVector(120f,25f));
    button.setLabel(javaVersionName);
  }

  @Override
  public void setup(){
    input=new Input(this, (PSurfaceJOGL)surface);
    glpg=(PGraphicsOpenGL)g;
  }

  @Override
  public void draw(){println(input.getAttackAngle(),input.getController().isAvariable());
    background(128);
    button.handleDisplay(glpg, false);
    button.handleUpdate(16f);
  }
}