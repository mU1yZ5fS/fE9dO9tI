extends Node3D
## 「纪念堂」—— 关于界面的 3D 参观模式。
## 第一人称漫游：南墙《写给每一位来访者》、西廊《历史画卷》、东廊《时代剪影》全量插画、
## 两侧致谢墙、柱廊与长明灯、北端纪念碑与英灵名录。
## 操作：WASD 行走 / Shift 快步 / Space 跳跃 / E 近赏展品 / Esc 菜单 / B 返回主菜单。
## 成员名单集中在下方常量区，增删即改即生效，馆内展墙自动同步。

# ── 导航与资源 ──────────────────────────────────────────────
const 主菜单场景 := "uid://bydan4iqthbaa" # 与旧版关于界面的返回目标保持一致
const 字体: Font = preload("res://资产/字体/方正跃进简体.ttf")
const 点击音效: AudioStream = preload("res://资产/音频/音效/click_default.wav")

# ── 名单数据：往数组里追加名字即可 ──
const 重制组成员: Array[String] = [
	"mU1yZ5fS", # Godot 重制工程 · 程序重构 / 主负责
]

const 致谢板块 := [
	{
		"标题": "原作 · 汉化",
		"行": [
			"《中国：毛的遗产》原作开发组",
			"",
			"GKchP 汉化组",
			"",
			"改版制作组",
		],
	},
	{
		"标题": "Godot 重制工程",
		"行": [
			"总负责 · 主程序",
			"XX****",
			"",
			"",
			"Godot 重制组全体成员",
			"",
			"（名单持续收录中，欢迎联系补充）",
		],
	},
	{
		"标题": "美术 · 音频 · 测试",
		"行": [
			"界面与场景视觉",
			"重制组美术组",
			"",
			"音频整理",
			"曲集 · 音效适配",
			"",
			"内测体验",
			"全体参与者",
		],
	},
	{
		"标题": "特别鸣谢",
		"行": [
			"Godot Engine 开发团队与全球社区",
			"Jolt Physics 物理引擎作者及贡献者",
			"方正字库 · 方正跃进简体",
			"所有提交反馈与 Issue 的玩家",
			"",
			"以及 —— 此刻正在参观的你",
		],
	},
]

# 西廊展品（大画单排）
const 西侧画作 := [
	{
		"路径": "res://资产/关于/匿名.jpg",
		"标题": "XX****",
		"说明": "总有一天光明要来到————“不愿透露姓名的代码组成员”",
	},
	{
		"路径": "res://资产/关于/Kazuha1029.png",
		"标题": "Kazuha1029",
		"说明": "知我罪我，其惟春秋",
	},
	{
		"路径": "res://资产/关于/丰川祥子.jpg",
		"标题": "丰川祥子",
		"说明": "冷冷的冰雨无情地泼洒在纪念堂前，伟大的无产阶级理想仿佛留在了春日的幻影中，\n欢迎回到过去，他们仍然在这里，但你只有最后一次机会，做一日雄狮，胜于百年羔羊。",
	},
	{
		"路径": "res://资产/关于/威廉先生.jpg",
		"标题": "威廉先生",
		"说明字号": 20,
		"说明": "面对自由而有尊严的自我批评，我们不应惧怕其后果，正因如此，我们要说：我们衰落了！\n我们消极被动地与“他人”搅在一起，与“他人”的政治图谋、虚假问题、意识形态主张纠缠不清。\n他者已经重新殖民了我们那些至少是模棱两可地与“他人”绑在一起的最终目标。所有人的表现——先是领导人，后是游击队员——往好的说是天真，往坏的说是愚钝。",
	},
	{
		"路径": "res://资产/加载图/4.png",
		"标题": "**",
		"说明": "*"
	},
	{
		"路径": "res://资产/加载图/5.png",
		"标题": "**",
		"说明": "*"
	},
]

# 东廊展品：事件插画全量收录
const 东侧编号 := ["38", "39", "40", "42", "43", "47", "48", "50", "51", "52", "53", "54", "56", "57", "60"]
const 汉数字 := ["壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾", "拾壹", "拾贰", "拾叁", "拾肆", "拾伍"]

# 北端英灵名录横幅
## ── 主席半身像 ──
const 雕像场景: PackedScene = preload("res://资产/关于/毛主席.glb") # uid://brgbpejiajwp6
const 雕像目标高度 := 1.9        # 自动归一化后的展示高度（米）
const 雕像朝向度 := 0.0          # 0 = 面向入口(+Z)；导入朝向不对可改 180.0
const 雕像铜材质覆盖 := true     # 自带贴图不佳保持 true；有精修贴图改 false
const 雕像铭文 := "人民万岁"

const 名录行 := "原作开发组 · GKchP 汉化组 · 改版制作组 · Godot 重制组  · 全体玩家 · 以及每一位来访者"

