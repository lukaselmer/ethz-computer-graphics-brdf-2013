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

float schlick(float theta) {
    float refractive_index = 1.5;
    float f0 = (1.0-refractive_index)/(1.0+refractive_index);
    return f0 + (1.0-f0)*pow(1.0-cos(theta),5.0);
}

float beckmann(float m, float alpha) {
    return 1.0/(m*m*pow(cos(alpha), 4.0))*exp(-pow(tan(alpha)/m,2.0));
}

void main() {
    float ax = 0.08;
    float ay = 0.2;
    float pd = 0.15;
    float ps = 0.16;

    float s = .5;
    float d = .5;
    float F = 1.;
    float dwi = .75;
    float solid_angle = .5;
    float PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628;

    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 V = normalize(-pos); // vector from point to camera
    vec3 tangentDirection = normalize(varyingTangentDirection);
    vec3 binormalDirection = normalize(cross(N, tangentDirection)); // Normalize?

    vec3 color = globalAmbientLightColor * materialAmbientColor;

    for (int i = 0; i < LIGHTS; i++) {
        //vec3 L = normalize(lightPosition[i] - V); // vector from point to light
        float dotNL = dot(N, L);

        color += clamp(materialDiffuseColor*lightColor[i]*dotNL, 0.0, 1.0);

        //float attenuation;

        vec3 R = normalize(reflect(-L,N));
        vec3 H = normalize(L+normalize(V));

        float dotNV = dot(N, V);
        float dotNR = dot(N, R);
        float dotHN = dot(H, N);
        float dotNH = dot(N, H);
        float dotVH = dot(V, H);

        float alpha = acos(dotNL);
        float D = beckmann(solid_angle, alpha);

        float G = min(1.0, min(2.0*dotNH*dotNV/dotVH, 2.0*dotNH*dotNL/dotVH));
        vec3 Rs = materialSpecularColor*lightColor[i]*F/PI*D*G/(dotNL*dotNV);
        vec3 Rd = materialDiffuseColor*lightColor[i]*max(0.0, dotNL);
        color += clamp(dwi*dot(N,L)*(s*Rs + d*Rd), .0, .1);
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
