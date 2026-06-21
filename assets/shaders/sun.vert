#version 460 core

const vec2 quadVertices[4] = vec2[4](
    vec2(-1.0, -1.0),
    vec2( 1.0, -1.0),
    vec2(-1.0,  1.0),
    vec2( 1.0,  1.0)
);
const int indices[6] = int[6](0, 1, 2, 1, 3, 2);

out vec3 vRayDir;

uniform mat4 uInvProjection;
uniform mat4 uInvView;

void main() {
    vec2 pos = quadVertices[indices[gl_VertexID]];
    // Z = 0.99999 ensures it renders behind everything but passes depth test (if GL_LEQUAL)
    gl_Position = vec4(pos, 0.99999, 1.0);

    // Unproject to get the ray direction in world space
    vec4 clipPos = vec4(pos, 1.0, 1.0);
    vec4 viewPos = uInvProjection * clipPos;
    viewPos.xyz /= viewPos.w;
    viewPos.w = 0.0;
    
    vRayDir = normalize((uInvView * viewPos).xyz);
}
