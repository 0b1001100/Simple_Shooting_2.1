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
    direction=switch((int)rawValue){
      case 0->Direction.None;
      case 1->Direction.Up_Left;
      case 2->Direction.Up;
      case 3->Direction.Up_Right;
      case 4->Direction.Right;
      case 5->Direction.Down_Right;
      case 6->Direction.Down;
      case 7->Direction.Down_Left;
      case 8->Direction.Left;
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
