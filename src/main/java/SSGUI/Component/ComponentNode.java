package SSGUI.Component;

import processing.data.JSONObject;

public class ComponentNode implements ConstractibleFromJSON<ComponentNode> {
  private GameComponent parent;

  private int id;

  private int up;
  private int down;
  private int right;
  private int left;

  public ComponentNode(GameComponent parent,int id){
    this(parent,id,-1,-1,-1,-1);
  }

  public ComponentNode(GameComponent parent,int id,int up,int down,int right,int left){
    this.parent=parent;
    this.id=id;
    this.up=up;
    this.down=down;
    this.right=right;
    this.left=left;
  }

  public GameComponent getComponent(){
    return parent;
  }

  public int getId(){
    return id;
  }

  public void setUp(int i){
    up=i;
  }

  public int getUp(){
    return up;
  }

  public void setDown(int i){
    down=i;
  }

  public int getDown(){
    return down;
  }

  public void setRight(int i){
    right=i;
  }

  public int getRight(){
    return right;
  }

  public void setLeft(int i){
    left=i;
  }

  public int getLeft(){
    return left;
  }

  public int get(Direction d){
    return switch(d){
      case Up->up;
      case Down->down;
      case Right->right;
      case Left->left;
      default->-1;
    };
  }

  @Override
  public ComponentNode buildFromJSON(JSONObject o){
    parent.buildFromJSON(o.getJSONObject("component"));
    id=o.getInt("id");
    up=o.getInt("up", -1);
    down=o.getInt("down", -1);
    right=o.getInt("right", -1);
    left=o.getInt("left", -1);
    return this;
  }
}

/*
 * JSON example
 * {
 *   "component":{
 *     "label":"example",
 *     "explanation":"This is an example button.",
 *     "position":[100,100],
 *     "size":[150,25],
 *     "animators":[
 *       {
 *         "type":"vector",
 *         "start":"GetFocus",
 *         "end":"LostFocus",
 *         "duration":150,
 *         "keyFrames":[
 *           0  ,0  ,25,
 *           100,125,25,
 *           150,150,25
 *         ]
 *       }
 *     ]
 *   },
 *   "id":4,          0  <1>  2
 *   "up":1,              |
 *   "down":7,   --> <3>-[4]-<5>
 *   "right":5,           |
 *   "left":3         6  <7>  8
 * }
 */