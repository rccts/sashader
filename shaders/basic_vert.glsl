#version 460

//in attributes
in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec4 at_tangent;

//uniforms
uniform mat3 normalMatrix;
uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 cameraPosition;
uniform vec3 chunkOffset;

out vec2 textureCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;

void main() {
    tangent = vec4(normalize(normalMatrix * at_tangent.rgb),at_tangent.a);

    geoNormal = normalMatrix * vaNormal;

    textureCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);

    vec3 worldSpaceVertexPosition = cameraPosition + (gbufferModelViewInverse * modelViewMatrix * vec4(vaPosition+chunkOffset,1)).xyz;
    float distanceFromCamera = distance(worldSpaceVertexPosition,cameraPosition);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition+chunkOffset - 0 * distanceFromCamera,1);
}