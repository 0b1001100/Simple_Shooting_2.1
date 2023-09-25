package SSGUI.Component;

import java.util.HashMap;

import SSGUI.input.Input;
import processing.data.JSONArray;
import processing.data.JSONObject;
import processing.opengl.PGraphicsOpenGL;

public class ComponentSet extends GameComponent {
  private HashMap<Integer,ComponentNode>nodes;

  private ComponentNode focusedComponent;

  @Override
  protected void init(){
    nodes=new HashMap<>();
    setConstraintDirection(Direction.All);
    setGetFocusProcess(c->{
      focusedComponent.getComponent().handleGetFocusProcess();
    });
    setLostFocusProcess(c->{
      focusedComponent.getComponent().handleLostFocusProcess();
    });
    setActive(false);
  }

  public ComponentSet add(ComponentNode node){
    nodes.put(node.getId(),node);
    if(focusedComponent==null&&(node.getComponent().getFocusable()||node.getComponent().getActive())){
      focusedComponent=node;
      focusedComponent.getComponent().handleGetFocusProcess();
    }
    setActive(true);
    return this;
  }

  public ComponentSet remove(int index){
    nodes.remove(index);
    if(nodes.isEmpty())setActive(false);
    return this;
  }

  public GameComponent get(int index){
    return nodes.get(index).getComponent();
  }

  public GameComponent getFocusedComponent(){
    return focusedComponent.getComponent();
  }

  public boolean containsKey(int i){
    return nodes.containsKey(i);
  }

  @Override
  public void displayBackground(PGraphicsOpenGL g,boolean focus){

  }

  @Override
  protected void displayForeground(PGraphicsOpenGL g,boolean focus){
    nodes.forEach((k,v)->v.getComponent().handleDisplay(g, v==focusedComponent));
  }

  @Override
  protected void update(float deltaTime){
    nodes.forEach((k,v)->v.getComponent().handleUpdate(deltaTime));
  }

  public void handleInput(Input i){
    if(i.getMouse().mouseMoved()){
      ComponentNode next=null;
      for (ComponentNode node : nodes.values()) {
        if(node.getComponent().onMouse(i.getMouse().getX(),i.getMouse().getY())){
          next=node;
          break;
        }
      }
      if(next!=null&&focusedComponent!=next)MoveFocus(next);
    }else{
      if(i.getKeyBoard().keyPress())constraintInput(i.getKeyBoard().getDirection());
      if(i.getController().getControllerMove())constraintInput(i.getController().getDirection());
    }
    if(i.isEnterInput()){
      focusedComponent.getComponent().handleSelectedProcess();
    }
  }

  @Override
  protected void constraintInput(Direction d){
    if(focusedComponent.getComponent().getConstraintDirection().matches(d)){
      focusedComponent.getComponent().handleConstraintInput(d);
    }else{
      int nowIndex=focusedComponent.getId();
      while(true){
        int nextIndex=focusedComponent.get(d);
        if(nodes.containsKey(nextIndex)){
          MoveFocus(nodes.get(nextIndex));
          if(focusedComponent.getComponent().getFocusable()&&
             focusedComponent.getComponent().getActive())break;
        }else{
          focusedComponent=nodes.get(nowIndex);
          break;
        }
      }
    }
  }

  private void MoveFocus(ComponentNode target){
    focusedComponent.getComponent().handleLostFocusProcess();
    focusedComponent=target;
    focusedComponent.getComponent().handleGetFocusProcess();
  }

  @Override
  public ComponentSet buildFromJSON(JSONObject o){
    JSONArray array=o.getJSONArray("nodes");
    for(int i=0;i<array.size();++i){
      add(new ComponentNode(null, 0).buildFromJSON(array.getJSONObject(i)));
    }
    return this;
  }
}

/*
 * JSON example
 * {
 *   "nodes":[
 *     {
 *       "component":{
 *         "label":"example",
 *         "explanation":"This is an example button.",
 *         "position":[100,100],
 *         "size":[150,25],
 *         "animators":[
 *           {
 *             "type":"vector",
 *             "start":"GetFocus",
 *             "end":"LostFocus",
 *             "duration":150,
 *             "keyFrames":[
 *               0  ,0  ,25,
 *               100,125,25,
 *               150,150,25
 *             ]
 *           }
 *         ]
 *       },
 *       "id":4,          0  <1>  2
 *       "up":1,              |
 *       "down":7,   --> <3>-[4]-<5>
 *       "right":5,           |
 *       "left":3         6  <7>  8
 *     },
 *     {
 *       "component":{
 *         "label":"example",
 *         "explanation":"This is an example button.",
 *         "position":[100,100],
 *         "size":[150,25],
 *         "animators":[
 *           {
 *             "type":"vector",
 *             "start":"GetFocus",
 *             "end":"LostFocus",
 *             "duration":150,
 *             "keyFrames":[
 *               0  ,0  ,25,
 *               100,125,25,
 *               150,150,25
 *             ]
 *           }
 *         ]
 *       },
 *       "id":1,         <0>-[1]-<2>
 *       "up":-1,             |
 *       "down":4,   -->  3  <4>  5
 *       "right":2,            
 *       "left":0         6   7   8
 *     }
 *   ]
 * }
 */