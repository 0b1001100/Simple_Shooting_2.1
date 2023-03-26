package SSGUI.input.controller;

import SSGUI.Component.Direction;
import net.java.games.input.Component;

public class Controller_Hat extends Controller_Button {
  private Direction direction;
  
  public Controller_Hat(Component component){
    super(component);
  }

  @Override
  public void update(){
    super.update();
    direction=switch(getRawValue()){
      case 0f->Direction.None;
      case 1f->Direction.Up_Left;
      case 2f->Direction.Up;
      case 3f->Direction.Up_Right;
      case 4f->Direction.Right;
      case 5f->Direction.Down_Right;
      case 6f->Direction.Down;
      case 7f->Direction.Down_Left;
      case 8f->Direction.Left;
      default->Direction.None;
    };
  }

  public Direction getDirection(){
    return direction;
  }

  public float getAngle(){
    return Direction.getAngle(direction);
  }
}
