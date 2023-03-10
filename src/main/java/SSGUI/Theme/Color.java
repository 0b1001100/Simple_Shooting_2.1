package SSGUI.Theme;

import processing.core.PApplet;

public class Color {
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

  private Color init(int r,int g,int b,int a){
    this.r=PApplet.constrain(r,0,255);
    this.g=PApplet.constrain(g,0,255);
    this.b=PApplet.constrain(b,0,255);
    this.a=PApplet.constrain(a,0,255);
    this.intValue=(this.a<<24)|(this.r<<16)|(this.g<<8)|this.b;
    return this;
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

  public Color sub(int scalar){
    return init(r-scalar,g-scalar,b-scalar,a);
  }

  public Color sub(int r,int g,int b){
    return init(this.r-r,this.g-g,this.b-b,a);
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

  /**
   * This method returns the integer representation of the color.
   * @return integer representation of the color.
   */
  public int intValue(){
    return intValue;
  }
}
