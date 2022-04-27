import com.jogamp.newt.event.awt.AWTKeyAdapter;

boolean Debug=false;
long RunTimeBuffer=0;
float ParticleTime=0;
float BulletTime=0;
float EnemyTime=0;

void Debug(){
  if(keyPress&&nowPressedKeyCode==99&&PressedKeyCode.contains("99")){
    Debug=!Debug;
  }
  if(Debug){
    String Time="";
    fill(255);
    textSize(15);
    textAlign(LEFT);
    pushMatrix();
    resetMatrix();
    for(int i=0;i<4;i++){
      switch(i){
        case 0:Time="RunTime(ms):"+(System.nanoTime()-RunTimeBuffer)/1000000f;break;
        case 1:Time="ParticleTime(ms):"+ParticleTime;break;
        case 2:Time="BulletTime(ms):"+BulletTime;break;
        case 3:Time="EnemyTime(ms):"+EnemyTime;break;
      }
      text(Time,30,100+i*20);
    }
    RunTimeBuffer=System.nanoTime();
    popMatrix();
  }
}
