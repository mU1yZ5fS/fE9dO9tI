class_name WarActionCatalog
extends RefCounted

## 干预行动 0-7，对齐原作 WarButtonScript.this_number。


static func all_actions() -> Array[Dictionary]:
	return [
		{
			"id": 0, "label": "人道援助", "side": 1,
			"budget": 20, "agents": 0, "army": 0, "interv": 10,
			"d_self": 40, "d_other": -40, "diplo": false, "diplo_i": 0,
			"rel_enemy": -5, "rel_friend": 0,
		},
		{
			"id": 1, "label": "派遣专家", "side": 1,
			"budget": 0, "agents": 30, "army": 0, "interv": 10,
			"d_self": 40, "d_other": -40, "diplo": false, "diplo_i": 0,
			"rel_enemy": -5, "rel_friend": 0,
		},
		{
			"id": 2, "label": "输出武器", "side": 1,
			"budget": 0, "agents": 0, "army": 30, "interv": 10,
			"d_self": 40, "d_other": -40, "diplo": false, "diplo_i": 0,
			"rel_enemy": -5, "rel_friend": 0,
		},
		{
			"id": 3, "label": "外交斡旋", "side": 1,
			"budget": 0, "agents": 0, "army": 0, "interv": 0,
			"d_self": 80, "d_other": -80, "diplo": true, "diplo_i": 0,
			"rel_enemy": 0, "rel_friend": 30,
		},
		{
			"id": 4, "label": "派遣专家", "side": 2,
			"budget": 0, "agents": 30, "army": 0, "interv": 10,
			"d_self": 40, "d_other": -40, "diplo": false, "diplo_i": 1,
			"rel_enemy": -5, "rel_friend": 0,
		},
		{
			"id": 5, "label": "人道援助", "side": 2,
			"budget": 20, "agents": 0, "army": 0, "interv": 10,
			"d_self": 40, "d_other": -40, "diplo": false, "diplo_i": 1,
			"rel_enemy": -5, "rel_friend": 0,
		},
		{
			"id": 6, "label": "输出武器", "side": 2,
			"budget": 0, "agents": 0, "army": 30, "interv": 10,
			"d_self": 40, "d_other": -40, "diplo": false, "diplo_i": 1,
			"rel_enemy": -5, "rel_friend": 0,
		},
		{
			"id": 7, "label": "外交斡旋", "side": 2,
			"budget": 0, "agents": 0, "army": 0, "interv": 0,
			"d_self": 80, "d_other": -80, "diplo": true, "diplo_i": 1,
			"rel_enemy": 0, "rel_friend": 30,
		},
	]


static func get_action(action_id: int) -> Dictionary:
	for a in all_actions():
		if int(a["id"]) == action_id:
			return a
	return {}
