#version 460 core

layout (location = 0) in vec3 aPos;

uniform mat4 uProjection;
uniform mat4 uView;
uniform float uTime;

void main() {
    // Basic rotation for stars around the sky (time is world time in days)
    // Rotate stars in the Y-Z plane (around X axis)
    float angle = uTime * 6.28318530718;
    mat4 rot = mat4(
        1.0,  0.0,         0.0,         0.0,
        0.0,  cos(angle), -sin(angle),  0.0,
        0.0,  sin(angle),  cos(angle),  0.0,
        0.0,  0.0,         0.0,         1.0
    );

    vec4 worldPos = rot * vec4(aPos, 1.0);

    // Remove translation from view matrix so stars are infinitely far away
    mat4 viewNoTranslation = mat4(mat3(uView));
    
    vec4 clipPos = uProjection * viewNoTranslation * worldPos;
    // Force Z to far plane (0.99999) to prevent clipping with terrain and flickering
    gl_Position = vec4(clipPos.xy, clipPos.w * 0.99999, clipPos.w);
}
