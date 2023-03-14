package SSGUI.Theme;

import java.util.HashMap;
import java.util.function.Supplier;

/**
 * This class provides a means of implementing color theme such as dark theme.
 */
public abstract class Theme{
  /**
   * The HashMap of Color with an element name.
   */
  private HashMap<String,Supplier<Color>>Colors;

  /**
   * This constructor calls {@link #init()} and initalize {@code Colors}.<br>
   * If you override constructor, you should call this constructor.
   */
  public Theme(){
    Colors=new HashMap<>();
    init();
  }

  /**
   * This method used to set the color element in {@Code Colors}.
   */
  protected abstract void init();

  /**
   * This method puts the color with an element name to {@code Colors}.
   * @param name The element name of color.
   * @param color The color element.
   */
  protected void putColor(String name,Color color){
    Colors.put(name,()->color);
  }

  public void putColor(String name,Supplier<Color> color){
    Colors.put(name,color);
  }

  /**
   * Get the color from element name.
   * @param name The element name of color.
   * @return The color gets from the element.
   */
  public Color getColor(String name){
    return Colors.get(name).get();
  }
}