# ── 移动手感 ────────────────────────────────────────────────
const 走速 := 4.6
const 跑速 := 8.4
const 跳速 := 4.8
const 重力加速度 := 12.0
const 鼠标灵敏度 := 0.0021

# ── 运行状态 ────────────────────────────────────────────────
var 偏航 := 0.0
var 俯仰 := 0.0
var 步频 := 0.0
var 时间 := 0.0
var 暂停中 := false
var 观展中 := false
var 运镜中 := true
var 已离开 := false
var 注视目标: Area3D = null

var _长明灯: Array[Dictionary] = []
var _星体材质: StandardMaterial3D
var _光柱材质: StandardMaterial3D
var _升降动画: Tween
var _序幕动画: Tween

@onready var _玩家: CharacterBody3D = $玩家
@onready var _头部: Node3D = $玩家/头部
@onready var _相机: Camera3D = $玩家/头部/相机
@onready var _视线: RayCast3D = $玩家/头部/相机/视线
@onready var _主星: MeshInstance3D = $纪念大厅/主星
@onready var _星环: MeshInstance3D = $纪念大厅/星环
@onready var _圣光: OmniLight3D = $纪念大厅/圣光
@onready var _音乐: AudioStreamPlayer = $音乐
@onready var _界面音: AudioStreamPlayer = $界面音
@onready var _生成区: Node3D = $生成区
@onready var _准星: ColorRect = $UI/准星
@onready var _提示条: PanelContainer = $UI/提示条
@onready var _顶部题字: Label = $UI/顶部题字
@onready var _注视信息: PanelContainer = $UI/注视信息
@onready var _展品名: Label = $UI/注视信息/列表/展品名
@onready var _弹层: Control = $UI/观展弹层
@onready var _大图: TextureRect = $UI/观展弹层/中/内容/大图
@onready var _题名: Label = $UI/观展弹层/中/内容/题名
@onready var _说明: Label = $UI/观展弹层/中/内容/说明
@onready var _菜单层: Control = $UI/菜单层
@onready var _遮罩层: Control = $UI/开场遮罩
@onready var _黑幕: ColorRect = $UI/开场遮罩/黑幕
@onready var _序言: Label = $UI/开场遮罩/序言


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_视线.add_exception(_玩家)

	var 星网格 := _建星体网格()
	_主星.mesh = 星网格
	_星体材质 = StandardMaterial3D.new()
	_星体材质.albedo_color = Color(0.95, 0.78, 0.32)
	_星体材质.metallic = 0.9
	_星体材质.roughness = 0.22
	_星体材质.emission_enabled = true
	_星体材质.emission = Color(1.0, 0.72, 0.25)
	_星体材质.emission_energy_multiplier = 2.0
	_主星.material_override = _星体材质
	_光柱材质 = $纪念大厅/光柱.get_surface_override_material(0) as StandardMaterial3D

	var 静态金星 := 造材质(Color(0.9, 0.72, 0.28), 0.3, 1.0, Color(0.5, 0.3, 0.08), 0.6)
	挂东廊画作()
	挂西廊画作()
	for i in 致谢板块.size():
		var 板块: Dictionary = 致谢板块[i]
		var 在西侧 := i < 2
		var z := -16.0 if i % 2 == 0 else -29.0
		var x := -19.25 if 在西侧 else 19.25
		var 朝向 := 90.0 if 在西侧 else -90.0
		立致谢墙(String(板块["标题"]), 板块["行"], Vector3(x, 5.6, z), 朝向)
	建柱廊(星网格, 静态金星)
	建藻井灯带()
	建长明灯()
	建方尖碑(星网格, 静态金星)
	建徽记与名录(星网格, 静态金星)
	建伟人雕像()

	$UI/菜单层/中/菜单盒/继续按钮.pressed.connect(继续参观)
	$UI/菜单层/中/菜单盒/返回按钮.pressed.connect(返回主菜单)

	_界面音.stream = 点击音效

	var 曲 := _音乐.stream as AudioStreamMP3
	if 曲:
		曲.loop = true
	_音乐.volume_db = -36.0
	_音乐.play()
	create_tween().tween_property(_音乐, "volume_db", -14.0, 3.0)

	开始序幕()


# ════════════════════════ 开场演出 ════════════════════════

func 开始序幕() -> void:
	_提示条.modulate.a = 0.0
	_顶部题字.modulate.a = 0.0
	_准星.visible = false
	_头部.position = Vector3(0, 5.6, 0)
	俯仰 = -0.16

	_升降动画 = create_tween()
	_升降动画.tween_interval(0.2)
	_升降动画.tween_property(_头部, "position:y", 1.62, 2.8) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	_序幕动画 = create_tween()
	_序幕动画.tween_interval(0.35)
	_序幕动画.tween_property(_黑幕, "color:a", 0.0, 1.5)
	_序幕动画.tween_interval(1.3)
	_序幕动画.tween_property(_序言, "modulate:a", 0.0, 1.0)
	_序幕动画.tween_callback(结束演出)


