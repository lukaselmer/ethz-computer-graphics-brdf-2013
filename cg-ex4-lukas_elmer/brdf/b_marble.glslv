attribute vec3 vertexPosition;
attribute vec3 vertexNormal;
attribute vec3 textureCoord;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

varying vec3 vTC;
varying vec3 vN;
varying vec4 vP;
varying vec3 varyingTangentDirection;

void main(void) {
    vP = modelViewMatrix * vec4(vertexPosition, 1.);
    gl_Position = projectionMatrix * vP;
    vTC = vertexPosition;
    //vTC = textureCoord;
    vN = normalMatrix * vertexNormal;
    varyingTangentDirection = cross(vN, vec3(0., 0., 1.));
}
