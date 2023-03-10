package SSGUI.Component;

import processing.data.JSONObject;

public interface ConstractibleFromJSON<T> {
  public T buildFromJSON(JSONObject o);
}
