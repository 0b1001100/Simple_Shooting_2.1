package Simple_shooting_2_1.Strategy;

import processing.opengl.PGraphicsOpenGL;

public abstract class Strategy {
  //protected ComponentSetLayer layer;
  
  public abstract void display(PGraphicsOpenGL g);

  public abstract void update();
}
