shader_type canvas_item;

render_mode blend_mix;

// 承载面放大倍数：>1.0 时可让阴影绘制超出原 Sprite 矩形
uniform float carrier_scale = 1.0;

// 灰度高度图：0=地面，1=最高处（由美术约定）
uniform sampler2D height_map : filter_nearest, repeat_disable;
// 原图采样（用于 alpha 掩码；不要依赖内建 TEXTURE，避免在辅助函数中报未定义）
uniform sampler2D albedo_map : filter_nearest, repeat_disable;

// 高度图 UV 缩放（以贴图中心为基准）。
// < 1.0：把高度图“缩小”（更集中在中间）；> 1.0：把高度图“放大”。
uniform float height_uv_scale = 1.0;

// 源贴图（颜色/高度）的采样区域缩放（以中心为基准）。
// 用途：当你把“阴影承载 Sprite”缩放得更大时，用这个参数让采样仍聚焦在中间的建筑区域，
// 从而让阴影可以画到原建筑贴图之外（但仍在承载 Sprite 的矩形内）。
// - > 1.0：源贴图在承载面中更“集中”（承载面更大，建筑占更小区域）
// - = 1.0：不改变
uniform vec2 source_uv_scale = vec2(1.0, 1.0);

// 太阳方向（在“贴图空间”里使用）：xy 控制影子方向，z 控制太阳高度（z 越大影子越短）。
// 这不是世界坐标的真实太阳向量，而是为了 2D 高度场投影而做的近似参数。
uniform vec3 sun_dir = vec3(0.6, 0.4, 1.0);

// 高度缩放：把 height_map 的 0..1 映射到“可投影的高度”。
uniform float height_scale = 1.0;

// 每步在 UV 上走多少像素（越大越快但更容易漏光/锯齿）
uniform float step_px = 1.0;

// 步进次数上限（越大越远的阴影越完整，但更耗）
uniform int steps = 32;

// 射线起点偏移（像素）：正值 = 向太阳方向偏移，让射线从 sprite 边缘外侧发出，
// 避免阴影在建筑内部出现偏移伪影；推荐从 step_px 的 0.5~1 倍开始调。
uniform float shadow_ray_offset_px = 0.0;

// 阴影边缘软化阈值（高度单位）：越大越柔和，越小越锐利
uniform float shadow_softness = 0.08;

// 是否启用 4tap 抗锯齿（沿光线垂直方向多重采样）
uniform bool shadow_aa_enabled = true;
// 抗锯齿采样半径（像素）
uniform float shadow_aa_radius_px = 0.75;

// 阴影强度与颜色（颜色通常用偏冷的深灰/蓝灰）
uniform float shadow_strength = 0.65;
uniform vec4 shadow_tint : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// 允许在原图透明区域也绘制阴影（需要你的 Sprite2D 纹理区域足够大，才能“画到建筑外的地面”）
uniform bool draw_shadow_on_transparent = true;
uniform float alpha_cutoff = 0.01;

// 用原图 alpha 作为“实体掩码”：透明像素不参与高度遮挡，避免圆角外的伪阴影。
uniform bool use_albedo_alpha_mask = true;

// 是否绘制原贴图（做“阴影专用 Sprite”时建议关掉）
uniform bool draw_albedo = true;

const int MAX_STEPS = 96;

void vertex() {
	VERTEX.xy *= max(carrier_scale, 1.0);
}

vec2 to_source_uv(vec2 uv) {
	// 把承载面的 UV 映射到源贴图的 UV（以中心为基准缩放）
	vec2 s = max(source_uv_scale, vec2(1e-4));
	return (uv - vec2(0.5)) * s + vec2(0.5);
}

float sample_height(vec2 uv) {
	vec2 huv = to_source_uv(uv);
	// 超出源贴图区域的地方视作“地面高度 0”，避免 clamp 到边缘造成阴影消失/异常。
	if (huv.x < 0.0 || huv.x > 1.0 || huv.y < 0.0 || huv.y > 1.0) {
		return 0.0;
	}

	float s = max(height_uv_scale, 1e-4);
	huv = (huv - vec2(0.5)) * s + vec2(0.5);
	huv = clamp(huv, vec2(0.0), vec2(1.0));
	// 用 R 通道作为高度；如果你的高度图存在 A 通道，也可以改成 .a
	float h = texture(height_map, huv).r * height_scale;
	if (use_albedo_alpha_mask) {
		float mask_alpha = texture(albedo_map, huv).a;
		h *= step(alpha_cutoff, mask_alpha);
	}
	return h;
}

