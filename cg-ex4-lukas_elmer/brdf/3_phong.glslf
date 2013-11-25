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


vec3 getAmbient(){
    return globalAmbientLightColor * materialAmbientColor;
}

void addDiffuse(inout vec3 color){
    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    for (int i = 0; i < LIGHTS; i++) {
        vec3 L = normalize(lightPosition[i]-pos); // vector from point to light

        // diffuse color
        color += materialDiffuseColor * max(0.0, dot(L, N)) * lightColor[i];

        // specular highlights
        if (materialShininess > 0.0) {
            vec3 R = normalize(reflect(-L, N)); // vector of reflected light
            vec3 V = normalize(-pos); // vector from point to camera
            color += materialSpecularColor * pow(max(0.0,dot(R, V)), materialShininess) * lightColor[i];
        }
    }
}

void main() {
    vec3 color = getAmbient();
    addDiffuse(color);
	gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
