ItemTable masterTable=new ItemTable();
ItemTable playerTable=new ItemTable();
JSONObject UpgradeArray;

class Item{
  protected SubWeapon w;
  protected JSONArray upgradeData;
  protected PImage image;
  protected String name="";
  protected String type;
  protected int weight=0;
  protected int level=0;
  
  Item(JSONObject o,String type){
    name=o.getString("name");
    weight=o.getInt("weight");
    switch(type){
      case "weapon":try{
                      w=(SubWeapon)WeaponConstructor.get(name).newInstance(CopyApplet,o);
                    }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}break;
      case "Item":break;
    }
    upgradeData=UpgradeArray.getJSONArray(name);
    this.type=type;
  }
  
  void update(){
    if(level>1){
      w.upgrade(upgradeData,level);
      JSONObject add=upgradeData.getJSONObject(level-2);
      HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").getStringArray()));
      if(param.contains("weight")){
        weight=upgradeData.getJSONObject(level-2).getInt("weight");
      }
    }
  }
  
  JSONArray getUpgradeArray(){
    return upgradeData;
  }
  
  SubWeapon getWeapon(){
    return w;
  }
  
  String getName(){
    return name;
  }
  
  int getWeight(){
    return weight;
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
  
  void addItem(Item i){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
    }
  }
  
  void addItem(ItemTable t){
    for(Item i:t.table.values()){
      if(!table.containsKey(i.getName())){
        table.put(i.getName(),i);
      }
    }
  }
  
  void addTable(Item i,float prob){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      this.prob.put(i.getName(),constrain(prob,0,100));
    }else{
      this.prob.replace(i.getName(),constrain(prob,0,100));
    }
    float sum=0;
    for(float f:this.prob.values()){
      sum+=f;
    }
    for(String s:this.prob.keySet()){
      this.prob.replace(s,sum==0?0:this.prob.get(s)/sum*100);
    }
  }
  
  void removeTable(String name){
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
  
  Item get(String s){
    return table.get(s);
  }
  
  Item getRandom(){
    float rand=random(0,100);
    float sum=0;
    for(String s:prob.keySet()){
      if(sum<=rand&rand<sum+prob.get(s))return table.get(s);
      sum+=prob.get(s);
    }
    return null;
  }
  
  ItemTable clone(){
    ItemTable New=new ItemTable();
    New.table.putAll(table);
    New.prob.putAll(prob);
    return New;
  }
}

interface ItemUseEvent{
  void ItemUse(Myself m);
}
