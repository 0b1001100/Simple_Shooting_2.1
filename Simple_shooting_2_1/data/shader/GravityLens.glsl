uniform sampler2D texture;
uniform vec2 center;
uniform vec2 resolution;
uniform float g;

void main(void){
  vec2 pos=vec2(gl_FragCoord)/resolution;
  vec2 dist=center-vec2(gl_FragCoord);
  float sqDist=dist.x*dist.x+dist.y*dist.y;
  gl_FragColor=g*g>sqDist?vec4(0.0, 0.0, 0.0, 1.0):texture2D(texture,pos+dist*(g*g/sqDist)/resolution);
}