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
    String Text="";
    fill(255);
    textSize(15);
    textAlign(LEFT);
    pushMatrix();
    resetMatrix();
    for(int i=0;i<5;i++){
      switch(i){
        case 0:Text="RunTime(ms):"+(System.nanoTime()-RunTimeBuffer)/1000000f;break;
        case 1:Text="ParticleTime(ms):"+ParticleTime;break;
        case 2:Text="BulletTime(ms):"+BulletTime;break;
        case 3:Text="EnemyTime(ms):"+EnemyTime;break;
        case 4:Text="EnemyNumber:"+Enemies.size();break;
      }
      text(Text,30,100+i*20);
    }
    RunTimeBuffer=System.nanoTime();
    popMatrix();
  }
}
