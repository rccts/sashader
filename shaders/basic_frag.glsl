#version 460

//uniforms
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform sampler2D specular;
uniform vec3 cameraPosition;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

//vertex to fragment
in vec2 textureCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;

//functions
mat3 tbnNormalTangent(vec3 normal,vec3 tangent) {
    vec3 bitangent = cross(tangent,normal);
    return mat3(tangent,bitangent,normal);
}

void main() {
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

    vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;

    vec4 normalData = texture(normals,textureCoord)*2.0-1.0;

    vec3 normalNormalSpace = vec3(normalData.xy,sqrt(1.0 - dot(normalData.xy,normalData.xy)));

    mat3 tbn = tbnNormalTangent(worldGeoNormal,tangent.rgb);

    vec3 normalWorldSpace = tbn * normalNormalSpace;

    //reflection calcs
    vec4 specularData = texture(specular,textureCoord);
    float perceptualSmoothness = specularData.r;
    float roughness = pow(1.0 - perceptualSmoothness,2.0);
    float smoothness = 1-roughness;
    vec3 reflectionDirection = reflect(-shadowLightDirection,normalWorldSpace);
    vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition,1.0)).xyz;
    vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;
    vec3 viewDirection = normalize(cameraPosition - fragWorldSpace);

    float diffuseLight = roughness*clamp(dot(shadowLightDirection,normalWorldSpace),0.0,1.0);
    float shininess = (1+(smoothness) * 100);
    float specularLight = clamp(smoothness*pow(dot(reflectionDirection,viewDirection),shininess),0.0,1.0 );
    float ambientLight = 0.2;
    float lightBrightness = ambientLight + diffuseLight + specularLight;

    vec3 lightColor = pow(texture(lightmap,lightMapCoords).rgb,vec3(2.2));

    vec4 outColorData = pow(texture(gtexture,textureCoord),vec4(2.2));
    vec3 outColor = outColorData.rgb * pow(foliageColor,vec3(2.2)) * lightColor;
    float transparency = outColorData.a;
    if(transparency < .1) {
        discard;
    }
    outColor *= lightBrightness;
    outColor0 = pow(vec4(outColor,transparency),vec4(1/2.2));
}