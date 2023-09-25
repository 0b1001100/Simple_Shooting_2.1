package SSGUI.Component;

/**
 * Direction is mainly used in {@link GameComponent}.
 * This class provides a better directional representation.
 */
public enum Direction {
  Horizonal(0b110000),
  Vertical(0b001100),
  Up(0b001000),
  Down(0b000100),
  Right(0b100000),
  Left(0b010000),
  Up_Right(0b101000),
  Up_Left(0b011000),
  Down_Right(0b100100),
  Down_Left(0b010100),
  Front(0b000010),
  Behind(0b000001),
  All(0b111111),
  None(0b000000);

  /**
   * This variable is consists of 0b[+x][-x][+y][-y][+z][-z].
   */
  private final int binary;

  /**
   * @param b a binary data.
   */
  private Direction(int b){
    binary=b;
  }

  public static Direction binalyOf(int binary){
    return switch(binary){
      case 0b110000->Horizonal;
      case 0b001100->Vertical;
      case 0b001000->Up;
      case 0b000100->Down;
      case 0b100000->Right;
      case 0b010000->Left;
      case 0b101000->Up_Right;
      case 0b011000->Up_Left;
      case 0b100100->Down_Right;
      case 0b010100->Down_Left;
      case 0b000010->Front;
      case 0b000001->Behind;
      case 0b111111->All;
      case 0b000000->None;
      default->null;
    };
  }

  /**
   * This function is mainly used to get binary data and compare directions.
   * @return a binary data.
   */
  public int getBinary(){
    return binary;
  }

  /**
   * Compare directions.
   * @param d the other direction.
   * @return do the two directions overlap?
   */
  public boolean matches(Direction d){
    return (binary&d.getBinary())>0;
  }

  public static float getAngle(Direction d){
    return switch(d){
      case Horizonal->Float.NaN;
      case Vertical->Float.NaN;
      case Up->(float)Math.PI*0.5f;
      case Down->(float)Math.PI*1.5f;
      case Right->0f;
      case Left->(float)Math.PI;
      case Up_Right->(float)Math.PI*0.25f;
      case Up_Left->(float)Math.PI*0.75f;
      case Down_Right->(float)Math.PI*1.75f;
      case Down_Left->(float)Math.PI*1.25f;
      case Front->Float.NaN;
      case Behind->Float.NaN;
      case All->Float.NaN;
      case None->Float.NaN;
    };
  }

  public static float getAngle(int binary){
    if((binary&0b111100)==0b000000)return Float.NaN;
    float angle_x=Float.NaN;
    float angle_y=Float.NaN;
    int y=binary&0b001100;
    Direction yd=binalyOf(y);
    if(yd!=Vertical){
      angle_y=switch(y){
        case 0b000100->(float)Math.PI*0.5f;
        case 0b001000->(float)Math.PI*1.5f;
        default->Float.NaN;
      };
    }
    int x=binary&0b110000;
    Direction xd=binalyOf(x);
    if(xd!=Horizonal){
      angle_x=switch(x){
        case 0b100000->(!Float.isNaN(angle_y)&&angle_y>Math.PI)?(float)Math.PI*2.0f:0f;
        case 0b010000->(float)Math.PI;
        default->Float.NaN;
      };
    }
    if(Float.isNaN(angle_x)){
      return angle_y;
    }else if(Float.isNaN(angle_y)){
      return angle_x;
    }
    return (angle_x+angle_y)*0.5f;
  }

  public static Direction angleTo4Direction(float angle){
    if(Float.isNaN(angle))return None;
    int num=(int)Math.floor((angle+Math.PI*0.25f)/(Math.PI*0.5f))%4;
    return switch (num) {
      case 0->Right;
      case 1->Up;
      case 2->Left;
      case 3->Down;
      default->None;
    };
  }

  public static Direction angleTo8Direction(float angle){
    if(Float.isNaN(angle))return None;
    int num=(int)Math.floor((angle+Math.PI*0.125f)/(Math.PI*0.25f))%8;
    return switch (num) {
      case 0->Right;
      case 1->Up_Right;
      case 2->Up;
      case 3->Up_Left;
      case 4->Left;
      case 5->Down_Left;
      case 6->Down;
      case 7->Down_Right;
      default->None;
    };
  }
}
