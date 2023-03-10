ItemTable masterTable=new ItemTable();
ItemTable playerTable=new ItemTable();
HashMap<String,JSONArray>nextDataMap=new HashMap<String,JSONArray>();
JSONObject UpgradeArray;
int sumLevel=0;

public Item build(JSONObject o,String type){
  Item i=null;
  switch(type){
    case "weapon":i=new Weapon_Item(o,type);break;
    case "item":i=new Item_Item(o,type);break;
    case "next_weapon":i=new NextWeapon_Item(o,type);break;
  }
  return i;
}

abstract class Item{
  protected SubWeapon w;
  protected JSONObject initData;
  protected JSONArray upgradeData;
  protected JSONArray nextData;
  protected PImage image;
  protected String nextName="";
  protected String name="";
  protected String type;
  protected float data;
  protected int weight=0;
  protected int level=1;
  protected int maxLevel=1;
  
  Item(JSONObject o,String type){
    initData=o;
    name=o.getString("name");
    weight=o.getInt("weight");
    maxLevel=o.getInt("maxLevel");
    init(o,type);
    if(!nextName.equals("undefined")){
      nextData=o.getJSONObject("nextWeapon").getJSONArray("need");
      nextDataMap.put(nextName,nextData);
    }
    upgradeData=UpgradeArray.getJSONArray(name);
    this.type=type;
  }
  
  public abstract void update();
   
  public abstract void init(JSONObject o,String type);
   
  public abstract boolean isAddNext(Item i);
  
  public void checkNext(){
    if(nextName.equals("undefined")||playerTable.contains(nextName)||player.attackWeapons.contains(masterTable.get(nextName).getWeapon()))return;
    if(upgradeData!=null&&level==maxLevel){
      for(int i=0;i<nextData.size();i++){
        JSONObject o=nextData.getJSONObject(i);
        Item it=playerTable.getForce(o.getString("name"));//it->need weapons
        if(!isAddNext(it))return;
      }
      if(main_game.EventSet.containsKey("addNextWeapon")){
        main_game.EventSet.replace("addNemtWeapon",main_game.EventSet.get("addNextWeapon")+"_"+nextName);
      }else{
        main_game.EventSet.put("addNextWeapon",nextName);
      }
    }
  }
  
   public void reset(){
    level=1;
    weight=initData.getInt("weight");
    w.init(initData);
  }
  
   public JSONArray getUpgradeArray(){
    return upgradeData;
  }
  
   public SubWeapon getWeapon(){
    return w;
  }
  
   public String getName(){
    return name;
  }
  
   public String getType(){
    return type;
  }
  
   public int getWeight(){
    return weight;
  }
  
   public float getData(){
    return data;
  }
  
   public float getData(int i){
    return upgradeData.getJSONObject(i-2).getFloat("value");
  }
}

class Weapon_Item extends Item{
  
  Weapon_Item(JSONObject o,String type){
    super(o,type);
  }
  
  @Override
  public void init(JSONObject o,String type){
    try{
      w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
    }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
    nextName=o.getJSONObject("nextWeapon").getString("name");
  }
  
  @Override
   public void update() throws NullPointerException{
    if(upgradeData!=null&&level>1&&level<=maxLevel){
      w.upgrade(upgradeData,level);
      JSONObject add=upgradeData.getJSONObject(level-2);
      HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").toStringArray()));
      if(param.contains("weight")){
        weight=upgradeData.getJSONObject(level-2).getInt("weight");
        playerTable.addTable(this,weight);
      }
    }
  }
  
  @Override
  public boolean isAddNext(Item i){
    return player.attackWeapons.contains(i.w)&&(i.level==i.maxLevel);
  }
}

class Item_Item extends Item{
  
  Item_Item(JSONObject o,String type){
    super(o,type);
  }
  
  @Override
  public void init(JSONObject o,String type){
    try{
      w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
    }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
    nextName="undefined";
  }
  
  @Override
   public void update() throws NullPointerException{
    if(upgradeData!=null&&level>1&&level<=maxLevel){
      w.upgrade(upgradeData,level);
      JSONObject add=upgradeData.getJSONObject(level-2);
      HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").toStringArray()));
      if(param.contains("weight")){
        weight=upgradeData.getJSONObject(level-2).getInt("weight");
        playerTable.addTable(this,weight);
      }
    }
  }
  
  @Override
  public boolean isAddNext(Item i){
    return player.attackWeapons.contains(i.w);
  }
}

class NextWeapon_Item extends Item{
  
  NextWeapon_Item(JSONObject o,String type){
    super(o,type);
  }
  
  @Override
  public void init(JSONObject o,String type){
    try{
      w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
    }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
    nextName=o.getJSONObject("nextWeapon").getString("name");
  }
  
