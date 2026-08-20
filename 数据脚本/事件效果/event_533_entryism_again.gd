extends "res://数据脚本/event_script_base.gd"

## 原作 Event533.cs：打入主义的再实践？（日本托派打入日共，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:292-294 ——
##   event_done[523] && resultOfEvents[523]==0 && !modifies[3].active
##   && c44.puppetOf<0 && c44.SubGosstroy==6 && (1982.6 或 1983+)。

const TXT_OPT0_DIS_TROT := "我们为什么要效仿托派？"
const TXT_OPT0_DIS_POWER := "赤军力量不够强大！"
const TXT_OPT0_DIS_OTHER := "支持恐怖分子？"
const TXT_R0 := "我们很快为共产主义抵抗者同盟的成员梳理了一份日本共产党在各地的基层组织的名单。他们也迅速行动起来前往各地并加入那里的共产党基层组织。不久许多人便因其积极表现而得到提拔，同盟也由此迈出了打入的第一步，但我们仍需注意为他们提供更多的支持，不然前面的努力随时都可能付诸东流。"
const TXT_R1 := "考虑到目前同盟的人手依旧不足，我们决定暂时按兵不动。但很快，同盟内部各个小组织成员间因为路线问题又一次爆发了矛盾。虽然我们尽力调节，但最终一大批人仍然脱离了同盟。这严重打击了我们的影响力和同盟本身的稳定性。最终同盟的中央委员会组织召开了最后一次大会。会上以大比例优势通过了共产主义抵抗者同盟解散的决议。我们的努力最终还是失败了......"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var c44 := world.get_country_by_legacy_index(44)
	if d[W.I_POLITICAL_LINE] == 0 and c44 != null and c44.prc_power >= 120 and not ws.modifiers[3].is_active:
		_enable(opt[0], event_def.options[0].text)
	elif ws.modifiers[3].is_active:
		_disable(opt[0], TXT_OPT0_DIS_TROT)
	elif c44 == null or c44.prc_power < 120:
		_disable(opt[0], TXT_OPT0_DIS_POWER)
	else:
		_disable(opt[0], TXT_OPT0_DIS_OTHER)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 30
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
