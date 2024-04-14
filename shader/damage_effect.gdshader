shader_type canvas_item;

uniform bool flash_red = false;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (flash_red && COLOR.a > 0.) {
		COLOR = mix(COLOR, vec4(1.0, 0., 0., 1.0), 0.3);
	}
}

