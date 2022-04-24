#define R_LUMINANCE 0.298912
#define G_LUMINANCE 0.586611
#define B_LUMINANCE 0.114478

uniform sampler2D tex;
uniform vec2 resolution;
const vec3 monochromeScale = vec3(R_LUMINANCE, G_LUMINANCE, B_LUMINANCE);

void main() {
  vec2 pos=vec2(gl_FragCoord)/resolution;
  vec4 color = texture2D(tex,pos);
  float grayColor = dot(color.rgb, monochromeScale);
  color = vec4(vec3(grayColor), 1.0);
  gl_FragColor = vec4(color);
}