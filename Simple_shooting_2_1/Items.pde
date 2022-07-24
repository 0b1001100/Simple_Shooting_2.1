ItemTable masterTable=new ItemTable();
ItemTable playerTable=new ItemTable();
JSONObject UpgradeArray;
int sumLevel=0;

class Item{
  protected SubWeapon w;
  protected JSONObject initData;
  protected JSONArray upgradeData;
  protected PImage image;
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
                    }catch(InstantiationException|IllegalAccessException|InvocationTargetException g){g.printStackTrace();}break;
      case "item":data=o.getFloat("value");break;
    }
    upgradeData=UpgradeArray.getJSONArray(name);
    this.type=type;
  }
  
  void update(){
    if(level>1){
      if(type.equals("weapon")){
        w.upgrade(upgradeData,level);
        JSONObject add=upgradeData.getJSONObject(level-2);
        HashSet<String>param=new HashSet<String>(Arrays.asList(add.getJSONArray("name").getStringArray()));
        if(param.contains("weight")){
          weight=upgradeData.getJSONObject(level-2).getInt("weight");
          playerTable.addTable(this,weight);
        }
      }else if(type.equals("item")){
        if(Arrays.asList(upgradeData.getJSONObject(level-2).getJSONArray("name").getStringArray()).contains("weight")){
          weight=upgradeData.getJSONObject(level-2).getInt("weight");
          playerTable.addTable(this,weight);
        }
      }
    }
  }
  
  void reset(){
    level=1;
    if(type.equals("weapon"))w.init(initData);
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
  
  String getType(){
    return type;
  }
  
  int getWeight(){
    return weight;
  }
  
  float getData(){
    return data;
  }
  
  float getData(int i){
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
  
  Item getRandomWeapon(){
    while(true){
      Item i=getRandom();
      if(i.type.equals("weapon"))return i;
    }
  }
  
  Item getRandomItem(){
    while(true){
      Item i=getRandom();
      if(i.type.equals("item"))return i;
    }
  }
  
  java.util.Collection<Item> getAll(){
    return table.values();
  }
  
  ItemTable clone(){
    ItemTable New=new ItemTable();
    New.table.putAll(table);
    New.prob.putAll(prob);
    return New;
  }
  
  int tableSize(){
    return table.size();
  }
  
  int probSize(){
    ArrayList<String> l=new ArrayList<String>();
    prob.forEach((k,v)->{
      if(v>0)l.add(k);
    });
    return l.size();
  }
}

interface ItemUseEvent{
  void ItemUse(Myself m);
}
