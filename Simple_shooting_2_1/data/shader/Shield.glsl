uniform vec2 resolution;
uniform float rad;
uniform sampler2D texture;

struct Ray{
  vec3 Origin;
  vec3 Direction;
};

struct Sphere{
  float Radius;
  vec3 Position;
};

struct Intersection{
  float Distance;
  vec3 HitPoint;
  vec3 Normal;
};

Intersection intersectSphere(Ray R, Sphere S, inout Intersection I){
  vec3  a = R.Origin - S.Position;
  float b = dot(a, R.Direction);
  float c = dot(a, a) - (S.Radius * S.Radius);
  float d = b * b - c;
  float t = -b - sqrt(d);
  if(d > 0.0 && t > 0.0 && t < I.Distance){
      I.HitPoint = R.Origin + R.Direction * t;
      I.Normal = normalize(I.HitPoint - S.Position);
      d = clamp(dot(lightDirection, I.Normal), 0.1, 1.0);
      I.Distance = t;
  }
}

void main(void){
  Ray ray;
  float half_res=resolution.y/2.;
  ray.Origin=vec3(0.,0.,half_res*5.);
  ray.Direction=normalize(vec3(gl_FragCoord.xy,-half_res));
  Sphere sphere;
  sphere.Radius=rad;
  sphere.Position=vec3(resolution/2.,0.);
  vec3 destColor = vec3(0.0);
  if(intersectSphere(ray, sphere)){
      destColor = vec3(1.);
  }

  gl_FragColor = vec4(destColor, 1.0);
}