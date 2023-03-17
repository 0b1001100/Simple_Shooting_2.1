package Simple_shooting_2_1;

import SSGUI.Menu.MenuButton;
import processing.core.PApplet;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;

public class Simple_shooting_2_1 extends PApplet{
  PGraphicsOpenGL glpg;

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
    glpg=(PGraphicsOpenGL)g;
  }

  @Override
  public void draw(){
    background(128);
    button.handleDisplay(glpg, false);
    button.handleUpdate(16f);
  }
}