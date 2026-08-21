extends RefCounted

## Event710 复杂触发钩子（EventDef.trigger_script 调用 evaluate(world) -> bool）。
## 对齐 TimeScript.cs:10580-10586：
##   c14.SubGosstroy==19 && c14.parts[7] && c14.puppetOf<0 && data.iraq_revolution_timer<=0
##   && !event_done[710]（fire_only_once 承担）&& event_done[709]
## event_done[709] 以端口 event_id "event_709" 判定（项目约定 event_NNN）。


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var iraq := world.get_country_by_legacy_index(14)
	if iraq == null or iraq.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST or iraq.puppet_of >= 0:
		return false
	if iraq.parts.size() <= 7 or not iraq.parts[7]:
		return false
	if world.size() <= 186 or world.iraq_revolution_timer > 0:
		return false
	if not world.completed_event_ids.has("event_709"):
		return false
	return true
