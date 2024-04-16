shader_type canvas_item;

uniform float y_cutoff = 0.0;

void fragment() {
	if (UV.y < y_cutoff) {
		discard;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
