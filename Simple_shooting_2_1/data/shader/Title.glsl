uniform sampler2D tex;
uniform vec2[20] position;
uniform vec2 resolution;

void main(void){
  vec4 c=step(0.1,texture2D(tex,gl_FragCoord.xy/resolution.xy)*0.9)*texture2D(tex,gl_FragCoord.xy/resolution.xy)*0.9;
  for(int i=0;i<20;i++){
    float mag=pow(1.1/length(gl_FragCoord.xy-position[i]),3.0);
    c+=vec4(0.,mag*0.5,mag,0.);
  }
  gl_FragColor=c;
}