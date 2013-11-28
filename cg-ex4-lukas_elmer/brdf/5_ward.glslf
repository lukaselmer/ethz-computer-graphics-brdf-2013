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

// Inspiration: https://en.wikibooks.org/wiki/GLSL_Programming/Unity/Brushed_Metal and https://github.com/minusinf/computer_graphics/tree/master/ex4/source
// Formula from: https://en.wikipedia.org/w/index.php?title=Specular_highlight&section=7#Ward_anisotropic_distribution

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
        float dotNL = dot(N, L);

        color += clamp(materialDiffuseColor*lightColor[i]*dotNL, 0.0, 1.0);

        vec3 viewDirection = normalize(-pos);
        vec3 lightDirection;
        float attenuation;

        vec3 R = normalize(reflect(-L,N));
        vec3 H = normalize(L+normalize(V));

        vec3 X = tangentDirection;
        vec3 Y = binormalDirection;

        float dotNR = dot(N, R);
        float dotHXax = dot(H, X) / ax;
        float dotHYay = dot(H, Y) / ay;
        float dotHN = dot(H, N);
        float t1 = 1./(sqrt(dotNL * dotNR));
        float t2 = dotNL / (4. * PI * ax * ay);
        float t3 = exp(-2. * (dotHXax*dotHXax + dotHYay*dotHYay) / (1. + dotHN));

        float pbd = t1 * t2 * t3;

        color += pbd * materialSpecularColor * lightColor[i];
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
