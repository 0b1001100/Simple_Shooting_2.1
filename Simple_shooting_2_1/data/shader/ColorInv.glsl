uniform sampler2D tex;
uniform vec2 resolution;

void main(void){
  vec2 pos=vec2(gl_FragCoord.xy)/vec2(resolution.xy);
  vec4 color=vec4(texture2D(tex,pos));
  gl_FragColor = vec4(vec3(1.0) - vec3(color.xyz), 1.0);
}
