package SSGUI.Theme;

import processing.core.PApplet;

public class Color implements Cloneable {
  private int r;
  private int g;
  private int b;
  private int a;

  private int intValue;
  
  public Color(int grayscale){
    init(grayscale,grayscale,grayscale,255);
  }
  
  public Color(int grayscale,int a){
    init(grayscale,grayscale,grayscale,a);
  }
  
  public Color(int r,int g,int b){
    init(r,g,b,255);
  }
  
  public Color(int r,int g,int b,int a){
    init(r,g,b,a);
  }

  /**
   * This method initalizes color data(Red, Green, Blue, Alpha) by
   * Clamping color source and configure {@code intValue}.<br>
   * If you want to change color, you must call this method.<br>
   * @param r Color source(Red).
   * @param g Color source(Green).
   * @param b Color source(Blue).
   * @param a Color source(Alpha).
   * @return The result of configured color.
   */
  private Color init(int r,int g,int b,int a){
    this.r=PApplet.constrain(r,0,255);
    this.g=PApplet.constrain(g,0,255);
    this.b=PApplet.constrain(b,0,255);
    this.a=PApplet.constrain(a,0,255);
    this.intValue=(this.a<<24)|(this.r<<16)|(this.g<<8)|this.b;
    return this;
  }

  public Color set(int grayscale){
    return init(grayscale,grayscale,grayscale,255);
  }

  public Color set(int grayscale,int a){
    return init(grayscale,grayscale,grayscale,a);
  }

  public Color set(int r,int g,int b){
    return init(r,g,b,a);
  }

  public Color set(int r,int g,int b,int a){
    return init(r,g,b,a);
  }

  public Color setRed(int r){
    return init(r,g,b,a);
  }

  public int getRed(){
    return r;
  }

  public Color setGreen(int g){
    return init(r,g,b,a);
  }

  public int getGreen(){
    return g;
  }

  public Color setBlue(int b){
    return init(r,g,b,a);
  }

  public int getBlue(){
    return b;
  }

  public Color setAlpha(int a){
    return init(r,g,b,a);
  }

  public int getAlpha(){
    return a;
  }

  public Color add(int scalar){
    return init(r+scalar,g+scalar,b+scalar,a);
  }

  public Color add(int r,int g,int b){
    return init(this.r+r,this.g+g,this.b+b,a);
  }

  public Color add(Color c){
    return init(r+c.r,g+c.g,b+c.b,a);
  }

  public Color sub(int scalar){
    return init(r-scalar,g-scalar,b-scalar,a);
  }

  public Color sub(int r,int g,int b){
    return init(this.r-r,this.g-g,this.b-b,a);
  }

  public Color sub(Color c){
    return init(r-c.r,g-c.g,b-c.b,a);
  }

  public Color mult(float scalar){
    return init(PApplet.round(r*scalar),PApplet.round(g*scalar),PApplet.round(b*scalar),a);
  }

  public Color mult(float r,float g,float b){
    return init(PApplet.round(this.r*r),PApplet.round(this.g*g),PApplet.round(this.b*b),a);
  }

  public Color div(float scalar){
    return init(PApplet.round(r/scalar),PApplet.round(g/scalar),PApplet.round(b/scalar),a);
  }

  public Color div(float r,float g,float b){
    return init(PApplet.round(this.r/r),PApplet.round(this.g/g),PApplet.round(this.b/b),a);
  }

  public static Color add(Color c1,Color c2){
    return new Color(c1.r+c2.r, c1.g+c2.g ,c1.b+c2.b ,c1.a );
  }

  public static Color sub(Color c1,Color c2){
    return new Color(c1.r-c2.r, c1.g-c2.g, c1.b-c2.b, c1.a );
  }

  /**
   * This method calculates <pre>c1*(1f-a)+c2*a</pre>(Linear interpolation)
   * @param c1 The first source color.
   * @param c2 Second source color.
   * @param a Blend factor.
   * @return The result of liner interpolation.
   */
  public static Color lerp(Color c1,Color c2,float a){
    return c1.clone().add(sub(c2,c1).mult(a));
  }

  @Override
  public Color clone(){
    return new Color(r,g,b,a);
  }

  /**
   * This method returns the integer representation of the color.
   * @return integer representation of the color.
   */
  public int intValue(){
    return intValue;
  }
}
