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

// Inspiration: https://en.wikibooks.org/wiki/GLSL_Programming/Unity/Brushed_Metal

void main() {

    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 viewDirection = normalize(-pos); // vector from point to camera
    vec3 tangentDirection = normalize(varyingTangentDirection);

    vec3 color = globalAmbientLightColor * materialAmbientColor;

    float _AlphaX = 0.8;
    float _AlphaY = 0.2;

    vec3 binormalDirection = cross(N, tangentDirection);

    for (int i = 0; i < LIGHTS; i++) {
        vec3 vertexToLightSource = lightPosition[i] - pos;
        vec3 lightDirection = normalize(vertexToLightSource); // vector from point to light
        vec3 H = normalize(lightDirection + viewDirection); // halfway vector between lightDirection and viewDirection

        // calc attenuation for spot light source
        float distance = length(vertexToLightSource);
        float attenuation = 1.0 / distance; // linear attenuation
        attenuation *= 2.0; // add more power to the light source


        vec3 halfwayVector = normalize(lightDirection + viewDirection);
        float dotLN = dot(lightDirection, N); // compute this dot product only once

        // Diffuse color
        color += attenuation * materialDiffuseColor * max(0.0, dotLN) * lightColor[i];

        if (dotLN < 0.0) continue; // light source on the wrong side => no specular reflection

        // Specular reflection
        float dotHN = dot(halfwayVector, N);
        float dotVN = dot(viewDirection, N);
        float dotHTAlphaX = dot(halfwayVector, tangentDirection) / _AlphaX;
        float dotHBAlphaY = dot(halfwayVector, binormalDirection) / _AlphaY;

        color += attenuation * materialSpecularColor
          * sqrt(max(0.0, dotLN / dotVN))
          * exp(-2.0 * (dotHTAlphaX * dotHTAlphaX + dotHBAlphaY * dotHBAlphaY) / (1.0 + dotHN)); // * lightColor[i]
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