func 结束演出() -> void:
	if not 运镜中:
		return
	运镜中 = false
	_遮罩层.visible = false
	渐显参观界面()


func 跳过演出() -> void:
	if not 运镜中:
		return
	if _升降动画:
		_升降动画.kill()
	if _序幕动画:
		_序幕动画.kill()
	_遮罩层.visible = false
	_黑幕.color.a = 0.0
	_序言.modulate.a = 0.0
	_头部.position = Vector3(0, 1.62, 0)
	运镜中 = false
	渐显参观界面()


func 渐显参观界面() -> void:
	var 渐显 := create_tween()
	渐显.set_parallel(true)
	渐显.tween_property(_提示条, "modulate:a", 1.0, 0.8)
	渐显.tween_property(_顶部题字, "modulate:a", 1.0, 0.8)
	渐显.set_parallel(false)
	渐显.tween_callback(func() -> void: _准星.visible = true)


# ════════════════════════ 输入 ════════════════════════

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not 暂停中 \
				and not 观展中 and not 运镜中:
			偏航 -= event.relative.x * 鼠标灵敏度
			俯仰 = clampf(俯仰 - event.relative.y * 鼠标灵敏度, -1.45, 1.45)
		return

	if event.is_action_pressed("ui_cancel"):
		if 运镜中:
			跳过演出()
		elif 观展中:
			关闭展品()
		elif 暂停中:
			继续参观()
		else:
			打开菜单()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var 码 := event.physical_keycode as int
		var 移动键 := 码 in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
		if 运镜中 and (移动键 or 码 == KEY_E):
			跳过演出()
			return
		if 码 == KEY_E and not 暂停中:
			if 观展中:
				关闭展品()
			elif 注视目标 != null:
				打开展品()
		elif 码 == KEY_B:
			返回主菜单()

	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if 运镜中:
			跳过演出()
		elif 观展中:
			关闭展品()
		elif 暂停中:
			pass
		elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif 注视目标 != null:
			打开展品()


# ════════════════════════ 移动与注视 ════════════════════════

func _physics_process(delta: float) -> void:
	var 可动 := not 暂停中 and not 观展中 and not 运镜中
	var 冲刺 := 可动 and Input.is_physical_key_pressed(KEY_SHIFT)
	var 速度目标 := 跑速 if 冲刺 else 走速
	var 前进 := 可动 and (Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	var 后退 := 可动 and (Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))
	var 左移 := 可动 and (Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	var 右移 := 可动 and (Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))

	var 局部 := Vector3(
		(1.0 if 右移 else 0.0) - (1.0 if 左移 else 0.0),
		0.0,
		(1.0 if 后退 else 0.0) - (1.0 if 前进 else 0.0))
	if 局部.length_squared() > 1.0:
		局部 = 局部.normalized()
	var 期望 := _玩家.global_transform.basis * (局部 * 速度目标)
	期望.y = 0.0
	if 期望.length_squared() > 0.01:
		期望 = 期望.normalized() * 速度目标 * 局部.length()

	var 水平 := Vector3(_玩家.velocity.x, 0.0, _玩家.velocity.z)
	水平 = 水平.lerp(期望, clampf(delta * 10.0, 0.0, 1.0))
	_玩家.velocity.x = 水平.x
	_玩家.velocity.z = 水平.z

	if not _玩家.is_on_floor():
		_玩家.velocity.y -= 重力加速度 * delta
	elif 可动 and Input.is_physical_key_pressed(KEY_SPACE):
		_玩家.velocity.y = 跳速

	_玩家.move_and_slide()
	_玩家.position.x = clampf(_玩家.position.x, -19.0, 19.0)
	_玩家.position.z = clampf(_玩家.position.z, -48.8, 48.8)

	_玩家.rotation.y = 偏航
	_头部.rotation.x = 俯仰

	var 平速 := Vector2(_玩家.velocity.x, _玩家.velocity.z).length()
	if not 运镜中:
		if _玩家.is_on_floor() and 平速 > 1.0:
			步频 += delta * (9.6 if 冲刺 else 7.2) * clampf(平速 / 走速, 0.6, 1.8)
			_头部.position.y = lerpf(_头部.position.y, 1.62 + sin(步频) * 0.05, delta * 12.0)
		else:
			_头部.position.y = lerpf(_头部.position.y, 1.62, delta * 8.0)
	var 目标视场 := 80.0 if (冲刺 and 平速 > 5.0) else 74.0
	_相机.fov = lerpf(_相机.fov, 目标视场, delta * 6.0)

	更新注视提示()


func 更新注视提示() -> void:
	if 暂停中 or 观展中 or 运镜中:
		_注视信息.visible = false
		设置准星(false)
		return
	var 命中 := _视线.get_collider()
	if 命中 is Area3D and 命中.has_meta("exhibit"):
		注视目标 = 命中
		_展品名.text = String(命中.get_meta("exhibit")["题"])
		_注视信息.visible = true
		设置准星(true)
	else:
		注视目标 = null
		_注视信息.visible = false
		设置准星(false)


