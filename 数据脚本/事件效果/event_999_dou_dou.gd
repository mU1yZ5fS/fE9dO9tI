extends "res://数据脚本/event_script_base.gd"

## 原作 Event999.cs：豆豆不能随便投……（民主回卷终局事件）
## 触发：TimeScript.cs:10020-10024 —— data[170] == 999（哨兵值，结果里清零）。
## 差异记录：
##  - 原版 result 3/4/5 为不可达“测试”分支（kolvo_variant=2），按死代码跳过。
##  - party_change[] 仅 UI 摆动数值，Godot 未建模，跳过（与 event_020 同类约定）。
##  - show_notification=false：沿用现存 101 个事件的统一约定（原版地图标记机制未启用）。
##  - <color> 标签去除：事件 UI Label 未开 bbcode，颜色不渲染，文本逐字保留。
##  - 原版字符间空格排版在 Godot 不再保留（既有约定，下同）。

const TXT_RESULT := "一党制已经来了，它的政治伴娘们还会远吗？很快，党便带领着它的老将们迅速推出了旨在一举打击当前制度痛处的新宪法，紧接着的全国公投则使其所向披靡。终于，契合“基本国情的民主主义”得以确立：总统直选、分权制衡、宪政原则等词语纷纷蒸发，均让位给直接履行主权的人民意志。紧接着便是把全国最大、待遇最好且薪酬最高的马戏团作彻底洗牌。在收拾干净其中的跳梁小丑后重树作为立法部门的威严；在“人制定法律，因此法依人为”的口号下，我们以“司法越权”一词无限期冻结了弹劾权，并将元首的审批作为最高法院决定放行的最后关卡。我们的迅速行动切实如先前所料的那般攻无不克，战无不胜：面对宵禁与封锁线，抗议者们纷纷自投罗网，松散的抵抗完全无法形成串联，只一瞬便消失殆尽。让体制的封存得以顺利进行。此后，得到我党背书的宣传家们很快便拿出了有关人民内部矛盾的经典名言来好好教育社会：“自由是有领导的自由，民主是集中指导下的民主。”顺便拿十年浩劫时期的有害案例做了特别点拨。显然是为了证明我党的社会责任与绝不再入同一条河流的坚定决心……"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# Event999.cs result 0
			_add(W.I_THOUGHT_FREEDOM, 200)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_CORRUPTION, 100)
		1:
			# Event999.cs result 1
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -50)
			_add(W.I_PEOPLE_SUPPORT, -30)
			_add(W.I_CORRUPTION, 150)
		_:
			return
	# 两个结果共同的体制收束（Event999.cs result 0/1 完全一致，原版重复书写）
	_apply_one_party_reset()
	context["result_text"] = TXT_RESULT


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


## Event999.cs：is_party_enabled / is_party_ally / party_number / party_ideology 批量重写。
## Godot：ws.factions[i] 对应原版 party 槽（faction_data.gd 头注：support=party_number、
## ideology=party_ideology、is_enabled=is_party_enabled、is_ally=is_party_ally）。
func _apply_one_party_reset() -> void:
	if ws.factions.size() < 5:
		return
	ws.factions[0].is_enabled = false
	for i in range(1, 5):
		ws.factions[i].is_enabled = true
	ws.factions[0].is_ally = false
	for i in range(2, 5):
		ws.factions[i].is_ally = false
	# 原版：4号=400、3号=500、1号=50、2号=50、0号=0
	ws.factions[4].support = 400
	ws.factions[4].ideology = 400
	ws.factions[3].support = 500
	ws.factions[3].ideology = 500
	ws.factions[1].support = 50
	ws.factions[1].ideology = 50
	ws.factions[2].support = 50
	ws.factions[2].ideology = 50
	ws.factions[0].support = 0
	ws.factions[0].ideology = 0
	# Event999.cs：data[52] == 37 时的分支覆盖
	if d.size() > W.I_ECON_DISPLAY and d[W.I_ECON_DISPLAY] == 37:
		ws.factions[4].support = 700
		ws.factions[4].ideology = 700
		ws.factions[3].support = 200
		ws.factions[3].ideology = 200
		ws.factions[1].support = 50
		ws.factions[1].ideology = 50
		ws.factions[2].support = 50
		ws.factions[2].ideology = 50
		ws.factions[0].support = 0
		ws.factions[0].ideology = 0
	# Event999.cs：data[170] = 0（触发哨兵清零）
	if d.size() > 170:
		d[170] = 0
