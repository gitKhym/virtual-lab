shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 1.0) = 0.0; // 0.0 = sharp, 1.0 = max blur

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
    vec4 color = texture(TEXTURE, UV);
    
    if (blur_amount > 0.0) {
        vec4 sum = vec4(0.0);
        int steps = int(blur_amount * 3.0); // 0–3
        for (int x = -steps; x <= steps; x++) {
            for (int y = -steps; y <= steps; y++) {
                vec2 offset = vec2(float(x), float(y)) * pixel_size;
                sum += texture(TEXTURE, UV + offset);
            }
        }
        color = mix(color, sum / pow(float(steps * 2 + 1), 2.0), blur_amount);
    }

    COLOR = color;
}
