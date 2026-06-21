#version 460 core
in vec3 vRayDir;
out vec4 FragColor;

uniform vec3 uSunDir;
uniform vec3 uSkyColor;
uniform sampler2D uSunTexture;
uniform sampler2D uMoonTexture;
uniform float uTime;

void main() {
    // 1. Use the skyColor passed from the engine (matches fog)
    vec3 skyColor = uSkyColor;
    
    // Smooth Alpha Sky Gradient: matches fog perfectly at horizon (upFactor = 0.0)
    // and fades to a slightly darker shade high up in the sky dome.
    float upFactor = clamp(vRayDir.y, 0.0, 1.0);
    skyColor = mix(skyColor, skyColor * 0.85, pow(upFactor, 1.5));

    // 2. Draw Sun & Moon (Classic Flat Textures)
    // Safe cross product: avoids NaN when uSunDir is parallel to Y-axis (noon/midnight)
    vec3 crossDir = cross(vec3(0.0, 1.0, 0.0), uSunDir);
    vec3 sunRight;
    if (length(crossDir) < 0.01) {
        sunRight = vec3(0.0, 0.0, 1.0);
    } else {
        sunRight = normalize(crossDir);
    }
    vec3 sunUp = normalize(cross(uSunDir, sunRight));
    
    float dx = dot(vRayDir, sunRight);
    float dy = dot(vRayDir, sunUp);
    float dz = dot(vRayDir, uSunDir);

    // Sun
    if (dz > 0.1) {
        float sunSize = 0.16;
        // Perspective projection correction: divides by dz to eliminate warping/tilting
        float projX = dx / dz;
        float projY = dy / dz;
        vec2 sunUV = vec2(projX, projY) / (2.0 * sunSize) + 0.5;
        if (sunUV.x >= 0.0 && sunUV.x <= 1.0 && sunUV.y >= 0.0 && sunUV.y <= 1.0) {
            vec4 tex = texture(uSunTexture, sunUV);
            // High-intensity color key: keeps only bright yellow/white sun pixels
            if (tex.r > 0.5 && tex.g > 0.5) {
                // First priority: draw the sun completely solid and bright
                skyColor = tex.rgb;
            }
        }
    }
    
    // Moon
    if (dz < -0.1) {
        float moonSize = 0.14;
        // Perspective projection correction: divides by -dz
        float projX = -dx / (-dz);
        float projY = dy / (-dz);
        vec2 moonUV = vec2(projX, projY) / (2.0 * moonSize) + 0.5;
        if (moonUV.x >= 0.0 && moonUV.x <= 1.0 && moonUV.y >= 0.0 && moonUV.y <= 1.0) {
            moonUV.x *= 0.25;
            moonUV.y *= 0.5;
            vec4 tex = texture(uMoonTexture, moonUV);
            // High-intensity color key: keeps only bright white moon pixels
            if (tex.r > 0.5 && tex.g > 0.5) {
                // First priority: draw the moon completely solid and bright
                skyColor = tex.rgb;
            }
        }
    }
    
    FragColor = vec4(skyColor, 1.0);
}
