#version 460 core
in vec2 vTexCoord;
in vec3 vLightColor;

out vec4 FragColor;

uniform sampler2D uTexture;

void main() {
    vec4 texColor = texture(uTexture, vTexCoord);
    if(texColor.a < 0.1) discard;

    texColor.rgb *= vLightColor;

    FragColor = texColor;
}
