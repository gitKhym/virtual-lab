shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D water_texture;

void fragment() {
	vec2 uv = UV;
	vec4 color = texture(water_texture, uv);

	if (uv.y > (1.0 - fill_amount)) {
		COLOR = color;
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}
