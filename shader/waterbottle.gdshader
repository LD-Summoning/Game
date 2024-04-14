shader_type canvas_item;

uniform float fill_level = 0.5;

void fragment() {
	vec4 bottle = texture(TEXTURE, UV);
	float my_fill_level = fill_level + sin(UV.x * 8. * PI + TIME) * 0.01;
	// Called for every pixel the material is visible on.
	if (bottle.a < 0.1 && UV.y > my_fill_level) {
		COLOR = vec4(0.2, 0.2, 1., .5);
	} else {
		COLOR = bottle;
	}
}