func 设置准星(有目标: bool) -> void:
	if 有目标:
		_准星.color = Color(0.98, 0.84, 0.4, 0.95)
		_准星.offset_left = -4
		_准星.offset_top = -4
		_准星.offset_right = 4
		_准星.offset_bottom = 4
	else:
		_准星.color = Color(1, 1, 1, 0.85)
		_准星.offset_left = -2
		_准星.offset_top = -2
		_准星.offset_right = 2
		_准星.offset_bottom = 2


# ════════════════════════ 动态氛围 ════════════════════════

func _process(delta: float) -> void:
	时间 += delta
	_主星.rotate_y(delta * 0.32)
	_星环.rotate_y(-delta * 0.11)
	_主星.position.y = 8.6 + sin(时间 * 0.8) * 0.15
	_圣光.light_energy = 2.4 + sin(时间 * 1.6) * 0.5
	if _星体材质:
		_星体材质.emission_energy_multiplier = 2.0 + sin(时间 * 1.6) * 0.5
	if _光柱材质:
		_光柱材质.albedo_color.a = 0.10 + 0.03 * sin(时间 * 0.7)
	for 灯 in _长明灯:
		var 光: OmniLight3D = 灯["光"]
		var 相位: float = 灯["相位"]
		光.light_energy = 灯["基准"] * (0.82 + 0.14 * sin(时间 * 相位) + 0.06 * sin(时间 * 相位 * 3.7))


# ════════════════════════ 场景生成 ════════════════════════

func 东廊数据() -> Array:
	var 列表: Array = []
	for i in 东侧编号.size():
		列表.append({
			"路径": "res://资产/事件插画/%s.png" % 东侧编号[i],
			"标题": "插图 · %s" % 汉数字[i],
			"说明": "事件系统插画 · 原件编号 %s" % 东侧编号[i],
		})
	return 列表


func 挂西廊画作() -> void:
	var z位 := [36.0, 27.0, 18.0, 9.0, 0.0, -8.0]
	for i in 西侧画作.size():
		var 件: Dictionary = 西侧画作[i]
		挂一幅(String(件["路径"]), String(件["标题"]), String(件["说明"]),
				Vector3(-19.3, 5.6, z位[i]), 90.0, 3.0,
				int(件.get("说明字号", 28)))


func 挂东廊画作() -> void:
	var 数据 := 东廊数据()
	var 上排z := [29.0, 23.5, 18.0, 12.5, 7.0, 1.5, -4.0]
	var 下排z := [26.0, 20.8, 15.6, 10.4, 5.2, 0.0, -5.2, -10.4]
	for i in mini(上排z.size(), 数据.size()):
		var 件: Dictionary = 数据[i]
		挂一幅(String(件["路径"]), String(件["标题"]), String(件["说明"]),
				Vector3(19.3, 7.0, 上排z[i]), -90.0, 2.2,
				int(件.get("说明字号", 28)))
	var 起点 := 上排z.size()
	for i in mini(下排z.size(), 数据.size() - 起点):
		var 件2: Dictionary = 数据[起点 + i]
		挂一幅(String(件2["路径"]), String(件2["标题"]), String(件2["说明"]),
				Vector3(19.3, 3.3, 下排z[i]), -90.0, 2.0,
				int(件2.get("说明字号", 28)))


func 挂一幅(路径: String, 标题文字: String, 说明文字: String, 位置: Vector3, 朝向度: float, 高: float, 说明字号 := 28) -> void:
	var 纹理 := load(路径) as Texture2D
	if 纹理 == null:
		return
	var 尺寸 := 纹理.get_size()
	var 宽 := clampf(高 * 尺寸.x / maxf(尺寸.y, 1.0), 1.6, 4.8)

	var 组 := Node3D.new()
	_生成区.add_child(组)
	组.position = 位置
	组.rotation.y = deg_to_rad(朝向度)

	add_box(组, Vector3(宽 + 0.9, 高 + 0.9, 0.1), Vector3.ZERO, 绒布材质())
	var 画面 := MeshInstance3D.new()
	var 面 := QuadMesh.new()
	面.size = Vector2(宽, 高)
	画面.mesh = 面
	var 画材 := StandardMaterial3D.new()
	画材.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	画材.albedo_texture = 纹理
	画面.material_override = 画材
	画面.position = Vector3(0, 0, 0.09)
	组.add_child(画面)

	add_box(组, Vector3(宽 + 0.32, 0.16, 0.16), Vector3(0, 高 * 0.5 + 0.08, 0.1), 金材质())
	add_box(组, Vector3(宽 + 0.32, 0.16, 0.16), Vector3(0, -高 * 0.5 - 0.08, 0.1), 金材质())
	add_box(组, Vector3(0.16, 高 + 0.32, 0.16), Vector3(-宽 * 0.5 - 0.08, 0, 0.1), 金材质())
	add_box(组, Vector3(0.16, 高 + 0.32, 0.16), Vector3(宽 * 0.5 + 0.08, 0, 0.1), 金材质())

	var _铭牌 := add_label(组, 标题文字, Vector3(0, -高 * 0.5 - 0.55, 0.12), 46, 0.0085,
			Color(0.95, 0.88, 0.66), 12)
	var 简介 := add_label(组, 说明文字, Vector3(0, -高 * 0.5 - 1.06, 0.13), 说明字号, 0.0072,
			Color(0.87, 0.82, 0.72), 9)
	简介.position.y -= (说明字号 - 22) * 0.006
	简介.width = 1150.0
	简介.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	简介.line_spacing = 6

	var 区域 := Area3D.new()
	var 形状节点 := CollisionShape3D.new()
	var 盒 := BoxShape3D.new()
	盒.size = Vector3(宽 + 1.4, 高 + 1.8, 1.6)
	形状节点.shape = 盒
	形状节点.position = Vector3(0, 0, 0.2)
	区域.add_child(形状节点)
	区域.set_meta("exhibit", {"题": 标题文字, "述": 说明文字, "图": 纹理})
	组.add_child(区域)


