shader_type canvas_item;

uniform float alpha_percentage: hint_range(0.0, 1.0, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.a *= alpha_percentage;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
