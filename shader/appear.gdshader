shader_type canvas_item;

uniform sampler2D NOISE;
uniform float threshhold = 0.0;

void fragment() {
	float noise = texture(NOISE, UV).r - UV.y * 0.5;
	if (noise > threshhold) {
		discard;
	}
	if (noise > threshhold - 0.2) {
		COLOR = vec4(1., 1., 1., 1.);
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}