func 立致谢墙(标题文字: String, 行内容: Array, 位置: Vector3, 朝向度: float) -> void:
	var 组 := Node3D.new()
	_生成区.add_child(组)
	组.position = 位置
	组.rotation.y = deg_to_rad(朝向度)

	add_box(组, Vector3(7.8, 8.8, 0.14), Vector3.ZERO, 绒布材质())
	add_box(组, Vector3(8.2, 0.18, 0.18), Vector3(0, 4.4, 0.05), 金材质())
	add_box(组, Vector3(8.2, 0.18, 0.18), Vector3(0, -4.4, 0.05), 金材质())
	add_box(组, Vector3(0.18, 8.98, 0.18), Vector3(-4.01, 0, 0.05), 金材质())
	add_box(组, Vector3(0.18, 8.98, 0.18), Vector3(4.01, 0, 0.05), 金材质())

	add_box(组, Vector3(5.4, 1.1, 0.1), Vector3(0, 3.35, 0.1), 金材质())
	add_label(组, 标题文字, Vector3(0, 3.38, 0.17), 64, 0.0095, Color(0.28, 0.11, 0.03))

	var 正文 := ""
	for 行 in 行内容:
		正文 += String(行) + "\n"
	正文 = 正文.strip_edges(false, true)
	var 牌文 := add_label(组, 正文, Vector3(0, -0.55, 0.12), 38, 0.008,
			Color(0.97, 0.92, 0.76))
	牌文.width = 900.0
	牌文.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	牌文.line_spacing = 12
	牌文.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func 建柱廊(星网格: ArrayMesh, 金星材质: StandardMaterial3D) -> void:
	var 绸材质 := 造材质(Color(0.48, 0.06, 0.075), 0.9, 0.0, Color(0.12, 0.02, 0.025), 0.4)
	for 侧 in [-1.0, 1.0]:
		for i in 7:
			var z := 30.0 - i * 10.0
			var 组 := Node3D.new()
			_生成区.add_child(组)
			组.position = Vector3(侧 * 14.0, 0, z)

			add_box(组, Vector3(2.2, 0.7, 2.2), Vector3(0, 0.35, 0), 石材质())
			var 身 := MeshInstance3D.new()
			var 柱 := CylinderMesh.new()
			柱.top_radius = 0.68
			柱.bottom_radius = 0.82
			柱.height = 11.6
			身.mesh = 柱
			身.material_override = 造材质(Color(0.3, 0.1, 0.11), 0.55, 0.08)
			身.position = Vector3(0, 6.5, 0)
			组.add_child(身)
			add_box(组, Vector3(2.0, 0.5, 2.0), Vector3(0, 12.55, 0), 金材质())

			add_box(组, Vector3(0.12, 4.8, 1.7), Vector3(-侧 * 1.05, 8.6, 0), 绸材质)
			var 徽 := MeshInstance3D.new()
			徽.mesh = 星网格
			徽.material_override = 金星材质
			徽.scale = Vector3.ONE * 0.34
			徽.position = Vector3(-侧 * 1.16, 9.5, 0)
			徽.rotation.y = deg_to_rad(-90.0 * 侧)
			组.add_child(徽)

			var 体 := StaticBody3D.new()
			var 形 := CollisionShape3D.new()
			var 柱形 := CylinderShape3D.new()
			柱形.radius = 0.85
			柱形.height = 12.4
			形.shape = 柱形
			形.position = Vector3(0, 6.2, 0)
			体.add_child(形)
			组.add_child(体)


