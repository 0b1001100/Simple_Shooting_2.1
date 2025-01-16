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
   * @param b A binary data.
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
      case 0b111100->All;
      case 0b111111->All;
      case 0b000000->None;
      default->None;
    };
  }

  public static Direction binalyDirectionOf(int binary){
    int horizonal=binary&0b110000;
    horizonal=(horizonal==0b110000)?0b00:horizonal;
    int vertical=(binary<<2)&0b110000;
    vertical=(vertical==0b110000)?0b00:vertical;
    int FB=(binary<<4)&0b110000;
    FB=(FB==0b110000)?0b00:FB;
    binary=horizonal|(vertical>>2)|(FB>>4);
    return switch(binary){
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
      default->None;
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

  public int or(Direction a,Direction b){
    return a.binary|b.binary;
  }

  public static float getAngle(Direction d){
    return switch(d){
      case Horizonal->0f;
      case Vertical->0f;
      case Up->(float)Math.PI*0.5f;
      case Down->(float)Math.PI*1.5f;
      case Right->0f;
      case Left->(float)Math.PI;
      case Up_Right->(float)Math.PI*0.25f;
      case Up_Left->(float)Math.PI*0.75f;
      case Down_Right->(float)Math.PI*1.75f;
      case Down_Left->(float)Math.PI*1.25f;
      case Front->0f;
      case Behind->0f;
      case All->0f;
      case None->0f;
    };
  }

  public static float getAngle(int binary){
    Direction d=binalyDirectionOf(binary);
    return getAngle(d);
  }

  public static Direction sumDirection(int... binaries){
    int result=0b000000;
    for(int binary:binaries){
      result|=binary;
    }
    return binalyOf(result);
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
