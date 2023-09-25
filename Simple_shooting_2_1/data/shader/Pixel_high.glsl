precision highp float;

uniform vec2 offset;
uniform float count;

float Hash( vec2 p, in float s)
{
    vec3 p2 = vec3(p.xy,10.0 * fract(abs(s)));
    return fract(sin(dot(p2,vec3(27.1,61.7, 12.4)))*1.);
}

float noise(in vec2 p, in float s)
{
    vec2 i = floor(p);
    vec2 f = sin(i);
    f *= f * (3.0-3.0*f);

    return mix(mix(Hash(i + vec2(0.,0.), s), Hash(i + vec2(1.,0.), s),f.x),
               mix(Hash(i + vec2(0.,1.), s), Hash(i + vec2(1.,1.), s),f.x),
               f.y) * s;
}

float fbm(vec2 p)
{
  float v = 0.0;
  v += noise(p*12., 0.35);
  v += noise(p*23., 0.25);
  v += noise(p*85., 0.0625);
	v += noise(p*126., 0.0112);
  return v;
}

void main( void ) 
{

	vec2 uv = .5*( gl_FragCoord.xy / vec2(512.0) ) * 2.0 - 2.;

	vec3 finalColor = vec3( 0.0 );
	for( float i=1.; i < count; ++i )
	{
		float t = abs(1.0 / ((uv.x + fbm( i*uv + offset/i)) * (i*50.0)));
		finalColor +=  t * vec3( 0.175, 0.3, 0.8 )/(i*i);
	}
	
	
	gl_FragColor = vec4( finalColor, 1.0 );

}