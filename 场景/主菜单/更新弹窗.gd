extends PopupPanel
## 更新弹窗：仅从 GitHub 静态托管拉取版本号与更新内容。
## 不显示任何可能跳转到 GitHub 仓库的按钮。

# 当前游戏本地版本，发布新版本时同步修改。
const LOCAL_VERSION_CODE := 36
const LOCAL_VERSION_TEXT := "0.3.6"

# GitHub Pages 地址（仓库开启 Pages 后生效）。
const UPDATE_URL_PRIMARY := "https://mU1yZ5fS.github.io/fE9dO9tI/update.json"
# raw 地址作为备用，公开仓库不需要先开启 Pages 也能访问。
const UPDATE_URL_FALLBACK := "https://raw.githubusercontent.com/mU1yZ5fS/fE9dO9tI/main/docs/update.json"

@onready var _title: Label = $布局/标题
@onready var _status: Label = $布局/状态
@onready var _announcement: Label = $布局/公告
@onready var _changelog: RichTextLabel = $布局/日志滚动/更新日志
@onready var _close_btn: Button = $布局/按钮行/关闭

var _used_fallback := false

func open_update_popup() -> void:
	_show_loading()
	popup_centered()
	_fetch_update()


func close_popup() -> void:
	hide()


func _show_loading() -> void:
	_used_fallback = false
	_title.text = "更新公告"
	_status.text = "正在检查更新…"
	_announcement.text = ""
	_changelog.text = "正在连接更新服务器…"
func _fetch_update() -> void:
	_used_fallback = false
	_request_json(UPDATE_URL_PRIMARY)


func _request_json(url: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_json_completed.bind(http, url))
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		_on_json_request_failed(url)


func _on_json_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	http: HTTPRequest,
	url: String
) -> void:
	http.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if parsed is Dictionary:
			_apply_update(parsed)
			return
	_on_json_request_failed(url)


func _on_json_request_failed(url: String) -> void:
	if url == UPDATE_URL_PRIMARY and not _used_fallback:
		_used_fallback = true
		_request_json(UPDATE_URL_FALLBACK)
		return
	_status.text = "无法连接更新服务器"
	_changelog.text = "请检查网络后重试，或稍后再试。"


func _apply_update(data: Dictionary) -> void:
	var remote_version := str(data.get("version", "未知"))
	var remote_code := int(data.get("version_code", 0))
	var display_title := str(data.get("title", "游戏更新"))

	_title.text = display_title

	if remote_code > LOCAL_VERSION_CODE:
		_status.text = "发现新版本：v%s（当前 v%s）" % [remote_version, LOCAL_VERSION_TEXT]
	elif remote_code == LOCAL_VERSION_CODE:
		_status.text = "当前已是最新版本：v%s" % remote_version
	else:
		_status.text = "当前版本：v%s" % remote_version

	var announcement := str(data.get("announcement", ""))
	_announcement.text = announcement

	var lines := ""
	for item in data.get("changelog", []):
		lines += "• " + str(item) + "\n"
	if lines.is_empty():
		lines = "暂无更新内容。"
	_changelog.text = lines
