package SSGUI.Component;

import processing.data.JSONObject;

public enum Language {
  ja_jp,
  en_us;

  JSONObject text;

  private Language(){}

  public void setTextObject(JSONObject o){
    text=o;
  }

  public String getText(String name){
    return text!=null?text.getString(name,""):"";
  }
}
