// ============================================================================
// 地图渲染 shader —— 自主两级调色板
// ============================================================================
// region_map(8K,只读) 每像素编码 region_id = (R<<16)|(G<<8)|B，0=水域
//   ① owner_palette: region_id → 归属 gwcode（领土变迁只改这里）
//   ② color_palette: gwcode → 显示颜色（换着色模式只改这里）
// 流程：region_id → owner → color，邻域 owner 比较画国界，选中/悬停高亮
// ============================================================================
shader_type spatial;
render_mode unshaded, cull_disabled;

// ---- 输入纹理（均最近邻，避免 id 插值错误）----
uniform sampler2D region_map : filter_nearest;
uniform sampler2D owner_palette : filter_nearest;
uniform sampler2D color_palette : filter_nearest;

// ---- 交互状态 ----
uniform int selected_gwcode = 0;
uniform int hover_gwcode = 0;

// ---- 外观 ----
uniform vec4 water_color : source_color = vec4(0.07, 0.22, 0.38, 1.0);
uniform vec4 border_color : source_color = vec4(0.02, 0.02, 0.02, 0.75);
uniform vec4 selected_color : source_color = vec4(1.0, 0.92, 0.15, 1.0);
uniform vec4 hover_color : source_color = vec4(1.0, 1.0, 1.0, 0.85);

// ---- 昼夜 ----
uniform bool day_night_enabled = true;
uniform vec3 sun_direction_local = vec3(0.45, 0.20, 0.87);
uniform vec4 night_tint : source_color = vec4(0.025, 0.04, 0.085, 1.0);
uniform float night_strength : hint_range(0.0, 1.0) = 0.55;
uniform float terminator_softness : hint_range(0.01, 0.5) = 0.09;

varying vec3 globe_normal;


void vertex() {
	globe_normal = normalize(VERTEX);
}


// value = (R<<16)|(G<<8)|B —— 与 GDScript _encode_id/_decode_id 一致
int decode_id(vec4 c) {
	return (int(c.r * 255.0 + 0.5) << 16) | (int(c.g * 255.0 + 0.5) << 8) | int(c.b * 255.0 + 0.5);
}

// 调色板索引：id 低 8 位 → U，高 8 位 → V（+0.5 居中到纹素中心）
vec2 pal_uv(int id) {
	return vec2((float(id & 255) + 0.5) / 256.0, (float((id >> 8) & 255) + 0.5) / 256.0);
}

int region_id_at(vec2 uv) {
	return decode_id(texture(region_map, uv));
}

// 取某 UV 处的归属 gwcode（水域返回 0）
int owner_at(vec2 uv) {
	int rid = region_id_at(uv);
	if (rid == 0) { return 0; }
	return decode_id(texture(owner_palette, pal_uv(rid)));
}

vec3 apply_day_night(vec3 color) {
	if (!day_night_enabled) { return color; }
	vec3 n = normalize(globe_normal);
	vec3 s = normalize(sun_direction_local);
	float light = dot(n, s);
	float night = 1.0 - smoothstep(-terminator_softness, terminator_softness, light);
	float edge = exp(-pow(light / max(terminator_softness, 0.001), 2.0));
	vec3 tinted = mix(color, night_tint.rgb, night * night_strength);
	return tinted + vec3(0.035, 0.026, 0.014) * edge * (1.0 - night * 0.45);
}


void fragment() {
	int rid = region_id_at(UV);
	if (rid == 0) {
		// 水域（fragment 不支持 return，用 else 分支）
		ALBEDO = apply_day_night(water_color.rgb);
		EMISSION = vec3(0.0);
	} else {
		int owner = decode_id(texture(owner_palette, pal_uv(rid)));
		vec3 base = texture(color_palette, pal_uv(owner)).rgb;

		// 国界线：邻域 owner 不同即为边界（同国下属区域自然合并）
		vec2 px = 1.0 / vec2(textureSize(region_map, 0));
		bool border = owner_at(UV + vec2(px.x, 0.0)) != owner
			|| owner_at(UV - vec2(px.x, 0.0)) != owner
			|| owner_at(UV + vec2(0.0, px.y)) != owner
			|| owner_at(UV - vec2(0.0, px.y)) != owner;

		// 选中/悬停发光
		vec3 emit = vec3(0.0);
		if (owner == selected_gwcode) { emit = selected_color.rgb * 0.36; }
		else if (owner == hover_gwcode) { emit = hover_color.rgb * 0.18; }

		if (border) {
			vec4 lc = border_color;
			if (owner == selected_gwcode) { lc = selected_color; }
			else if (owner == hover_gwcode) { lc = hover_color; }
			base = mix(base, lc.rgb, lc.a);
		}

		ALBEDO = apply_day_night(base);
		EMISSION = emit;
	}
}
