extends "res://数据脚本/event_script_base.gd"

## 原作 Event532.cs：大海航行靠舵手（日本共产主义抵抗者同盟合并，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:287-289 ——
##   event_done[524] && resultOfEvents[524]==0 && c44.puppetOf<0
##   && c44.prcpower>=100 && c44.SubGosstroy==6 && (1982.1 或 1983+)。

const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_R0 := "我们迅速与日本共产党和日本共产主义抵抗者同盟展开了磋商。尽管二者对于合并一事有许多疑虑（特别是后者内部此时仍有个别人是托洛茨基主义的支持者），但我们还是耐心地说服了他们。很快，两个组织的中央委员展开了磋商，在我们的影响下，最终通过了一份正式协议：日本共产主义抵抗者同盟正式并入日本共产党，党名也更改为日本革命共产党，整体以毛主义作为指导思想。\n两股强劲左翼力量成功合二为一，这为接下来在全日本掀起进一步的革命斗争打下了重要的基础。但我们也必须抓紧时间，尤其考虑到目前政府已经对新左翼力量有所察觉的情况下，必须尽快集结力量抢在“窗口期”内发动新的起义。"
const TXT_R1 := "我们与日本共产党和日本共产主义抵抗者同盟展开了磋商，但二者对于合并一事有许多疑虑（特别是后者内部此时仍有个别人是托洛茨基主义的支持者）。加之后者的力量和组织架构均欠缺很多，最终磋商不了了之。两股力量继续各自为战，尽管它们仍然试图扩大支持者群体并能够不定期收到援助，但缺少更大力量的它们已经难以为继了......"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	if d.political_line < 2:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], TXT_OPT0_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, 5)
			_add_relation(EmpireData.USA, -50)
			if c44 != null:
				c44.prc_power += 10
			ws.influence_prc += 10
			context["result_text"] = TXT_R0
		1:
			ws.influence_prc -= 10
			context["result_text"] = TXT_R1