func 建藻井灯带() -> void:
	for i in 11:
		var z := -40.0 + i * 8.0
		add_box(_生成区, Vector3(36, 0.35, 0.5), Vector3(0, 18.15, z), 金材质())
	for x in [-6.0, 6.0]:
		add_box(_生成区, Vector3(0.5, 0.35, 84), Vector3(x, 18.15, 0), 金材质())
	for z in [-32.0, -16.0, 0.0, 16.0, 32.0]:
		var 盘 := MeshInstance3D.new()
		var 柱 := CylinderMesh.new()
		柱.top_radius = 1.15
		柱.bottom_radius = 1.15
		柱.height = 0.14
		盘.mesh = 柱
		盘.material_override = 造材质(Color(0.2, 0.15, 0.1), 1.0, 0.0, Color(1, 0.85, 0.55), 2.2)
		盘.position = Vector3(0, 18.35, z)
		_生成区.add_child(盘)
		var 光 := OmniLight3D.new()
		光.light_color = Color(1, 0.85, 0.6)
		光.light_energy = 0.85
		光.omni_range = 15.0
		光.position = Vector3(0, 16.8, z)
		_生成区.add_child(光)


func 建长明灯() -> void:
	var z列 := [32.0, 20.0, 8.0, -4.0, -16.0, -26.0]
	for z in z列:
		for 侧 in [-1.0, 1.0]:
			var 组 := Node3D.new()
			_生成区.add_child(组)
			组.position = Vector3(侧 * 5.0, 0, z)

			var 座 := MeshInstance3D.new()
			var 柱 := CylinderMesh.new()
			柱.top_radius = 0.24
			柱.bottom_radius = 0.32
			柱.height = 1.05
			座.mesh = 柱
			座.material_override = 石材质()
			座.position = Vector3(0, 0.52, 0)
			组.add_child(座)

			var 盏 := MeshInstance3D.new()
			var 碗 := CylinderMesh.new()
			碗.top_radius = 0.3
			碗.bottom_radius = 0.18
			碗.height = 0.14
			盏.mesh = 碗
			盏.material_override = 金材质()
			盏.position = Vector3(0, 1.1, 0)
			组.add_child(盏)

			var 焰 := MeshInstance3D.new()
			var 球 := SphereMesh.new()
			球.radius = 0.17
			球.height = 0.36
			焰.mesh = 球
			焰.material_override = 造材质(Color(1, 0.45, 0.12), 1.0, 0.0, Color(1, 0.5, 0.15), 3.2)
			焰.position = Vector3(0, 1.32, 0)
			组.add_child(焰)

			var 光 := OmniLight3D.new()
			光.light_color = Color(1, 0.55, 0.22)
			光.light_energy = 1.5
			光.omni_range = 6.5
			光.position = Vector3(0, 1.55, 0)
			组.add_child(光)
			_长明灯.append({"光": 光, "相位": randf_range(5.0, 9.0), "基准": 1.5})


func 建方尖碑(星网格: ArrayMesh, 金星材质: StandardMaterial3D) -> void:
	var 黑石 := 造材质(Color(0.12, 0.09, 0.09), 0.35, 0.45)
	for 侧 in [-1.0, 1.0]:
		for z in [-26.0, -33.0, -40.0, -47.0]:
			var 组 := Node3D.new()
			_生成区.add_child(组)
			组.position = Vector3(侧 * 10.5, 0, z)

			add_box(组, Vector3(1.5, 0.8, 1.5), Vector3(0, 0.4, 0), 石材质())
			var 身 := MeshInstance3D.new()
			var 柱 := CylinderMesh.new()
			柱.top_radius = 0.3
			柱.bottom_radius = 0.62
			柱.height = 6.8
			身.mesh = 柱
			身.material_override = 黑石
			身.position = Vector3(0, 4.2, 0)
			组.add_child(身)

			var 顶星 := MeshInstance3D.new()
			顶星.mesh = 星网格
			顶星.material_override = 金星材质
			顶星.scale = Vector3.ONE * 0.42
			顶星.position = Vector3(0, 8.05, 0)
			组.add_child(顶星)

			var 灯 := SpotLight3D.new()
			灯.rotation.x = -PI / 2.0
			灯.light_color = Color(1, 0.8, 0.5)
			灯.light_energy = 3.0
			灯.spot_range = 11.0
			灯.spot_angle = 26.0
			灯.spot_angle_attenuation = 1.5
			灯.shadow_enabled = false
			灯.position = Vector3(0, 0.35, 0)
			组.add_child(灯)

			var 体 := StaticBody3D.new()
			var 形 := CollisionShape3D.new()
			var 盒 := BoxShape3D.new()
			盒.size = Vector3(1.4, 7.6, 1.4)
			形.shape = 盒
			形.position = Vector3(0, 3.8, 0)
			体.add_child(形)
			组.add_child(体)


func 建徽记与名录(星网格: ArrayMesh, 金星材质: StandardMaterial3D) -> void:
	var 徽星 := MeshInstance3D.new()
	徽星.mesh = 星网格
	徽星.material_override = 金星材质
	徽星.scale = Vector3.ONE * 2.7
	徽星.position = Vector3(0, 9, -49.24)
	_生成区.add_child(徽星)

	add_label(_生成区, 名录行, Vector3(0, 1.35, -49.36), 40, 0.0078,
			Color(0.93, 0.8, 0.5))