float trace_shadow_occlusion(vec2 start_uv, float start_h, vec2 step_uv, float ray_rise_per_step, float edge_softness) {
	float occlusion = 0.0;
	float ray_h = start_h;
	vec2 uv = start_uv;

	for (int i = 0; i < MAX_STEPS; i++) {
		if (i >= steps) {
			break;
		}

		uv -= step_uv;
		ray_h += ray_rise_per_step;

		// 越界直接停止
		if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
			break;
		}

		float h = sample_height(uv);
		// 把硬阈值(h > ray_h)改成软阈值，减轻锯齿
		float occ_step = smoothstep(0.0, edge_softness, h - ray_h);
		occlusion = max(occlusion, occ_step);
		if (occlusion > 0.999) {
			break;
		}
	}

	return occlusion;
}

void fragment() {
	vec2 src_uv = to_source_uv(UV);
	bool in_src = (src_uv.x >= 0.0 && src_uv.x <= 1.0 && src_uv.y >= 0.0 && src_uv.y <= 1.0);

	vec4 base = vec4(0.0);
	if (draw_albedo && in_src) {
		base = texture(TEXTURE, src_uv) * COLOR;
	}

	// 当前像素高度（同一张 UV 对齐的高度图）
	float h0 = sample_height(UV);

	// 归一化后的太阳方向（贴图空间近似）
	vec3 L = normalize(sun_dir);
	float sun_xy_len = max(length(L.xy), 1e-5);
	float sun_z = max(L.z, 1e-4);

	// 沿“指向太阳”的反方向采样（从当前点往太阳方向追溯遮挡物）
	vec2 dir_uv = normalize(L.xy);
	float px_to_uv = length(TEXTURE_PIXEL_SIZE);
	vec2 step_uv = dir_uv * (step_px * px_to_uv);

	// 简化的“每走一步，射线高度上升多少”
	// 这里的单位是经验近似：想要更物理，需要把高度单位和像素/UV单位严格统一。
	float ray_rise_per_step = (sun_z / sun_xy_len) * (step_px * 0.02);

	// 射线起点：向太阳方向偏移 shadow_ray_offset_px 像素，让射线从建筑外侧发出
	vec2 ray_offset = dir_uv * (shadow_ray_offset_px * px_to_uv);
	vec2 start_uv = UV + ray_offset;
	float edge_softness = max(shadow_softness, 1e-4);

	float occlusion = trace_shadow_occlusion(start_uv, h0, step_uv, ray_rise_per_step, edge_softness);

	// 4tap 抗锯齿：沿光线垂直方向做多重采样，缓解边缘像素跳变
	if (shadow_aa_enabled && shadow_aa_radius_px > 0.0) {
		vec2 perp_uv = vec2(-dir_uv.y, dir_uv.x) * (shadow_aa_radius_px * px_to_uv);

		float h_p05 = sample_height(UV + perp_uv * 0.5);
		float h_n05 = sample_height(UV - perp_uv * 0.5);
		float h_p15 = sample_height(UV + perp_uv * 1.5);
		float h_n15 = sample_height(UV - perp_uv * 1.5);

		float occ_p05 = trace_shadow_occlusion(start_uv + perp_uv * 0.5, h_p05, step_uv, ray_rise_per_step, edge_softness);
		float occ_n05 = trace_shadow_occlusion(start_uv - perp_uv * 0.5, h_n05, step_uv, ray_rise_per_step, edge_softness);
		float occ_p15 = trace_shadow_occlusion(start_uv + perp_uv * 1.5, h_p15, step_uv, ray_rise_per_step, edge_softness);
		float occ_n15 = trace_shadow_occlusion(start_uv - perp_uv * 1.5, h_n15, step_uv, ray_rise_per_step, edge_softness);

		occlusion = (occlusion + occ_p05 + occ_n05 + occ_p15 + occ_n15) / 5.0;
	}

	float shadow = shadow_strength * occlusion;

	// 只在可见像素上压暗，或在透明区域“补画地面阴影”
	vec4 out_color = vec4(0.0);
	if (base.a > alpha_cutoff) {
		base.rgb = mix(base.rgb, base.rgb * (1.0 - shadow), shadow);
		out_color = base;
	} else if (draw_shadow_on_transparent && shadow > 0.0) {
		out_color = shadow_tint;
		out_color.a *= shadow;
	}

	COLOR = out_color;
}