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

// inspiration: https://github.com/ashima/webgl-noise
vec3 color_lightgrey = vec3(252.0/255.0, 252.0/255.0, 252.0/255.0);
vec3 color_grey = vec3(162.0/255.0, 162.0/255.0, 162.0/255.0);
vec3 color_dark = vec3(72.0/255.0, 63.0/255.0, 51./255.0);
vec3 color_bright = vec3(241.0/255.0, 242.0/255.0, 251.0/255.0);
vec3 color_sand = vec3(231.0/255.0, 234.0/255.0, 142.0/255.0);
vec3 color_light_blue = vec3(32.0/255.0, 45.0/255.0, 90.0/255.0);
vec3 color_dark_blue = vec3(28.0/255.0, 38.0/255.0, 74.0/255.0);
vec3 color_green = vec3(140.0/229.0, 194.0/255.0, 81.0/255.0);
vec3 color_darkgreen = vec3(102.0/229.0, 180.0/255.0, 14.0/255.0);

uniform float currentTime;


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


float beckmann(float m, float alpha) {
    //return 1.0/(m*m*pow(cos(alpha), 4.0))*exp(-pow(tan(alpha)/m,2.0));
    //return exp(-pow(tan(alpha)/m,2.0)) / (m*m*pow(cos(alpha), 4.0));
    return exp(-pow(tan(alpha)/m,2.0)) / (PI*m*m*pow(cos(alpha), 4.0));
}


vec4 computeClouds(vec3 v) {
    float p = 0.0;
    float amplitude = 2.0;
    float frequency = 01.75;
    float scale = 0.75;
    float shift = 0.0;
    float x = scale * vTC.x + shift + v.x;
    float y = scale * vTC.y + shift + v.y;
    float z = scale * vTC.z + shift + v.z;

    for (int i = 0; i < 6; i++) {
        p += amplitude * (cnoise (frequency * vec3(x,y,z)));
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    if (p > 0.0)
        return vec4(color_grey * p, p);

    return vec4(0.0, 0.0, 0.0, 0.0);
}

vec3 computeLand(float heightP) {
    float p = 0.0;
    float amplitude = 1.5;
    float frequency = 0.5;
    float scale = 10.0;
    float shift = 0.0;
    float x = scale * vTC.x + shift;
    float y = scale * vTC.y + shift;
    float z = scale * vTC.z + shift;

    for (int i = 0; i < 5; i++) {
        p += amplitude * cnoise(frequency * vec3(x,y,z));
        frequency *= 2.0;
        amplitude *= 0.75;
    }

    if(heightP > .97)
        return color_lightgrey;

    //desert
    if (p < 0.0)
        return mix(color_sand, color_green, p);

    // forrest
    return mix(color_green, color_darkgreen, p);
}

vec4 getSurfaceColor() {
    float p = 0.0;
    float amplitude = 2.0;
    float frequency = 2.0;
    float scale = 1.0;
    float shift = 0.0;
    float x = scale * vTC.x + shift;
    float y = scale * vTC.y + shift;
    float z = scale * vTC.z + shift;

    for (int i = 0; i < 10; i++) {
        p += amplitude * cnoise(frequency * vec3(x,y,z));
        frequency *= 1.85;
        amplitude *= 0.6;
    }

    // water
    if (p < 0.45)
        return vec4 (mix (color_dark_blue, color_light_blue, p+5.0), 0.0);

    // beach
    if (p < 0.65)
        return vec4 (mix (color_sand, color_green, p), p);

    // land
    return vec4(computeLand(p), p);
}

float bumpMapping(vec3 shift) {
    float p = 0.0;
    float amplitude = 1.25;
    float frequency = 0.5;
    float scale = 1.0;
    float x = shift.x + vTC.x * scale;
    float y = shift.y + vTC.y * scale;
    float z = shift.z + vTC.z * scale;

    for (int i = 0; i < 8; i++) {
        p += amplitude * (cnoise(frequency * vec3(x,y,z)));
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return p;
}

vec3 computeEarthNormals(vec3 N, float height, float cloudiness) {
    float eps = 1.0;
    float aX = bumpMapping(vec3(eps, 0.0, 0.0)) * 0.1;
    float aY = bumpMapping(vec3(0.0, eps, 0.0)) * 0.1;
    float aZ = bumpMapping(vec3(0.0, 0.0, eps)) * 0.1;

    mat3 rotX = mat3(1., 0., 0.,
                     0., cos(aX), -sin(aX),
                     0., sin(aX), cos(aX));

    mat3 rotY = mat3(cos(aY), 0., sin(aY),
                     0., 1., 0.,
                     -sin(aY), 0., cos(aY));

    mat3 rotZ = mat3(cos(aZ), -sin(aZ), 0.,
                     sin(aZ), cos(aZ), 0.,
                     0., 0., 1.);

    N = rotX * rotY * rotZ * N;

    return normalize(N - max(1.0 - height, 0.0));
}

vec3 step = vec3(0.003, 0.008, 0.07);

void main() {
    float cook_s = .9;
    float cook_d = .8;
    float F0 = 1.;
    float dwi = 1.;
    float solid_angle = .3;
    float refractive_index = 1.5;

    vec3 pos = vP.xyz;
    vec3 N = normalize(vN);
    vec3 E = normalize(-pos); // vector from point to camera


    vec4 cloudColor = clamp(computeClouds(step*currentTime), 0.0, 1.0);
    bool is_cloud = (cloudColor.w > 0.0);

    vec4 surfaceColor = getSurfaceColor();
    bool is_ocean = (surfaceColor.w == 0.0);

    if (!is_ocean) {
        N = computeEarthNormals(N, surfaceColor.w, cloudColor.w);
    }

    //vec3 color = vec3(0., 0., 0.);

    vec3 color = globalAmbientLightColor * (cloudColor.xyz + surfaceColor.xyz) ;

    for (int i = 0; i < LIGHTS; i++) { // there is only one sun...
        vec3 L = normalize(lightPosition[i] - pos); // vector from position to light
        vec3 H = normalize(L + E); // halfway vector

        if (dot(N,L) >= .0) {
            float lambda = dot(H, N);
            float F = pow(1. + dot(E, N), lambda);
            float G = min(1., 2. * min(dot(E, N) * dot(H, N) / dot(E, H), dot(L, N) * dot(H, N) / dot(E, H)));
            float alpha = acos(max(0.0, dot(N, H)));
            float D = beckmann(solid_angle, alpha);

            float rs = D * F * G / (4. * dot(E, N) * dot(N, L));
            vec3 diffColor = (cloudColor.xyz + surfaceColor.xyz) * lightColor[i] * max(0., dot(N, L));

            if (is_ocean){
                vec3 specColor = rs * color_dark_blue * lightColor[i];
                color += clamp(dwi*dot(N,L)*(cook_s*specColor + cook_d*diffColor), 0., 1.);
            }else{
                vec3 specColor = rs * (cloudColor.xyz + surfaceColor.xyz) * lightColor[i];
                color += clamp(dwi*dot(N,L)*(cook_s*specColor * .1 + cook_d*diffColor), 0., 1.);
            }
        }
    }
    gl_FragColor = clamp(vec4(color, 1.), 0., 1.);
}

