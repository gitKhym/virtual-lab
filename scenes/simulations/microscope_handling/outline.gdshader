shader_type canvas_item;

uniform bool active = false;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE;
    vec4 color = texture(TEXTURE, UV);

    if (active) {
        float outline = 0.0;
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                if (x == 0 && y == 0) {
                    continue;
                }
                outline += texture(TEXTURE, UV + vec2(float(x), float(y)) * size * line_thickness).a;
            }
        }
        outline = min(outline, 1.0);

        color = mix(color, line_color, outline - color.a);
    }

    COLOR = color;
}