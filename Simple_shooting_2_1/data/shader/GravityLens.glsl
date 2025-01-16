uniform sampler2D input_texture;
uniform vec2 center[10];
uniform vec2 resolution;
uniform float g[10];
uniform int len;

void main(void){
  vec2 pos=gl_FragCoord.xy/resolution;
  bool black=false;
  for(int i=0;i<len;i++){
    vec2 dist=center[i]-gl_FragCoord.xy;
    float sqDist=dist.x*dist.x+dist.y*dist.y;
    float g2=g[i]*g[i];
    if(g2>sqDist){
      black=true;
      break;
    }
    pos=g2>sqDist?pos:pos+dist*(g2/sqDist)/resolution;
  }
  gl_FragColor=black?vec4(0.0, 0.0, 0.0, 1.0):texture2D(input_texture,pos);
}
