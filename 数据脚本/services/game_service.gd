## GameService — 事件脚本/UI 对 GameManager 的窄接口门面。
## 目标：事件脚本不再直接依赖全局 autoload，而是通过 context 注入的 game 服务调用。
## 后续 GameManager 内部拆分时，这个门面可以改为转发到具体 Service。
class_name GameService
extends RefCounted

var gm: Node = null


func _init(game_manager: Node = null) -> void:
	gm = game_manager


func is_available() -> bool:
	return gm != null


func start_war(
		war_id: int,
		side1: String = "",
		side2: String = "",
		infl1: int = -1,
		infl2: int = -1,
		usa_side: int = -1,
		ussr_side: int = -1
) -> bool:
	if gm == null:
		return false
	return gm.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)


func is_faction_leading(faction_index: int) -> bool:
	if gm == null:
		return false
	return gm.is_faction_leading(faction_index)


func kill_politician(pol_index: int, preferred_name: String = "") -> void:
	if gm == null:
		return
	gm.kill_politician(pol_index, preferred_name)


func queue_ending_after_event(ending_id: int) -> void:
	if gm == null:
		return
	gm.queue_ending_after_event(ending_id)


func set_map_region_owner(region_ids: Array, to_gwcode: int) -> void:
	if gm == null:
		return
	gm.set_map_region_owner(region_ids, to_gwcode)


func start_event(event_id: String) -> void:
	if gm == null:
		return
	gm.start_event(event_id)


func resolve_war_finished(war_id: int) -> void:
	if gm == null:
		return
	if gm.has_method("resolve_war_finished"):
		gm.resolve_war_finished(war_id)
