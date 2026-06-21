#version 460 core

in vec2 vUV;
flat in uint vData;
in float vShading;
in float vFogFactor;
in vec3 vLightColor;

out vec4 FragColor;

uniform sampler2DArray uTextureArray;
uniform vec3 uViewPos;
uniform vec3 uSkyColor;
uniform int uIsUnderwater;

void main() {
    if (uIsUnderwater == 0 && vFogFactor <= 0.15) {
        discard;
    }
    uint layerIdx = (vData >> 3) & 0x1FFFu;
    uint tintType = (vData >> 16) & 0x3u;
    vec4 texColor = texture(uTextureArray, vec3(vUV, float(layerIdx)));
    if (texColor.a < 0.01) discard;

    if (tintType == 1u && (vData & 0x7u) == 2u) {
        texColor.rgb *= vec3(0.44, 0.74, 0.28);
    } else if (tintType == 2u) {
        texColor.rgb *= vec3(0.34, 0.63, 0.17);
    } else if (tintType == 3u) {
        texColor.rgb *= vec3(0.30, 0.52, 0.90);
        texColor.a = 0.45;
    }

    texColor.rgb *= vShading * vLightColor;

    vec3 skyColor = uSkyColor;
    if (uIsUnderwater == 0) {
        float caveFactor = clamp((36.0 - uViewPos.y) / 36.0, 0.0, 1.0);
        skyColor = mix(uSkyColor, vec3(0.015, 0.015, 0.02), caveFactor);
    }

    FragColor = mix(vec4(skyColor, texColor.a), texColor, vFogFactor);
}
