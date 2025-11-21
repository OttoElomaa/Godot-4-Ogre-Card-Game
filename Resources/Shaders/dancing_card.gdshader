shader_type canvas_item;

uniform float r = 0.0;
uniform float offset: hint_range(-10.0, 10.0) = 0.0;

void vertex() {
	VERTEX.xy *= 3.;
}

void fragment() {
	mat2 rotation_matrix = mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
	mat2 scale_matrix = mat2(vec2(1.0, 0.0),vec2(0.0, TEXTURE_PIXEL_SIZE.x/TEXTURE_PIXEL_SIZE.y));
	vec2 uv = (((UV * 2.0 - 1.0)*3.+1.0)/2.0-vec2(0.5))*scale_matrix;
	vec2 uv_normal = uv * rotation_matrix * inverse(scale_matrix) + vec2(0.5);
	uv = (uv * rotation_matrix + vec2(0.25)*offset*rotation_matrix)*inverse(scale_matrix)+vec2(0.5);
	vec4 shadow;
	vec4 real;
	if(offset != 0.0 && uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0) {
		vec4 c = texture(TEXTURE, uv);
		shadow = vec4(0.,0.,0.,c.a-0.6);
	}
	if(uv_normal.x >= 0.0 && uv_normal.x <= 1.0 && uv_normal.y >= 0.0 && uv_normal.y <= 1.0) {
		real = texture(TEXTURE,uv_normal);
	}
	COLOR = mix(shadow,real,real.a);
}