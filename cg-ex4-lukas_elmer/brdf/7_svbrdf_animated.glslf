#define LIGHTS 3

precision mediump float;

uniform vec3 materialAmbientColor;
uniform vec3 materialDiffuseColor;
uniform vec3 materialSpecularColor;
uniform float materialShininess;

uniform vec3 lightPosition[3];
uniform vec3 lightColor[3];
uniform vec3 globalAmbientLightColor;

varying vec3 vTC;
varying vec3 vN;
varying vec4 vP;
float PI = 3.1415926535897932384626433832795;

uniform float currentTime;

// inspiration: https://github.com/ashima/webgl-noise
vec3 c1 = vec3(183.0/255.0, 65.0/255.0, 14.0/255.0);
vec3 c2 = vec3(165.0/255.0, 93.0/255.0, 53.0/255.0);
vec3 c3 = vec3(128.0/255.0, 44.0/255.0, 8.0/255.0);

vec3 mod289(vec3 x) {
    return x - floor(x * (1. / 289.)) * 289.;
}
vec4 mod289(vec4 x) {
    return x - floor(x * (1. / 289.)) * 289.;
}
vec4 permute(vec4 x) {
    return mod289(((x*34.)+1.)*x);
}
vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}
vec3 fade(vec3 t) {
    return t*t*t*(t*(t*6.-15.)+10.);
}

float cnoise(vec3 P) {
    vec3 Pi0 = floor(P); // Integer part for indexing
    vec3 Pi1 = Pi0 + vec3(1.); // Integer part + 1
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;

    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);

    vec4 gx0 = ixy0 * (1. / 7.);
    vec4 gy0 = fract(floor(gx0) * (1. / 7.)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    vec4 gx1 = ixy1 * (1. / 7.);
    vec4 gy1 = fract(floor(gx1) * (1. / 7.)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

vec3 getColor() {
    float scale = .5;
    float shift = 1000.0 + currentTime / 3.;
    float x = scale * vTC.x + shift + 10.0;
    float y = scale * vTC.y + shift - 100000.0;
    float z = scale * vTC.z + shift + 0.0;


    float frequency = .5;
    float amplitude = 46.2;
    float c = 0.;
    for (float i = 0.; i < 10.; i++) {
        float p = cnoise(frequency * vec3(x,y,z));
        c += amplitude * p;
        c += sin(abs(x+y+z + p) + cos(y + p));
        amplitude *= 0.2;
        frequency *= 2. + i * 8.;
    }

    c = sin(c/20.0) + cos(c/20.0);

    if(c < 0.)
        return c3;
    else if(c < 0.95)
        return mix(c1, c2, c);
    else if (c < 0.97)
        return mix(c2, c1, c);
    else
        return mix(c3, c2, c);
}

float beckmann(float m, float alpha) {
    //return 1.0/(m*m*pow(cos(alpha), 4.0))*exp(-pow(tan(alpha)/m,2.0));
    //return exp(-pow(tan(alpha)/m,2.0)) / (m*m*pow(cos(alpha), 4.0));
    return exp(-pow(tan(alpha)/m,2.0)) / (PI*m*m*pow(cos(alpha), 4.0));
}

void main() {
    vec3 material = getColor();
    float cook_s = .9;
    float cook_d = .8;
    float F0 = 1.;
    float dwi = 1.;
    float solid_angle = .3;
    float refractive_index = 1.5;

    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 E = normalize(-pos); // vector from point to camera

    vec3 color = globalAmbientLightColor * materialAmbientColor * material;

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
            vec3 specColor = rs * material * materialSpecularColor * lightColor[i];
            vec3 diffColor = material * materialDiffuseColor * lightColor[i] * max(0., dot(N, L));

            color += clamp(dwi*dot(N,L)*(cook_s*specColor + cook_d*diffColor), 0., 1.);
        }
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}

