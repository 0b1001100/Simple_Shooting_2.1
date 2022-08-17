uniform float time;
uniform vec2 xy;
uniform vec2 resolution;
uniform vec4 menuColor;
uniform sampler2D tex;

vec4 toScreen(float standard,vec4 col){
  return mix(menuColor*vec4(time/30),col,floor(standard));
}

void main(void){
  vec2 pos=vec2(gl_FragCoord);
  vec2 normPos=pos/resolution.xy;
  vec4 color=vec4(texture2D(tex,normPos));
  vec2 dist=vec2(floor(pos/(resolution/xy)));
  float scale=min(max(time*(xy.y/9)-(dist.x+(xy.y-dist.y)),0.0),1.0);
  gl_FragColor=vec4(toScreen(scale,color));
}