extends "res://数据脚本/event_script_base.gd"

## 原作 Event693.cs：押运花石纲（瑞士存钱，手动事件，二选项）。
## 触发：DiploButtonScript.cs:9428（this_type==49, selected_country==39）
##   → 外交互动_批2.gd 的 _def_104? 分支，已改为 start_event_num(w, 693)。
## 差异：ServeRMB→ws.serve_rmb、LeaderAsset→ws.leader_asset、proprc→亲中。

const TXT_OPT1_DIS := "为人民服务，不是为人民币服务！"
const TXT_R0 := "瑞银集团人士已根据您的需求，将一切都办得妥当。我党预算由此得到相当补充，并足以通过更加频繁地开展文化宣传，团队建设与扩展党员福利制等方式拉拢广大党员的心。最终巩固了您与党中央的威信。"
const TXT_R1 := "瑞银集团人士已根据您的需求，将一切都办得妥当。不久后，您的特殊业务便基本通过审批，在分流了一部分党款后混入了灰色世界中。虽说人们无法追踪这笔资金的去向，但他们只需要知道巨款失踪这点便已足够。党内高层已开始对您去巴塞尔度假与“公款吃喝”的系列行为窃窃私语，并试着在此方面上行下效。某种意义上来说挺好的。毕竟，他们也只是各扫门前雪，学习您的经验办“私事”而已。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if not mod3 or not mod6:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var swiss := ws.get_country_by_legacy_index(39)
	var proprc := swiss != null and swiss.has_tag("亲中")
	if opt == 0:
		context["result_text"] = TXT_R0
		_add(W.I_CORRUPTION, 10)
		if not proprc:
			_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_BUDGET, -100)
		else:
			_add(W.I_PARTY_SUPPORT, 400)
			_add(W.I_BUDGET, -50)
		return
	if opt == 1:
		context["result_text"] = TXT_R1
		_add(W.I_CORRUPTION, 20)
		ws.leader_asset += 20
		ws.serve_rmb = true
		if not proprc:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_BUDGET, -100)
		else:
			_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_BUDGET, -50)
