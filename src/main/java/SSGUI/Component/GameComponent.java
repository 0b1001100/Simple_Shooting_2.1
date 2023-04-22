package SSGUI.Component;

import java.util.HashMap;
import java.util.function.Consumer;
import java.util.function.Supplier;

import SSGUI.Component.Animator.Animator;
import SSGUI.Component.Animator.ColorAnimator;
import SSGUI.Component.Animator.VectorAnimator;
import SSGUI.Trio;
import SSGUI.Theme.Color;
import SSGUI.Theme.Theme;
import processing.core.PFont;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;

/**
 * This class defines the GUI component which can use in
 * <a href=https://processing.org/>Processing</a>.
 * @author Asynchronous-0x4C
 */
public abstract class GameComponent implements ConstractibleFromJSON<GameComponent> {
  /**
   * This variable was changed {@code Supplier<PVector>} from {@link PVector}
   * because when the window resized,the offset from right is deviate.
   */
  private Supplier<PVector>position;
  /**
   * This variable was changed {@code Supplier<PVector>} from {@link PVector}
   * because when the window resized, this variable has the potential to change
   * size follow to window ratio.
   */
  private Supplier<PVector>size;

  protected Theme theme;

  protected HashMap<String,Trio<Animator<?>,ComponentEventType,ComponentEventType>>animatorMap=new HashMap<>();

  private Consumer<GameComponent>selectedProcess=(c)->{};
  private Consumer<GameComponent>getFocusProcess=(c)->{};
  private Consumer<GameComponent>lostFocusProcess=(c)->{};

  private Direction constraintDirection=Direction.None;

  private boolean isActive=true;
  private boolean focusable=true;

  private Language language=Language.ja_jp;

  private PFont font;

  private String Label;
  private String Explanation;
  
  public GameComponent(){
    init();
  }

  protected abstract void init();

  public void handleUpdate(float deltaTime){
    if(isActive){
      animatorMap.forEach((k,v)->{v.getKey().update(deltaTime);});
      update(deltaTime);
    }
  }

  protected abstract void update(float deltaTime);

  public void handleDisplay(PGraphicsOpenGL g,boolean focus){
    if(isActive){
      displayBackground(g,focus);
      displayForeground(g,focus);
    }
  }

  protected abstract void displayBackground(PGraphicsOpenGL g,boolean focus);

  protected abstract void displayForeground(PGraphicsOpenGL g,boolean focus);

  public GameComponent setBounds(Supplier<PVector>position,Supplier<PVector>size){
    this.position=position;
    this.size=size;
    return this;
  }

  public PVector getPosition(){
    return position.get();
  }

  public PVector getSize(){
    return size.get();
  }

  protected void setTheme(Theme theme){
    this.theme=theme;
  }

  public Color getBackgroundColor(boolean focus){
    return theme.getColor((focus?"selectedB":"b")+"ackground");
  }

  public Color getForegroundColor(boolean focus){
    return theme.getColor((focus?"selectedF":"f")+"oreground");
  }

  public Color getBorderColor(boolean focus){
    return theme.getColor((focus?"selectedB":"b")+"order");
  }

  public void setAnimator(String name, Animator<?> anim, ComponentEventType startType, ComponentEventType endType){
    switch(anim){
      case VectorAnimator v:
        switch(name){
          case "position":position=v;break;
          case "size":size=v;break;
        }
        break;

      case ColorAnimator c:theme.putColor(name, c);

      default :break;
    }
    animatorMap.put(name,new Trio<>(anim,startType,endType));
  }

  public Animator<?> getAnimator(String name){
    return animatorMap.get(name).getKey();
  }

  public void setSelectedProcess(Consumer<GameComponent> process){
    this.selectedProcess=process;
  }

  /**
   * If you use this method, you can get {@code selectedProcess}.
   * But you shouldn't call {@link Consumer#accept(Object)} without special reason.
   * @return The {@code selectedProcess} of this component.
   */
  public Consumer<GameComponent> getSelectedProcess(){
    return selectedProcess;
  }

  protected void handleSelectedProcess(){
    if(!(isActive||focusable))return;
    animatorMap.forEach((k,v)->{
      if(v.getValue1()==ComponentEventType.Selected)v.getKey().animate();
      else
      if(v.getValue2()==ComponentEventType.Selected)v.getKey().reverse();
    });
    selectedProcess.accept(this);
  }

  public void setGetFocusProcess(Consumer<GameComponent> process){
    this.getFocusProcess=process;
  }

  public Consumer<GameComponent> getGetFocusProcess(){
    return getFocusProcess;
  }

  protected void handleGetFocusProcess(){
    if(!(isActive||focusable))return;
    animatorMap.forEach((k,v)->{
      if(v.getValue1()==ComponentEventType.GetFocus)v.getKey().animate();
      else
      if(v.getValue2()==ComponentEventType.GetFocus)v.getKey().reverse();
    });
    getFocusProcess.accept(this);
  }

  public void setLostFocusProcess(Consumer<GameComponent> process){
    this.lostFocusProcess=process;
  }

  public Consumer<GameComponent> getLostFocusProcess(){
    return lostFocusProcess;
  }

  protected void handleLostFocusProcess(){
    if(!(isActive||focusable))return;
    animatorMap.forEach((k,v)->{
      if(v.getValue1()==ComponentEventType.LostFocus)v.getKey().animate();
      else
      if(v.getValue2()==ComponentEventType.LostFocus)v.getKey().reverse();
    });
    lostFocusProcess.accept(this);
  }

  /**
   * This method sets the direction which constrains the cursor move.
   * @param direction The direction which constrains the cursor move.
   */
  public void setConstraintDirection(Direction direction){
    this.constraintDirection=direction;
  }

  public Direction getConstraintDirection(){
    return constraintDirection;
  }

  public void handleConstraintInput(Direction d){
    if(isActive&&focusable){
      constraintInput(d);
    }
  }

  /**
   * This method called when detected input in constrained direction.
   * @param d Input direction.
   */
  protected abstract void constraintInput(Direction d);

  /**
   * This method activate/deactivate this component.<br>
   * If this component have activated, this component will visible and accept your input.<br>
   * If this component have deactivated, this component will invisible and ignore your input.
   * @param active Whether this component is active.
   */
  public void setActive(boolean active){
    this.isActive=active;
  }

  public boolean getActive(){
    return isActive;
  }

  public void setFocusable(boolean focusable){
    this.focusable=focusable;
  }

  public boolean getFocusable(){
    return focusable;
  }

  protected PFont getFont(PGraphicsOpenGL g){
    if(font==null){
      font=g.parent.createFont("SansSerif.plain",getSize().y*0.5f);
    }
    return font;
  }

  /**
   * This method sets the label of this component.<br>
   * a label used to display text such as Button name.
   * @param name The label of this component.
   * @return This Object.
   */
  public GameComponent setLabel(String name){
    Label=name;
    return this;
  }

  /**
   * This method returns the label of this component.<br>
   * The label is mutable but you shouldn't change it.
   * @return The label of this component.
   */
  public String getLabel(){
    return Label;
  }

  public GameComponent setExplanation(String ex){
    Explanation=ex;
    return this;
  }

  public String getExplanation(){
    return Explanation;
  }

  public GameComponent setLanguage(Language language){
    this.language=language;
    return this;
  }

  public Language getLanguage(){
    return language;
  }

  public boolean onMouse(int mouseX,int mouseY){
    PVector pos=getPosition();
    PVector size=getSize();
    return pos.x<=mouseX&&pos.y<=mouseY&&mouseX<=pos.x+size.x&&mouseY<=pos.y+size.y;
  }
}
