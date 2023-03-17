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
}
