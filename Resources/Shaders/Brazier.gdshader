shader_type canvas_item;

// warping and blending textures, Simplex Smooth noise
uniform sampler2D flame1_texture: repeat_enable;
uniform sampler2D flame2_texture: repeat_enable;
uniform sampler2D flame3_texture: repeat_enable;
// flame color gradient. Use a GradientTexture1D
uniform sampler2D color_gradient;
// for capturing the screen
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

vec4 blend_screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
	// scrolling vectors for 3 flame textures
	vec2 f1_uv = vec2(UV.x - TIME * 0.3, UV.y + TIME * 0.1);
	vec2 f2_uv = vec2(UV.x + TIME * 0.3, UV.y + TIME * 0.1);
	// gives our upward feeling
	vec2 f3_uv = vec2(UV.x, UV.y + TIME * 0.8);

	// calculate a flame distortion effect using 2 of the textures
	// sped up a bit from the samping
	float warp1 =  texture(flame1_texture, f1_uv * 2.1).r;
	float warp2 =  texture(flame2_texture, f2_uv * 2.1).r;
	// we only warp on the X axis as warping effectively in
	// other directions would require more data
	vec2 warp = vec2( warp1 - warp2, 0.0) * 0.05;

	// sample our flame noise textures
	float flame1_sample = texture(flame1_texture, f1_uv).r;
	float flame2_sample = texture(flame2_texture, f2_uv).r;
	float flame3_sample = texture(flame3_texture, f3_uv + warp).r;

	// Fire shape. Could use a texture instead
	// Half oval from bottom middle
	float shape_fade = 1.0 - sqrt(pow(UV.x - 0.5, 2.0) + pow(UV.y - 1.0, 2.0) * 0.2) * 2.0;

	// blend all of our flame samples together, giving more weight to the texture moving up
	float flame = ((flame1_sample + flame2_sample + flame3_sample * 1.5) / 3.5) * shape_fade;

	// give us a 1 or 0 to cut off the flame
	float alpha = step(0.12, flame);
	// slight larger cut off for warping effect
	float warp_alpha = smoothstep(0.0, 0.25, flame) * 0.7;

	// sample our background, including warping within the warp_alpha
	vec3 screen = texture(screen_texture, SCREEN_UV + warp * warp_alpha).rgb;
	// get a color by applying the color gradient to the flame
	vec3 color = texture(color_gradient, vec2(flame, 0.0)).rgb * flame * 3.5;

	// blend the colors with the screen
	// our mix applies the screen straight where our flame isn't
	// otherwise we use a screen style color blend
	COLOR = mix(vec4(screen, 1.0), blend_screen(vec4(screen, 1.0), vec4(color, 1.0)), alpha);
}