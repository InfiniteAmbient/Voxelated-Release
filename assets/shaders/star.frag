#version 460 core

uniform float uAlpha;

out vec4 FragColor;

void main() {
    // Pure white alpha-blended stars
    FragColor = vec4(1.0, 1.0, 1.0, uAlpha);
}
