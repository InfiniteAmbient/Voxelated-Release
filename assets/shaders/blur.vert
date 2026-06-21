#version 460 core
const vec2 quadVertices[4] = vec2[4](
    vec2(-1.0, -1.0),
    vec2( 1.0, -1.0),
    vec2(-1.0,  1.0),
    vec2( 1.0,  1.0)
);
const int indices[6] = int[6](0, 1, 2, 1, 3, 2);

out vec2 vUV;

void main() {
    vec2 pos = quadVertices[indices[gl_VertexID]];
    gl_Position = vec4(pos, -0.99999, 1.0); // Draw at near plane
    vUV = pos * 0.5 + 0.5;
}
