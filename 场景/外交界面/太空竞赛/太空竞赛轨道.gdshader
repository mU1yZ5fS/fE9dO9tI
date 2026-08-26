shader_type canvas_item;

// ═══════════════════════════════════════════════════════════
// 太空竞赛作战室 · 平面轨道监视屏
// 星球大战式矢量荧光屏：极坐标网格 + 轨道环 + 移动目标括号
// + 雷达扫掠 + 中央行星表面扫描带 + 扫描线噪点。
// 中国目标为红色脉冲，其他目标为磷光绿。
// ═══════════════════════════════════════════════════════════

uniform float aspect : hint_range(0.5, 3.0) = 1.06;
uniform vec3 phosphor : source_color = vec3(0.25, 1.0, 0.47);
uniform vec3 alert_red : source_color = vec3(1.0, 0.16, 0.10);
uniform float grid_density : hint_range(4.0, 16.0) = 8.0;

const float CIRCLE = 6.28318530718;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 orbit_point(float r, float speed, float phase) {
	float a = TIME * speed + phase;
	return r * vec2(cos(a), sin(a));
}

float ring_line(float r, float radius, float w) {
	return 1.0 - smoothstep(0.0, w, abs(r - radius));
}

// 目标括号：方形边框标记（矢量雷达风格）
float sat_bracket(vec2 p, vec2 c, float s) {
	vec2 d = abs(p - c);
	float m = max(d.x, d.y);
	float band = 1.0 - smoothstep(0.004, 0.012, abs(m - s * 0.62));
	float cap = step(max(d.x, d.y), s * 0.66);
	return band * cap;
}

// 目标后方渐隐尾迹弧
float trail_arc(float rr, float speed, float phase, float r, float ang_v) {
	float aa = TIME * speed + phase;
	float dd = fract((aa - ang_v)  / CIRCLE);
	return ring_line(r, rr, 0.0045) * exp(-dd * 6.0);
}

void fragment() {
	vec2 p = (UV - vec2(0.5)) * vec2(aspect, 1.0) * 2.0;
	float r = length(p);
	float ang_v = atan(p.y, p.x);

	// —— 底色：深空黑绿 + 微弱辉光 ——
	vec3 col = vec3(0.004, 0.016, 0.012);
	col += vec3(0.004, 0.020, 0.030) * clamp(1.0 - r * 0.55, 0.0, 1.0);

	// —— 雷达扫掠亮区 ——
	float sweep_a = mod(TIME * 0.55, CIRCLE);
	float da = mod(sweep_a - ang_v, CIRCLE);
	float sweep = exp(-da * 2.2);
	col += phosphor * sweep * 0.055;

	// —— 细密极坐标网格（随扫掠增亮） ——
	float gr = fract(r * grid_density);
	float rings = 1.0 - smoothstep(0.0, 0.07, min(gr, 1.0 - gr));
	col += phosphor * rings * (0.045 + sweep * 0.11);
	float ga = fract(ang_v  / CIRCLE * 24.0);
	float spokes = (1.0 - smoothstep(0.0, 0.035, min(ga, 1.0 - ga))) * step(0.14, r);
	col += phosphor * spokes * (0.035 + sweep * 0.09);

	// —— 四条主任务轨道 ——
	float orbits = ring_line(r, 0.34, 0.006)
			+ ring_line(r, 0.52, 0.006)
			+ ring_line(r, 0.70, 0.006)
			+ ring_line(r, 0.88, 0.005);
	col += phosphor * orbits * (0.32 + sweep * 0.5);

	// —— 十字准线 ——
	float cross_l = ((1.0 - smoothstep(0.0, 0.0025, abs(p.x)))
			+ (1.0 - smoothstep(0.0, 0.0025, abs(p.y)))) * step(r, 0.95);
	col += phosphor * cross_l * 0.22;

	// —— 中央行星：暗面 + 表面扫描带 + 边缘辉光 ——
	float planet_r = 0.155;
	float pd = 1.0 - smoothstep(planet_r - 0.004, planet_r, r);
	vec3 surf = vec3(0.012, 0.050, 0.090);
	float bands = smoothstep(0.75, 1.0, sin(p.y * 46.0 - TIME * 1.6)) * 0.5
			+ smoothstep(0.90, 1.0, sin(p.y * 23.0 + TIME * 0.7 + p.x * 6.0)) * 0.5;
	surf += phosphor * bands * 0.10;
	col = mix(col, surf, pd);
	float limb = (1.0 - smoothstep(planet_r * 0.82, planet_r, r)) * pd;
	col += phosphor * limb * (0.22 + sweep * 0.30);
	col += phosphor * ring_line(r, planet_r + 0.012, 0.004) * 0.45;

	// —— 绿方目标（美苏阵营）：括号 + 尾迹 ——
	vec2 s1 = orbit_point(0.34, 0.42, 0.0);
	vec2 s2 = orbit_point(0.52, -0.31, 2.1);
	vec2 s3 = orbit_point(0.52, -0.31, 4.4);
	vec2 s4 = orbit_point(0.70, 0.22, 1.2);
	vec2 s5 = orbit_point(0.88, -0.15, 5.3);
	float g = sat_bracket(p, s1, 0.045)
			+ sat_bracket(p, s2, 0.045)
			+ sat_bracket(p, s3, 0.045)
			+ sat_bracket(p, s4, 0.045)
			+ sat_bracket(p, s5, 0.045);
	col += phosphor * g * 1.5;
	float tr = trail_arc(0.34, 0.42, 0.0, r, ang_v)
			+ trail_arc(0.52, -0.31, 2.1, r, ang_v)
			+ trail_arc(0.52, -0.31, 4.4, r, ang_v)
			+ trail_arc(0.70, 0.22, 1.2, r, ang_v)
			+ trail_arc(0.88, -0.15, 5.3, r, ang_v);
	col += phosphor * tr * 0.50;

	// —— 红色目标（中国航天器）：呼吸括号 + 外扩脉冲环 + 尾迹 ——
	vec2 cc = orbit_point(0.70, 0.30, 3.6);
	col += alert_red * sat_bracket(p, cc, 0.060) * (1.4 + 0.7 * sin(TIME * 6.0));
	float pr = fract(TIME * 0.45);
	float dr = length(p - cc);
	col += alert_red * ring_line(dr, 0.05 + pr * 0.35, 0.008) * (1.0 - pr) * 0.9;
	col += alert_red * trail_arc(0.70, 0.30, 3.6, r, ang_v) * 0.8;

	// —— CRT 后期：扫描线 + 噪点闪烁 + 暗角 ——
	float sl = 0.90 + 0.10 * sin(UV.y * 720.0);
	col *= sl;
	col *= 1.0 + (hash21(vec2(floor(TIME * 24.0), 7.0)) - 0.5) * 0.05;
	col *= (1.0 - smoothstep(0.58, 1.42, r)) * 0.85 + 0.15;

	COLOR = vec4(col, 1.0);
}
