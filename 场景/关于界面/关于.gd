extends Node3D
## 「纪念堂」—— 关于界面的 3D 参观模式。
## 3D场景内容（画作、致谢墙、柱廊、长明灯、方尖碑、徽记名录）已烘焙到.tscn
## 操作：WASD 行走 / Shift 快步 / Space 跳跃 / E 近赏展品 / Esc 菜单 / B 返回主菜单。

# ── 导航与资源 ──────────────────────────────────────────────
const 主菜单场景 := "uid://bydan4iqthbaa" # 与旧版关于界面的返回目标保持一致
const 字体: Font = preload("res://资产/字体/方正跃进简体.ttf") # 保留用于动态标签（如展品名称）
const 点击音效: AudioStream = preload("res://资产/音频/音效/click_default.wav")

# ── 名单数据已烘焙到.tscn ──
# 致谢板块、西廊画作、东廊画作等数据已移至烘焙工具
## ── 主席半身像（已烘焙到.tscn） ──
# 雕像场景、雕像目标高度等配置已移至烘焙工具

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

var _星体材质: StandardMaterial3D
var _升降动画: Tween
var _序幕动画: Tween

@onready var _玩家: CharacterBody3D = $玩家
@onready var _头部: Node3D = $玩家/头部
@onready var _相机: Camera3D = $玩家/头部/相机
@onready var _视线: RayCast3D = $玩家/头部/相机/视线
@onready var _主星: MeshInstance3D = $纪念大厅/主星
@onready var _音乐: AudioStreamPlayer = $音乐
@onready var _界面音: AudioStreamPlayer = $界面音
@onready var _准星: ColorRect = $UI/准星
@onready var _提示条: PanelContainer = $UI/提示条
@onready var _遮罩层: Control = $UI/开场遮罩
@onready var _黑幕: ColorRect = $UI/开场遮罩/黑幕
@onready var _序言: Label = $UI/开场遮罩/序言
@onready var _菜单层: Control = $UI/菜单层

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_视线.add_exception(_玩家)

	# ── 星体材质（主星在.tscn中，保留材质设置）──
	_星体材质 = StandardMaterial3D.new()
	_星体材质.albedo_color = Color(0.95, 0.78, 0.32)
	_星体材质.metallic = 0.9
	_星体材质.roughness = 0.22
	_星体材质.emission_enabled = true
	_星体材质.emission = Color(1.0, 0.72, 0.25)
	_星体材质.emission_energy_multiplier = 2.0
	_主星.material_override = _星体材质

	# ── 3D内容已烘焙到.tscn，不再动态生成 ──
	# 画作、致谢墙、柱廊、藻井灯带、长明灯、方尖碑、徽记名录、雕像
	# 均已在编辑器中通过烘焙工具生成并保存

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
		elif 码 == KEY_B:
			返回主菜单()

	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if 运镜中:
			跳过演出()
		elif 暂停中:
			pass
		elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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

# ════════════════════════ 弹层与导航 ════════════════════════


func 打开菜单() -> void:
	_菜单层.visible = true
	暂停中 = true
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
