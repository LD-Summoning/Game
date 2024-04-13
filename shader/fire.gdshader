shader_type canvas_item;

uniform vec2 scroll =vec2(0.5, 0.5);
uniform vec2 scroll2 = vec2(0.3, 0.3);
uniform sampler2D TONE_MAPPING;

void fragment() {
	float noise_intensity = texture(TEXTURE, UV+ scroll * TIME).r;
	float noise_intensity2 = texture(TEXTURE, UV+scroll2 * TIME).r;
	float intensity = noise_intensity * noise_intensity2;
	vec2 centered = vec2(0.5, 0.5) - UV;
	float d = length(centered);
	if (d > 0.5) {
		discard;
	}
	if (d > 0.48) {
		COLOR = vec4(vec3(0.), 1.);
	} else {
		COLOR = texture(TONE_MAPPING, vec2(intensity));
	}
}

