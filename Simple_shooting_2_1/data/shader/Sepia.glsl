#define R_LUMINANCE 0.298912
#define G_LUMINANCE 0.586611
#define B_LUMINANCE 0.114478

uniform sampler2D tex;
uniform vec2 resolution;

void main() {
  vec2 pos=vec2(gl_FragCoord)/resolution;
  vec4 color = texture2D(tex,pos);
  float v = color.x * R_LUMINANCE + color.y * G_LUMINANCE + color.z * B_LUMINANCE;
  color.x = v * 0.9;
  color.y = v * 0.7;
  color.z = v * 0.4;
  gl_FragColor = vec4(color);
}