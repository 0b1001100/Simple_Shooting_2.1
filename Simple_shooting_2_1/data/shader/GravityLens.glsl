uniform sampler2D input_texture;
uniform vec2 center[10];
uniform vec2 resolution;
uniform float g[10];
uniform int len;

void main(void){
  vec2 pos=vec2(gl_FragCoord)/resolution;
  bool black=false;
  for(int i=0;i<len;i++){
    vec2 dist=center[i]-vec2(gl_FragCoord);
    float sqDist=dist.x*dist.x+dist.y*dist.y;
    pos=g[i]*g[i]<length(dist)?pos:pos+dist*(g[i]*g[i]/sqDist)/resolution;
    if(g[i]*g[i]>sqDist){
      black=true;
      break;
    }
  }
  gl_FragColor=black?vec4(0.0, 0.0, 0.0, 1.0):texture2D(input_texture,pos);
}
