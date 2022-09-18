ItemTable masterTable=new ItemTable();
ItemTable playerTable=new ItemTable();
HashMap<String,JSONArray>nextDataMap=new HashMap<String,JSONArray>();
JSONObject UpgradeArray;
int sumLevel=0;

class Item{
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
  
  Item(JSONObject o,String type){
    initData=o;
    name=o.getString("name");
    weight=o.getInt("weight");
    switch(type){
      case "weapon":try{
                      w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
                    }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
                    nextName=o.getJSONObject("nextWeapon").getString("name");
                    if(!nextName.equals("undefined")){
                      nextData=o.getJSONObject("nextWeapon").getJSONArray("need");
                      nextDataMap.put(nextName,nextData);
                    }break;
      case "item":try{
                    w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
                  }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
                  nextName="undefined";break;
      case "next_weapon":try{
                           w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
                         }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}
                         nextName=o.getJSONObject("nextWeapon").getString("name");
                         if(!nextName.equals("undefined")){
                           nextData=o.getJSONObject("nextWeapon").getJSONArray("need");
                           nextDataMap.put(nextName,nextData);
                         }break;
    }
    upgradeData=UpgradeArray.getJSONArray(name);
    this.type=type;
  }
  
   public void update() throws NullPointerException{
    if(type.equals("next_weapon")&&!player.subWeapons.contains(this.w)){
      if(main.EventSet.containsKey("getNextWeapon")){
        main.EventSet.replace("getNextWeapon",main.EventSet.get("getNextWeapon")+"_"+name);
      }else{
        main.EventSet.put("getNextWeapon",name);
      }
      if(upgradeData==null){
        weight=0;
      }
    }
    if(upgradeData!=null&&level>1&&level-1<=upgradeData.size()){
      if(!type.equals("next_weapon")){//println(name,upgradeData);
        w.upgrade(upgradeData,level);
        JSONObject add=upgradeData.getJSONObject(level-2);
        HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").getStringArray()));
        if(param.contains("weight")){
          weight=upgradeData.getJSONObject(level-2).getInt("weight");
          playerTable.addTable(this,weight);
        }
      }else if(type.equals("next_weapon")){
        ++level;
        w.upgrade(upgradeData,level);
        JSONObject add=upgradeData.getJSONObject(level-2);
        HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").getStringArray()));
        if(param.contains("weight")){
          weight=upgradeData.getJSONObject(level-2).getInt("weight");
          playerTable.addTable(this,weight);
        }
      }
    }
  }
  
   public void checkNext(){
    if(nextName.equals("undefined")||playerTable.contains(nextName)||player.subWeapons.contains(masterTable.get(nextName).getWeapon()))return;
    if(upgradeData!=null&&level-1==upgradeData.size()){
      for(int i=0;i<nextData.size();i++){
        JSONObject o=nextData.getJSONObject(i);
        Item it=playerTable.get(o.getString("name"));
        switch(it.type){
          case "weapon":if(!player.subWeapons.contains(it.w)||!(it.level-1==it.upgradeData.size()))return;break;
          case "item":if(!player.subWeapons.contains(it.w))return;break;
          case "next_weapon":if(!player.subWeapons.contains(it.w))return;break;
        }
      }
      if(main.EventSet.containsKey("addNextWeapon")){
        main.EventSet.replace("addNemtWeapon",main.EventSet.get("addNextWeapon")+"_"+nextName);
      }else{
        main.EventSet.put("addNextWeapon",nextName);
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
    return table.get(s);
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
  void ItemUse(Myself m);
}
