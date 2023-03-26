package SSGUI.Component;

import SSGUI.EventHandler;
import SSGUI.Component.Animator.ColorAnimator;
import SSGUI.Component.Animator.VectorAnimator;
import processing.core.PVector;
import processing.data.JSONArray;
import processing.data.JSONObject;

public abstract class SButton extends GameComponent {
  
  @Override
  public SButton buildFromJSON(JSONObject o){
    setLabel(getLanguage().getText(o.getString("label", "")));
    setExplanation(getLanguage().getText(o.getString("explanation", "")));
    float posArray[]=o.getJSONArray("position").toFloatArray();
    PVector pos=new PVector(posArray[0],posArray[1]);
    float sizeArray[]=o.getJSONArray("size").toFloatArray();
    PVector size=new PVector(sizeArray[0],sizeArray[1]);
    setBounds(()->pos, ()->size);
    //initiailze animator
    JSONArray animatorArray=o.getJSONArray("animators");
    for(int i=0;i<animatorArray.size();++i){
      JSONObject anim=animatorArray.getJSONObject(i);
      String type=anim.getString("type");
      setAnimator(anim.getString("name"), (type=="color"?new ColorAnimator(0f, false):new VectorAnimator(0f, false)).buildFromJSON(anim)
                  , ComponentEventType.valueOf(anim.getString("start")), ComponentEventType.valueOf(anim.getString("end")));
    }
    //initialize event
    if(o.hasKey("event")){
      if(o.getJSONObject("event").hasKey("getFocus"))setGetFocusProcess(EventHandler.INSTANCE.getEvent(o.getJSONObject("event").getString("getFocus")));
      if(o.getJSONObject("event").hasKey("lostFocus"))setLostFocusProcess(EventHandler.INSTANCE.getEvent(o.getJSONObject("event").getString("lostFocus")));
      if(o.getJSONObject("event").hasKey("selected"))setSelectedProcess(EventHandler.INSTANCE.getEvent(o.getJSONObject("event").getString("selected")));
    }
    return this;
  }
}

/*
 * JSON example
 * {
 *   "label":"example",
 *   "explanation":"This is an example button.",
 *   "position":[100,100],
 *   "size":[150,25],
 *   "animators":[
 *     {
 *       "type":"vector",
 *       "start":"GetFocus",
 *       "end":"LostFocus",
 *       "duration":150,
 *       "keyFrames":[
 *         0  ,0  ,25,
 *         100,125,25,
 *         150,150,25
 *       ]
 *     }
 *   ]
 * }
 */