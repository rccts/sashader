#version 460 compatibility

in vec3 vaPosition;

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;

out vec4 blockColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;

void main() {
    geoNormal = gl_NormalMatrix * gl_Normal;

    blockColor = gl_Color;
    lightMapCoords = (gl_TextureMatrix[2] * gl_MultiTexCoord2).xy;

    viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;

    //horizon curvature
    vec3 worldSpaceVertexPosition = cameraPosition + (gbufferModelViewInverse * modelViewMatrix * vec4(vaPosition+chunkOffset,1)).xyz;
    float distanceFromCamera = distance(worldSpaceVertexPosition,cameraPosition);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition+chunkOffset - 0 * distanceFromCamera,1);
}