#version 430
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

uniform vec2 resolution;

layout(std430, binding = 0) buffer pixels
{
  int pixel[];
};

void main(void){
  const vec3 index=gl_GlobalInvocationID.xyz;
  pixel[int(index.x+index.y*resolution.x)]+=index.z>0?pixel[int(index.x+index.y*resolution.x+index.z*resolution.x*resolution.y)]:0;
}