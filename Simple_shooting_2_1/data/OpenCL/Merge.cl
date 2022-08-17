__kernel void merge(__global int* input_pixel,__global int* output_pixel){
  if(get_global_id(2)==0){
    output_pixel[get_global_id(0)+get_global_size(0)*get_global_id(1)]=&input_pixel[get_global_id(0)+get_global_size(0)*get_global_id(1)];
  }else{
    atomic_add(&input_pixel[get_global_id(0)+get_global_size(0)*get_global_id(1)],input_pixel[get_global_id(0)+get_global_size(0)*get_global_id(1)+get_global_size(0)*get_global_size(1)*get_global_id(2)]);
  }
}