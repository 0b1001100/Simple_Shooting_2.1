__kernel void Main(float mag,__global float* px,__global float* py,__global float* vx,__global float* vy){
  int i=get_global_id(0);
  px[i]+=vx[i]*mag;
  py[i]+=vy[i]*mag;
}