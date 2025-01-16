package SSGUI.input;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.function.Consumer;

import com.jogamp.newt.event.KeyAdapter;
import com.jogamp.newt.event.KeyEvent;
import com.jogamp.newt.opengl.GLWindow;

import SSGUI.Component.Direction;
import processing.core.PApplet;
import processing.opengl.PSurfaceJOGL;

import static com.jogamp.newt.event.KeyEvent.*;

public class KeyBoard extends Device {
  private HashSet<Integer>pressedKeys;
  private HashSet<Integer>currentPressedKeys;
  private HashMap<String,HashSet<Integer>>keyBind;
  private HashMap<String,HashMap<String,Consumer<KeyEvent>>>eventMap;

  private boolean keyPress;
  private boolean keyRelease;
  
  public static final String eventNames[]=new String[]{"pressed","released"};

  public KeyBoard(PApplet applet,PSurfaceJOGL surface){
    super(applet,surface);
  }

  protected void init(){
    eventMap=new HashMap<>();
    for(String s:eventNames){
      eventMap.put(s,new HashMap<>());
    }
    initKeyBind();
    pressedKeys=new HashSet<>();
    currentPressedKeys=new HashSet<>();
    ((GLWindow)surface.getNative()).addKeyListener(new KeyAdapter(){
      @Override
      public void keyPressed(com.jogamp.newt.event.KeyEvent e) {
        if(e.isAutoRepeat())return;
        keyPress=true;
        pressedKeys.add((int)e.getKeyCode());
        currentPressedKeys.add((int)e.getKeyCode());
        eventMap.get(eventNames[0]).forEach((k,v)->v.accept(e));
      }
      @Override
      public void keyReleased(com.jogamp.newt.event.KeyEvent e) {
        if(e.isAutoRepeat())return;
        keyRelease=true;
        pressedKeys.remove((int)e.getKeyCode());
        eventMap.get(eventNames[1]).forEach((k,v)->v.accept(e));
      }
    });
  }

  private void initKeyBind(){
    keyBind=new HashMap<>();
    keyBind.put("Up",new HashSet<>(Arrays.asList((int)VK_W,(int)VK_UP)));
    keyBind.put("Down",new HashSet<>(Arrays.asList((int)VK_S,(int)VK_DOWN)));
    keyBind.put("Right",new HashSet<>(Arrays.asList((int)VK_D,(int)VK_RIGHT)));
    keyBind.put("Left",new HashSet<>(Arrays.asList((int)VK_A,(int)VK_LEFT)));
    keyBind.put("Enter",new HashSet<>(Arrays.asList((int)VK_ENTER)));
    keyBind.put("Back",new HashSet<>(Arrays.asList((int)VK_SHIFT,(int)VK_ESCAPE)));
    keyBind.put("Menu",new HashSet<>(Arrays.asList((int)VK_CONTROL)));
    keyBind.put("Change",new HashSet<>(Arrays.asList((int)VK_TAB)));
  }

  public void clearKeyBind(){
    keyBind.clear();
  }

  public void addKeyBind(String name,Integer... key){
    if(keyBind.containsKey(name)){
      keyBind.get(name).addAll(Arrays.asList(key));
    }else{
     keyBind.put(name,new HashSet<>(Arrays.asList(key)));

    }
  }

  public void removeKeyBind(String name){
    if(keyBind.containsKey(name))keyBind.get(name).clear();
  }

  public void removeKeyBind(String name,Integer... key){
    if(keyBind.containsKey(name))keyBind.get(name).removeAll(Arrays.asList(key));
  }

  public void addMoveKeyGroup(KeyGroup group){
    int[] keys=group.getKeys();
    int loop=Math.min(keys.length, 4);
    for(int i=0;i<loop;i++){
      switch(i){
        case 0:addKeyBind("Up", keys[i]);break;
        case 1:addKeyBind("Down", keys[i]);break;
        case 2:addKeyBind("Right", keys[i]);break;
        case 3:addKeyBind("Left", keys[i]);break;
      }
    }
  }

  /**
   * This method updates inner variable state.
   * This method should call after processing the input.
   */
  public void update(){
    currentPressedKeys.clear();
    keyPress=keyRelease=false;
  }

  public void addProcess(String eventName,String name,Consumer<KeyEvent> process){
    eventMap.get(eventName).put(name,process);
  }

  public Consumer<KeyEvent> getProcess(String eventName,String name){
    return eventMap.get(eventName).get(name);
  }

  public void removeProcess(String eventName,String name){
    eventMap.get(eventName).remove(name);
  }

  public boolean keyPress(){
    return keyPress;
  }

  public boolean keyPressed(){
    return applet.keyPressed;
  }

  public boolean keyRelease(){
    return keyRelease;
  }

  public int keyCode(){
    return applet.keyCode;
  }

  public HashSet<Integer> getPressedKeys(){
    return pressedKeys;
  }

  public boolean getBindedInput(String bind){
    return keyPress&&keyBind.containsKey(bind)&&containsSet(currentPressedKeys, keyBind.get(bind));
  }

  public Direction getDirection(){
    if(!keyPressed()&&!keyPress())return Direction.None;
    int binary=0b000000;
    if(containsSet(keyBind.get("Up"), pressedKeys))binary=binary|Direction.Up.getBinary();
    if(containsSet(keyBind.get("Down"), pressedKeys))binary=binary|Direction.Down.getBinary();
    if(containsSet(keyBind.get("Right"), pressedKeys))binary=binary|Direction.Right.getBinary();
    if(containsSet(keyBind.get("Left"), pressedKeys))binary=binary|Direction.Left.getBinary();
    return Direction.binalyDirectionOf(binary);
  }

  public float getAngle(){
    if(!keyPressed()&&!keyRelease())return 0f;
    int binary=0b000000;
    if(containsSet(keyBind.get("Up"), pressedKeys))binary=binary|Direction.Up.getBinary();
    if(containsSet(keyBind.get("Down"), pressedKeys))binary=binary|Direction.Down.getBinary();
    if(containsSet(keyBind.get("Right"), pressedKeys))binary=binary|Direction.Right.getBinary();
    if(containsSet(keyBind.get("Left"), pressedKeys))binary=binary|Direction.Left.getBinary();
    return Direction.getAngle(binary);
  }

  private <T> boolean containsSet(Set<T> src,Set<T> target){
    for(T val:target){
      if(src.contains(val))return true;
    }
    return false;
  }
}
