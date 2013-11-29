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
float PI = 3.1415926535897932384626433832795;

// Inspiration: https://en.wikibooks.org/wiki/GLSL_Programming/Unity/Brushed_Metal and https://github.com/minusinf/computer_graphics/tree/master/ex4/source
// Formula from: https://en.wikipedia.org/w/index.php?title=Specular_highlight&section=7#Cook.E2.80.93Torrance_model

float beckmann(float m, float alpha) {
    //return 1.0/(m*m*pow(cos(alpha), 4.0))*exp(-pow(tan(alpha)/m,2.0));
    //return exp(-pow(tan(alpha)/m,2.0)) / (m*m*pow(cos(alpha), 4.0));
    return exp(-pow(tan(alpha)/m,2.0)) / (PI*m*m*pow(cos(alpha), 4.0));
}

void main() {
    float cook_s = .7;
    float cook_d = .3;
    float F0 = 1.;
    float dwi = 1.;
    float solid_angle = .3;
    float refractive_index = 5.;

    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 E = normalize(-pos); // vector from point to camera

    vec3 color = globalAmbientLightColor * materialAmbientColor;

    for (int i = 0; i < LIGHTS; i++) {
        vec3 L = normalize(lightPosition[i] - pos); // vector from position to light
        vec3 H = normalize(L + E); // halfway vector

        if (dot(N,L) >= .0) {
            float lambda = dot(H, N);
            float F = pow(1. + dot(E, N), lambda);
            float G = min(1., 2. * min(dot(E, N) * dot(H, N) / dot(E, H), dot(L, N) * dot(H, N) / dot(E, H)));
            float alpha = acos(max(0.0, dot(N, H)));
            float D = beckmann(solid_angle, alpha);

            float rs = D * F * G / (4. * dot(E, N) * dot(N, L));
            vec3 specColor = rs * materialSpecularColor * lightColor[i];
            vec3 diffColor = materialDiffuseColor * lightColor[i] * max(0., dot(N, L));

            color += clamp(dwi*dot(N,L)*(cook_s*specColor + cook_d*diffColor), 0., 1.);
        }
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}


















