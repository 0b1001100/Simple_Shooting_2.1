package SSGUI.Component;

import java.util.function.Consumer;
import java.util.function.Supplier;

import SSGUI.Theme.Theme;
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

  private Consumer<GameComponent>selectedProcess;
  private Consumer<GameComponent>getFocusProcess;
  private Consumer<GameComponent>lostFocusProcess;

  private Direction constraintDirection;

  private boolean isActive=true;
  private boolean focusable=true;

  private String Label;
  
  public GameComponent(){}

  public void HandleUpdate(float deltaTime){
    if(isActive)update(deltaTime);
  }

  protected abstract void update(float deltaTime);

  public void HandleDisplay(PGraphicsOpenGL g,boolean focus){
    if(isActive){
      g.fill(theme.getColor((focus?"selectedB":"b")+"ackground").intValue());
      g.stroke(theme.getColor((focus?"selectedB":"b")+"order").intValue());
      displayBackground(g);
      g.fill(theme.getColor((focus?"selectedF":"f")+"oreground").intValue());
      g.stroke(theme.getColor((focus?"selectedB":"b")+"order").intValue());
      displayForeground(g);
    }
  }

  protected abstract void displayBackground(PGraphicsOpenGL g);

  protected abstract void displayForeground(PGraphicsOpenGL g);

  public void setBounds(Supplier<PVector>position,Supplier<PVector>size){
    this.position=position;
    this.size=size;
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

  public void setGetFocusProcess(Consumer<GameComponent> process){
    this.getFocusProcess=process;
  }

  public Consumer<GameComponent> getGetFocusProcess(){
    return getFocusProcess;
  }

  public void setLostFocusProcess(Consumer<GameComponent> process){
    this.lostFocusProcess=process;
  }

  public Consumer<GameComponent> getLostFocusProcess(){
    return lostFocusProcess;
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

  /**
   * This method sets the label of this component.<br>
   * a label used to display text such as Button name.
   * @param name The label of this component.
   */
  public void setLabel(String name){
    Label=name;
  }

  /**
   * This method returns the label of this component.<br>
   * The label is mutable but you shouldn't change it.
   * @return The label of this component.
   */
  public String getLabel(){
    return Label;
  }
}
