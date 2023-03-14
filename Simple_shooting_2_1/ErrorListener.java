import org.antlr.v4.runtime.*;

import java.util.LinkedHashMap;

class ThrowingErrorListener extends BaseErrorListener{
  public static final ThrowingErrorListener INSTANCE = new ThrowingErrorListener();
  private LinkedHashMap<DebugText,Float> WarningMap=new LinkedHashMap<>();
  
  public ThrowingErrorListener setWarningMap(LinkedHashMap<DebugText,Float> h){
    WarningMap=h;
    return this;
  }

  @Override
  public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e){
    if(!WarningMap.containsKey(new DebugText("line "+line+":"+charPositionInLine+" "+msg,true)))WarningMap.put(new DebugText("line "+line+":"+charPositionInLine+" "+msg,true),0f);
  }
}

class DebugText{
  String text;
  boolean warning=false;
  
  public DebugText(String s,boolean w){
    text=s;
    warning=w;
  }
  
  public String getText(){
    return text;
  }
  
  public boolean isWarning(){
    return warning;
  }
  
  @Override
  public boolean equals(Object o){
    if(o==this)return true;
    if(o instanceof DebugText){
      DebugText dt=(DebugText)o;
      return text.equals(dt.text)&&(warning==dt.warning);
    }
    return false;
  }
}
