class Item{
  protected ItemUseEvent e=(m)->{};
  protected PImage image;
  protected String name="";
  String explanation="";
  float recovoryPercent=0;
  float recovory=0;
  int maxStack=99;
  int type=1;
  
  protected final int USEABLE=1;
  protected final int MATERAL=2;
  protected final int EQUIP=3;
  protected final int COLLECTION=4;
  
  Item(String name){
    this.name=name;
  }
  
  Item(String name,int type){
    this.type=type;
    this.name=name;
  }
  
  Item(int max,String name){
    maxStack=max;
    this.name=name;
  }
  
  Item(int max,String name,int type){
    maxStack=max;
    this.type=type;
    this.name=name;
  }
  
  String getName(){
    return name;
  }
  
  String getExplanation(){
    return explanation;
  }
  
  int getType(){
    return type;
  }
  
  float getRecovory(){
    return recovory!=0?recovory:player.HP.getMax().floatValue()*recovoryPercent;
  }
  
  Item setType(int i){
    type=i;
    return this;
  }
  
  Item setRecovory(float f){
    recovoryPercent=0;
    recovory=f;
    return this;
  }
  
  Item setRecovoryPercent(float f){
    recovoryPercent=f;
    recovory=0;
    return this;
  }
  
  Item setExplanation(String s){
    explanation=s;
    return this;
  }
  
  Item setExplanation(String s,float len){
    String e="";
    float l=0;
    for(char c:s.toCharArray()){
      l+=g.textFont.width(c)*15;
      if((l>len|c=='\n')&c!=','&c!='.'&c!='、'&c!='。'){
        l=0;
        e+=c=='\n'?"":"\n";
        e+=c;
      }else{
        e+=c;
      }
    }
    explanation=e;
    return this;
  }
  
  Item addListener(ItemUseEvent e){
    this.e=e;
    return this;
  }
  
  void ExecuteEvent(){
    e.ItemUse(player);
    player.HP.add(recovory!=0?recovory:player.HP.getMax().floatValue()*recovoryPercent);
  }
}

class ItemTable implements Cloneable{
  LinkedHashMap<String,Item>table;
  HashMap<String,Float>prob;
  HashMap<String,Integer>num;
  
  ItemTable(){
    table=new LinkedHashMap<String,Item>();
    prob=new HashMap<String,Float>();
    num=new HashMap<String,Integer>();
  }
  
  ItemTable(String[]names){
    table=new LinkedHashMap<String,Item>();
    num=new HashMap<String,Integer>();
    for(String s:names){
      table.put(s,new Item(s));
      num.put(s,0);
    }
    prob=new HashMap<String,Float>();
  }
  
  ItemTable(ArrayList<String>names){
    table=new LinkedHashMap<String,Item>();
    num=new HashMap<String,Integer>();
    for(String s:names){
      table.put(s,new Item(s));
      num.put(s,0);
    }
    prob=new HashMap<String,Float>();
  }
  
  ItemTable(Item[]items){
    table=new LinkedHashMap<String,Item>();
    num=new HashMap<String,Integer>();
    for(Item i:items){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
    }
    prob=new HashMap<String,Float>();
  }
  
  void addItem(Item i){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
    }
  }
  
  void addItem(ItemTable t){
    for(Item i:t.table.values()){
      if(!table.containsKey(i.getName())){
        table.put(i.getName(),i);
        num.put(i.getName(),0);
      }
    }
  }
  
  void addTable(Item i,float prob){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
      this.prob.put(i.getName(),constrain(prob,0,100));
    }else{
      this.prob.put(i.getName(),prob);
    }
  }
  
  boolean addStorage(Item i){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
      int n=num.get(i.getName())+1;
      if(n>i.maxStack)return false;
      num.put(i.getName(),max(0,n));
      return true;
    }else{
      int n=num.get(i.getName())+1;
      if(n>i.maxStack)return false;
      num.put(i.getName(),max(0,n));
      return true;
    }
  }
  
  int addStorage(Item i,int number){
    int ri=0;
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
      int n=num.get(i.getName())+number;
      if(n>i.maxStack){
        ri=n-i.maxStack;
        n=i.maxStack;
      }
      num.put(i.getName(),max(0,n));
      return ri;
    }else{
      int n=num.get(i.getName())+number;
      if(n>i.maxStack){
        ri=n-i.maxStack;
        n=i.maxStack;
      }
      num.put(i.getName(),max(0,n));
      return ri;
    }
  }
  
  boolean removeStorage(String name,int num){
    if(table.containsKey(name)){
      int n=this.num.get(name)-num;
      boolean b=true;
      if(n<=0){
        table.remove(name);
        this.num.remove(name);
        b=false;
      }else{
        this.num.put(name,n);
      }
      return b;
    }
    return false;
  }
  
  Item get(String s){
    return table.get(s);
  }
  
  int getNumber(Item i){
    if(table.containsKey(i.getName())){
      return num.get(i.getName());
    }else{
      return -1;
    }
  }
  
  Item getRandom(){
    for(String s:prob.keySet()){
      float rand=random(0,100);
      if(0<=rand&rand<prob.get(s))return table.get(s);
    }
    return null;
  }
  
  ItemTable clone(){
    try{
      return (ItemTable)super.clone();
    }catch(CloneNotSupportedException e){
      return new ItemTable();
    }
  }
}

interface ItemUseEvent{
  void ItemUse(Myself m);
}
