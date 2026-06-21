#version 460 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUV;
layout (location = 2) in uint aData;

uniform mat4 uView;
uniform mat4 uProjection;
uniform vec3 uViewPos;
uniform int uIsUnderwater;
uniform float uSunHeight;

out vec2 vUV;
flat out uint vData;
out float vShading;
out float vFogFactor;
out vec3 vLightColor;

const float FACE_SHADING[6] = float[6](0.75, 0.75, 1.0, 0.40, 0.60, 0.60);

void main() {
    vec4 worldPos = vec4(aPos, 1.0);
    gl_Position = uProjection * uView * worldPos;
    vUV = aUV;
    vData = aData;

    float dist = length(uView * worldPos);
    uint normalIdx = aData & 0x7u;
    uint shadowLevel = (aData >> 18u) & 0x3u;
    uint skyLight = (aData >> 20u) & 0xFu;
    uint blockLight = (aData >> 24u) & 0xFu;

    float shadowMult = 1.0;
    if (shadowLevel == 3u) shadowMult = 0.4;
    else if (shadowLevel == 2u) shadowMult = 0.6;
    else if (shadowLevel == 1u) shadowMult = 0.8;
    vShading = FACE_SHADING[normalIdx] * shadowMult;

    float sunlightIntensity = pow(clamp((uSunHeight + 0.3) / 0.6, 0.0, 1.0), 0.7);
    float minSkyLight = (skyLight > 0u) ? 4.0 : 0.0;
    float dynamicSkyLight = max(float(skyLight) * sunlightIntensity, minSkyLight);

    float skyCurve = pow(0.82, 15.0 - dynamicSkyLight);
    float blockCurve = pow(0.82, 15.0 - float(blockLight));
    vec3 coldShadowTint = vec3(0.5, 0.6, 0.8);
    vec3 sunlightColor = vec3(1.0, 1.0, 1.0);
    vec3 torchColor = vec3(1.0, 0.85, 0.5);
    vec3 lightColor = mix(coldShadowTint * 0.25, sunlightColor, skyCurve);
    vLightColor = max(lightColor, torchColor * blockCurve) * 0.95;

    float fogFactor = 1.0;
    if (uIsUnderwater == 1) {
        float distFactor = clamp((dist - 0.0) / 25.0, 0.0, 1.0);
        fogFactor = 1.0 - (distFactor * distFactor);
    } else {
        float caveFactor = clamp((36.0 - uViewPos.y) / 36.0, 0.0, 1.0);
        float fogStart = mix(40.0, 10.0, caveFactor);
        float fogEnd = mix(120.0, 30.0, caveFactor);
        float distFactor = clamp((dist - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
        float heightFactor = exp(-max(aPos.y - 40.0, 0.0) * 0.015);
        float valleyFactor = mix(0.4 + 0.6 * heightFactor, 1.0, caveFactor);
        distFactor = clamp(distFactor * valleyFactor, 0.0, 1.0);
        fogFactor = 1.0 - (distFactor * distFactor);
    }
    vFogFactor = fogFactor;
}
