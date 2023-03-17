package SSGUI;

import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.function.Consumer;

import SSGUI.Component.GameComponent;

public enum EventHandler {
  INSTANCE;

  private HashMap<String,Consumer<GameComponent>>events=new HashMap<>();

  public void setHandlerClass(Object o){
    Method methodArray[]=o.getClass().getDeclaredMethods();
    try {
      for(int i=0;i<methodArray.length;++i){
        Method m=methodArray[i];
        MethodHandle mh;
          mh = MethodHandles.lookup().unreflect(m);
        events.put(m.getName(),(gc)->{
          try {
            mh.invoke(o,gc);
          } catch (Throwable e) {
            e.printStackTrace();
          }
        });
      }
    } catch (IllegalAccessException e) {
      e.printStackTrace();
    }
  }

  public void addEvent(String name,Consumer<GameComponent> event){
    events.put(name,event);
  }

  public Consumer<GameComponent> getEvent(String name){
    return events.get(name);
  }

  public HashMap<String,Consumer<GameComponent>> getEvents(){
    return events;
  }
}
