class Stage{
  HashMap<String,ArrayList<TimeSchedule>> t;
  ArrayList<SpownPoint>spown;
  ArrayList<Enemy>autoEnemy;
  boolean displaySpown=false;
  boolean endSchedule=false;
  String name;
  int frag=0;
  int score=0;
  float time=0;
  float freq=0;
  
  Stage(){
    t=new HashMap<String,ArrayList<TimeSchedule>>();
    spown=new ArrayList<SpownPoint>();
    autoEnemy=new ArrayList<Enemy>();
    score=0;
    time=0;
    name="1.1";
  }
  
  void addProcess(String name,TimeSchedule... t){
    if(this.t.get(name)==null)this.t.put(name,new ArrayList<TimeSchedule>());
    this.t.get(name).addAll(Arrays.asList(t));
  }
  
  void addSpown(EnemySpown s,float offset,Enemy e){
    addSpown(s,offset,120,e);
  }
  
  void addSpown(EnemySpown s,float offset,float t,Enemy e){
    int number=0;
    switch(s){
      case Single:spown.add(new SpownPoint(player.pos.copy(),t,e));return;
      case Double:number=2;break;
      case Triangle:number=3;break;
      case Rect:number=4;break;
      case Pentagon:number=5;break;
      case Hexagon:number=6;break;
      case Heptagon:number=7;break;
      case Octagon:number=8;break;
      case Nonagon:number=9;break;
      case Decagon:number=10;break;
    }
    float r=TWO_PI/number;
    try{
      for(int i=0;i<number;i++){
        spown.add(new SpownPoint(player.pos.copy().add(new PVector(e.size*4*cos(r*i+offset+HALF_PI),-e.size*4*sin(r*i+offset+HALF_PI))),t,e.clone()));
      }
    }catch(CloneNotSupportedException f){}
  }
  
  void addSpown(int n,float dist,float offset,Enemy e){
    addSpown(n,dist,offset,120,e);
  }
  
  void addSpown(int n,float dist,float offset,float t,Enemy e){
    float r=TWO_PI/n;
    try{
      for(int i=0;i<n;i++){
        spown.add(new SpownPoint(player.pos.copy().add(new PVector(e.size*4*dist*cos(r*i+offset+HALF_PI),-e.size*4*dist*sin(r*i+offset+HALF_PI))),t,e.clone()));
      }
    }catch(CloneNotSupportedException f){}
  }
  
  void autoSpown(boolean b,float freq,Enemy... e){
    this.freq=freq;
    displaySpown=b;
    autoEnemy.clear();
    autoEnemy.addAll(Arrays.asList(e));
  }
  
  void display(){
    spown.forEach(s->{s.display();});
  }
  
  void update(){
    if(freq!=0&&random(0,1)<freq){
      float r=TWO_PI*random(0,1);
      PVector v=new PVector(cos(r)*(width+height),sin(r)*(width+height));
      for(int i=0;i<4;i++){
        PVector p=new PVector();
        switch(i){
          case 0:p=SegmentCrossPoint(player.pos.copy().sub(width/2,height/2),new PVector(width,0),player.pos.copy(),v);break;
          case 1:p=SegmentCrossPoint(player.pos.copy().sub(width/2,-height/2),new PVector(width,0),player.pos.copy(),v);break;
          case 2:p=SegmentCrossPoint(player.pos.copy().sub(width/2,height/2),new PVector(0,height),player.pos.copy(),v);break;
          case 3:p=SegmentCrossPoint(player.pos.copy().sub(width/2,-height/2),new PVector(0,height),player.pos.copy(),v);break;
        }
        if(p!=null){
          v=p;
          break;
        }
      }
      try{
        Enemy e=autoEnemy.get(round(random(0,autoEnemy.size()-1))).clone();
        if(displaySpown){
          spown.add(new SpownPoint(v.add(cos(r)*e.size,sin(r)*e.size),e));
        }else{
          EnemyHeap.add(e.setPos(v.add(cos(r)*e.size,sin(r)*e.size)));
        }
      }catch(CloneNotSupportedException f){}
    }
    TimeSchedule T=t.get(name).get(frag);
    if(time>T.getTime()){
      T.getProcess().Process(this);
      if(!endSchedule)++frag;
    }
    ArrayList<SpownPoint>nextSpown=new ArrayList<SpownPoint>(spown.size());
    spown.forEach(s->{
      s.update();
      if(!s.isDead)nextSpown.add(s);
    });
    spown=nextSpown;
    time+=vectorMagnification;
  }
}

class SpownPoint{
  Enemy e;
  boolean isDead=false;
  PVector pos;
  float time;
  
  SpownPoint(PVector pos,Enemy e){
    this.pos=pos;
    time=120;
    this.e=e;
  }
  
  SpownPoint(PVector pos,float time,Enemy e){
    this.pos=pos;
    this.time=time;
    this.e=e;
  }
  
  void display(){
    float t=time%25/25;
    noFill();
    strokeWeight(1);
    stroke((int)(255*t),0,0);
    ellipse(pos.x,pos.y,e.size*t*0.7,e.size*t*0.7);
  }
  
  void update(){
    time-=vectorMagnification;
    if(time<0){
      isDead=true;
      e.setPos(pos);
      EnemyHeap.add(e);
    }
  }
}

class TimeSchedule{
  float time;
  StageProcess p;
  
  TimeSchedule(float time,StageProcess p){
    this.time=time;
    this.p=p;
  }
  
  float getTime(){
    return time;
  }
  
  StageProcess getProcess(){
    return p;
  }
}

enum EnemySpown{
  Single,
  Double,
  Triangle,
  Rect,
  Pentagon,
  Hexagon,
  Heptagon,
  Octagon,
  Nonagon,
  Decagon
}

interface StageProcess{
  void Process(Stage s);
}
