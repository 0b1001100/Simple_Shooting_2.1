package SSGUI.Menu;

import SSGUI.Component.Direction;
import SSGUI.Component.SButton;
import processing.core.PApplet;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;

public class MenuButton extends SButton {

  @Override
  protected void init(){
    setTheme(MenuSettings.INSTANCE.getTheme());
    MenuSettings.INSTANCE.setFocusAnimator(this);
  }
  
  @Override
  protected void displayBackground(PGraphicsOpenGL g,boolean focus){
    PVector pos=getPosition();
    PVector size=getSize();
    g.rectMode(PApplet.CORNER);
    g.noStroke();
    g.fill(getBackgroundColor(focus).intValue());
    g.rect(pos.x,pos.y,size.x,size.y);
  }

  @Override
  protected void displayForeground(PGraphicsOpenGL g,boolean focus){
    PVector pos=getPosition();
    PVector size=getSize();
    PVector anim_size=(PVector)getAnimator("foreground_animator").get();
    g.noStroke();
    g.fill(theme.getColor("foreground_fill").intValue());
    g.rect(pos.x,pos.y,anim_size.x,anim_size.y);
    g.fill(getForegroundColor(focus).intValue());
    g.textAlign(PApplet.CENTER,PApplet.CENTER);
    g.textSize(size.y*0.5f);
    g.textFont(getFont(g));
    g.text(getLabel(),pos.x+size.x*0.5f,pos.y+size.y*0.5f);
  }

  @Override
  protected void update(float deltaTime) {
    
  }

  @Override
  protected void constraintInput(Direction d) {
    
  }
}
