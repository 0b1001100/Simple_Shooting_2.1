ArrayList<AABBData>EntityDataX=new ArrayList<AABBData>();
ArrayList<ArrayList<AABBData>>HeapEntityDataX=new ArrayList<ArrayList<AABBData>>();
AABBData[]SortedDataX;

class Enemy extends Entity implements Cloneable{
  HashMap<Class<? extends Weapon>,Float>MultiplyerMap=new HashMap<Class<? extends Weapon>,Float>();
  PVector addtionalVel=new PVector();
  Weapon useWeapon=null;
  Weapon ShotWeapon=null;
  ItemTable dropTable;
  boolean inScreen=true;
  boolean hit=false;
  double damage=0;
  flo