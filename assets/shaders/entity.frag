#version 460 core
in vec2 vTexCoord;
in float vLayer;
in float vIsTinted;
in vec3 vLightColor;

out vec4 FragColor;

uniform sampler2DArray uTextureArray;

void main() {
    vec4 texColor = texture(uTextureArray, vec3(vTexCoord, vLayer));
    if (texColor.a < 0.1) discard;
    
    if (vIsTinted > 0.5) {
        texColor.rgb *= vec3(0.56, 0.73, 0.35);
    }
    
    texColor.rgb *= vLightColor;

    FragColor = texColor;
}