  @Override
   public void update() throws NullPointerException{
    if(!player.attackWeapons.contains(this.w)){
      if(main_game.EventSet.containsKey("getNextWeapon")){
        main_game.EventSet.replace("getNextWeapon",main_game.EventSet.get("getNextWeapon")+"_"+name);
      }else{
        main_game.EventSet.put("getNextWeapon",name);
      }
      if(upgradeData==null){
        weight=0;
      }
    }
    if(upgradeData!=null&&level>1&&level<=maxLevel){
      ++level;
      w.upgrade(upgradeData,level);
      JSONObject add=upgradeData.getJSONObject(level-2);
      HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").toStringArray()));
      if(param.contains("weight")){
        weight=upgradeData.getJSONObject(level-2).getInt("weight");
        playerTable.addTable(this,weight);
      }
    }
  }
  
  @Override
  public boolean isAddNext(Item i){
    return player.attackWeapons.contains(i.w);
  }
}

class ItemTable implements Cloneable{
  LinkedHashMap<String,Item>table;
  HashMap<String,Float>prob;
  
  ItemTable(){
    table=new LinkedHashMap<String,Item>();
    prob=new HashMap<String,Float>();
  }
  
  ItemTable(Item[]items){
    table=new LinkedHashMap<String,Item>();
    for(Item i:items){
      table.put(i.getName(),i);
    }
    prob=new HashMap<String,Float>();
  }
  
   public void addItem(Item i){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
    }
  }
  
   public void addItem(ItemTable t){
    for(Item i:t.table.values()){
      if(!table.containsKey(i.getName())){
        table.put(i.getName(),i);
      }
    }
  }
  
   public void addTable(Item i,float prob){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      this.prob.put(i.getName(),prob);
    }else{
      this.prob.replace(i.getName(),prob);
    }
    float sum=0;
    for(float f:this.prob.values()){
      sum+=f;
    }
    for(String s:this.prob.keySet()){
      this.prob.replace(s,sum==0?0:(this.prob.get(s)/sum*100));
    }
  }
  
   public void removeTable(String name){
    if(table.containsKey(name)){
      table.remove(name);
      this.prob.remove(name);
    }else{
      return;
    }
    float sum=0;
    for(float f:this.prob.values()){
      sum+=f;
    }
    for(String s:this.prob.keySet()){
      this.prob.replace(s,sum==0?0:this.prob.get(s)/sum*100);
    }
  }
  
  public Item get(String s){
    return prob.containsKey(s)?prob.get(s)>0?table.get(s):null:null;
  }
  
  public Item getForce(String s){
    return table.get(s);
  }
  
  public AttackWeapon getWeapon(String s){
    return prob.containsKey(s)?prob.get(s)>0?(AttackWeapon)table.get(s).getWeapon():null:null;
  }
  
  public ItemWeapon getItem(String s){
    return prob.containsKey(s)?prob.get(s)>0?(ItemWeapon)table.get(s).getWeapon():null:null;
  }
  
   public Item getRandom(){
    float rand=random(0,100);
    float sum=0;
    for(String s:prob.keySet()){
      if(sum<=rand&rand<sum+prob.get(s))return table.get(s);
      sum+=prob.get(s);
    }
    return null;
  }
  
  protected Item getRandom(HashMap<String,Float>prob){
    float rand=random(0,100);
    float sum=0;
    for(String s:prob.keySet()){
      if(sum<=rand&rand<sum+prob.get(s))return table.get(s);
      sum+=prob.get(s);
    }
    return null;
  }
  
   public Item getRandomWeapon(){
    HashMap<String,Float>p=new HashMap<String,Float>();
    for(String s:table.keySet()){
      if(table.get(s).type.equals("item"))continue;
      p.put(s,prob.get(s));
    }
    float sum=0;
    for(float f:p.values()){
      sum+=f;
    }
    for(String s:p.keySet()){
      p.replace(s,sum==0?0:(p.get(s)/sum*100));
    }
    return getRandom(p);
  }
  
   public Item getRandomItem(){
    HashMap<String,Float>p=new HashMap<String,Float>();
    for(String s:table.keySet()){
      if(!table.get(s).type.equals("item"))continue;
      p.put(s,prob.get(s));
    }
    float sum=0;
    for(float f:p.values()){
      sum+=f;
    }
    for(String s:p.keySet()){
      p.replace(s,sum==0?0:(p.get(s)/sum*100));
    }
    return getRandom(p);
  }
  
   public java.util.Collection<Item> getAll(){
    return table.values();
  }
  
   public ItemTable clone(){
    ItemTable New=new ItemTable();
    New.table.putAll(table);
    New.prob.putAll(prob);
    return New;
  }
  
   public void clear(){
    table.clear();
    prob.clear();
  }
  
   public int tableSize(){
    return table.size();
  }
  
   public int probSize(){
    ArrayList<String> l=new ArrayList<String>();
    prob.forEach((k,v)->{
      if(v>0)l.add(k);
    });
    return l.size();
  }
  
   public boolean contains(String s){
    return table.containsKey(s);
  }
}

interface ItemUseEvent{
  public void ItemUse(Myself m);
}
