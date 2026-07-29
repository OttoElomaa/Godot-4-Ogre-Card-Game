shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float outline_thickness: hint_range(0.0, 16.0, 1.0) = 1.0;
uniform vec4 outline_color: source_color = vec4(1.0);

bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
    float alpha = top.a + bottom.a * (1.0 - top.a);
    if (alpha < 0.0001) return vec4(0.0);

    vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
    return vec4(color, alpha);
}

void vertex() {
	if (allow_out_of_bounds) VERTEX += (UV * 2.0 - 1.0) * outline_thickness;
}

void fragment() {
	if (outline_thickness > 0.0 && outline_color.a > 0.0) {
		vec2 uv = UV;
		vec4 texture_color = texture(TEXTURE, UV);

		if (allow_out_of_bounds) {
			vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(outline_thickness * 2.0));
			uv = (uv - texture_pixel_size * outline_thickness) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

			if (is_inside_usquare(uv)) {
				texture_color = texture(TEXTURE, uv);
			} else {
				texture_color = vec4(0.0);
			}
		}

		float alpha = 0.0;
		
		for (float y = 1.0; y <= outline_thickness; y++) {
			for (float x = 0.0; x <= y; x++) {
				if (length(vec2(x, y - 0.5)) > outline_thickness) break;

				float look_at_alpha;
				vec2 look_at_uv[8] = {
					uv + vec2(x, y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-x, y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(x, -y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-x, -y) * TEXTURE_PIXEL_SIZE,
					uv + vec2(y, x) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-y, x) * TEXTURE_PIXEL_SIZE,
					uv + vec2(y, -x) * TEXTURE_PIXEL_SIZE,
					uv + vec2(-y, -x) * TEXTURE_PIXEL_SIZE
				};

				for (int i = 0; i < 8; i++) {
					if (is_inside_usquare(look_at_uv[i])) {
						look_at_alpha = texture(TEXTURE, look_at_uv[i]).a;
						if (look_at_alpha > alpha) alpha = look_at_alpha;
						if (1.0 - alpha < 0.0001) break;
					}
				}
				
				if (1.0 - alpha < 0.0001) break;
			}
				
			if (1.0 - alpha < 0.0001) break;
		}

		COLOR = blend(vec4(outline_color.rgb, alpha * outline_color.a), texture_color);
	}
}