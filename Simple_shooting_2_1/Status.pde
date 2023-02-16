import java.math.*;

class Status{
  protected BigDecimal status;
  protected BigDecimal maxStatus;
  protected BigDecimal resetStatus;
  protected BigDecimal minStatus=new BigDecimal(0);
  
  Status(double s){
    status=new BigDecimal(s);
    maxStatus=new BigDecimal(s);
    resetStatus=new BigDecimal(s);
    maxStatus=isMin(maxStatus);
    status=isMin(isMax(status));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  Status(double s,double max,double reset){
    status=new BigDecimal(s);
    maxStatus=new BigDecimal(max);
    resetStatus=new BigDecimal(reset);
    maxStatus=isMin(maxStatus);
    status=isMin(isMax(status));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  public void add(double s){
    status=status.add(new BigDecimal(s));
    status=isMin(isMax(status));
  }
  
  public void addMax(double s){
    maxStatus=maxStatus.add(new BigDecimal(s));
    maxStatus=isMin(maxStatus);
  }
  
  public void addReset(double s){
    resetStatus=resetStatus.add(new BigDecimal(s));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  public void addMin(double s){
    minStatus=minStatus.add(new BigDecimal(s));
    minStatus=isMax(minStatus);
  }
  
  public void sub(double s){
    status=status.subtract(new BigDecimal(s));
    status=isMin(isMax(status));
  }
  
  public void subMax(double s){
    maxStatus=maxStatus.subtract(new BigDecimal(s));
    maxStatus=isMin(maxStatus);
    status=isMax(status);
  }
  
  public void subReset(double s){
    resetStatus=resetStatus.subtract(new BigDecimal(s));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  public void subMin(double s){
    minStatus=minStatus.subtract(new BigDecimal(s));
    minStatus=isMax(minStatus);
  }
  
  public void set(double s){
    status=new BigDecimal(s);
    status=isMin(isMax(status));
  }
  
  public void setMax(double s){
    maxStatus=new BigDecimal(s);
    maxStatus=isMin(maxStatus);
  }
  
  public void setReset(double s){
    resetStatus=new BigDecimal(s);
    resetStatus=isMin(isMax(resetStatus));
  }
  
  public void setMin(double s){
    minStatus=new BigDecimal(s);
    minStatus=isMax(minStatus);
  }
  
  BigDecimal get(){
    return new BigDecimal(status.toString());
  }
  
  BigDecimal getMax(){
    return new BigDecimal(maxStatus.toString());
  }
  
  BigDecimal getReset(){
    return new BigDecimal(resetStatus.toString());
  }
  
  BigDecimal getMin(){
    return new BigDecimal(minStatus.toString());
  }
  
  Long maxLongValue(){
    return maxStatus.longValue();
  }
  
  Double maxDoubleValue(){
    return maxStatus.doubleValue();
  }
  
  String toString(){
    return status.toString();
  }
  
  float getPercentage(){
    return !status.equals(new BigDecimal(0)) ? status.divide(maxStatus,6,RoundingMode.FLOOR).floatValue():0;
  }
  
  public void reset(){
    status=new BigDecimal(resetStatus.toString());
  }
  
  private BigDecimal isMax(BigDecimal b){
    return new BigDecimal(maxStatus.min(b).toString());
  }
  
  private BigDecimal isMin(BigDecimal b){
    return new BigDecimal(minStatus.max(b).toString());
  }
}

class StatusManage{
  protected Myself m;
  protected float maxTime=0;
  protected float time=0;
  double addDefence=0;
  double addAttak=0;
  double addHP=0;
  boolean isEnd=false;
  
  final float INFINITY=-0xFFFF;
  
  StatusManage(Myself m){
    this.m=m;
    time=INFINITY;
  }
  
  StatusManage setTime(float t){
    maxTime=t;
    time=t;
    return this;
  }
  
  StatusManage setDefence(double d){
    m.Defence.subMax(addDefence);
    m.Defence.addMax(d);
    addDefence=d;
    return this;
  }
  
  StatusManage setAttak(double d){
    m.Attak.subMax(addAttak);
    m.Attak.addMax(d);
    addAttak=d;
    return this;
  }
  
  StatusManage setHP(double d){
    m.HP.subMax(addHP);
    m.HP.addMax(d);
    addHP=d;
    return this;
  }
  
  StatusManage setDefencePercent(double d){
    m.Defence.subMax(addDefence);
    m.Defence.addMax(m.absHP*constrain((float)d,0,1));
    addDefence=m.absHP*constrain((float)d,0,1);
    return this;
  }
  
  StatusManage setAttakPercent(double d){
    m.Attak.subMax(addAttak);
    m.Attak.addMax(d);
    addAttak=d;
    return this;
  }
  
  StatusManage setHPPercent(double d){
    m.HP.subMax(addHP);
    m.HP.addMax(d);
    addHP=d;
    return this;
  }
  
  float getMaxTime(){
    return maxTime;
  }
  
  float getTime(){
    return time;
  }
  
  public void update(){
    if(time>0){
      time-=vectorMagnification/60;
    }
    if(time!=-0xFFFF&time<=0){
      removeEffect();
      isEnd=true;
    }
  }
  
  public void removeEffect(){
    m.HP.subMax(addDefence);
    m.HP.subMax(addAttak);
    m.HP.subMax(addHP);
  }
}
