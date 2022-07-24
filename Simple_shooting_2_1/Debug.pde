import com.jogamp.newt.event.awt.AWTKeyAdapter;

boolean Debug=false;
long RunTimeBuffer=0;
float EntityTime=0;
float DrawTime=0;

void Debug(){
  if(keyPress&&nowPressedKeyCode==99&&PressedKeyCode.contains("99")){
    Debug=!Debug;
  }
  if(Debug){
    String Text="";
    fill(255);
    textSize(15);
    textAlign(LEFT);
    pushMatrix();
    resetMatrix();
    for(int i=0;i<5;i++){
      switch(i){
        case 0:Text="RunTime(ms):"+(System.nanoTime()-RunTimeBuffer)/1000000f;break;
        case 1:Text="EntityDraw(ms):"+DrawTime;break;
        case 2:Text="EntityTime(ms):"+EntityTime;break;
        case 3:Text="EntityNumber:"+Entities.size();break;
        case 4:Text="Memory(MB)"+nf(((float)(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory()))/1048576f,0,3);break;
      }
      text(Text,30,100+i*20);
    }
    RunTimeBuffer=System.nanoTime();
    popMatrix();
  }
}
