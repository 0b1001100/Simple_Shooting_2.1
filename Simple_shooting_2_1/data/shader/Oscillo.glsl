uniform vec2 resolution;
uniform float time;
uniform sampler2D input_texture;

void main(void){
    float frac=mod(time*1000.,25.)/25.;
    float frac_min=mod(time*1000.-24.9,25.)/25.;
    
    float scale=0.875+fract(sin(time)*1000000.0)*0.25;
    
    bool two=frac_min>frac;
    
    vec2 uv = gl_FragCoord.xy/resolution.xy;
    
    float sum=resolution.x*resolution.y;
    
    float pos=(max(0.,gl_FragCoord.y-1.)*resolution.x+gl_FragCoord.x)/sum;
    
    float posRand=0.875+fract(sin(pos+time)*1000000.0)*0.25;
    
    bool display=two?pos<frac||pos>frac_min:pos<frac&&pos>frac_min;

    vec4 col = texture(input_texture,uv);
    
    float gray=length(col.rgb);

    gl_FragColor = posRand*scale*vec4(0.05,0.65,0.45,1.)*(vec4(vec3(step(0.06, length(vec2(dFdx(gray), dFdy(gray))))),1.)*(display?vec4(1.):vec4(posRand)));
}