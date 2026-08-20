extends "res://数据脚本/event_script_base.gd"

## 原作 Event524.cs：炮打代代木司令部（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "左派的社会实践太多了！"
const TXT_OPT1_DIS := "和修正主义和解？你也想开修了？"
const TXT_R0_A := "我们迅速与日本共产党（左派）、日本劳动党、日本共产党（马列）、日本共产党（行动派）等坚持毛主义思想的革命左翼派别建立了联系。在我们的帮助下，经过短暂的磋商，这些组织最终正式合并成为日本共产党（马列主义革命派）。由于他们中的大多数人都曾是日共党员，因此想要重新对党内成员施加影响力并不困难。而作为修正主义头子的宫本显治本人不久也“意外”死于一次精心安排的车祸事故。\n在宫本身亡后不久召开的日本共产党特别党代会上，革命左翼的代表与日共党内被其说服的党员联合起来，猛烈抨击了宫本显治的右派思想、独断专行、修正主义与破坏中日两国人民友好往来的行为。最终，党代会以小幅优势通过了批准革命左翼回归的提案。在随即召开的临时全会上，福田正义被正式选为新任领导人。\n在革命左翼的推动下，日本共产党停止了进一步的右倾化与修正化，开始全面清算“宫本路线”。诸如“马克思列宁主义”“无产阶级专政”等字眼也重新回归到党的纲领中。当然为了适应日本经济发展下的社会阶层变化，也对一些语句进行了重新调整。无论如何，我们成功帮助日本同志们走上了正确的道路！"
const TXT_R1_A := "经过反复考虑，我们最终决定主动释放和解的信号。随后不久，《朝日新闻》刊登了我们内部对违反不干涉内政原则进行反省（当然，是有限度的）的消息，这对恢复两党间的关系是一个非正式信号。此后在一次中日国民间团体友好沟通的活动上，我们在访问团中秘密混入了自己的代表并私下与日共方面进行接触，表示愿意对过去两党关系进行一定的自我批评，希望重建双方的关系，并且承诺未来将给予日共更多的帮助。最终在经过全会讨论后，日共同意恢复双方的关系。数月后，宫本显治亲率代表团来华正式访问，双方充分交换了意见并发布了联合声明，正式恢复两党关系。有了这个支点，我们便可以方便地为日本共产党提供各种援助了。但党内许多人对此反应冷淡，毕竟我们这次可是与修正主义者握手言和了......"
const TXT_R2_A := "中央经过讨论决定不采取任何行动。既然日共已经与我们彻底决裂，我们又为什么要主动与他们联系？更何况他们到现在还在公开场合继续批评我们！此外，我们目前的力量还难以对革命左翼进行长期的稳定援助，并且这样的举动似乎有点太激进了......\n日本共产党在宫本显治的带领下究竟会走向何方，无人知晓。但唯一可以确定的是，它已经彻底丧失了马列主义的色彩与活力。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.political_line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.political_line > 1 and ws.political_line < 4:
		_enable(opt[1], event_def.options[1].text)
	elif ws.political_line >= 0:
		_disable(opt[1], "和修正主义和解？你也想开修了？")
	else:
		_disable(opt[1], "和一群死不接受民主观念的人合作？")
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(50))
			_add(9, -(50))
			_add(1, 50)
			_add(3, 50)
			_add(6, 5)
			_add_relation(0, -(50))
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(30))
			_add(9, -(30))
			_add(1, -(50))
			_add(3, 50)
			_add(6, -(5))
			_add_relation(0, -(20))
		2:
			context["result_text"] = TXT_R2_A

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data.party_system == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data.ideology <= 2 and data.econ_system < 13 				and data.diplomatic_reputation >= 700 and data.party_system < 8 				and _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
			result = 0
		elif (data.econ_system >= 13 and data.war_support >= 700 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK)) 				or _mod_active(GameConstants.Modifier.PRESIDENT_FOR_LIFE):
			result = 9
		elif data.econ_system <= 13 and data.war_support >= 700 				and data.diplomatic_reputation >= 700 and (_mod_active(GameConstants.Modifier.MAOIST_BULWARK) or _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)):
			result = 10
		elif data.econ_system >= 13 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(GameConstants.Modifier.FOURTH_INTERNATIONAL):
			result = 18
		elif _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and data.party_system <= 7 				and data.econ_system <= 12 and data.religion_policy <= 25:
			result = 17
		elif data.ideology == 1 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and data.religion_policy <= 26:
			result = 16
		elif data.econ_system < 13 and data.press_policy >= 17 				and data.ideology == 1 and data.religion_policy <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(GameConstants.Modifier.RETURN_TO_AGRARIAN_CIVILIZATION):
			result = 8
		elif data.ideology >= 2 and data.econ_system >= 13 				and data.diplomatic_reputation <= 700 and data.party_system >= 8 				and data.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data.ideology <= 3 and data.econ_system >= 12 				and data.econ_system <= 13 and data.diplomatic_reputation >= 300 				and data.territory_policy > 21 and data.war_support >= 700:
			result = 11
		elif data.ideology <= 3 and data.econ_system <= 14 				and data.diplomatic_reputation >= 500 and data.econ_system > 11 				and data.war_support >= 400:
			result = 8
		elif data.ideology <= 3 and data.econ_system <= 13 				and data.press_policy > 17:
			result = 3
		elif data.party_system <= 8 				and (data.econ_system == 13 or data.econ_system == 12) 				and data.war_support < 700 and not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) 				and data.press_policy >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data.econ_system <= 13 and data.diplomatic_reputation >= 500:
		result = 4
	elif (data.party_system <= 8 and data.press_policy <= 18) 			or data.war_support >= 700:
		result = 12
	elif data.econ_system > 13 and data.diplomatic_reputation < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
