#define LIGHTS 3

precision mediump float;

uniform vec3 materialAmbientColor;
uniform vec3 materialDiffuseColor;
uniform vec3 materialSpecularColor;
uniform float materialShininess;

uniform vec3 lightPosition[LIGHTS];
uniform vec3 lightColor[LIGHTS];
uniform vec3 globalAmbientLightColor;

varying vec2 vTC;
varying vec3 vN;
varying vec4 vP;
varying vec3 varyingTangentDirection;

uniform float currentTime;

// Inspiration: https://en.wikibooks.org/wiki/GLSL_Programming/Unity/Brushed_Metal

void main() {
    float ax = 0.08;
    float ay = 0.2;
    float pd = 0.15;
    float ps = 0.16;
    float PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628;


    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 V = normalize(-pos); // vector from point to camera
    vec3 tangentDirection = normalize(varyingTangentDirection);
    vec3 binormalDirection = normalize(cross(N, tangentDirection)); // Normalize?

    vec3 color = globalAmbientLightColor * materialAmbientColor;
    color *= pd/PI;



    for (int i = 0; i < LIGHTS; i++) {
        vec3 L = normalize(lightPosition[i] - pos); // vector from point to light
        //vec3 H = (L + V) / length(L + V); // halfway vector between L and V
        vec3 vertexToLightSource = L;

        vec3 viewDirection = normalize(-pos);
        //vec3 viewDirection = L;
        vec3 lightDirection;
        float attenuation;

        vec3 R = normalize(reflect(-L,N));
        vec3 H = normalize(L+normalize(V));

        float cosphi_r = dot(R,N);
        float cosphi_i = dot(L,N);
        float hxax = dot(H,tangentDirection)/ax;
        float hyay = dot(H,binormalDirection)/ay;
        float pbd = pd/PI + ps*(1.0/sqrt(cosphi_i*cosphi_r))*(1.0/(4.0*PI*ax*ay))
                *exp(-2.0*(hxax*hxax+hyay*hyay)/(1.0+dot(H,N)));

        vec3 HP = normalize(tangentDirection*dot(tangentDirection,H) + binormalDirection*dot(binormalDirection,H));
        float cosphi = dot(HP, tangentDirection);

        color += clamp(materialDiffuseColor*lightColor[i]*dot(N,L), 0.0, 1.0);
        color += pbd*materialSpecularColor*lightColor[i];
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
