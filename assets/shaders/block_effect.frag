#version 460 core
in vec2 vTexCoord;
out vec4 FragColor;

uniform sampler2D uTexture;
uniform vec4 uColor; // Flat color override (e.g. black outline, or overlay multiplier)
uniform int uUseTexture;

void main() {
    if (uUseTexture != 0) {
        vec4 texColor = texture(uTexture, vTexCoord);
        if (texColor.a < 0.05) discard;
        // Apply texture alpha combined with user-defined overlay opacity
        FragColor = vec4(texColor.rgb, texColor.a * uColor.a);
    } else {
        FragColor = uColor;
    }
}
