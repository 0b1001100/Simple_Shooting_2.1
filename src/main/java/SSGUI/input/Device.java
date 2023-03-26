package SSGUI.input;

import processing.core.PApplet;
import processing.opengl.PSurfaceJOGL;

public abstract class Device {
  protected PApplet applet;
  protected PSurfaceJOGL surface;

  public Device(PApplet applet,PSurfaceJOGL surface){
    this.applet=applet;
    this.surface=surface;
    init();
  }

  protected abstract void init();
}
