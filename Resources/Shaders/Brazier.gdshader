shader_type canvas_item;
render_mode blend_mix, unshaded;

// Fire properties
uniform vec2 fire_scale = vec2(1.0, 1.0);
uniform vec2 fire_speed_direction = vec2(0.0, 1.0);

// Fire texture maps
uniform sampler2D fire_noise : source_color, repeat_enable;
uniform sampler2D fire_height_gradient : source_color;
uniform sampler2D fire_shape_gradient : source_color;
uniform sampler2D flame_height_gradient : source_color;
uniform sampler2D fire_color : source_color;

void fragment() {
	// Scale UV coordinates based on fire_scale
	vec2 scaled_uv = (UV - vec2(0.0)) * fire_scale + vec2(0.0);

	// Animate fire movement using TIME and speed direction
	vec3 time_offset = vec3(TIME) * vec3(fire_speed_direction, 0.0);
	vec2 animated_uv = time_offset.xy + scaled_uv;

	// Sample noise texture to create fire flickering effect
	vec4 noise_tex = texture(fire_noise, animated_uv);
	float noise_value = noise_tex.r;

	// Sample fire height gradient to control fire elevation
	vec4 height_tex = texture(fire_height_gradient, UV);
	float height_value = height_tex.r;

	// Combine noise and height for flame dynamics
	float combined_value = noise_value + height_value;

	// Sample fire shape gradient to define fire boundaries
	vec4 shape_tex = texture(fire_shape_gradient, UV);
	float shape_value = shape_tex.r;

	// Apply shape influence to fire dynamics
	float shaped_fire = combined_value * shape_value;

	// Sample flame height gradient to modify fire height
	vec4 flame_height_tex = texture(flame_height_gradient, UV);
	float flame_height_value = flame_height_tex.r;

	// Final fire intensity calculation
	float fire_intensity = shaped_fire - flame_height_value;

	// Clamp fire intensity between 0 and 1
	fire_intensity = clamp(fire_intensity, 0.0, 1.0);

	// Sample fire color based on intensity
	vec4 final_fire_color = texture(fire_color, vec2(fire_intensity));

	// Assign final color output
	COLOR.rgb = final_fire_color.rgb;
	COLOR.a = final_fire_color.a;
}