# ════════════════════════ 构建小工具 ════════════════════════

func 造材质(固色: Color, 粗糙 := 0.8, 金属 := 0.0, 自发光 := Color(0, 0, 0, -1), 光强 := 1.0) -> StandardMaterial3D:
	var 材 := StandardMaterial3D.new()
	材.albedo_color = 固色
	材.roughness = 粗糙
	材.metallic = 金属
	if 自发光.a >= 0.0:
		材.emission_enabled = true
		材.emission = 自发光
		材.emission_energy_multiplier = 光强
	return 材


func 绒布材质() -> StandardMaterial3D:
	return 造材质(Color(0.145, 0.032, 0.042), 0.95)


func 金材质() -> StandardMaterial3D:
	return 造材质(Color(0.88, 0.68, 0.24), 0.26, 1.0, Color(0.28, 0.17, 0.045), 0.35)


func 石材质() -> StandardMaterial3D:
	return 造材质(Color(0.19, 0.165, 0.165), 0.6, 0.18)


func add_box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var 节点 := MeshInstance3D.new()
	var 盒 := BoxMesh.new()
	盒.size = size
	节点.mesh = 盒
	节点.material_override = mat
	节点.position = pos
	parent.add_child(节点)
	return 节点


func add_label(parent: Node3D, 文字: String, pos: Vector3, 字号: int, pixel: float, 颜色: Color, 描边 := 0) -> Label3D:
	var 节点 := Label3D.new()
	节点.text = 文字
	节点.font = 字体
	节点.font_size = 字号
	节点.outline_size = 描边
	节点.pixel_size = pixel
	节点.modulate = 颜色
	节点.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	节点.position = pos
	parent.add_child(节点)
	return 节点


func _建星体网格() -> ArrayMesh:
	var 内径 := 0.42
	var 厚 := 0.22
	var 点 := PackedVector2Array()
	for i in 10:
		var 角 := deg_to_rad(90.0 + i * 36.0)
		var 半径 := 1.0 if i % 2 == 0 else 内径
		点.append(Vector2(cos(角), sin(角)) * 半径)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 10:
		var a := 点[i]
		var b := 点[(i + 1) % 10]
		var af := Vector3(a.x, a.y, 厚)
		var bf := Vector3(b.x, b.y, 厚)
		var ab := Vector3(a.x, a.y, -厚)
		var bb := Vector3(b.x, b.y, -厚)
		# 正面扇形（法线朝 +Z）
		st.add_vertex(Vector3(0, 0, 厚))
		st.add_vertex(af)
		st.add_vertex(bf)
		# 背面扇形（反向）
		st.add_vertex(Vector3(0, 0, -厚))
		st.add_vertex(bb)
		st.add_vertex(ab)
		# 侧面两三角
		st.add_vertex(af)
		st.add_vertex(bb)
		st.add_vertex(bf)
		st.add_vertex(af)
		st.add_vertex(ab)
		st.add_vertex(bb)
	st.generate_normals()
	return st.commit()


## ════════════════════════ 主席半身像 ════════════════════════

