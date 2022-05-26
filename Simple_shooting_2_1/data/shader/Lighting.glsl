uniform float mag;
uniform vec2 resolution;
uniform sampler2D texture;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void){
  vec2 pos=vec2(gl_FragCoord)/resolution;
  vec2 norm=vec2(1.,1.)/resolution;
  vec4 c=vec4(texture2D(texture,pos));
  vec4 blend=vec4(0.);
  blend=max(blend,vec4(texture2D(texture,pos+vec2(0.,norm.y))));
  blend=max(blend,0.7*vec4(texture2D(texture,pos+norm)));
  blend=max(blend,vec4(texture2D(texture,pos+vec2(norm.x,0))));
  blend=max(blend,0.7*vec4(texture2D(texture,pos+vec2(norm.x,-norm.y))));
  blend=max(blend,vec4(texture2D(texture,pos+vec2(0.,-norm.y))));
  blend=max(blend,0.7*vec4(texture2D(texture,pos-norm)));
  blend=max(blend,vec4(texture2D(texture,pos+vec2(-norm.x,0.))));
  blend=max(blend,0.7*vec4(texture2D(texture,pos+vec2(-norm.x,norm.y))));
  gl_FragColor=max(c,blend*0.15);
}