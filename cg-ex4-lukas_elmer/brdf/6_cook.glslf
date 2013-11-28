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
float PI = 3.14159265358979323846264338327950;

// Inspiration: https://en.wikibooks.org/wiki/GLSL_Programming/Unity/Brushed_Metal and https://github.com/minusinf/computer_graphics/tree/master/ex4/source
// Formula from: https://en.wikipedia.org/w/index.php?title=Specular_highlight&section=7#Cook.E2.80.93Torrance_model

float schlick(float theta) {
    float refractive_index = 1.5;
    float f0 = (1.0-refractive_index)/(1.0+refractive_index);
    return f0 + (1.0-f0)*pow(1.0-cos(theta),5.0);
}

float beckmann(float m, float alpha) {
    //return 1.0/(m*m*pow(cos(alpha), 4.0))*exp(-pow(tan(alpha)/m,2.0));
    //return exp(-pow(tan(alpha)/m,2.0)) / (m*m*pow(cos(alpha), 4.0));
    return exp(-pow(tan(alpha)/m,2.0)) / (PI*m*m*pow(cos(alpha), 4.0));
}


void main() {
    float s = .5;
    float d = .5;
    float F0 = 1.;
    float dwi = .75;
    float solid_angle = .5;

    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 V = normalize(-pos); // vector from point to camera
    vec3 E = normalize(-pos); // vector from camera to point
    //vec3 tangentDirection = normalize(varyingTangentDirection);
    //vec3 binormalDirection = normalize(cross(N, tangentDirection)); // Normalize?

    vec3 color = globalAmbientLightColor * materialAmbientColor;


    for (int i = 0; i < LIGHTS; i++) {
        vec3 L = normalize(lightPosition[i] - pos);

        vec3 R = normalize(reflect(-L,N));
        vec3 H = normalize(L+normalize(V));

        float dotNL = dot(N, L);
        float dotNV = dot(N, V);
        float dotNR = dot(N, R);
        float dotHN = dot(H, N);
        float dotNH = dot(N, H);
        float dotVH = dot(V, H);
        float dotEN = dot(E, N);
        float dotLN = dot(N, N);
        float dotEH = dot(E, H);
        float dotHV = dot(H, V);
        float m = solid_angle;

        //float G = min(min(1.0, (2.0*dotNV*dotNH)/dotVH), (2.0*dotNL*dotNH)/dotVH);


        float G = min(1., min(2.*dotHN*dotEN, 2.*dotHN*dotLN)/dotEH);
        //float D = pow(1.0/(pow(m,2.0)*pow(dotNH,4.0)), (pow(dotNH,2.0)-1.0)/( pow(m,2.0)*pow(dotNH,2.0)));
        //float D = (1.0/(pow(m,2.0)*pow(dotNH,4.0)) * exp ( pow(dotNH,2.0)-1.0)/( pow(m,2.0)*pow(dotNH,2.0)));
        //float D = (1.0/(pow(m,2.0)*pow(dotNH,4.0)) * exp ( pow(dotNH,2.0)-1.0)/( pow(m,2.0)*pow(dotNH,2.0)));
        //float alpha = acos(dotNL);
        float D = beckmann(m, acos(dotNH));
        float F = F0 + pow(1.-dotHV,5.0) * (1.-F0);
        //float F = F0 + pow(1.-dotVH,5.0) * (1.-F0);

        //return (Fresnel * Rough * Geom)/(dotNV*dotNL);





        //float F = beckmann(solid_angle, alpha);

        //float specColor = D*F*G/(4. * dotNV * dotNL);
        float specColor = D*F*G/(4. * dotEN * dotNL);

        color += clamp(specColor*lightColor[i], .0, .1);


        //vec3 L = (lightPosition[i] - V); // vector from point to light
        //vec3 L = normalize(lightPosition[i] - V); // vector from point to light


        color += clamp(materialDiffuseColor*lightColor[i]*dotNL, .0, 1.);

        //float attenuation;


        /*float alpha = acos(dotNL);
        float D = beckmann(solid_angle, alpha);

        float G = min(1.0, min(2.0*dotNH*dotNV/dotVH, 2.0*dotNH*dotNL/dotVH));
        vec3 Rs = materialSpecularColor*lightColor[i]*F/PI*D*G/(dotNL*dotNV);
        vec3 Rd = materialDiffuseColor*lightColor[i]*max(0.0, dotNL);
        color += clamp(dwi*dotNL*(s*Rs + d*Rd), .0, .1);*/
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}
