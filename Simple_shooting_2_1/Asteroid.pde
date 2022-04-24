class Asteroid extends Entity{
  
}

class AsteroidBase{
  ArrayList<PVector>Vert;
  float size;
  
  AsteroidBase(ArrayList<PVector>Vert,float size){
    this.Vert=Vert;
    this.size=size;
  }
}
