shader_type spatial;
// 渲染模式：blend_mix=标准半透明混合, unshaded=不受光照影响, cull_front=剔除正面（从球体内部看向外面时可见）
render_mode blend_mix, unshaded, cull_front;

// 3D哈希函数：输入一个三维向量，输出0~1之间的伪随机值
// 用于在球面上生成看似随机的星点分布
float hash3(vec3 p) {
	// 点积 + 正弦 + 取小数：经典的GPU随机数生成方法
	return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

void fragment() {
	// 将法线从模型空间转换到世界空间并归一化
	// 法线方向代表了球面上每个片元指向的方向
	vec3 world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);

	// 将球面按法线方向划分成120×120×120的网格单元
	// 每个单元对应天空中的一小块区域，作为一颗"潜在星星"的位置
	vec3 cell = floor(world_normal * 120.0);

	// 对该网格单元做哈希，得到0~1的随机值
	float h = hash3(cell);

	// 只有哈希值 > 0.997 的单元格才会成为星星（约占0.3%的单元格）
	// smoothstep 使星星边缘略微柔化
	float star = smoothstep(0.997, 1.0, h);

	if (star > 0.01) {
		// --- 该片元是一颗星星 ---

		// 随机亮度：范围 0.45 ~ 1.0，保证星星不会太暗
		float brightness = hash3(cell + vec3(1.0, 2.0, 3.0)) * 0.55 + 0.45;

		// 随机色调：在蓝白色(0.85, 0.9, 1.0)和暖黄色(1.0, 0.92, 0.75)之间混合
		// 混合比例由另一组哈希值控制，最多偏移30%向暖色
		vec3 tint = mix(vec3(0.85, 0.9, 1.0), vec3(1.0, 0.92, 0.75), hash3(cell + 999.0) * 0.3);

		// 最终颜色 = 色调 × 亮度
		ALBEDO = tint * brightness;
		// Alpha由smoothstep决定，边缘有柔化过渡
		ALPHA = star;
	} else {
		// --- 该片元不是星星，完全透明 ---
		ALPHA = 0.0;
		ALBEDO = vec3(0.0);
	}
}
