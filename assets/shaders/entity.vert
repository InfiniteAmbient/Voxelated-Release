#version 460 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 vTexCoord;
out float vLayer;
out float vIsTinted;
out vec3 vLightColor;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;
uniform vec3 uLayers[6];
uniform float uSkyLight;
uniform float uBlockLight;
uniform float uSunHeight;

void main() {
    vTexCoord = aTexCoord;
    int faceIndex = (gl_VertexID / 6) % 6;
    vLayer = uLayers[faceIndex].x;
    vIsTinted = uLayers[faceIndex].y;
    gl_Position = uProjection * uView * uModel * vec4(aPos, 1.0);

    float sunlightIntensity = clamp((uSunHeight + 0.15) / 0.35, 0.0, 1.0);
    float minSkyLight = (uSkyLight > 0.0) ? 4.0 : 0.0;
    float dynamicSkyLight = max(uSkyLight * sunlightIntensity, minSkyLight);
    float skyCurve = pow(0.82, 15.0 - dynamicSkyLight);
    float blockCurve = pow(0.82, 15.0 - uBlockLight);
    
    vec3 coldShadowTint = vec3(0.5, 0.6, 0.8);
    vec3 sunlightColor = vec3(1.0, 1.0, 1.0);
    vec3 torchColor = vec3(1.0, 0.85, 0.5);
    
    vec3 lightColor = mix(coldShadowTint * 0.18, sunlightColor, skyCurve);
    vLightColor = max(lightColor, torchColor * blockCurve) * 0.95;
}
