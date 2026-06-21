#version 460 core
in vec2 vUV;
out vec4 FragColor;

uniform sampler2D uScreenTexture;

void main() {
    // Basic optimized FXAA (Cheap edge blur)
    vec2 texel = 1.0 / textureSize(uScreenTexture, 0);
    vec3 rgbNW = texture(uScreenTexture, vUV + vec2(-1.0, -1.0) * texel).rgb;
    vec3 rgbNE = texture(uScreenTexture, vUV + vec2(1.0, -1.0) * texel).rgb;
    vec3 rgbSW = texture(uScreenTexture, vUV + vec2(-1.0, 1.0) * texel).rgb;
    vec3 rgbSE = texture(uScreenTexture, vUV + vec2(1.0, 1.0) * texel).rgb;
    vec3 rgbM  = texture(uScreenTexture, vUV).rgb;
    
    vec3 blurred = (rgbNW + rgbNE + rgbSW + rgbSE + rgbM * 4.0) * 0.125;
    
    // 15% accumulation blur (optimized motion blur + anti aliasing)
    FragColor = vec4(blurred, 0.15);
}
