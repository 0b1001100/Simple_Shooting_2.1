package Simple_shooting_2_1;

import SSGUI.Component.ComponentNode;
import SSGUI.Component.ComponentSet;
import SSGUI.Menu.MenuButton;
import SSGUI.input.Input;
import processing.core.PApplet;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;
import processing.opengl.PSurfaceJOGL;

public class Simple_shooting_2_1 extends PApplet{
  PGraphicsOpenGL glpg;

  Input input;

  ComponentSet main;

  public static void main(String args[]){
    PApplet.main("Simple_shooting_2_1.Simple_shooting_2_1");
  }

  @Override
  public void settings(){
    size(1280,720,P2D);
    initUI();
  }

  @Override
  public void setup(){
    hint(DISABLE_KEY_REPEAT);
    input=new Input(this, (PSurfaceJOGL)surface);
    glpg=(PGraphicsOpenGL)g;
  }

  @Override
  public void draw(){
    background(128);
    main.handleDisplay(glpg, false);
    main.handleUpdate(16f);
    main.handleInput(input);
    input.update();
  }

  private void initUI(){
    main=new ComponentSet();
    MenuButton button=new MenuButton();
    button.setBounds(()->new PVector(100f,100f), ()->new PVector(120f,25f));
    button.setLabel(javaVersionName);
    MenuButton button2=new MenuButton();
    button2.setBounds(()->new PVector(100f,150f), ()->new PVector(120f,25f));
    button2.setLabel("I'm");
    MenuButton button3=new MenuButton();
    button3.setBounds(()->new PVector(100f,200f), ()->new PVector(120f,25f));
    button3.setLabel("a");
    MenuButton button4=new MenuButton();
    button4.setBounds(()->new PVector(100f,250f), ()->new PVector(120f,25f));
    button4.setLabel("new");
    MenuButton button5=new MenuButton();
    button5.setBounds(()->new PVector(100f,300f), ()->new PVector(120f,25f));
    button5.setLabel("GUI");
    main.add(new ComponentNode(button, 0, 12, 3, -1, 1));
    main.add(new ComponentNode(button2, 3, 0, 6, -1, 1));
    main.add(new ComponentNode(button3, 6, 3, 9, -1, 1));
    main.add(new ComponentNode(button4, 9, 6, 12, -1, 1));
    main.add(new ComponentNode(button5, 12, 9, 0, -1, 1));
  }
}