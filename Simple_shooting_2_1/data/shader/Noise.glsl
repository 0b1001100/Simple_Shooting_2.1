uniform float rand;
uniform vec2 resolution;
uniform sampler2D tex;

float random(vec2 co){
    return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void){
  vec2 pos=vec2(gl_FragCoord);
  vec4 color=texture2D(tex,(pos+vec2(4.)*rand*random(gl_FragCoord.xy))/resolution);
  gl_FragColor=vec4(color)+vec4(rand*0.43342,rand*-0.31877,rand*0.51241,0.0)*random(gl_FragCoord.xy)/4.0;
}