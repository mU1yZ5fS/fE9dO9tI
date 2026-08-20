extends "res://数据脚本/event_script_base.gd"

## 原作 Event564.cs：安拉，叙利亚，阿萨德（叙利亚阿萨德，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:764-766 —— (1980.6.1 或 1981+)。
## 差异：load_scene_after_click → EventEngine.enqueue_chain(["event_565"])。

const TXT_OPT1_DIS := "我们对叙利亚内政干涉的太激进了！"
const TXT_R0 := "1980年6月27日，在招待马里总统的正式国宴上，数名伊斯兰主义者试图刺杀参加国宴的阿萨德，但阿萨德最终只受轻伤。作为报复，数百名被关押的伊斯兰主义者被处决。在1982年的哈马大屠杀之后，伊斯兰主义者再起不能，叙利亚也逐渐稳定下去。"
const TXT_R1 := "得益于我们之前的行动，部分叙利亚库尔德组织，伊斯兰主义者，自由主义者与左派被联合起来组成了解放叙利亚全国同盟，在我们特勤的帮助下，1980年6月27日在招待马里总统的正式国宴上，数名被安插进去的反对派分子成功刺杀了阿萨德。阿萨德之死彻底使得叙利亚局势变得更加动乱，解放叙利亚全国同盟借此机会拿着我们支援的武器发动了起义。继任的里法特·阿萨德宣布与中国断交，并寻求苏联的支持来镇压叛乱。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var c35 := world.get_country_by_legacy_index(35)
	if c35 != null and c35.内战中 and d[W.I_POLITICAL_LINE] != 2 and not ws.completed_event_ids.has("event_707"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c35 := ws.get_country_by_legacy_index(35)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if c35 != null:
				c35.set_tag("对华贸易", false)
				c35.government = GameConstants.Government.AUTHORITARIAN
				c35.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, -150)
			EventEngine.enqueue_chain(["event_565"])
			context["result_text"] = TXT_R1
