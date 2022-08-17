import org.antlr.v4.runtime.*;

import java.util.LinkedHashMap;

class ThrowingErrorListener extends BaseErrorListener{
  public static final ThrowingErrorListener INSTANCE = new ThrowingErrorListener();
  private LinkedHashMap<String,Float> WarningMap=new LinkedHashMap<String,Float>();
  
  public ThrowingErrorListener setWarningMap(LinkedHashMap h){
    WarningMap=h;
    return this;
  }

  @Override
  public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e){
    if(!WarningMap.containsKey("line "+line+":"+charPositionInLine+" "+msg))WarningMap.put("line "+line+":"+charPositionInLine+" "+msg,0f);
  }
}
