package SSGUI.input;

import static com.jogamp.newt.event.KeyEvent.*;

import java.util.Arrays;

public enum KeyGroup {
  WASD(VK_W,VK_S,VK_D,VK_A),
  Arrow(VK_UP,VK_DOWN,VK_RIGHT,VK_LEFT),
  IJKL(VK_I,VK_K,VK_J,VK_L);

  private int[] keys;

  private KeyGroup(int... keys){
    this.keys=keys;
  }

  int[] getKeys(){
    return keys;
  }

  Integer[] getKeysInteger(){
    return Arrays.stream(keys).boxed().toArray(Integer[]::new);
  }
}
