class_name PoliticianData
extends Resource

## 政治家数据。对应原版 Politic 类。
## 每个 .tres 文件即一位历史人物的完整模板。

# ── 身份 ──
@export var name_display: String = ""       # 显示全名（如"江青"）
@export var portrait: Texture2D = null      # 真实肖像（256×256 照片）
@export var is_historical: bool = true      # 历史固定人物标记

# ── 人物池控制 ──
@export var pool_priority: int = 0          # 预备池优先级（越大越先补入）
@export var entry_year: int = 1976          # 最早可登场年份
@export var exit_year: int = 9999           # 最晚在场年份（自然退场）

# ── 特质（对应原版 Politic.traits[4]，显示名见 Traits 表，不是 Party 表） ──
# traits[0]: 0极左 20保守 1温和 2改革 3自由
# traits[1]: 4硬汉 5实用主义 6宽容 7重视技术（扩展 29/30/39-42）
# traits[2]: 8-19 特殊
# traits[3]: 21-28/34/43 出身背景（月度被动效果；暗杀硬目标判定 ==28；34 托派仅托线可刷）
# Party 派系另有 0极左 1保守 2温和 3改革 4自由；映射见 party_index()
@export var trait_personality: int = 0
@export var trait_alignment: int = 4
@export var trait_special: int = 11
@export var trait_background: int = 0

# ── 数值 ──
@export var loyalty: int = 500              # 对玩家/领导人的忠诚度（内部×10，显示约 0~100）
@export var loyalty_matrix: Array[int] = [] # 对其他政治家的忠诚度
@export var power: int = 0                  # 政治权力
@export var age: int = 40
@export var experience: int = 10            # 经验等级

# ── 派系（Party 槽 0-4，与 trait_personality 不同表） ──
@export var faction: int = -1               # Party 索引 0-4
@export var in_power: bool = false          # 是否在职（持有 politics_positions）
@export var years_in_power: int = 0         # 任职累计年（原版 in_power 计数）

# ── 监察与阴谋 ──
@export var is_under_surveillance: bool = false
@export var is_under_investigation: bool = false
@export var is_conspiracy: bool = false
@export var you_fall: bool = false          # 政变/阴谋失败等「倒台未遂」标记
@export var days_surveillance: int = 0
@export var investigator_index: int = -1

# ── 其他 ──
@export var wanted_position: int = 3
@export var auto_support: int = 0
@export var auto_hound: int = 0
@export var is_citizen_dlc: bool = false

# ── 旧字段（保留兼容存档） ──
@export var name_first: int = 0
@export var name_last: int = 0
@export var face_type: int = 0
@export var face_parts: Array[int] = []
@export var jacket: int = 0

func _init() -> void:
	face_parts.resize(8)
	loyalty_matrix.resize(18)
	for i in 18:
		loyalty_matrix[i] = 50


## 矩阵长度对齐：名录扩容后把缺失段补为默认值（不缩容，旧档安全）。
func ensure_matrix_size(n: int, default_value: int = 50) -> void:
	var old := loyalty_matrix.size()
	if n <= old:
		return
	loyalty_matrix.resize(n)
	for i in range(old, n):
		loyalty_matrix[i] = default_value


## Party 槽：优先显式 faction；否则 traits[0] 启发式（0→0，20→1，1→2，2→3，3→4）
func party_index() -> int:
	if faction >= 0:
		return faction
	if trait_personality <= GameConstants.PoliticianPersonality.FAR_LEFT:
		return 0
	if trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
		return 1
	return trait_personality + 1


## 卡片第一行：Party 派系名
func ideology_label() -> String:
	return WorldFactory.PARTY_LABELS_ZH.get(party_index(), "未知")


## 第二槽出身背景标签：合法值域 21-28/34/43（traits[3]；34 托派自特质槽移入），
## 0 或缺省一律显示「未知」，避免误落到 traits[0] 的「极左派」标签。
func background_label() -> String:
	if (trait_background >= GameConstants.PoliticianBackground.PARTY_CADRE and trait_background <= GameConstants.PoliticianBackground.AMBITIOUS) \
			or trait_background == GameConstants.PoliticianBackground.SPECIAL \
			or trait_background == GameConstants.PoliticianSpecial.TROTSKYITE:
		return WorldFactory.TRAIT_LABELS_ZH.get(trait_background, "未知")
	return "未知"


## 卡片第二行：性格 traits[1]
func alignment_label() -> String:
	return WorldFactory.TRAIT_LABELS_ZH.get(trait_alignment, "未知")


## 是否拥有“真实人物肖像”。
## 之前把所有 `N_N.png` 编号图一律判为无肖像，导致大量实际有肖像的人物也显示“无肖像”。
## 现在改为：只要 portrait 非空就认为有肖像；确属错误复用的个例，应在对应
## .tres 里把 portrait 置空（而不是在全局判定里按文件名误伤）。
func has_real_portrait() -> bool:
	return portrait != null


## 深拷贝
func make_instance() -> PoliticianData:
	var inst := duplicate(true) as PoliticianData
	inst.loyalty_matrix = loyalty_matrix.duplicate()
	inst.face_parts = face_parts.duplicate()
	inst.is_under_surveillance = false
	inst.is_under_investigation = false
	inst.is_conspiracy = false
	inst.you_fall = false
	inst.days_surveillance = 0
	inst.investigator_index = -1
	inst.in_power = false
	inst.years_in_power = 0
	inst.auto_support = 0
	inst.auto_hound = 0
	return inst
