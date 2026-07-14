class_name PoliticianData
extends Resource

## 政治家数据。对应原版 Politic 类（22字段）。

# ── 姓名 ──
@export var name_first: int = 0             # 名索引 → polit_names
@export var name_last: int = 0              # 姓索引 → polit_surnames
@export var name_display: String = ""       # 运行时拼接的全名

# ── 特质 ──
@export var trait_personality: int = 0      # traits[0]: 0=极左 1=温和 2=改良 3=自由
@export var trait_alignment: int = 4        # traits[1]: 4=坚定 5=务实 6=温和 7=科学家
@export var trait_special: int = 8          # traits[2]: 8-18 特殊特质

# ── 数值 ──
@export var loyalty: int = 50               # 对玩家/领导人的忠诚度 (0-100)
@export var loyalty_matrix: Array[int] = [] # 对其他17位政治家的忠诚度
@export var power: int = 0                  # 政治权力
@export var age: int = 40
@export var experience: int = 10            # 经验等级

# ── 派系 ──
@export var faction: int = -1               # 所属派系编号 0-4
@export var in_power: bool = false          # 是否在职

# ── 头像 ──
@export var face_type: int = 0              # 脸部模板
@export var face_parts: Array[int] = []     # 8个面部部件索引
@export var jacket: int = 0                 # 服装索引

# ── 监察与阴谋 ──
@export var is_under_surveillance: bool = false     # is_sleshka
@export var is_under_investigation: bool = false    # is_sledstvie
@export var is_conspiracy: bool = false             # is_sagovor
@export var days_surveillance: int = 0              # days_sleshka
@export var investigator_index: int = -1            # sled_slej

# ── 其他 ──
@export var wanted_position: int = 3        # wantedDolzh
@export var auto_support: int = 0           # 自动支持值
@export var auto_hound: int = 0             # 自动迫害值
@export var is_citizen_dlc: bool = false    # 是否从 Persona 转换

func _init() -> void:
	face_parts.resize(8)
	loyalty_matrix.resize(18)
	for i in 18:
		loyalty_matrix[i] = 50

## 获取意识形态标签
func ideology_label() -> String:
	match trait_personality:
		0: return "极左/毛主义者"
		1: return "温和派"
		2: return "改良派"
		3: return "自由派"
	return "未知"

## 获取对齐标签
func alignment_label() -> String:
	match trait_alignment:
		4: return "坚定"
		5: return "务实"
		6: return "温和"
		7: return "科学家"
	return "未知"
