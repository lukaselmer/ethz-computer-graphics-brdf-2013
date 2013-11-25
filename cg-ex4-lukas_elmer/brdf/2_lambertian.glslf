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

void main() {
    vec3 color = globalAmbientLightColor * materialAmbientColor;

    vec3 pos = vP.xyz;
    vec3 n = normalize(vN);
    for (int i = 0; i < LIGHTS; ++i) {
        vec3 lightDirection = normalize(lightPosition[i] - pos);
        color += materialDiffuseColor * max(0.0, dot(n, lightDirection)) * lightColor[i];
    }

    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
