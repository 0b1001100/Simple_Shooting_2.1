package SSGUI;

import org.junit.jupiter.api.Test;

import SSGUI.Component.Direction;
import SSGUI.Component.GameComponent;
import SSGUI.Menu.MenuButton;
import SSGUI.Theme.Color;
import Simple_shooting_2_1.net.NetworkConfiguration;

public class GUI_test {
  
  @Test
  void testDirection(){
    Direction d1=Direction.Left;
    Direction d2=Direction.Up;
    Direction d3=Direction.Horizonal;
    assert d1.matches(d3);
    assert !d2.matches(d3);
    assert Direction.getAngle(0b111000)==(float)Math.PI*0.5;
  }

  @Test
  void testColor(){
    Color c1=new Color(100,200,300);
    assert c1.getRed()==100;
    assert c1.getGreen()==200;
    assert c1.getBlue()==255;
    assert c1.getAlpha()==255;
    assert c1.mult(0.5f).getRed()==50;
    assert c1.add(100).getGreen()==200;
    assert c1.sub(100).getGreen()==100;
    assert c1.div(2f).getGreen()==50;
  }

  @Test
  void testNet(){
    NetworkConfiguration conf=NetworkConfiguration.getInstance();
    String s=conf.getGlobalIP();
    assert "[Global IP address]".equals(s);
  }

  @Test
  void testEventHandler(){
    EventHandler.INSTANCE.setHandlerClass(this);
    System.out.println(EventHandler.INSTANCE.getEvents()+"\n"+EventHandler.INSTANCE.getEvent("testEventHandler_exanple"));
    EventHandler.INSTANCE.getEvent("testEventHandler_exanple").accept(new MenuButton());
  }

  void testEventHandler_exanple(GameComponent c){
    System.out.println("called");
  }
}
