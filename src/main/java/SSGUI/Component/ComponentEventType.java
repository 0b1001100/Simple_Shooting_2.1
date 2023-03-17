package SSGUI.Component;

public enum ComponentEventType {
  GetFocus,
  LostFocus,
  Selected,
  None;

  public static ComponentEventType parse(String name){
    return switch(name){
      case "GetFocus"->GetFocus;
      case "LostFocus"->LostFocus;
      case "Selected"->Selected;
      default->None;
    };
  }
}
