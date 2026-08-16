extends "res://数据脚本/event_script_base.gd"

## 原作 Event648.cs：代号太白（金星探测，三选项）。
## 触发：ReqEventsDLC02.cs:102-104 —— y>=1983 && ((r361!=2 && ev361) || r362==1) && science[16]
##   复合条件 → trigger_script evaluate。
## 差异：原版选项1置 resultOfEvents[648]=2 → Godot context["result_index_override"]=2。

const TXT_TITLE := "代号太白"
const TXT_DESC := "在我们征服了一颗星球之后，主席同志，是时候望向连强大的苏联都屡次碰壁的金星了。在二十世纪六十年代以来，苏联启动了知名的“金星计划”。但直到金星四号才第一次接触到金星大气层，数分钟后便被恐怖的高温和大气压所粉碎。金星七号成为了第一个在金星表面硬着陆的人造物体，在被大气压摧毁殆尽之前还和地球完成了23分钟的通信传输。在航天史上留下浓墨重彩一笔的金星13号探测器则是苏联在本世纪八十年代初向金星派遣的英勇使者。1981年10月30日，这个重达4363千克的行星际自动站踏上了前往金星的漫长旅程，并在1982年3月1日成功实现了在金星恶劣环境下的软着陆壮举。主席同志，也许是时候让我们也去探索这颗“炼狱般”的星球了。现在我们有两个方案，一个是类似苏联人的版本，在苏联人的数据的基础上，我们将发射一颗软着陆的探测器。在完成录像，录音和采集工作后返回地球。或者我们可以尝试发射一颗探测卫星，它将为我们在未来的金星任务提供莫大的帮助。"
const TXT_OPT0 := "借鉴苏联经验，发射一个探测器"
const TXT_OPT0_DIS := "他们不会让我们抄作业的！"
const TXT_OPT1 := "发射一颗卫星"
const TXT_OPT2 := "我们去不起那种鬼地方"
const TXT_R0 := "我们的航天局根据相关要求，设计了一台革命性的新探测器，我们将其命名为“长庚一号”。\n“长庚一号”探测器搭载了一台创新性的科学设备——能够在极端条件下工作的钻头及样品回收系统。着陆器配备的钻头能够穿透金星表面厚重的矿物层，采集珍贵的土壤样本，并通过精密的机械结构将样品送入一个特殊的低温内腔。在这个内腔中，利用液氮冷却技术，科学家们巧妙地将内腔保持在相对温和的0.05个大气压和30摄氏度，从而创造了一个适合光谱仪工作的微环境。这在当时是航空史上第二次在地外行星上应用光谱仪对采集的实物样品进行原位分析的重大实践。（同时，苏联科学院发动了一场揪出学术间谍的运动）\n尽管面对着金星表面难以想象的严酷条件——高达464摄氏度的高温和超过89个地球大气压的压力，“长庚一号”着陆器的设计寿命仅为短短15分钟，但它却顽强地工作了长达84分钟，这大大超出了预期。其着陆器外壳采用了耐高温高压的钛金属材质，并通过液氮制冷技术有效保护了内部组件，尤其是那个至关重要的内腔和光谱仪，确保它们能在极端环境下稳定运行。\n最终，我们也有了自己的一份录音，一小捧金星土壤和照片。瞧！照片里面还有金星十三和十四号的残骸哩！"
const TXT_R1 := "在我国西北部的酒泉航天中心，我们的科学家将一个以知名旅行家杜环命名的探测器送上了太空。\n“杜环”号探测卫星上采用了先进的合成孔径雷达，主要作用是成像，但也进行辐射测量等，其特点是精度高，可以360米以上的分辨率测绘金星，这样高的精度是以往探测金星的航天器所没有的。其扫描宽度25公里，高频增益无线直径为3.7米，该天线的作用是或供合成孔径雷达使用；或用于向地球发送数据。雷达系统重163公斤（无线除外）。该雷达系统由休斯飞机公司制造。此外，探测器上还装有一台测高仪，也使用高分辨率测量金星。此外，探测器上还携带有备用系统，万一出了差错，其备用的合成孔径雷达，低频增益天线以及计算机软件将重新调整并核查探测器系统，为了保证探测器安全可靠，其上还安装了两种星载错误保护系统装置，一种用于针对姿态控制，一种用于针对除姿控外的各种错误。姿控监测系统进行的全系统“健康”检查能查出造成反常现象的原因，并能确定补救方法。其它故障则由“杜环”号中搭载的指令与数据系统中的计算机软件作个别处理。\n由于我们缺少在地球和金星间的长期通讯卫星，必须有专人时时刻刻监控着这颗卫星。就让我们祝他好运吧！"
const TXT_R1_FAIL := "\n最终，我们渴望一步登天的计划遭到了辩证法无情的拷打。所有的金星探测器均未能成功突破地球轨道，更别提什么被金星轨道捕获了。这一劳民伤财的计划最终被叫停。"
const TXT_R2 := "地球上多好啊，我最怕去金星，一提到去金星我就发怵。有五百度高温，92倍的大气压，听说还有硫酸大气层。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var ussr_rel := ws.empires[EmpireData.USSR].relations if ws.empires.size() > EmpireData.USSR \
		and ws.empires[EmpireData.USSR] != null else 0
	var opt := event_def.options
	if ussr_rel >= 500:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_AGENTS, -100)
			_add(W.I_INDUSTRY, -300)
			_add(W.I_BUDGET, -160)
		1:
			var text := TXT_R1
			if _res(W.I_INDUSTRY) < 1200:
				text += TXT_R1_FAIL
				_add(W.I_BUDGET, -100)
				_add(W.I_PEOPLE_SUPPORT, -300)
				_add(W.I_PARTY_SUPPORT, -200)
			context["result_text"] = text
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_AGENTS, -100)
			_add(W.I_INDUSTRY, -200)
			_add(W.I_BUDGET, -80)
			# 原版 :61 resultOfEvents[648]=2
			context["result_index_override"] = 2
		2:
			context["result_text"] = TXT_R2


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.year < 1983:
		return false
	if not _tech_on(world, 16):
		return false
	var r361 := int(world.completed_event_ids.get("event_361", 0))
	var r362 := int(world.completed_event_ids.get("event_362", 0))
	return (world.completed_event_ids.has("event_361") and r361 != 2) or r362 == 1


func _tech_on(world: WorldState, idx: int) -> bool:
	return world.techs != null and idx >= 0 and idx < world.techs.unlocked.size() and world.techs.unlocked[idx]
