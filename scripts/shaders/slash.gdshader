shader_type canvas_item;

uniform sampler2D slash_tex;
uniform float slash_offset : hint_range(-1.0, 1.0);

void fragment() {
	vec4 tex_color = texture(slash_tex, UV - vec2(slash_offset,0.0));
	COLOR = tex_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
