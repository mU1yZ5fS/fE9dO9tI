extends "res://数据脚本/event_script_base.gd"

## 原作 Event15.cs：柬越战争。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10134（!vietnampeace && !event_done[15] && 日期>=1978.12.25）。
##    vietnampeace 端口无对应 → 视为 false（默认未和平，行为一致）；fire_only_once=true 表达 !event_done[15]。
##  - party_change[2]=1f（派系支持缓冲）：端口无等价 → 跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_start_war1()
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_opt_stand_by(context)
	elif opt == 1:
		_opt_support(context)


# 所有选项共用：启动战争 1（Event15.cs ResultsOfEvents 开头无条件部分）
func _start_war1() -> void:
	if ws.wars.size() <= 1:
		return
	var war := ws.wars[1]
	war.name_war = "柬埔寨－越南战争"
	war.is_going = true
	war.side1 = "柬埔寨"
	war.side2 = "越南"
	war.ussr_side = 1


# 选项0：我们无能为力（Event15.cs result 0）
func _opt_stand_by(context: Dictionary) -> void:
	ws.influence_prc -= 10
	if ws.wars.size() > 1:
		ws.wars[1].infl1 = 300
		ws.wars[1].infl2 = 700
	var cambodia := ws.get_country_by_legacy_index(23)
	var stab1: bool = cambodia != null and cambodia.stab == 1
	if not stab1:
		context["result_text"] = "我们决定不介入这场冲突。波尔布特和红色高棉领导人当然对此非常不满，但他们似乎也活不了多久了——越南军队行动迅速，柬埔寨士兵开始集体叛逃。波尔布特政权的垮台似乎只是个时间问题。"
	else:
		context["result_text"] = "我们决定不介入这场冲突。民主柬埔寨领导人当然对此非常不满，但他们似乎也坚持不了多久——柬埔寨的经济仍未从战后恢复过来，也并没有太多的资源和产业能用于抵抗越南的侵略。"


# 选项1：支持民主柬埔寨（Event15.cs result 1）
func _opt_support(context: Dictionary) -> void:
	if d.size() > W.I_AGENTS:
		d[W.I_AGENTS] -= 30
	if ws.wars.size() > 1:
		ws.wars[1].infl1 = 450
		ws.wars[1].infl2 = 550
	context["result_text"] = "我们决定对我们的老朋友民主柬埔寨提供支持。双方之间的战争仍在进行，越南和苏联对我们的行动并不满意，他们很可能会加强合作并损害我们的利益。"