func 建伟人雕像() -> void:
	var 组 := Node3D.new()
	_生成区.add_child(组)
	组.position = Vector3(0, 1.5, -40)   # 三层基座顶面正中
	组.rotation.y = deg_to_rad(雕像朝向度)

	var 实例 := 雕像场景.instantiate()
	组.add_child(实例)

	# 自动归一化尺寸：合并所有网格 AABB，按高度缩放并落座于台面中心
	var 合框 := AABB()
	var 初次 := true
	for 网 in 实例.find_children("*", "MeshInstance3D", true, false):
		var 相对: Transform3D = 实例.global_transform.affine_inverse() * 网.global_transform
		var 框: AABB = 相对 * 网.get_aabb()
		合框 = 框 if 初次 else 合框.merge(框)
		初次 = false
	if not 初次:
		var 系数 := 雕像目标高度 / maxf(合框.size.y, 0.01)
		实例.scale = Vector3.ONE * 系数
		实例.position = Vector3(
			-(合框.position.x + 合框.size.x * 0.5) * 系数,
			-合框.position.y * 系数,
			-(合框.position.z + 合框.size.z * 0.5) * 系数)

	if 雕像铜材质覆盖:
		for 网2 in 实例.find_children("*", "MeshInstance3D", true, false):
			网2.material_override = 铜像材质()

	# 背板红绒，衬托轮廓
	add_box(组, Vector3(1.9, 2.4, 0.12), Vector3(0, 1.25, -0.55),
			造材质(Color(0.16, 0.035, 0.045), 0.95))

	# 布光：正面主聚光（投影）+ 背部轮廓 + 座前泛红（先入树，再瞄准）
	var 主灯 := SpotLight3D.new()
	主灯.light_color = Color(1, 0.86, 0.62)
	主灯.light_energy = 5.0
	主灯.spot_range = 10.0
	主灯.spot_angle = 27.0
	主灯.spot_angle_attenuation = 1.4
	主灯.shadow_enabled = true
	组.add_child(主灯)
	主灯.look_at_from_position(
		组.to_global(Vector3(1.1, 4.3, 2.8)),
		组.to_global(Vector3(0, 1.15, 0)))

	var 轮廓 := SpotLight3D.new()
	轮廓.light_color = Color(1, 0.93, 0.8)
	轮廓.light_energy = 2.2
	轮廓.spot_range = 7.5
	轮廓.spot_angle = 34.0
	组.add_child(轮廓)
	轮廓.look_at_from_position(
		组.to_global(Vector3(-0.7, 3.7, -2.9)),
		组.to_global(Vector3(0, 1.4, 0)))

	var 座光 := OmniLight3D.new()
	座光.light_color = Color(0.95, 0.45, 0.24)
	座光.light_energy = 0.85
	座光.omni_range = 3.2
	座光.position = Vector3(0, 0.35, 1.2)
	组.add_child(座光)

	# 座周缓缓上升的金色微尘
	var 微尘 := GPUParticles3D.new()
	微尘.amount = 26
	微尘.lifetime = 3.4
	微尘.preprocess = 1.6
	微尘.position = Vector3(0, 1.7, 0)
	微尘.visibility_aabb = AABB(Vector3(-2, -1, -2), Vector3(4, 5, 4))
	var 过程 := ParticleProcessMaterial.new()
	过程.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	过程.emission_box_extents = Vector3(0.75, 0.12, 0.75)
	过程.direction = Vector3(0, 1, 0)
	过程.spread = 18.0
	过程.gravity = Vector3(0, 0.5, 0)
	过程.initial_velocity_min = 0.25
	过程.initial_velocity_max = 0.75
	过程.scale_min = 0.4
	过程.scale_max = 1.0
	过程.color = Color(1, 0.82, 0.5, 0.55)
	微尘.process_material = 过程
	var 小片 := QuadMesh.new()
	小片.size = Vector2(0.05, 0.05)
	微尘.draw_pass_1 = 小片
	var 片材 := StandardMaterial3D.new()
	片材.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	片材.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	片材.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	片材.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	片材.vertex_color_use_as_albedo = true
	片材.cull_mode = BaseMaterial3D.CULL_DISABLED
	微尘.material_override = 片材
	组.add_child(微尘)

	# 交互区域：准星提示 + E 打开说明面板
	var 区域 := Area3D.new()
	var 形状节点 := CollisionShape3D.new()
	var 盒 := BoxShape3D.new()
	盒.size = Vector3(1.5, 2.4, 1.3)
	形状节点.shape = 盒
	形状节点.position = Vector3(0, 1.05, 0)
	区域.add_child(形状节点)
	区域.set_meta("exhibit", {
		"题": "毛主席半身像",
		"述": "人民领袖",
		"详": 雕像铭文,
	})
	组.add_child(区域)

	# 台前铭牌
	add_label(_生成区, "伟大领袖毛主席",
			Vector3(0, 1.22, -36.72), 44, 0.0082, Color(0.95, 0.88, 0.66), 12)
	var _台注 := add_label(_生成区, "按 E 阅读铭文",
			Vector3(0, 0.84, -36.72), 30, 0.0072, Color(0.89, 0.83, 0.73), 9)


func 铜像材质() -> StandardMaterial3D:
	var 材 := StandardMaterial3D.new()
	材.albedo_color = Color(0.33, 0.21, 0.115)
	材.metallic = 0.95
	材.roughness = 0.33
	材.rim_enabled = true
	材.rim = 0.65
	材.rim_tint = 0.25
	return 材


# ════════════════════════ 弹层与导航 ════════════════════════

func 打开展品() -> void:
	if 注视目标 == null:
		return
	var 信息: Dictionary = 注视目标.get_meta("exhibit")
	var 图: Texture2D = 信息.get("图")
	if 图 != null:
		_大图.texture = 图
		_大图.visible = true
	else:
		_大图.visible = false
	_题名.text = 信息["题"]
	_说明.text = String(信息.get("详", 信息.get("述", "")))
	_弹层.visible = true
	观展中 = true
	_注视信息.visible = false
	_准星.visible = false
	_界面音.play()


func 关闭展品() -> void:
	_弹层.visible = false
	_大图.visible = true
	观展中 = false
	_界面音.play()


func 打开菜单() -> void:
	_菜单层.visible = true
	暂停中 = true
	_注视信息.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_界面音.play()


func 继续参观() -> void:
	_菜单层.visible = false
	暂停中 = false
	if not 运镜中:
		_准星.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_界面音.play()


func 返回主菜单() -> void:
	if 已离开:
		return
	已离开 = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(主菜单场景)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
